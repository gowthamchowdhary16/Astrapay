import 'package:flutter/material.dart';

class AstraTheme {
  static const Color primaryBlue = Color(0xFF1677FF);
  static const Color deepBlue = Color(0xFF09245C);
  static const Color lightBlue = Color(0xFFEAF4FF);
  static const Color borderBlue = Color(0xFFBFD9FF);
  static const Color textBlue = Color(0xFF102A5C);
  static const Color secondaryText = Color(0xFF7182A3);

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'Roboto',
    colorScheme: const ColorScheme.light(
      primary: primaryBlue,
      secondary: primaryBlue,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: textBlue,
      elevation: 0,
    ),
  );
}