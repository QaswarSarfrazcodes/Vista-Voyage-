import 'package:flutter/material.dart';

import '../services/notification_service.dart';
import '../utils/app_toast.dart';
import '../theme/app_colors.dart';

/// VistaVoyage — Notifications Screen
/// Covers Task 26 (notifications file link), Task 27 (configure evidence),
/// and Task 28 (test notification alert evidence).
///
/// Design tokens (matching existing app):
///   AppBar background : #2563EB (Dark Blue)
///   Scaffold bg        : #F9FAFB
///   Card bg            : White, rounded 16, subtle shadow
///   Bell accent        : #F5A623 (Amber)
///   Button color       : #3B82F6 (Primary Blue), height 54
///   Unread dot         : #3B82F6

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const Color darkBlue = AppColors.primaryDark;
  static const Color primaryBlue = AppColors.primary;
  static const Color amber = AppColors.gold;
  static const Color charcoal = AppColors.charcoal;
  static const Color lightGray = AppColors.gray;
  static const Color surfaceBg = AppColors.surface;

  bool _permissionGranted = false;
  bool _sending = false;

  final List<_NotificationItem> _items = [
    _NotificationItem(
      title: 'Travel Reminder',
      body: 'Your saved trip to Santorini is waiting — plan it today!',
      time: '2h ago',
      unread: true,
    ),
    _NotificationItem(
      title: 'New Destination Added',
      body: 'Kyoto, Japan just joined the Tripline collection.',
      time: '1d ago',
      unread: true,
    ),
    _NotificationItem(
      title: 'AI Itinerary Ready',
      body: 'Your personalized Bali itinerary has been generated.',
      time: '3d ago',
      unread: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final granted = await NotificationService.isPermissionGranted();
    if (mounted) setState(() => _permissionGranted = granted);
  }

  Future<void> _requestPermission() async {
    final granted = await NotificationService.requestPermission();
    if (mounted) setState(() => _permissionGranted = granted);
  }

  Future<void> _sendTest() async {
    setState(() => _sending = true);
    await NotificationService.sendTestNotification();
    if (mounted) {
      setState(() => _sending = false);
      AppToast.show(context, 'Test notification sent!', type: ToastType.success);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: surfaceBg,
      appBar: AppBar(
        backgroundColor: darkBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Notifications',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 20),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Permission / configuration card — Task 27 evidence
          _buildPermissionCard(),
          const SizedBox(height: 20),

          // Test notification button — Task 28 evidence
          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: _sending ? null : _sendTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.send_outlined),
              label: Text(
                _sending ? 'Sending...' : 'Send Test Notification',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Recent',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: charcoal,
            ),
          ),
          const SizedBox(height: 12),
          ..._items.map(_buildNotificationCard),
        ],
      ),
    );
  }

  Widget _buildPermissionCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: amber.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.notifications_active, color: amber),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _permissionGranted
                      ? 'Notifications Enabled'
                      : 'Enable Notifications',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _permissionGranted
                      ? 'You\'ll receive travel reminders and updates.'
                      : 'Turn on notifications to get travel reminders.',
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: lightGray),
                ),
              ],
            ),
          ),
          if (!_permissionGranted)
            TextButton(
              onPressed: _requestPermission,
              child: const Text(
                'Enable',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  color: primaryBlue,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          else
            const Icon(Icons.check_circle, color: primaryBlue),
        ],
      ),
    );
  }

  Widget _buildNotificationCard(_NotificationItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.unread)
            Container(
              margin: const EdgeInsets.only(top: 6, right: 10),
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: primaryBlue,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: charcoal,
                      ),
                    ),
                    Text(
                      item.time,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: lightGray,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.body,
                  style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: lightGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String body;
  final String time;
  final bool unread;

  _NotificationItem({
    required this.title,
    required this.body,
    required this.time,
    required this.unread,
  });
}
