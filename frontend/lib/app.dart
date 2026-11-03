import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/splash_screen.dart';

class AstraPayApp extends StatelessWidget {
  const AstraPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ASTRApay',
      theme: AstraTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}