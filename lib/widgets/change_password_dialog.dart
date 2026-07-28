// lib/widgets/change_password_dialog.dart
// Shared "Change Password" dialog — previously duplicated only in
// ProfileScreen (with a weaker ≥6-char rule) while SettingsScreen's own
// "Change Password" tile did nothing (`onTap: () {}`). Extracted here so
// both entry points use the exact same dialog and the same password rule
// as Signup (see lib/utils/validators.dart).
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../utils/app_toast.dart';
import '../utils/validators.dart';

void showChangePasswordDialog(BuildContext context) {
  final newPassCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();
  bool saving = false;
  showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Change Password', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(controller: newPassCtrl, obscureText: true,
            decoration: const InputDecoration(labelText: 'New Password', border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(controller: confirmCtrl, obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirm Password', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: saving ? null : () async {
              final validationError = strongPasswordValidator(newPassCtrl.text);
              if (validationError != null) {
                AppToast.show(ctx, validationError, type: ToastType.error);
                return;
              }
              if (newPassCtrl.text != confirmCtrl.text) {
                AppToast.show(ctx, 'Passwords do not match.', type: ToastType.error);
                return;
              }
              setDialogState(() => saving = true);
              try {
                await SupabaseService.updatePassword(newPassCtrl.text);
                if (ctx.mounted) Navigator.pop(ctx);
                if (context.mounted) {
                  AppToast.show(context, 'Password updated!', type: ToastType.success);
                }
              } catch (e) {
                setDialogState(() => saving = false);
                if (ctx.mounted) {
                  AppToast.show(ctx, 'Error: $e', type: ToastType.error);
                }
              }
            },
            child: saving
              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Update'),
          ),
        ],
      ),
    ),
  );
}
