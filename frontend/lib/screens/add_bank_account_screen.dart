
import 'package:flutter/material.dart';
import '../theme.dart';

class AddBankAccountScreen extends StatefulWidget {
  const AddBankAccountScreen({super.key});
  @override State<AddBankAccountScreen> createState() => _AddBankAccountScreenState();
}
class _AddBankAccountScreenState extends State<AddBankAccountScreen> {
  final account = TextEditingController();
  final confirm = TextEditingController();
  final ifsc = TextEditingController();
  String bank = 'State Bank of India';

  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('Add Bank Account')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: AstraTheme.lightBlue, borderRadius: BorderRadius.circular(20)), child: const Row(children: [
        Icon(Icons.account_balance, color: AstraTheme.primaryBlue, size: 30),
        SizedBox(width: 12),
        Expanded(child: Text('Link your own eligible bank account for supported wallet operations.', style: TextStyle(color: AstraTheme.textBlue, fontWeight: FontWeight.w600))),
      ])),
      const SizedBox(height: 20),
      DropdownButtonFormField<String>(
        value: bank,
        items: const ['State Bank of India','HDFC Bank','ICICI Bank','Axis Bank','Other'].map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(),
        onChanged: (v) => setState(() => bank = v ?? bank),
        decoration: const InputDecoration(labelText: 'Bank'),
      ),
      const SizedBox(height: 14),
      TextField(controller: account, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Account Number')),
      const SizedBox(height: 14),
      TextField(controller: confirm, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Confirm Account Number')),
      const SizedBox(height: 14),
      TextField(controller: ifsc, textCapitalization: TextCapitalization.characters, decoration: const InputDecoration(labelText: 'IFSC Code')),
      const SizedBox(height: 24),
      SizedBox(height: 52, child: FilledButton(onPressed: () {
        if (account.text.length < 9 || account.text != confirm.text || ifsc.text.length < 8) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter valid bank details.')));
          return;
        }
        Navigator.pop(context, {'bank': bank, 'last4': account.text.substring(account.text.length - 4)});
      }, child: const Text('Add Bank Account'))),
    ]),
  );
}
