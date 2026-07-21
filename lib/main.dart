// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/supabase_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/ai_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/map_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/support_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_colors.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await SupabaseService.initialize();
  await NotificationService.initialize();
  runApp(const VistaVoyageApp());
}

class VistaVoyageApp extends StatelessWidget {
  const VistaVoyageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VistaVoyage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.gold,
          surface: Colors.white,
        ),
        fontFamily: 'Nunito',
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/home': (_) => const HomeScreen(),
        '/detail': (_) => const DetailScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/ai': (_) => const AiScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/map': (_) => const MapScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/support': (_) => const SupportScreen(),
      },
      onUnknownRoute: (s) => MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
