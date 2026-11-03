
import 'package:flutter/material.dart';
import '../theme.dart';

class ScanPayScreen extends StatefulWidget {
  final double balance;
  final double remaining;
  const ScanPayScreen({super.key, required this.balance, required this.remaining});
  @override State<ScanPayScreen> createState() => _ScanPayScreenState();
}

class _ScanPayScreenState extends State<ScanPayScreen> {
  final upi = TextEditingController(text: 'merchant@astrapay');
  final amount = TextEditingController();
  bool scanned = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Scan & Pay')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(28),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                const Icon(Icons.qr_code_scanner_rounded, size: 130, color: Colors.white),
                Positioned(
                  top: 35, left: 35, right: 35,
                  child: Container(height: 2, color: AstraTheme.primaryBlue),
                ),
                Positioned(
                  bottom: 25,
                  child: Text(
                    scanned ? 'QR detected' : 'Point camera at QR code',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => setState(() => scanned = true),
            icon: const Icon(Icons.qr_code_scanner),
            label: const Text('Scan QR'),
          ),
          const SizedBox(height: 18),
          TextField(controller: upi, decoration: const InputDecoration(labelText: 'UPI ID')),
          const SizedBox(height: 12),
          TextField(controller: amount, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Amount', prefixText: '₹ ')),
          const SizedBox(height: 8),
          Text('Wallet ₹${widget.balance.toStringAsFixed(2)} • Daily remaining ₹${widget.remaining.toStringAsFixed(2)}', style: const TextStyle(color: AstraTheme.secondaryText, fontSize: 12)),
          const SizedBox(height: 22),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: () {
                final value = double.tryParse(amount.text) ?? 0;
                if (upi.text.trim().isEmpty || value <= 0 || value > widget.balance || value > widget.remaining) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid UPI ID and amount within your limits.')));
                  return;
                }
                Navigator.pop(context, {'recipient': upi.text.trim(), 'amount': value});
              },
              child: const Text('Pay Now'),
            ),
          ),
        ],
      ),
    );
  }
}