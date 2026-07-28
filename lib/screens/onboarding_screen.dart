// lib/screens/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_colors.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageCtrl = PageController();
  int _page = 0;

  static const _pages = [
    {'icon': Icons.explore, 'title': 'Discover the World',
     'desc': 'Browse hand-picked destinations across Pakistan and the globe.'},
    {'icon': Icons.auto_awesome, 'title': 'AI Travel Assistant',
     'desc': 'Get personalized itineraries, food tips, and budget advice instantly.'},
    {'icon': Icons.favorite, 'title': 'Plan & Save',
     'desc': 'Save favorites, plan trips, and get travel reminders — all in one app.'},
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: SafeArea(child: Column(children: [
        Expanded(child: PageView.builder(controller: _pageCtrl, itemCount: _pages.length,
          onPageChanged: (i) => setState(() => _page = i),
          itemBuilder: (ctx, i) => Padding(padding: const EdgeInsets.all(32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(_pages[i]['icon'] as IconData, size: 100, color: Colors.white),
              const SizedBox(height: 32),
              Text(_pages[i]['title'] as String, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'PlayfairDisplay', fontSize: 28,
                  fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 16),
              Text(_pages[i]['desc'] as String, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 15, color: Colors.white70, height: 1.5)),
            ])))),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_pages.length, (i) => Container(
            margin: const EdgeInsets.symmetric(horizontal: 4), width: 8, height: 8,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: i == _page ? AppColors.gold : Colors.white24)))),
        Padding(padding: const EdgeInsets.all(24), child: Row(children: [
          TextButton(onPressed: _finish, child: const Text('Skip', style: TextStyle(color: Colors.white70, fontFamily: 'Nunito'))),
          const Spacer(),
          ElevatedButton(
            onPressed: _page == _pages.length - 1 ? _finish
              : () => _pageCtrl.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: Text(_page == _pages.length - 1 ? 'Get Started' : 'Next',
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold))),
        ])),
      ])),
    );
  }
}
