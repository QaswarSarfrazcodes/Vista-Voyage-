// lib/screens/privacy_policy_screen.dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white,
        title: const Text('Privacy Policy', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold))),
      body: ListView(padding: const EdgeInsets.all(20), children: const [
        _P('What We Collect', 'Your email, display name, favorites, trips, and reviews you choose to submit. We never collect more than what a feature explicitly needs.'),
        _P('How We Use It', 'To power your account, sync favorites/trips across devices, and personalize recommendations. We do not sell your data to third parties.'),
        _P('Third-Party Services', 'We use Supabase for authentication and data storage, and Groq for AI-generated travel suggestions. These providers process data solely to deliver those features.'),
        _P('Your Rights', 'You can edit your profile, delete your account (Settings → Delete Account), and request a copy of your data at any time by contacting support.'),
        _P('Security', 'Passwords are hashed by Supabase Auth and never stored in plain text. All network traffic uses HTTPS.'),
      ]),
    );
  }
}

class _P extends StatelessWidget {
  final String t, b;
  const _P(this.t, this.b);
  @override
  Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 18),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(t, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 15)),
      const SizedBox(height: 6),
      Text(b, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.gray, height: 1.6)),
    ]));
}
