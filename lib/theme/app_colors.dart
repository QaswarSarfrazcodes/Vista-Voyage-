import 'package:flutter/material.dart';

/// VistaVoyage V4 — "Golden Horizon" color system.
class AppColors {
  AppColors._();

  static const Color gold        = Color(0xFFFFC570); // Primary accent / CTAs
  static const Color cream       = Color(0xFFEFD2B0); // Warm surface tint
  static const Color slateBlue   = Color(0xFF547792);  // Secondary / icons
  static const Color deepNavy    = Color(0xFF1A3263);  // AppBars / headers

  // Derived / functional tokens (kept consistent with the new palette)
  static const Color primary     = slateBlue;
  static const Color primaryDark = deepNavy;
  static const Color accent      = gold;
  static const Color coral       = Color(0xFFE85D4E); // Favorites/delete (warm red, harmonizes with gold)
  static const Color error       = Color(0xFFDC2626);
  static const Color charcoal    = Color(0xFF1E293B);
  static const Color gray        = Color(0xFF64748B);
  static const Color surface     = Color(0xFFFFFBF5); // Warm-tinted white (pairs with cream)
  static const Color cardTint    = cream;
  static const Color divider     = Color(0xFFE7D9C4);

  static const List<Color> darkGradient = [deepNavy, Color(0xFF2C4A7C)];

  // Dark mode variants
  static const Color surfaceDark   = Color(0xFF15202B);
  static const Color cardDark      = Color(0xFF1F2E3D);
  static const Color charcoalDark  = Color(0xFFE7E9EC);
}
