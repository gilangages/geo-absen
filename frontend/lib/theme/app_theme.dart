import 'package:flutter/material.dart';

class AppTheme {
  // Warna Utama
  static const Color primarySeed = Color(0xFF4C45B9);
  static const Color hoverColor = Color(0xFFE9E8F6);

  // Light Theme
  static final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primarySeed,
      brightness: Brightness.light,
      surface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.white,
    hoverColor: hoverColor,
    splashColor: hoverColor,
    highlightColor: hoverColor.withOpacity(0.5),
    useMaterial3: true,
  );
}
