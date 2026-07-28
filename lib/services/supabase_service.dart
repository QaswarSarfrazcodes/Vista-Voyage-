// lib/services/supabase_service.dart
// Replaces Firebase Auth + Firestore with Supabase (free tier, no credit card)

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL']!,
      anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static User? get currentUser => client.auth.currentUser;

  static String? get currentUserId => currentUser?.id;

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<AuthResponse> signIn(String email, String password) async {
    return await client.auth.signInWithPassword(
      email: email, password: password);
  }

  static Future<AuthResponse> signUp(
      String email, String password, String name) async {
    return await client.auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<void> updatePassword(String newPassword) async {
    await client.auth.updateUser(UserAttributes(password: newPassword));
  }

  static Future<void> resendConfirmationEmail(String email) async {
    await client.auth.resend(type: OtpType.signup, email: email);
  }

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
