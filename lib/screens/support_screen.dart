import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  static const _faqs = [
    {
      'q': 'How do I save a destination to favorites?',
      'a': 'Tap the heart icon on any destination\'s detail screen. It will appear in your Favorites tab instantly.'
    },
    {
      'q': 'Can I use VistaVoyage offline?',
      'a': 'Browsing requires internet to fetch destinations from our database, but previously viewed favorites remain visible if cached.'
    },
    {
      'q': 'How does the AI Travel Assistant work?',
      'a': 'It uses an AI language model to generate custom itineraries, food tips, and travel advice based on your selected destination.'
    },
    {
      'q': 'How do I turn off notifications?',
      'a': 'Go to Settings → Notifications → toggle off "Enable Push Notifications".'
    },
    {
      'q': 'Is my data secure?',
      'a': 'Yes — all data is stored securely via Supabase with row-level security, meaning only you can access your favorites and profile.'
    },
    {
      'q': 'How do I delete my account?',
      'a': 'Please contact support below and we\'ll process your account deletion request within 48 hours.'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Support & FAQs', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Frequently Asked Questions',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.charcoal),
          ),
          const SizedBox(height: 12),
          ..._faqs.map((f) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: ExpansionTile(
                  title: Text(
                    f['q']!,
                    style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.charcoal),
                  ),
                  iconColor: AppColors.primary,
                  collapsedIconColor: AppColors.gray,
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        f['a']!,
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.gray, height: 1.5),
                      ),
                    ),
                  ],
                ),
              )),
          const SizedBox(height: 20),
          const Text(
            'Still need help?',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.charcoal),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Contact our support team and we\'ll get back to you within 24 hours.',
                  style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.charcoal),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.email_outlined, size: 18),
                    label: const Text('Email Support', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
