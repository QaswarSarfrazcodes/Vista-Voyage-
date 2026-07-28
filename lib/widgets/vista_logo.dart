// lib/widgets/vista_logo.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// VistaVoyage V4 brand mark — a compass inside a rounded badge.
/// Replaces the previous airplane icon (Icons.flight_takeoff) app-wide.
class VistaLogo extends StatelessWidget {
  final double size;
  final Color? badgeColor;
  final Color? iconColor;

  const VistaLogo({super.key, this.size = 48, this.badgeColor, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: badgeColor ?? AppColors.gold,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: size * 0.2, offset: Offset(0, size * 0.08))],
      ),
      child: Icon(Icons.explore, color: iconColor ?? AppColors.deepNavy, size: size * 0.55),
    );
  }
}

/// Small wordmark used in AppBars — replaces "VistaVoyage ✈"
class VistaWordmark extends StatelessWidget {
  final Color color;
  const VistaWordmark({super.key, this.color = Colors.white});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.explore, color: AppColors.gold, size: 22),
      const SizedBox(width: 8),
      Text('Tripline', style: TextStyle(
        fontFamily: 'PlayfairDisplay', fontWeight: FontWeight.bold, fontSize: 20, color: color)),
    ]);
  }
}
