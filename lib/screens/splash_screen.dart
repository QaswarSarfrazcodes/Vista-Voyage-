// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

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
    Future.delayed(const Duration(milliseconds: 2800), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final user = SupabaseService.currentUser;
    Navigator.pushReplacementNamed(context, user != null ? '/home' : '/login');
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
              colors: [Color(0xFF0F2044), Color(0xFF1E3A5F)],
            ),
          ),
        ),
        FadeTransition(opacity: _fade,
          child: ScaleTransition(scale: _scale,
            child: Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(width: 120, height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: Colors.white.withOpacity(0.35), width: 1.5),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 24)]),
                child: ClipRRect(borderRadius: BorderRadius.circular(30),
                  child: Image.asset('assets/images/logo.png', fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.flight_takeoff, size: 60, color: Colors.white)))),
              const SizedBox(height: 28),
              const Text('VistaVoyage', style: TextStyle(
                fontSize: 40, fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay', color: Colors.white, letterSpacing: 1.5,
                shadows: [Shadow(color: Colors.black45, blurRadius: 12, offset: Offset(0, 4))])),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.3))),
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
                style: TextStyle(color: Colors.white.withOpacity(0.7),
                  fontSize: 12, fontFamily: 'Nunito')),
            ]))),
      ]));
  }
}
