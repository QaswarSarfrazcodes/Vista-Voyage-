// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'l10n/gen/app_localizations.dart';
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
import 'screens/trip_planner_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/main_shell.dart';
import 'screens/terms_screen.dart';
import 'screens/privacy_policy_screen.dart';
import 'screens/trip_detail_screen.dart';
import 'screens/qr_scan_screen.dart';
import 'screens/trip_blueprint_screen.dart';
import 'screens/trip_buddies_screen.dart';
import 'screens/landmark_scan_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_colors.dart';
import 'theme/locale_provider.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    debugPrint('dotenv load error: $e');
  }

  Future<void> appRunner() async {
    try {
      await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    } catch (e) {
      debugPrint('SystemChrome error: $e');
    }
    try {
      await SupabaseService.initialize();
    } catch (e) {
      debugPrint('SupabaseService initialize error: $e');
    }
    try {
      await NotificationService.initialize();
    } catch (e) {
      debugPrint('NotificationService initialize error: $e');
    }
    runApp(
      MultiProvider(providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
      ], child: const TriplineApp()),
    );
  }

  final sentryDsn = dotenv.env['SENTRY_DSN'];
  if (sentryDsn != null && sentryDsn.trim().isNotEmpty) {
    try {
      await SentryFlutter.init(
        (options) {
          options.dsn = sentryDsn;
          options.tracesSampleRate = 0.2;
          options.environment = 'production';
        },
        appRunner: appRunner,
      );
    } catch (e) {
      debugPrint('Sentry init error: $e');
      await appRunner();
    }
  } else {
    await appRunner();
  }
}

class TriplineApp extends StatelessWidget {
  const TriplineApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    return MaterialApp(
      title: 'Tripline',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.mode,
      locale: localeProvider.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('ur')],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
          secondary: AppColors.gold,
          surface: Colors.white,
        ),
        scaffoldBackgroundColor: AppColors.surface,
        fontFamily: 'Nunito',
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
          primary: AppColors.primary,
          secondary: AppColors.gold,
        ),
        fontFamily: 'Nunito',
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
        ),
      ),
      builder: (context, child) {
        final clamped = MediaQuery.textScalerOf(context).clamp(minScaleFactor: 0.85, maxScaleFactor: 1.25);
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(textScaler: clamped),
          child: child!,
        );
      },
      initialRoute: '/splash',
      routes: {
        '/splash': (_) => const SplashScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/login': (_) => const LoginScreen(),
        '/signup': (_) => const SignupScreen(),
        '/main': (_) => const MainShell(),
        '/home': (_) => const HomeScreen(),
        '/detail': (_) => const DetailScreen(),
        '/favorites': (_) => const FavoritesScreen(),
        '/ai': (_) => const AiScreen(),
        '/settings': (_) => const SettingsScreen(),
        '/notifications': (_) => const NotificationsScreen(),
        '/map': (_) => const MapScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/support': (_) => const SupportScreen(),
        '/trips': (_) => const TripPlannerScreen(),
        '/admin': (_) => const AdminScreen(),
        '/terms': (_) => const TermsScreen(),
        '/privacy': (_) => const PrivacyPolicyScreen(),
        '/trip-detail': (_) => const TripDetailScreen(),
        '/qr-scan': (_) => const QrScanScreen(),
        '/trip-blueprint': (_) => const TripBlueprintScreen(),
        '/trip-buddies': (_) => const TripBuddiesScreen(),
        '/landmark-scan': (_) => const LandmarkScanScreen(),
      },
      onUnknownRoute: (s) => MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}
