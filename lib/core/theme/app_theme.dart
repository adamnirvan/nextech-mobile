import 'package:flutter/material.dart';

class AppTheme {
  // Light mode
  static ThemeData get lightTheme => ThemeData(
    fontFamily: 'PlusJakartaSans',
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF1A1A1A), onPrimary: Colors.white,
      surface: Colors.white, onSurface: Color(0xFF1A1A1A),
      surfaceContainerHighest: Color(0xFFF5F5F5), error: Colors.red,
    ),
  );

  // Ireng mode
  static ThemeData get darkTheme => ThemeData(
    fontFamily: 'PlusJakartaSans',
    colorScheme: const ColorScheme.dark(
      primary: Colors.white, onPrimary: Colors.black,
      surface: Color(0xFF121212), onSurface: Colors.white,
      surfaceContainerHighest: Color(0xFF2C2C2C), error: Colors.redAccent,
    ),
  );
}