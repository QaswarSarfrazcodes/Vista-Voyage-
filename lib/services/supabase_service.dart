// lib/services/supabase_service.dart
// Replaces Firebase Auth + Firestore with Supabase (free tier, no credit card)

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  static const _url    = 'https://qieqfinzunytmdulyyko.supabase.co';
  static const _anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9'
      '.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpZXFmaW56dW55dG1kdWx5eWtvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3Nzg1MTAsImV4cCI6MjA5MzM1NDUxMH0'
      '.lwieWngZ1DoBueCwHAzqoNvnxKpg0amH-XDrxGKkkxU';

  static Future<void> initialize() async {
    await Supabase.initialize(url: _url, anonKey: _anonKey);
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

  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;
}
