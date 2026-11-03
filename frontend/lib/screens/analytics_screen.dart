
import 'package:flutter/material.dart';
import '../theme.dart';
import 'wallet_dashboard_screen.dart';

class AnalyticsScreen extends StatelessWidget {
  final List<WalletTransaction> transactions;
  final double spentToday;
  final double dailyLimit;
  const AnalyticsScreen({super.key, required this.transactions, required this.spentToday, required this.dailyLimit});

  @override
  Widget build(BuildContext context) {
    final spent = transactions.where((x) => !x.credit).fold<double>(0, (a, b) => a + b.amount);
    final received = transactions.where((x) => x.credit).fold<double>(0, (a, b) => a + b.amount);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 100),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Analytics', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AstraTheme.textBlue)),
        const SizedBox(height: 6),
        const Text('Your wallet activity at a glance', style: TextStyle(color: AstraTheme.secondaryText)),
        const SizedBox(height: 20),
        Row(children: [
          Expanded(child: _stat('Spent', '₹${spent.toStringAsFixed(0)}', Icons.arrow_upward, false)),
          const SizedBox(width: 12),
          Expanded(child: _stat('Received', '₹${received.toStringAsFixed(0)}', Icons.arrow_downward, true)),
        ]),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AstraTheme.lightBlue, borderRadius: BorderRadius.circular(22), border: Border.all(color: AstraTheme.borderBlue)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Today', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AstraTheme.textBlue)),
            const SizedBox(height: 12),
            Text('₹${spentToday.toStringAsFixed(0)} / ₹${dailyLimit.toStringAsFixed(0)}', style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800, color: AstraTheme.textBlue)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: dailyLimit == 0 ? 0 : (spentToday / dailyLimit).clamp(0,1), minHeight: 9, borderRadius: BorderRadius.circular(20)),
          ]),
        ),
        const SizedBox(height: 20),
        const Text('Smart Insights', style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: AstraTheme.textBlue)),
        const SizedBox(height: 10),
        _insight(Icons.lightbulb_outline, 'Keep daily spending within your selected limit.'),
        _insight(Icons.auto_awesome, 'AstraPay can categorize transactions for budgeting.'),
        _insight(Icons.shield_outlined, 'Large transactions can trigger parent notifications for minor accounts.'),
      ]),
    );
  }

  static Widget _stat(String title, String value, IconData icon, bool green) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: AstraTheme.borderBlue)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: green ? Colors.green : AstraTheme.primaryBlue),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(color: AstraTheme.secondaryText)),
      const SizedBox(height: 4),
      Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AstraTheme.textBlue)),
    ]),
  );

  static Widget _insight(IconData icon, String text) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17), border: Border.all(color: const Color(0xFFE4EBF5))),
    child: Row(children: [Icon(icon, color: AstraTheme.primaryBlue), const SizedBox(width: 12), Expanded(child: Text(text, style: const TextStyle(color: AstraTheme.textBlue, fontWeight: FontWeight.w600)))]),
  );
}
