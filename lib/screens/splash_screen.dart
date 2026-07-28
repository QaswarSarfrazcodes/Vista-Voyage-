// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../widgets/vista_logo.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200));
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();

    // Returning users with an active session skip the artificial splash
    // delay — new/logged-out users still see the full branded animation.
    Duration delay = const Duration(milliseconds: 2800);
    try {
      if (SupabaseService.currentUser != null) {
        delay = const Duration(milliseconds: 600);
      }
    } catch (e) {
      debugPrint('SplashScreen auth check error in initState: $e');
    }
    Future.delayed(delay, _navigate);
  }

  void _navigate() async {
    if (!mounted) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      
      dynamic user;
      try {
        user = SupabaseService.currentUser;
      } catch (e) {
        debugPrint('SplashScreen currentUser error: $e');
      }

      if (!mounted) return;
      if (!seenOnboarding) {
        Navigator.pushReplacementNamed(context, '/onboarding');
        return;
      }
      if (user == null) {
        Navigator.pushReplacementNamed(context, '/login');
        return;
      }
      Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      debugPrint('SplashScreen navigate error: $e');
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(fit: StackFit.expand, children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.darkGradient,
            ),
          ),
        ),
        FadeTransition(opacity: _fade,
          child: ScaleTransition(scale: _scale,
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
              const VistaLogo(size: 96),
              const SizedBox(height: 28),
              const Text('Tripline', style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay', color: Colors.white, letterSpacing: 1.5,
                shadows: [Shadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4))])),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.5))),
                child: const Text('Your World. Your Way.', style: TextStyle(
                  fontSize: 14, color: Colors.white, fontFamily: 'Nunito',
                  letterSpacing: 1.0, fontWeight: FontWeight.w600))),
            ])))),
        Positioned(bottom: 50, left: 0, right: 0,
          child: FadeTransition(opacity: _fade,
            child: Column(children: [
              const SizedBox(width: 28, height: 28,
                child: CircularProgressIndicator(color: Colors.white70, strokeWidth: 2)),
              const SizedBox(height: 12),
              Text('Discovering the world for you…',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 12, fontFamily: 'Nunito')),
            ]))),
      ]));
  }
}
