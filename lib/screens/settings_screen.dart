import 'package:flutter/material.dart';
import '../services/notification_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _travelReminders = true;
  bool _darkMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          _buildSectionHeader('👤  Account'),
          _buildCard([
            _buildTile(
              icon: Icons.person_outline,
              title: 'Edit Profile',
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {},
            ),
          ]),
          _buildSectionHeader('🔔  Notifications'),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: 'Enable Push Notifications',
              value: _pushNotifications,
              onChanged: (val) async {
                if (val) {
                  final granted = await NotificationService.requestPermission();
                  setState(() => _pushNotifications = granted);
                } else {
                  setState(() => _pushNotifications = false);
                }
              },
            ),
            _buildDivider(),
            _buildSwitchTile(
              icon: Icons.card_travel_outlined,
              title: 'Travel Reminders',
              value: _travelReminders,
              onChanged: (val) => setState(() => _travelReminders = val),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.notification_add_outlined,
              title: 'Notifications Center',
              onTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
          ]),
          _buildSectionHeader('🎨  Appearance'),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: 'Dark Mode',
              value: _darkMode,
              onChanged: (val) => setState(() => _darkMode = val),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.language_outlined,
              title: 'Language',
              trailingText: 'English',
              onTap: () {},
            ),
          ]),
          _buildSectionHeader('ℹ️  About'),
          _buildCard([
            _buildTile(
              icon: Icons.info_outline,
              title: 'App Version',
              trailingText: '1.0.0',
              onTap: null,
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.description_outlined,
              title: 'Terms of Service',
              onTap: () {},
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              onTap: () {},
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.help_outline,
              title: 'Support & FAQs',
              onTap: () => Navigator.pushNamed(context, '/support'),
            ),
          ]),
          const SizedBox(height: 12),
          _buildCard([
            _buildTile(
              icon: Icons.logout,
              title: 'Logout',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () => _confirmLogout(context),
            ),
          ]),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Text(
        text,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: AppColors.charcoal,
        ),
      ),
    );
  }

  Widget _buildCard(List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1, thickness: 1, color: AppColors.divider);
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    String? trailingText,
    Color? iconColor,
    Color? textColor,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.charcoal,
        ),
      ),
      trailing: trailingText != null
          ? Text(
              trailingText,
              style: const TextStyle(fontFamily: 'Nunito', color: AppColors.gray, fontSize: 14),
            )
          : (onTap != null ? const Icon(Icons.chevron_right, color: AppColors.gray) : null),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required dynamic onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.charcoal,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Log out?',
          style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Are you sure you want to log out of VistaVoyage?',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.error,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
