import 'package:flutter/material.dart';

class AdminColors {
  AdminColors._();

  static const Color deepNavy   = Color(0xFF0D1B2A);
  static const Color sidebarNavy= Color(0xFF1B263B);
  static const Color gold        = Color(0xFFFFC570);
  static const Color slateBlue   = Color(0xFF415A77);
  static const Color lightBg     = Color(0xFFF8FAFC);
  static const Color cardBg      = Colors.white;
  static const Color charcoal    = Color(0xFF1E293B);
  static const Color gray        = Color(0xFF64748B);
  static const Color success     = Color(0xFF10B981);
  static const Color warning     = Color(0xFFF59E0B);
  static const Color danger      = Color(0xFFEF4444);
  static const Color border      = Color(0xFFE2E8F0);
}

class AdminTheme {
  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AdminColors.lightBg,
      primaryColor: AdminColors.deepNavy,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AdminColors.deepNavy,
        primary: AdminColors.deepNavy,
        secondary: AdminColors.gold,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: AdminColors.deepNavy,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AdminColors.deepNavy,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AdminColors.deepNavy, width: 1.5),
        ),
      ),
    );
  }
}
