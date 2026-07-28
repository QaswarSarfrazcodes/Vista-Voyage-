// lib/screens/terms_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white,
        title: const Text('Terms & Conditions', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold))),
      body: ListView(padding: const EdgeInsets.all(20), children: const [
        _Section(title: '1. Acceptance of Terms',
          body: 'By creating an account and using Tripline, you agree to these Terms & Conditions and our Privacy Policy.'),
        _Section(title: '2. Use of the App',
          body: 'Tripline provides travel discovery, planning, and AI-assisted recommendations for informational purposes only. Always verify travel advisories independently.'),
        _Section(title: '3. User Content',
          body: 'Reviews, ratings, and profile information you submit may be visible to other users. Do not post offensive or false content.'),
        _Section(title: '4. Data & Privacy',
          body: 'Your data is stored securely via Supabase with row-level security. We do not sell your personal data to third parties.'),
        _Section(title: '5. AI-Generated Content',
          body: 'Itineraries and suggestions from the AI Travel Assistant are generated automatically and may contain inaccuracies. Verify details before booking travel.'),
        _Section(title: '6. Account Termination',
          body: 'We reserve the right to suspend accounts that violate these terms or misuse the platform.'),
        _Section(title: '7. Changes to Terms',
          body: 'These terms may be updated periodically. Continued use of the app constitutes acceptance of any changes.'),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  final String title, body;
  const _Section({required this.title, required this.body});
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 20),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.charcoal)),
      const SizedBox(height: 6),
      Text(body, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.gray, height: 1.6)),
    ]));
}
