import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/admin_login_screen.dart';
import 'screens/dashboard_shell.dart';
import 'theme/admin_theme.dart';

// Supabase credentials — same as your mobile app .env
const _supabaseUrl = 'https://qieqfinzunytmdulyyko.supabase.co';
const _supabaseAnonKey =
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFpZXFmaW56dW55dG1kdWx5eWtvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzc3Nzg1MTAsImV4cCI6MjA5MzM1NDUxMH0.lwieWngZ1DoBueCwHAzqoNvnxKpg0amH-XDrxGKkkxU';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: _supabaseUrl,
    anonKey: _supabaseAnonKey,
  );

  runApp(const AdminDashboardApp());
}

class AdminDashboardApp extends StatelessWidget {
  const AdminDashboardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'Tripline Web Admin Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AdminTheme.themeData,
      initialRoute: session != null ? '/dashboard' : '/login',
      routes: {
        '/login': (context) => const AdminLoginScreen(),
        '/dashboard': (context) => const DashboardShell(),
      },
    );
  }
}
