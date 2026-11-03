import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme.dart';
import '../widgets/astra_brand.dart';

import 'send_money_screen.dart';
import 'scan_pay_screen.dart';
import 'analytics_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'add_bank_account_screen.dart';
import 'check_balance_screen.dart';

class WalletTransaction {
  final String title;
  final String subtitle;
  final double amount;
  final bool credit;
  final DateTime time;

  const WalletTransaction({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.credit,
    required this.time,
  });
}

class WalletDashboardScreen extends StatefulWidget {
  final String? initialUpiId;

  const WalletDashboardScreen({
    super.key,
    this.initialUpiId,
  });

  @override
  State<WalletDashboardScreen> createState() =>
      _WalletDashboardScreenState();
}

class _WalletDashboardScreenState
    extends State<WalletDashboardScreen> {
  double balance = 2450.00;
  double spentToday = 650.00;

  // Parent-controlled limit for the prototype.
  double dailyLimit = 2000.00;

  bool hideBalance = false;

  int navIndex = 0;

  String upiId = 'gowtham82@astrapay';

  String? bankName;
  String? bankLast4;

  final List<WalletTransaction> transactions = [
    WalletTransaction(
      title: 'College Canteen',
      subtitle: 'Today • UPI',
      amount: 150,
      credit: false,
      time: DateTime(2026, 9, 26, 13, 10),
    ),
    WalletTransaction(
      title: 'Added to Wallet',
      subtitle: 'Today • UPI',
      amount: 500,
      credit: true,
      time: DateTime(2026, 9, 26, 11, 20),
    ),
    WalletTransaction(
      title: 'Rahul Kumar',
      subtitle: 'Yesterday • UPI',
      amount: 250,
      credit: false,
      time: DateTime(2026, 9, 25, 18, 30),
    ),
    WalletTransaction(
      title: 'Received from Anil',
      subtitle: 'Yesterday • UPI',
      amount: 800,
      credit: true,
      time: DateTime(2026, 9, 25, 12, 15),
    ),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.initialUpiId != null &&
        widget.initialUpiId!.trim().isNotEmpty) {
      upiId = widget.initialUpiId!.trim();
    }
  }

  String money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  // ============================================================
  // ADD MONEY
  // ============================================================

  Future<void> openAddMoney() async {
    final result = await showModalBottomSheet<double>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AddMoneySheet(),
    );

    if (!mounted || result == null || result <= 0) {
      return;
    }

    setState(() {
      balance += result;

      transactions.insert(
        0,
        WalletTransaction(
          title: 'Added to Wallet',
          subtitle: 'Just now • UPI',
          amount: result,
          credit: true,
          time: DateTime.now(),
        ),
      );
    });

    _message('Wallet balance updated');
  }

  // ============================================================
  // SEND MONEY
  // ============================================================

  Future<void> openSendMoney() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => SendMoneyScreen(
          balance: balance,
          dailyLimit: dailyLimit,
          spentToday: spentToday,
          ownUpiId: upiId,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final amount =
        (result['amount'] as num?)?.toDouble();

    final recipient =
        result['recipient'] as String?;

    if (amount == null ||
        amount <= 0 ||
        recipient == null ||
        recipient.trim().isEmpty) {
      return;
    }

    setState(() {
      balance =
          (result['newBalance'] as num?)?.toDouble() ??
              (balance - amount);

      spentToday =
          (result['newSpentToday'] as num?)?.toDouble() ??
              (spentToday + amount);

      transactions.insert(
        0,
        WalletTransaction(
          title: recipient,
          subtitle: 'Just now • UPI',
          amount: amount,
          credit: false,
          time: DateTime.now(),
        ),
      );
    });

    _message('Payment successful • Balance updated');
  }

  // ============================================================
  // SCAN & PAY
  // ============================================================

  Future<void> openScanPay() async {
    final result =
        await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => ScanPayScreen(
          balance: balance,
          remaining: dailyLimit - spentToday,
        ),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    final amount =
        (result['amount'] as num?)?.toDouble();

    final recipient =
        result['recipient'] as String?;

    if (amount == null ||
        amount <= 0 ||
        recipient == null ||
        recipient.trim().isEmpty) {
      return;
    }

    setState(() {
      balance -= amount;
      spentToday += amount;

      transactions.insert(
        0,
        WalletTransaction(
          title: recipient,
          subtitle: 'Just now • Scan & Pay',
          amount: amount,
          credit: false,
          time: DateTime.now(),
        ),
      );
    });

    _message('Payment successful • Balance updated');
  }

  // ============================================================
  // ADD BANK
  // ============================================================

  Future<void> openBank() async {
    final result =
        await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => const AddBankAccountScreen(),
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      bankName = result['bank'];
      bankLast4 = result['last4'];
    });

    _message('Bank account added');
  }

  // ============================================================
  // CHECK BALANCE
  // ============================================================

  Future<void> openCheckBalance() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CheckBalanceScreen(
          balance: balance,
          upiId: upiId,
          bankName: bankName,
          bankLast4: bankLast4,
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE
  // ============================================================

  void _message(String text) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ============================================================
  // CURRENT BODY
  // ============================================================

  Widget currentBody() {
    switch (navIndex) {
      case 1:
        return _SearchView(
          transactions: transactions,
        );

      case 3:
        return AnalyticsScreen(
          transactions: transactions,
          spentToday: spentToday,
          dailyLimit: dailyLimit,
        );

      case 4:
        return const HistoryScreen();

      case 0:
      default:
        return _HomeView(
          balance: balance,
          spentToday: spentToday,
          dailyLimit: dailyLimit,
          hideBalance: hideBalance,
          upiId: upiId,
          bankName: bankName,
          bankLast4: bankLast4,
          transactions: transactions,
          onToggleBalance: () {
            setState(() {
              hideBalance = !hideBalance;
            });
          },
          onAddMoney: openAddMoney,
          onSendMoney: openSendMoney,
          onScanPay: openScanPay,
          onAddBank: openBank,
          onCheckBalance: openCheckBalance,
          onShowAllHistory: () {
            setState(() {
              navIndex = 4;
            });
          },
        );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: currentBody(),
      ),

      // Only the bottom Scan & Pay navigation is used.
      // The duplicate floating Scan & Pay button has been removed.
      bottomNavigationBar: NavigationBar(
        selectedIndex: navIndex,

        onDestinationSelected: (index) {
          if (index == 2) {
            openScanPay();
            return;
          }

          setState(() {
            navIndex = index;
          });
        },

        backgroundColor: Colors.white,

        indicatorColor: AstraTheme.lightBlue,

        destinations: const [
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
            ),
            selectedIcon: Icon(
              Icons.home,
            ),
            label: 'Home',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.search,
            ),
            label: 'Search',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.qr_code_scanner,
            ),
            label: 'Scan & Pay',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.analytics_outlined,
            ),
            selectedIcon: Icon(
              Icons.analytics,
            ),
            label: 'Analytics',
          ),

          NavigationDestination(
            icon: Icon(
              Icons.history,
            ),
            label: 'History',
          ),
        ],
      ),
    );
  }
}

// ================================================================
// HOME VIEW
// ================================================================

class _HomeView extends StatelessWidget {
  final double balance;
  final double spentToday;
  final double dailyLimit;

  final bool hideBalance;

  final String upiId;

  final String? bankName;
  final String? bankLast4;

  final List<WalletTransaction> transactions;

  final VoidCallback onToggleBalance;
  final VoidCallback onAddMoney;
  final VoidCallback onSendMoney;
  final VoidCallback onScanPay;
  final VoidCallback onAddBank;
  final VoidCallback onCheckBalance;
  final VoidCallback onShowAllHistory;

  const _HomeView({
    required this.balance,
    required this.spentToday,
    required this.dailyLimit,
    required this.hideBalance,
    required this.upiId,
    required this.bankName,
    required this.bankLast4,
    required this.transactions,
    required this.onToggleBalance,
    required this.onAddMoney,
    required this.onSendMoney,
    required this.onScanPay,
    required this.onAddBank,
    required this.onCheckBalance,
    required this.onShowAllHistory,
  });

  String money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final double remaining =
        (dailyLimit - spentToday)
            .clamp(0, dailyLimit)
            .toDouble();

    final double progress =
        dailyLimit <= 0
            ? 0
            : (spentToday / dailyLimit)
                .clamp(0, 1)
                .toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        18,
        14,
        18,
        35,
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [

          // ======================================================
          // HEADER
          // ======================================================

          Row(
            children: [
              const Expanded(
                child: AstraBrand(
                  logoSize: 42,
                  textSize: 22,
                ),
              ),

              _circleButton(
                Icons.notifications_none_rounded,
                () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text(
                        'Notifications',
                      ),
                      content: const Text(
                        'No new notifications.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(
                              context,
                            );
                          },
                          child: const Text(
                            'Close',
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(
                width: 8,
              ),

              _circleButton(
                Icons.person_outline_rounded,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const ProfileScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(
            height: 24,
          ),

          const Text(
            'Good evening 👋',
            style: TextStyle(
              fontSize: 15,
              color: AstraTheme.secondaryText,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          const Text(
            'Hi, Gowtham',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w800,
              color: AstraTheme.textBlue,
            ),
          ),

          const SizedBox(
            height: 18,
          ),

          // ======================================================
          // WALLET BALANCE CARD
          // ======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1677FF),
                  Color(0xFF09245C),
                ],
              ),
              borderRadius:
                  BorderRadius.circular(26),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 20,
                  offset: Offset(0, 10),
                  color: Color(0x331677FF),
                ),
              ],
            ),
            child: Row(
              children: [

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Wallet Balance',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),

                      const SizedBox(
                        height: 7,
                      ),

                      Row(
                        children: [

                          Flexible(
                            child: Text(
                              hideBalance
                                  ? '₹ •••••'
                                  : money(balance),
                              overflow:
                                  TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight:
                                    FontWeight.w800,
                              ),
                            ),
                          ),

                          IconButton(
                            onPressed:
                                onToggleBalance,
                            color: Colors.white70,
                            icon: Icon(
                              hideBalance
                                  ? Icons
                                      .visibility_off_outlined
                                  : Icons
                                      .visibility_outlined,
                            ),
                          ),
                        ],
                      ),

                      Text(
                        upiId,
                        overflow:
                            TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),

                      const SizedBox(
                        height: 16,
                      ),

                      Row(
                        children: [

                          _whiteMiniButton(
                            Icons.add,
                            'Add Money',
                            onAddMoney,
                          ),

                          const SizedBox(
                            width: 8,
                          ),

                          _whiteMiniButton(
                            Icons.qr_code_2,
                            'Wallet QR',
                            () {
                              showDialog(
                                context: context,
                                builder: (_) =>
                                    AlertDialog(
                                  title: const Text(
                                    'Your AstraPay QR',
                                  ),
                                  content: Column(
                                    mainAxisSize:
                                        MainAxisSize.min,
                                    children: [
                                      QrImageView(
                                        data: upiId,
                                        size: 210,
                                      ),
                                      const SizedBox(
                                        height: 12,
                                      ),
                                      Text(
                                        upiId,
                                        textAlign:
                                            TextAlign
                                                .center,
                                        style:
                                            const TextStyle(
                                          fontWeight:
                                              FontWeight
                                                  .w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(
                                          context,
                                        );
                                      },
                                      child:
                                          const Text(
                                        'Close',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),

          // ======================================================
          // ACTION CARDS
          // ======================================================

          Row(
            children: [

              Expanded(
                child: _actionCard(
                  Icons.send_rounded,
                  'Send Money',
                  onSendMoney,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: _actionCard(
                  Icons.call_received_rounded,
                  'Receive',
                  () {
                    showDialog(
                      context: context,
                      builder: (_) =>
                          AlertDialog(
                        title: const Text(
                          'Receive Money',
                        ),
                        content: Column(
                          mainAxisSize:
                              MainAxisSize.min,
                          children: [
                            QrImageView(
                              data: upiId,
                              size: 190,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              upiId,
                              textAlign:
                                  TextAlign.center,
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                              );
                            },
                            child: const Text(
                              'Close',
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: _actionCard(
                  Icons.account_balance_rounded,
                  'Add Bank',
                  onAddBank,
                ),
              ),

              const SizedBox(
                width: 10,
              ),

              Expanded(
                child: _actionCard(
                  Icons.account_balance_wallet_outlined,
                  'Balance',
                  onCheckBalance,
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 22,
          ),

          // ======================================================
          // DAILY SPENDING LIMIT
          // ======================================================

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AstraTheme.lightBlue,
              borderRadius:
                  BorderRadius.circular(22),
              border: Border.all(
                color: AstraTheme.borderBlue,
              ),
            ),
            child: Row(
              children: [

                Container(
                  height: 48,
                  width: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.speed_rounded,
                    color:
                        AstraTheme.primaryBlue,
                  ),
                ),

                const SizedBox(
                  width: 13,
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [

                      const Text(
                        'Daily Spending Limit',
                        style: TextStyle(
                          fontWeight:
                              FontWeight.w700,
                          color:
                              AstraTheme.textBlue,
                        ),
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        borderRadius:
                            BorderRadius.circular(
                          10,
                        ),
                        backgroundColor:
                            Colors.white,
                        color:
                            AstraTheme.primaryBlue,
                      ),

                      const SizedBox(
                        height: 6,
                      ),

                      Text(
                        '₹${remaining.toStringAsFixed(0)} remaining of ₹${dailyLimit.toStringAsFixed(0)}',
                        style:
                            const TextStyle(
                          fontSize: 12,
                          color: AstraTheme
                              .secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 24,
          ),

          // ======================================================
          // RECENT TRANSACTIONS
          // ======================================================

          Row(
            children: [

              const Expanded(
                child: Text(
                  'Recent Transactions',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight:
                        FontWeight.w800,
                    color:
                        AstraTheme.textBlue,
                  ),
                ),
              ),

              TextButton(
                onPressed:
                    onShowAllHistory,
                child: const Text(
                  'View All',
                ),
              ),
            ],
          ),

          const SizedBox(
            height: 5,
          ),

          if (transactions.isEmpty)
            const Padding(
              padding:
                  EdgeInsets.symmetric(
                vertical: 25,
              ),
              child: Center(
                child: Text(
                  'No transactions yet',
                ),
              ),
            )
          else
            ...transactions
                .take(4)
                .map(
                  (tx) =>
                      _transactionTile(tx),
                ),

          // ======================================================
          // LINKED BANK
          // ======================================================

          if (bankName != null) ...[
            const SizedBox(
              height: 18,
            ),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                border: Border.all(
                  color:
                      AstraTheme.borderBlue,
                ),
              ),
              child: Row(
                children: [

                  const CircleAvatar(
                    backgroundColor:
                        AstraTheme.lightBlue,
                    child: Icon(
                      Icons.account_balance,
                      color:
                          AstraTheme.primaryBlue,
                    ),
                  ),

                  const SizedBox(
                    width: 12,
                  ),

                  Expanded(
                    child: Text(
                      '$bankName •••• ${bankLast4 ?? ''}',
                      style:
                          const TextStyle(
                        fontWeight:
                            FontWeight.w700,
                      ),
                    ),
                  ),

                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.green,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ============================================================
  // HEADER BUTTON
  // ============================================================

  static Widget _circleButton(
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius:
          BorderRadius.circular(15),
      child: Container(
        height: 44,
        width: 44,
        decoration: BoxDecoration(
          color: AstraTheme.lightBlue,
          borderRadius:
              BorderRadius.circular(15),
        ),
        child: Icon(
          icon,
          color: AstraTheme.textBlue,
        ),
      ),
    );
  }

  // ============================================================
  // WHITE BUTTON ON BLUE CARD
  // ============================================================

  static Widget _whiteMiniButton(
    IconData icon,
    String text,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(13),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 10,
          ),
          decoration: BoxDecoration(
            color: Colors.white
                .withValues(alpha: .14),
            borderRadius:
                BorderRadius.circular(13),
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              Icon(
                icon,
                size: 17,
                color: Colors.white,
              ),

              const SizedBox(
                width: 5,
              ),

              Flexible(
                child: Text(
                  text,
                  overflow:
                      TextOverflow.ellipsis,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight:
                        FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION CARD
  // ============================================================

  static Widget _actionCard(
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(17),
        child: Container(
          height: 82,
          padding:
              const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(17),
            border: Border.all(
              color:
                  const Color(0xFFE1E9F5),
            ),
            boxShadow: const [
              BoxShadow(
                blurRadius: 12,
                color:
                    Color(0x0F102A5C),
                offset:
                    Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [

              Icon(
                icon,
                color:
                    AstraTheme.primaryBlue,
                size: 24,
              ),

              const SizedBox(
                height: 6,
              ),

              Text(
                label,
                textAlign:
                    TextAlign.center,
                style:
                    const TextStyle(
                  fontSize: 10.5,
                  fontWeight:
                      FontWeight.w700,
                  color:
                      AstraTheme.textBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TRANSACTION TILE
  // ============================================================

  static Widget _transactionTile(
    WalletTransaction tx,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),
      child: Container(
        padding:
            const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color:
                const Color(0xFFE8EEF7),
          ),
        ),
        child: Row(
          children: [

            CircleAvatar(
              backgroundColor: tx.credit
                  ? const Color(
                      0xFFE9F8EF,
                    )
                  : AstraTheme.lightBlue,
              child: Icon(
                tx.credit
                    ? Icons
                        .south_west_rounded
                    : Icons
                        .north_east_rounded,
                color: tx.credit
                    ? Colors.green
                    : AstraTheme
                        .primaryBlue,
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [

                  Text(
                    tx.title,
                    overflow:
                        TextOverflow.ellipsis,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.w700,
                      color:
                          AstraTheme.textBlue,
                    ),
                  ),

                  const SizedBox(
                    height: 3,
                  ),

                  Text(
                    tx.subtitle,
                    style:
                        const TextStyle(
                      fontSize: 11,
                      color: AstraTheme
                          .secondaryText,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              width: 8,
            ),

            Text(
              '${tx.credit ? '+' : '-'}₹${tx.amount.toStringAsFixed(2)}',
              style: TextStyle(
                fontWeight:
                    FontWeight.w800,
                color: tx.credit
                    ? Colors.green
                    : AstraTheme.textBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ================================================================
// SEARCH VIEW
// ================================================================

class _SearchView extends StatefulWidget {
  final List<WalletTransaction> transactions;

  const _SearchView({
    required this.transactions,
  });

  @override
  State<_SearchView> createState() =>
      _SearchViewState();
}

class _SearchViewState
    extends State<_SearchView> {
  final TextEditingController controller =
      TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query =
        controller.text.trim().toLowerCase();

    final items =
        widget.transactions.where((transaction) {
      return transaction.title
              .toLowerCase()
              .contains(query) ||
          transaction.subtitle
              .toLowerCase()
              .contains(query);
    }).toList();

    return Column(
      children: [

        const Padding(
          padding: EdgeInsets.fromLTRB(
            18,
            18,
            18,
            8,
          ),
          child: Align(
            alignment:
                Alignment.centerLeft,
            child: Text(
              'Search',
              style: TextStyle(
                fontSize: 28,
                fontWeight:
                    FontWeight.w800,
                color:
                    AstraTheme.textBlue,
              ),
            ),
          ),
        ),

        Padding(
          padding:
              const EdgeInsets.all(18),
          child: TextField(
            controller: controller,
            onChanged: (_) {
              setState(() {});
            },
            decoration:
                InputDecoration(
              hintText:
                  'Search transactions...',
              prefixIcon:
                  const Icon(
                Icons.search,
              ),
              filled: true,
              fillColor:
                  AstraTheme.lightBlue,
              border:
                  OutlineInputBorder(
                borderRadius:
                    BorderRadius.circular(
                  17,
                ),
                borderSide:
                    BorderSide.none,
              ),
            ),
          ),
        ),

        Expanded(
          child: items.isEmpty
              ? const Center(
                  child: Text(
                    'No matching transactions',
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 18,
                  ),
                  itemCount:
                      items.length,
                  itemBuilder:
                      (_, index) {
                    return _HomeView
                        ._transactionTile(
                      items[index],
                    );
                  },
                ),
        ),
      ],
    );
  }
}

// ================================================================
// ADD MONEY SHEET
// ================================================================

class _AddMoneySheet
    extends StatefulWidget {
  const _AddMoneySheet();

  @override
  State<_AddMoneySheet> createState() =>
      _AddMoneySheetState();
}

class _AddMoneySheetState
    extends State<_AddMoneySheet> {
  final TextEditingController controller =
      TextEditingController();

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit() {
    final value =
        double.tryParse(
          controller.text.trim(),
        ) ??
        0;

    if (value <= 0) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Enter a valid amount.',
          ),
        ),
      );
      return;
    }

    Navigator.pop(
      context,
      value,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(
        bottom:
            MediaQuery.viewInsetsOf(
          context,
        ).bottom,
      ),
      child: Container(
        padding:
            const EdgeInsets.fromLTRB(
          20,
          22,
          20,
          24,
        ),
        decoration:
            const BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            const Text(
              'Add Money',
              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.w800,
                color:
                    AstraTheme.textBlue,
              ),
            ),

            const SizedBox(
              height: 8,
            ),

            const Text(
              'Choose an amount to add through UPI.',
              style: TextStyle(
                color:
                    AstraTheme.secondaryText,
              ),
            ),

            const SizedBox(
              height: 18,
            ),

            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                100,
                250,
                500,
                1000,
                2000,
              ].map(
                (value) {
                  return ActionChip(
                    label:
                        Text('₹$value'),
                    onPressed: () {
                      controller.text =
                          '$value';
                    },
                  );
                },
              ).toList(),
            ),

            const SizedBox(
              height: 15,
            ),

            TextField(
              controller: controller,
              keyboardType:
                  const TextInputType
                      .numberWithOptions(
                decimal: true,
              ),
              decoration:
                  const InputDecoration(
                labelText:
                    'Amount',
                prefixText:
                    '₹ ',
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            SizedBox(
              width:
                  double.infinity,
              child: FilledButton(
                onPressed:
                    submit,
                child:
                    const Text(
                  'Continue to Pay',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}