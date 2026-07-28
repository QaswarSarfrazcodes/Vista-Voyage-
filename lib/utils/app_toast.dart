// lib/utils/app_toast.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum ToastType { info, success, error }

/// Single source of truth for snackbar styling so every screen's toast
/// looks and behaves the same instead of each one hand-rolling a SnackBar.
class AppToast {
  AppToast._();

  static void show(BuildContext context, String message, {ToastType type = ToastType.info, SnackBarAction? action}) {
    final color = switch (type) {
      ToastType.success => AppColors.primary,
      ToastType.error => AppColors.error,
      ToastType.info => AppColors.deepNavy,
    };
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message, style: const TextStyle(fontFamily: 'Nunito', color: Colors.white)),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: action,
    ));
  }
}
