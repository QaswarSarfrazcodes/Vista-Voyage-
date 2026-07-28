import 'package:flutter/material.dart';
import '../services/supabase_data_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';

void showSettingsMenu(BuildContext context) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const SettingsMenu(),
  );
}

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        child: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: AppColors.gray.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: AppColors.charcoal,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _menuItem(
              context,
              icon: Icons.person_outline,
              label: 'Profile / Account',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile');
              },
            ),
            _menuItem(
              context,
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            _menuItem(
              context,
              icon: Icons.card_travel_outlined,
              label: 'My Trips',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/trips');
              },
            ),
            _menuItem(
              context,
              icon: Icons.camera_alt_outlined,
              label: 'Scan a Landmark',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/landmark-scan');
              },
            ),
            _menuItem(
              context,
              icon: Icons.settings_outlined,
              label: 'App Settings',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/settings');
              },
            ),
            _menuItem(
              context,
              icon: Icons.info_outline,
              label: 'About Tripline',
              onTap: () {
                Navigator.pop(context);
                showAboutDialog(
                  context: context,
                  applicationName: 'Tripline',
                  applicationVersion: '1.0.0',
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.help_outline,
              label: 'Help & Support',
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/support');
              },
            ),
            FutureBuilder<bool>(
              future: SupabaseDataService().isCurrentUserAdmin(),
              builder: (ctx, snap) {
                if (snap.data != true) return const SizedBox.shrink();
                return _menuItem(context, icon: Icons.admin_panel_settings_outlined, label: 'Admin Panel',
                  onTap: () { Navigator.pop(context); Navigator.pushNamed(context, '/admin'); });
              },
            ),
            const Divider(height: 12, indent: 20, endIndent: 20),
            _menuItem(
              context,
              icon: Icons.logout,
              label: 'Logout',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () async {
                Navigator.pop(context);
                await SupabaseService.signOut();
                if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
              },
            ),
          ],
        ),
          ),
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: iconColor ?? AppColors.primary),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: textColor ?? AppColors.charcoal,
        ),
      ),
      onTap: onTap,
    );
  }
}
