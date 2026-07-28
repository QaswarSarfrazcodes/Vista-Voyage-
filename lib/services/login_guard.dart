// lib/services/login_guard.dart
// Client-side brute-force lockout — SharedPreferences only, no network calls,
// so it adds no measurable latency to the login flow.
import 'package:shared_preferences/shared_preferences.dart';

class LoginGuard {
  static const _maxAttempts = 5;
  static const _lockoutMinutes = 5;

  static Future<bool> isLockedOut() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntil = prefs.getInt('lockout_until') ?? 0;
    return DateTime.now().millisecondsSinceEpoch < lockUntil;
  }

  static Future<int> remainingLockoutSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    final lockUntil = prefs.getInt('lockout_until') ?? 0;
    final diff = lockUntil - DateTime.now().millisecondsSinceEpoch;
    return diff > 0 ? (diff / 1000).ceil() : 0;
  }

  static Future<void> recordFailedAttempt() async {
    final prefs = await SharedPreferences.getInstance();
    final attempts = (prefs.getInt('failed_attempts') ?? 0) + 1;
    await prefs.setInt('failed_attempts', attempts);
    if (attempts >= _maxAttempts) {
      final until = DateTime.now().add(const Duration(minutes: _lockoutMinutes));
      await prefs.setInt('lockout_until', until.millisecondsSinceEpoch);
      await prefs.setInt('failed_attempts', 0);
    }
  }

  static Future<void> resetOnSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('failed_attempts');
    await prefs.remove('lockout_until');
  }
}
