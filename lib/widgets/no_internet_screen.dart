// lib/widgets/no_internet_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Full-screen "can't reach the server" state with a single consistent
/// retry action — used app-wide instead of each screen handling connection
/// failures differently.
class NoInternetScreen extends StatelessWidget {
  final VoidCallback onRetry;
  final String message;

  const NoInternetScreen({super.key, required this.onRetry,
    this.message = "Can't connect right now. Check your internet connection and try again."});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primary.withValues(alpha: 0.1)),
              child: const Icon(Icons.wifi_off_rounded, size: 44, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            const Text("You're Offline", style: TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.charcoal)),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center,
              style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppColors.gray, height: 1.5)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            ),
          ]),
        ),
      ),
    );
  }
}
