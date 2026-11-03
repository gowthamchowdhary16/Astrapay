
import 'package:flutter/material.dart';
import '../theme.dart';
import 'package:qr_flutter/qr_flutter.dart';

class CheckBalanceScreen extends StatelessWidget {
  final double balance;
  final String upiId;
  final String? bankName, bankLast4;
  const CheckBalanceScreen({super.key, required this.balance, required this.upiId, required this.bankName, required this.bankLast4});

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('Check Balance')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(gradient: const LinearGradient(colors: [AstraTheme.primaryBlue, AstraTheme.deepBlue]), borderRadius: BorderRadius.circular(26)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Available Wallet Balance', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text('₹${balance.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(upiId, style: const TextStyle(color: Colors.white70)),
        ]),
      ),
      const SizedBox(height: 18),
      ListTile(leading: const Icon(Icons.account_balance_wallet, color: AstraTheme.primaryBlue), title: const Text('Wallet Status'), subtitle: const Text('Active')),
      ListTile(leading: const Icon(Icons.account_balance, color: AstraTheme.primaryBlue), title: const Text('Linked Bank'), subtitle: Text(bankName == null ? 'Not linked' : '$bankName •••• ${bankLast4 ?? ''}')),
      const SizedBox(height: 18),
      Center(child: Column(children: [const Text('Wallet QR', style: TextStyle(fontWeight: FontWeight.w800, color: AstraTheme.textBlue)), const SizedBox(height: 8), QrImageView(data: upiId, size: 190)])),
    ]),
  );
}
