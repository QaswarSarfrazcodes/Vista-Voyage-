import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/biometric_service.dart';
import '../services/notification_service.dart';
import '../services/supabase_data_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../theme/locale_provider.dart';
import '../theme/theme_provider.dart';
import '../utils/app_toast.dart';
import '../widgets/change_password_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _pushNotifications = true;
  bool _travelReminders = true;
  String _versionLabel = '';
  bool _biometricAvailable = false;
  bool _biometricEnabled = false;

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((info) {
      if (mounted) setState(() => _versionLabel = '${info.version}+${info.buildNumber}');
    });
    BiometricService.isAvailable().then((available) async {
      final enabled = await BiometricService.isEnabled();
      if (mounted) setState(() { _biometricAvailable = available; _biometricEnabled = enabled; });
    });
  }

  void _pickLanguage(BuildContext context) {
    final current = context.read<LocaleProvider>().locale.languageCode;
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Language', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        RadioListTile<String>(
          title: const Text('English', style: TextStyle(fontFamily: 'Nunito')),
          value: 'en', groupValue: current,
          onChanged: (v) { context.read<LocaleProvider>().setLocale(const Locale('en')); Navigator.pop(ctx); },
        ),
        RadioListTile<String>(
          title: const Text('اردو', style: TextStyle(fontFamily: 'Nunito')),
          value: 'ur', groupValue: current,
          onChanged: (v) { context.read<LocaleProvider>().setLocale(const Locale('ur')); Navigator.pop(ctx); },
        ),
      ]),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final locale = context.watch<LocaleProvider>().locale.languageCode;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.settingsTitle,
          style: const TextStyle(
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
          _buildSectionHeader('👤  ${l10n.account}'),
          _buildCard([
            _buildTile(
              icon: Icons.person_outline,
              title: l10n.editProfile,
              onTap: () => Navigator.pushNamed(context, '/profile'),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.lock_outline,
              title: l10n.changePassword,
              onTap: () => showChangePasswordDialog(context),
            ),
            if (_biometricAvailable) ...[
              _buildDivider(),
              _buildSwitchTile(
                icon: Icons.fingerprint,
                title: 'Biometric Lock',
                value: _biometricEnabled,
                onChanged: (val) async {
                  await BiometricService.setEnabled(val);
                  setState(() => _biometricEnabled = val);
                },
              ),
            ],
          ]),
          _buildSectionHeader('🔔  ${l10n.notifications}'),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.notifications_active_outlined,
              title: l10n.enablePushNotifications,
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
              title: l10n.travelReminders,
              value: _travelReminders,
              onChanged: (val) => setState(() => _travelReminders = val),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.notification_add_outlined,
              title: l10n.notificationsCenter,
              onTap: () => Navigator.pushNamed(context, '/notifications'),
            ),
          ]),
          _buildSectionHeader('🎨  ${l10n.appearance}'),
          _buildCard([
            _buildSwitchTile(
              icon: Icons.dark_mode_outlined,
              title: l10n.darkMode,
              value: context.watch<ThemeProvider>().mode == ThemeMode.dark,
              onChanged: (val) => context.read<ThemeProvider>().toggle(val),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.language_outlined,
              title: l10n.language,
              trailingText: locale == 'ur' ? 'اردو' : 'English',
              onTap: () => _pickLanguage(context),
            ),
          ]),
          _buildSectionHeader('ℹ️  ${l10n.about}'),
          _buildCard([
            _buildTile(
              icon: Icons.info_outline,
              title: l10n.appVersion,
              trailingText: _versionLabel.isEmpty ? '…' : _versionLabel,
              onTap: null,
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.description_outlined,
              title: l10n.termsOfService,
              onTap: () => Navigator.pushNamed(context, '/terms'),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.privacy_tip_outlined,
              title: l10n.privacyPolicy,
              onTap: () => Navigator.pushNamed(context, '/privacy'),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.help_outline,
              title: l10n.supportFaqs,
              onTap: () => Navigator.pushNamed(context, '/support'),
            ),
          ]),
          _buildSectionHeader('🔐  Security'),
          _buildCard([
            _buildTile(
              icon: Icons.phonelink_erase_outlined,
              title: 'Log Out of All Devices',
              onTap: () => _confirmForceLogout(context),
            ),
            _buildDivider(),
            _buildTile(
              icon: Icons.delete_outline,
              title: 'Delete Account',
              iconColor: AppColors.error,
              textColor: AppColors.error,
              onTap: () => _confirmAccountDeletion(context),
            ),
          ]),
          const SizedBox(height: 12),
          _buildCard([
            _buildTile(
              icon: Icons.logout,
              title: l10n.logout,
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
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 1, color: AppColors.divider);
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

  void _confirmForceLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log out of all devices?', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
        content: const Text(
          'This will end your session on every device signed in to this account, including this one.',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SupabaseService.client.auth.signOut(scope: SignOutScope.global);
              if (context.mounted) Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('Log Out Everywhere', style: TextStyle(fontFamily: 'Nunito', color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _confirmAccountDeletion(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete your account?', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
        content: const Text(
          'Your account will be permanently removed within 48 hours. This cannot be undone.',
          style: TextStyle(fontFamily: 'Nunito'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await SupabaseDataService().requestAccountDeletion();
              await SupabaseService.signOut();
              if (context.mounted) {
                Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
                AppToast.show(context, 'Deletion request received. Your account will be removed within 48 hours.');
              }
            },
            child: const Text('Delete Account', style: TextStyle(fontFamily: 'Nunito', color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
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
          'Are you sure you want to log out of Tripline?',
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
