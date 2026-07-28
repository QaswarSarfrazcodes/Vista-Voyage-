// lib/screens/main_shell.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/gen/app_localizations.dart';
import '../services/biometric_service.dart';
import '../services/session_timeout_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';
import 'home_screen.dart';
import 'map_screen_tab.dart';
import 'trip_planner_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';

/// Root shell with a persistent bottom navigation bar.
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  DateTime? _lastBackPress;
  // Only tabs the user has actually opened get built — avoids all 5 tabs'
  // network/image requests firing simultaneously on cold start (was blocking
  // the main thread for seconds and starving Home's own image loads).
  // Once built, a tab stays in the IndexedStack so its state/scroll position
  // is preserved on switch (unlike simply swapping the single body widget).
  final Set<int> _visited = {0};
  // Shown only if the user enabled biometric lock in Settings — checked
  // here (not in splash_screen) so the splash→main route transition never
  // waits on the local_auth platform-channel round trip.
  bool _biometricLocked = false;

  final _pages = const [
    HomeScreen(),
    MapScreenTab(),
    TripPlannerScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    SessionTimeoutService.start(() {
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
        AppToast.show(context, 'Session expired — please sign in again.');
      }
    });
    _maybeRequireBiometric();
  }

  Future<void> _maybeRequireBiometric() async {
    if (!await BiometricService.isEnabled()) return;
    if (!await BiometricService.isAvailable()) return;
    if (!mounted) return;
    setState(() => _biometricLocked = true);
    final ok = await BiometricService.authenticate();
    if (!mounted) return;
    if (ok) {
      setState(() => _biometricLocked = false);
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
    }
  }

  @override
  void dispose() {
    SessionTimeoutService.stop();
    super.dispose();
  }

  Future<void> _onBackPress(bool didPop, Object? result) async {
    if (didPop) return;
    final now = DateTime.now();
    if (_lastBackPress == null || now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      AppToast.show(context, 'Press back again to exit');
      return;
    }
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        Listener(
          behavior: HitTestBehavior.translucent,
          // onPointerDown only — fires once per touch, not per move/scroll frame,
          // so this adds no measurable cost to scrolling or map panning.
          onPointerDown: (_) => SessionTimeoutService.recordActivity(),
          child: PopScope(
            canPop: false,
            onPopInvokedWithResult: _onBackPress,
            child: Scaffold(
              body: IndexedStack(
                index: _index,
                children: List.generate(_pages.length,
                    (i) => _visited.contains(i) ? _pages[i] : const SizedBox.shrink()),
              ),
              bottomNavigationBar: NavigationBar(
                selectedIndex: _index,
                onDestinationSelected: (i) => setState(() {
                  _index = i;
                  _visited.add(i);
                }),
                backgroundColor: Colors.white,
                indicatorColor: AppColors.gold.withValues(alpha: 0.25),
                elevation: 8,
                destinations: [
                  NavigationDestination(icon: const Icon(Icons.explore_outlined), selectedIcon: const Icon(Icons.explore, color: AppColors.deepNavy), label: l10n.explore),
                  NavigationDestination(icon: const Icon(Icons.map_outlined), selectedIcon: const Icon(Icons.map, color: AppColors.deepNavy), label: l10n.map),
                  NavigationDestination(icon: const Icon(Icons.card_travel_outlined), selectedIcon: const Icon(Icons.card_travel, color: AppColors.deepNavy), label: l10n.trips),
                  NavigationDestination(icon: const Icon(Icons.favorite_border), selectedIcon: const Icon(Icons.favorite, color: AppColors.coral), label: l10n.favorites),
                  NavigationDestination(icon: const Icon(Icons.person_outline), selectedIcon: const Icon(Icons.person, color: AppColors.deepNavy), label: l10n.profile),
                ],
              ),
            ),
          ),
        ),
        // Opaque cover shown while a biometric check is pending, so the app's
        // content is never visible mid-authentication — removed the instant
        // this resolves (success clears it, failure routes to /login).
        if (_biometricLocked)
          Positioned.fill(
            child: Container(
              color: AppColors.primaryDark,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.fingerprint, color: Colors.white, size: 56),
                    SizedBox(height: 16),
                    Text('Unlocking…', style: TextStyle(fontFamily: 'Nunito', color: Colors.white70)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
