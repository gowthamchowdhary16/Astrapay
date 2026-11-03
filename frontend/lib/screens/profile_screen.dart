
import 'package:flutter/material.dart';
import '../theme.dart';
import '../widgets/astra_brand.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(title: const Text('Profile')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const Center(child: AstraBrand(logoSize: 58, textSize: 27)),
      const SizedBox(height: 28),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: AstraTheme.lightBlue, borderRadius: BorderRadius.circular(24), border: Border.all(color: AstraTheme.borderBlue)),
        child: const Row(children: [
          CircleAvatar(radius: 30, backgroundColor: Colors.white, child: Icon(Icons.person, color: AstraTheme.primaryBlue, size: 32)),
          SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Gowtham', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AstraTheme.textBlue)),
            SizedBox(height: 4),
            Text('gowtham82@astrapay', style: TextStyle(color: AstraTheme.secondaryText)),
          ]),
        ]),
      ),
      const SizedBox(height: 18),
      _item(Icons.person_outline, 'Personal Information'),
      _item(Icons.verified_user_outlined, 'KYC & Verification'),
      _item(Icons.security_outlined, 'Security'),
      _item(Icons.notifications_none, 'Notifications'),
      _item(Icons.help_outline, 'Help & Support'),
      _item(Icons.info_outline, 'About AstraPay'),
    ]),
  );
  static Widget _item(IconData icon, String text) => Card(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(17), side: const BorderSide(color: Color(0xFFE4EBF5))),
    child: ListTile(leading: Icon(icon, color: AstraTheme.primaryBlue), title: Text(text, style: const TextStyle(fontWeight: FontWeight.w700, color: AstraTheme.textBlue)), trailing: const Icon(Icons.chevron_right)),
  );
}
