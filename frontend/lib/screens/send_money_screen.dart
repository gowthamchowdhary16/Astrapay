import 'dart:async';
import 'security_verification_screen.dart';

import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';

class SendMoneyScreen extends StatefulWidget {
  final double balance;
  final double dailyLimit;
  final double spentToday;
  final String ownUpiId;

  const SendMoneyScreen({
    super.key,
    required this.balance,
    this.dailyLimit = 2000,
    this.spentToday = 650,
    required this.ownUpiId,
  });

  @override
  State<SendMoneyScreen> createState() =>
      _SendMoneyScreenState();
}

class _SendMoneyScreenState
    extends State<SendMoneyScreen> {
  int selectedMethod = 0;

  final TextEditingController recipientController =
      TextEditingController();

  final TextEditingController amountController =
      TextEditingController();

  String? recipientName;

  bool showReview = false;
  bool processing = false;

  final List<String> methods = [
    'UPI ID',
    'Mobile',
    'Bank Account',
  ];

  final List<double> quickAmounts = [
    100,
    250,
    500,
    1000,
  ];

  @override
  void dispose() {
    recipientController.dispose();
    amountController.dispose();
    super.dispose();
  }

  // ==========================================================
  // GET PLACEHOLDER
  // ==========================================================

  String get recipientHint {
    switch (selectedMethod) {
      case 1:
        return 'Enter 10-digit mobile number';

      case 2:
        return 'Enter bank account number';

      default:
        return 'example@upi';
    }
  }

  String get recipientLabel {
    switch (selectedMethod) {
      case 1:
        return 'Mobile Number';

      case 2:
        return 'Bank Account Number';

      default:
        return 'UPI ID';
    }
  }

  // ==========================================================
  // VALIDATE RECIPIENT
  // ==========================================================

  bool validateRecipient() {
    final value =
        recipientController.text.trim();

    if (selectedMethod == 0) {
      if (value.length < 5 ||
          !value.contains('@')) {
        _showMessage(
          'Enter a valid UPI ID.',
        );
        return false;
      }

      if (value.toLowerCase() ==
          widget.ownUpiId.toLowerCase()) {
        _showMessage(
          'You cannot send money to your own UPI ID.',
        );
        return false;
      }
    }

    if (selectedMethod == 1) {
      if (!RegExp(r'^[0-9]{10}$')
          .hasMatch(value)) {
        _showMessage(
          'Enter a valid 10-digit mobile number.',
        );
        return false;
      }
    }

    if (selectedMethod == 2) {
      if (!RegExp(r'^[0-9]{9,18}$')
          .hasMatch(value)) {
        _showMessage(
          'Enter a valid bank account number.',
        );
        return false;
      }
    }

    return true;
  }

  // ==========================================================
  // VALIDATE AMOUNT
  // ==========================================================

  double? validateAmount() {
    final amount =
        double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showMessage(
        'Enter a valid amount.',
      );
      return null;
    }

    if (amount > widget.balance) {
      _showMessage(
        'Insufficient wallet balance.',
      );
      return null;
    }

    final remainingLimit =
        widget.dailyLimit -
            widget.spentToday;

    if (amount > remainingLimit) {
      _showMessage(
        'This payment exceeds your remaining daily limit of ₹${remainingLimit.toStringAsFixed(0)}.',
      );
      return null;
    }

    return amount;
  }

  // ==========================================================
  // CONTINUE
  // ==========================================================

  void continueToReview() {
    if (!validateRecipient()) {
      return;
    }

    final amount = validateAmount();

    if (amount == null) {
      return;
    }

    setState(() {
      recipientName =
          _displayRecipient();
      showReview = true;
    });
  }

  String _displayRecipient() {
    final value =
        recipientController.text.trim();

    if (selectedMethod == 0) {
      return value;
    }

    if (selectedMethod == 1) {
      return 'Mobile •••• ${value.substring(value.length - 4)}';
    }

    return 'Bank •••• ${value.substring(value.length - 4)}';
  }

  // ==========================================================
  // PROCESS PAYMENT
  // ==========================================================

 Future<void> confirmPayment() async {
  final amount = validateAmount();

  if (amount == null) {
    return;
  }

  final verified = await Navigator.push<bool>(
    context,
    MaterialPageRoute(
      builder: (_) =>
          SecurityVerificationScreen(
        amount: amount,
        currentBalance:
            widget.balance,
        dailyLimit:
            widget.dailyLimit,
        spentToday:
            widget.spentToday,
        recipient:
            recipientName ?? '',
        paymentMethod:
            methods[selectedMethod],
      ),
    ),
  );

  if (!mounted || verified != true) {
    return;
  }

  setState(() {
    processing = true;
  });

  // Demo payment processing.
  await Future.delayed(
    const Duration(seconds: 2),
  );

  if (!mounted) return;

  setState(() {
    processing = false;
  });

  final newBalance =
      widget.balance - amount;

  final newSpentToday =
      widget.spentToday + amount;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) =>
          SendMoneySuccessScreen(
        amount: amount,
        newBalance: newBalance,
        newSpentToday:
            newSpentToday,
        recipient:
            recipientName ?? '',
      ),
    ),
  );
}
  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    if (showReview) {
      return _reviewScreen();
    }

    return _recipientScreen();
  }

  // ==========================================================
  // RECIPIENT SCREEN
  // ==========================================================

  Widget _recipientScreen() {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor:
            AstraTheme.textBlue,

        title: const Text(
          'Send Money',
          style: TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            8,
            22,
            30,
          ),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [
              const AstraBrand(
                logoSize: 42,
                textSize: 23,
              ),

              const SizedBox(height: 24),

              const Text(
                'Send Money',
                style: TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 27,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Send money using UPI, mobile number or bank account.',
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // BALANCE
              // ==================================================

              _balanceCard(),

              const SizedBox(height: 25),

              // ==================================================
              // PAYMENT METHOD
              // ==================================================

              const Text(
                'Send To',
                style: TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Row(
                children: List.generate(
                  methods.length,
                  (index) {
                    return Expanded(
                      child: Padding(
                        padding:
                            EdgeInsets.only(
                          right: index ==
                                  methods.length - 1
                              ? 0
                              : 7,
                        ),
                        child:
                            _methodButton(
                          index,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 22),

              // ==================================================
              // RECIPIENT
              // ==================================================

              Text(
                recipientLabel,
                style:
                    const TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller:
                    recipientController,

                keyboardType:
                    selectedMethod == 0
                        ? TextInputType
                            .emailAddress
                        : TextInputType
                            .number,

                decoration:
                    InputDecoration(
                  hintText:
                      recipientHint,

                  prefixIcon: Icon(
                    selectedMethod == 0
                        ? Icons
                            .alternate_email_rounded
                        : selectedMethod ==
                                1
                            ? Icons
                                .phone_outlined
                            : Icons
                                .account_balance_outlined,
                    color:
                        AstraTheme.primaryBlue,
                  ),

                  filled: true,

                  fillColor:
                      const Color(
                    0xFFF6F9FF,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          AstraTheme.borderBlue,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          AstraTheme.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // ==================================================
              // AMOUNT
              // ==================================================

              const Text(
                'Amount',
                style: TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 9),

              TextField(
                controller:
                    amountController,

                keyboardType:
                    const TextInputType
                        .numberWithOptions(
                  decimal: true,
                ),

                decoration:
                    InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle:
                      const TextStyle(
                    color:
                        AstraTheme.primaryBlue,
                    fontSize: 21,
                    fontWeight:
                        FontWeight.w800,
                  ),

                  hintText: '0',

                  filled: true,

                  fillColor:
                      const Color(
                    0xFFF6F9FF,
                  ),

                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          AstraTheme.borderBlue,
                    ),
                  ),

                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                    borderSide:
                        const BorderSide(
                      color:
                          AstraTheme.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // ==================================================
              // QUICK AMOUNTS
              // ==================================================

              Wrap(
                spacing: 8,
                runSpacing: 8,

                children:
                    quickAmounts.map(
                  (amount) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          amountController
                                  .text =
                              amount
                                  .toStringAsFixed(
                            0,
                          );
                        });
                      },

                      child: Container(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 9,
                        ),

                        decoration:
                            BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            12,
                          ),
                          border:
                              Border.all(
                            color:
                                AstraTheme
                                    .borderBlue,
                          ),
                        ),

                        child: Text(
                          '₹${amount.toStringAsFixed(0)}',
                          style:
                              const TextStyle(
                            color:
                                AstraTheme
                                    .textBlue,
                            fontSize: 11,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),

              const SizedBox(height: 28),

              // ==================================================
              // LIMIT INFO
              // ==================================================

              Container(
                padding:
                    const EdgeInsets.all(15),

                decoration:
                    BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),
                  border:
                      Border.all(
                    color:
                        AstraTheme.borderBlue,
                  ),
                ),

                child: Row(
                  children: [
                    const Icon(
                      Icons
                          .shield_outlined,
                      color:
                          AstraTheme.primaryBlue,
                      size: 21,
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Text(
                        '₹${(widget.dailyLimit - widget.spentToday).clamp(0, widget.dailyLimit).toStringAsFixed(0)} remaining from today’s spending limit.',
                        style:
                            const TextStyle(
                          color:
                              AstraTheme
                                  .secondaryText,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 25),

              // ==================================================
              // CONTINUE
              // ==================================================

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                    ElevatedButton(
                  onPressed:
                      continueToReview,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AstraTheme
                            .primaryBlue,
                    foregroundColor:
                        Colors.white,
                    elevation: 2,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),

                  child:
                      const Row(
                    mainAxisAlignment:
                        MainAxisAlignment
                            .center,

                    children: [
                      Text(
                        'Continue',
                        style:
                            TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons
                            .arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Center(
                child: Text(
                  'Demo payment flow • No real money is moved',
                  style: TextStyle(
                    color:
                        AstraTheme
                            .secondaryText,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // BALANCE CARD
  // ==========================================================

  Widget _balanceCard() {
    return Container(
      width: double.infinity,

      padding:
          const EdgeInsets.all(17),

      decoration:
          BoxDecoration(
        color:
            AstraTheme.lightBlue,
        borderRadius:
            BorderRadius.circular(18),
        border:
            Border.all(
          color:
              AstraTheme.borderBlue,
        ),
      ),

      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,

            decoration:
                const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons
                  .account_balance_wallet_outlined,
              color:
                  AstraTheme.primaryBlue,
            ),
          ),

          const SizedBox(width: 12),

          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              const Text(
                'Available Balance',
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 3),

              Text(
                '₹${widget.balance.toStringAsFixed(2)}',
                style:
                    const TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // METHOD BUTTON
  // ==========================================================

  Widget _methodButton(
    int index,
  ) {
    final selected =
        selectedMethod == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedMethod = index;
          recipientController.clear();
        });
      },

      child: Container(
        height: 74,

        decoration:
            BoxDecoration(
          color: selected
              ? AstraTheme.lightBlue
              : Colors.white,

          borderRadius:
              BorderRadius.circular(15),

          border: Border.all(
            color: selected
                ? AstraTheme.primaryBlue
                : AstraTheme.borderBlue,

            width: selected ? 1.5 : 1,
          ),
        ),

        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [
            Icon(
              index == 0
                  ? Icons
                      .alternate_email_rounded
                  : index == 1
                      ? Icons
                          .phone_outlined
                      : Icons
                          .account_balance_outlined,

              color:
                  selected
                      ? AstraTheme.primaryBlue
                      : AstraTheme.secondaryText,

              size: 22,
            ),

            const SizedBox(height: 5),

            Text(
              methods[index],
              style: TextStyle(
                color: selected
                    ? AstraTheme.primaryBlue
                    : AstraTheme.textBlue,
                fontSize: 10,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // REVIEW SCREEN
  // ==========================================================

  Widget _reviewScreen() {
    final amount =
        double.tryParse(
              amountController.text,
            ) ??
            0;

    final remainingAfter =
        widget.dailyLimit -
        widget.spentToday -
        amount;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor:
            AstraTheme.textBlue,

        leading: IconButton(
          onPressed: () {
            setState(() {
              showReview = false;
            });
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),

        title: const Text(
          'Review Payment',
          style: TextStyle(
            fontSize: 19,
            fontWeight:
                FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            22,
            10,
            22,
            25,
          ),

          child: Column(
            children: [
              const AstraBrand(
                logoSize: 42,
                textSize: 23,
              ),

              const SizedBox(height: 30),

              Container(
                width: 90,
                height: 90,

                decoration:
                    const BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  shape:
                      BoxShape.circle,
                ),

                child: const Icon(
                  Icons.send_rounded,
                  color:
                      AstraTheme.primaryBlue,
                  size: 42,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Confirm Payment',
                style: TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'Review the details before sending.',
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 25),

              // Amount
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(20),

                decoration:
                    BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  border:
                      Border.all(
                    color:
                        AstraTheme.borderBlue,
                  ),
                ),

                child: Column(
                  children: [
                    const Text(
                      'You are sending',
                      style:
                          TextStyle(
                        color:
                            AstraTheme
                                .secondaryText,
                        fontSize: 12,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style:
                          const TextStyle(
                        color:
                            AstraTheme
                                .primaryBlue,
                        fontSize: 32,
                        fontWeight:
                            FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _detailRow(
                'Recipient',
                recipientName ?? '',
              ),

              _detailRow(
                'Payment method',
                methods[selectedMethod],
              ),

              _detailRow(
                'Wallet balance after',
                '₹${(widget.balance - amount).toStringAsFixed(2)}',
              ),

              _detailRow(
                'Daily limit remaining',
                '₹${remainingAfter.clamp(0, widget.dailyLimit).toStringAsFixed(0)}',
              ),

              const Spacer(),

              // Parent notification info
              if (amount > 1000)
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.all(
                    13,
                  ),
                  margin:
                      const EdgeInsets.only(
                    bottom: 12,
                  ),
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFFFF7E6,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      14,
                    ),
                    border:
                        Border.all(
                      color:
                          const Color(
                        0xFFFFD98A,
                      ),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons
                            .notifications_none_rounded,
                        color:
                            Color(0xFFD88A00),
                        size: 20,
                      ),
                      SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'Your parent will receive a notification for this transaction.',
                          style:
                              TextStyle(
                            color:
                                Color(
                              0xFF8A6200,
                            ),
                            fontSize: 11,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                    ElevatedButton(
                  onPressed:
                      processing
                          ? null
                          : confirmPayment,

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AstraTheme
                            .primaryBlue,
                    foregroundColor:
                        Colors.white,
                    disabledBackgroundColor:
                        AstraTheme
                            .borderBlue,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),

                  child: processing
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color:
                                Colors.white,
                          ),
                        )
                      : const Text(
                          'Confirm & Send',
                          style:
                              TextStyle(
                            fontSize: 15,
                            fontWeight:
                                FontWeight.w800,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(
    String label,
    String value,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        vertical: 13,
      ),

      decoration:
          const BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color:
                Color(0xFFE8EFF8),
          ),
        ),
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [
          Text(
            label,
            style:
                const TextStyle(
              color:
                  AstraTheme.secondaryText,
              fontSize: 12,
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.end,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color:
                    AstraTheme.textBlue,
                fontSize: 12,
                fontWeight:
                    FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showMessage(
    String message,
  ) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}

// =================================================================
// SEND MONEY SUCCESS
// =================================================================

class SendMoneySuccessScreen
    extends StatelessWidget {
  final double amount;
  final double newBalance;
  final double newSpentToday;
  final String recipient;

  const SendMoneySuccessScreen({
    super.key,
    required this.amount,
    required this.newBalance,
    required this.newSpentToday,
    required this.recipient,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.fromLTRB(
            24,
            30,
            24,
            25,
          ),

          child: Column(
            children: [
              const AstraBrand(
                logoSize: 48,
                textSize: 25,
              ),

              const Spacer(),

              Container(
                width: 100,
                height: 100,

                decoration:
                    const BoxDecoration(
                  color:
                      Color(0xFFE4F9F0),
                  shape:
                      BoxShape.circle,
                ),

                child: const Icon(
                  Icons.check_rounded,
                  color:
                      Color(0xFF00A875),
                  size: 58,
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Payment Successful!',
                textAlign:
                    TextAlign.center,
                style:
                    TextStyle(
                  color:
                      AstraTheme.textBlue,
                  fontSize: 24,
                  fontWeight:
                      FontWeight.w800,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                '₹${amount.toStringAsFixed(2)} sent successfully.',
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 25),

              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(
                  20,
                ),

                decoration:
                    BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  borderRadius:
                      BorderRadius.circular(
                    20,
                  ),
                  border:
                      Border.all(
                    color:
                        AstraTheme.borderBlue,
                  ),
                ),

                child: Column(
                  children: [
                    _successRow(
                      'Recipient',
                      recipient,
                    ),

                    _successRow(
                      'Amount',
                      '₹${amount.toStringAsFixed(2)}',
                    ),

                    _successRow(
                      'Wallet Balance',
                      '₹${newBalance.toStringAsFixed(2)}',
                    ),

                    _successRow(
                      'Today\'s Spending',
                      '₹${newSpentToday.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                height: 55,

                child:
                    ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AstraTheme
                            .primaryBlue,
                    foregroundColor:
                        Colors.white,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                        16,
                      ),
                    ),
                  ),

                  child:
                      const Text(
                    'Back to Wallet',
                    style:
                        TextStyle(
                      fontSize: 15,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _successRow(
    String label,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 8,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [
          Text(
            label,
            style:
                const TextStyle(
              color:
                  AstraTheme.secondaryText,
              fontSize: 11,
            ),
          ),

          Flexible(
            child: Text(
              value,
              textAlign:
                  TextAlign.end,
              overflow:
                  TextOverflow.ellipsis,
              style:
                  const TextStyle(
                color:
                    AstraTheme.textBlue,
                fontSize: 12,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}