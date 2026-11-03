import 'package:flutter/material.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';
import 'payment_processing_screen.dart';

class AddMoneyScreen extends StatefulWidget {
  final double currentBalance;

  const AddMoneyScreen({
    super.key,
    required this.currentBalance,
  });

  @override
  State<AddMoneyScreen> createState() =>
      _AddMoneyScreenState();
}

class _AddMoneyScreenState
    extends State<AddMoneyScreen> {
  final TextEditingController amountController =
      TextEditingController();

  double? selectedAmount;

  final List<double> quickAmounts = [
    100,
    250,
    500,
    1000,
    2000,
  ];

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  void selectAmount(double amount) {
    setState(() {
      selectedAmount = amount;
      amountController.text =
          amount.toStringAsFixed(0);
    });
  }

  void continuePayment() {
    final amount =
        double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      _showMessage(
        'Enter a valid amount.',
      );
      return;
    }

    if (amount > 50000) {
      _showMessage(
        'Maximum demo amount is ₹50,000.',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            PaymentProcessingScreen(
          amount: amount,
          currentBalance:
              widget.currentBalance,
        ),
      ),
    ).then((newBalance) {
      if (!mounted) return;

      if (newBalance != null) {
        Navigator.pop(
          context,
          newBalance,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor:
            AstraTheme.textBlue,
        title: const Text(
          'Add Money',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            22,
            10,
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

              const SizedBox(height: 25),

              const Text(
                'Add Money to Wallet',
                style: TextStyle(
                  color: AstraTheme.textBlue,
                  fontSize: 27,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Add money securely to your AstraPay wallet.',
                style: TextStyle(
                  color:
                      AstraTheme.secondaryText,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 25),

              // Balance
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color:
                      AstraTheme.lightBlue,
                  borderRadius:
                      BorderRadius.circular(18),
                  border: Border.all(
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
                    const SizedBox(width: 13),
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Current Balance',
                          style: TextStyle(
                            color:
                                AstraTheme.secondaryText,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '₹${widget.currentBalance.toStringAsFixed(2)}',
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
              ),

              const SizedBox(height: 25),

              const Text(
                'Enter Amount',
                style: TextStyle(
                  color: AstraTheme.textBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) {
                  setState(() {
                    selectedAmount = null;
                  });
                },
                decoration:
                    InputDecoration(
                  prefixText: '₹ ',
                  prefixStyle:
                      const TextStyle(
                    color:
                        AstraTheme.primaryBlue,
                    fontSize: 22,
                    fontWeight:
                        FontWeight.w800,
                  ),
                  hintText: '0',
                  hintStyle:
                      const TextStyle(
                    color:
                        AstraTheme.secondaryText,
                  ),
                  filled: true,
                  fillColor:
                      const Color(0xFFF6F9FF),
                  enabledBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(
                      color:
                          AstraTheme.borderBlue,
                    ),
                  ),
                  focusedBorder:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                    borderSide:
                        const BorderSide(
                      color:
                          AstraTheme.primaryBlue,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Quick Amount',
                style: TextStyle(
                  color: AstraTheme.textBlue,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 9,
                runSpacing: 9,
                children:
                    quickAmounts.map((amount) {
                  final selected =
                      selectedAmount == amount;

                  return GestureDetector(
                    onTap: () =>
                        selectAmount(amount),
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(
                        horizontal: 17,
                        vertical: 11,
                      ),
                      decoration:
                          BoxDecoration(
                        color: selected
                            ? AstraTheme.primaryBlue
                            : Colors.white,
                        borderRadius:
                            BorderRadius.circular(13),
                        border: Border.all(
                          color: selected
                              ? AstraTheme.primaryBlue
                              : AstraTheme.borderBlue,
                        ),
                      ),
                      child: Text(
                        '₹${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : AstraTheme.textBlue,
                          fontWeight:
                              FontWeight.w700,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 30),

              // Payment method
              const Text(
                'Payment Method',
                style: TextStyle(
                  color: AstraTheme.textBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),

              const SizedBox(height: 12),

              Container(
                padding:
                    const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(17),
                  border: Border.all(
                    color:
                        AstraTheme.primaryBlue,
                    width: 1.4,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration:
                          BoxDecoration(
                        color:
                            AstraTheme.lightBlue,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color:
                            AstraTheme.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'UPI',
                            style:
                                TextStyle(
                              color:
                                  AstraTheme.textBlue,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Use a supported UPI app',
                            style:
                                TextStyle(
                              color:
                                  AstraTheme.secondaryText,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons
                          .check_circle_rounded,
                      color:
                          AstraTheme.primaryBlue,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed:
                      continuePayment,
                  style:
                      ElevatedButton.styleFrom(
                    backgroundColor:
                        AstraTheme.primaryBlue,
                    foregroundColor:
                        Colors.white,
                    elevation: 2,
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Text(
                        'Continue to Pay',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight:
                              FontWeight.w800,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              const Center(
                child: Text(
                  'Demo payment flow • No real money is moved',
                  style: TextStyle(
                    color:
                        AstraTheme.secondaryText,
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

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
        behavior:
            SnackBarBehavior.floating,
      ),
    );
  }
}