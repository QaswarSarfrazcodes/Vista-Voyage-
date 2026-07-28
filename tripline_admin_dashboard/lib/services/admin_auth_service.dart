import 'package:supabase_flutter/supabase_flutter.dart';

class AdminAuthResult {
  final bool ok;
  final String? error;
  AdminAuthResult({required this.ok, this.error});
}

class AdminAuthService {
  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static Future<AdminAuthResult> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AdminAuthResult(ok: false, error: 'Authentication failed.');
      }

      // Any authenticated user can access the admin dashboard
      return AdminAuthResult(ok: true);
    } catch (e) {
      return AdminAuthResult(ok: false, error: e.toString());
    }
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<bool> checkIsAdmin() async {
    final user = currentUser;
    if (user == null) return false;
    try {
      final profile = await client
          .from('profiles')
          .select('is_admin')
          .eq('id', user.id)
          .maybeSingle();
      return profile?['is_admin'] == true;
    } catch (_) {
      return false;
    }
  }
}
