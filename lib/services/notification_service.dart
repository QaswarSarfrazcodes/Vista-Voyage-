// lib/services/notification_service.dart
// Local push notification service using flutter_local_notifications.
// Call NotificationService.initialize() once in main() before runApp().

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _channelId    = 'vistavoyage_channel';
  static const _channelName  = 'VistaVoyage';
  static const _channelDesc  = 'Travel reminders and updates';

  // ── Initialize ────────────────────────────────────────────────────────────
  static Future<void> initialize() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios     = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );
  }

  // ── Request permission (Android 13+ / iOS) ────────────────────────────────
  static Future<bool> requestPermission() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  static Future<bool> isPermissionGranted() async {
    return await Permission.notification.isGranted;
  }

  // ── Send test notification ────────────────────────────────────────────────
  static Future<void> sendTestNotification() async {
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority:   Priority.high,
        icon: '@mipmap/ic_launcher',
        playSound: true,
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
    await _plugin.show(
      0,
      '✈️ VistaVoyage',
      'Your next adventure awaits! Check out today\'s top picks.',
      details,
    );
  }

  // ── Schedule a daily reminder ─────────────────────────────────────────────
  static Future<void> scheduleDaily(int hour, int minute) async {
    // Basic scheduled notification (non-repeating for demo)
    await _plugin.show(
      1,
      '🌍 Time to Explore!',
      'New destinations are waiting for you on VistaVoyage.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId, _channelName,
          channelDescription: _channelDesc,
          importance: Importance.defaultImportance,
          priority:   Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
  }
}
