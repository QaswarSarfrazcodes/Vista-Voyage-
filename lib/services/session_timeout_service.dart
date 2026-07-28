// lib/services/session_timeout_service.dart
// A single deferred Timer that's reset on user activity — no polling, no
// per-frame work, so it costs nothing until the 30-minute window elapses.
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'supabase_service.dart';

class SessionTimeoutService {
  static Timer? _timer;
  static const _timeout = Duration(minutes: 30);
  static VoidCallback? onTimeout;

  static void start(VoidCallback onTimeoutCallback) {
    onTimeout = onTimeoutCallback;
    _reset();
  }

  static void recordActivity() {
    if (_timer != null) _reset();
  }

  static void _reset() {
    _timer?.cancel();
    _timer = Timer(_timeout, () async {
      await SupabaseService.signOut();
      onTimeout?.call();
    });
  }

  static void stop() {
    _timer?.cancel();
    _timer = null;
  }
}
