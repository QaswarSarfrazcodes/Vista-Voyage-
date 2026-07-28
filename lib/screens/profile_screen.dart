import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/supabase_service.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/change_password_dialog.dart';
import 'travel_stats_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _bioCtrl  = TextEditingController();
  final _homeCountryCtrl = TextEditingController();
  bool _loading = true, _saving = false, _editing = false;
  int _favoritesCount = 0, _tripsCount = 0, _reviewsCount = 0;
  int _points = 0;
  String? _referralCode;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final service = SupabaseDataService();
    final profile = await service.getProfile();
    final user = SupabaseService.currentUser;
    _nameCtrl.text = profile?['full_name'] as String? ?? (user?.userMetadata?['full_name'] as String? ?? '');
    _bioCtrl.text = profile?['bio'] as String? ?? 'Exploring the world, one destination at a time.';
    _homeCountryCtrl.text = profile?['home_country'] as String? ?? 'Pakistan';
    _referralCode = profile?['referral_code'] as String?;
    final favs = await service.getUserFavorites();
    final trips = await service.getUserTrips();
    final reviewsCount = await service.getUserReviewsCount();
    final points = await service.getPoints();

    if (mounted) {
      setState(() {
        _favoritesCount = favs.length;
        _tripsCount = trips.length;
        _reviewsCount = reviewsCount;
        _points = points;
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final service = SupabaseDataService();
    await service.upsertProfile(fullName: _nameCtrl.text.trim(), bio: _bioCtrl.text.trim());
    if (_homeCountryCtrl.text.trim().isNotEmpty) {
      await service.updateHomeCountry(_homeCountryCtrl.text.trim());
    }
    if (mounted) setState(() { _saving = false; _editing = false; });
  }

  void _changePassword() => showChangePasswordDialog(context);

  String _getTierBadge(int pts) {
    if (pts >= 500) return '🥇 Gold Tier';
    if (pts >= 100) return '🥈 Silver Tier';
    return '🥉 Bronze Tier';
  }

  void _shareReferralCode() {
    final code = _referralCode ?? 'TRIPLINE123';
    Share.share(
      'Join me on Tripline! Use my referral code "$code" when you sign up to get started planning incredible trips: https://tripline.app',
      subject: 'Tripline Invitation',
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = SupabaseService.currentUser?.email ?? '';
    final initial = _nameCtrl.text.isNotEmpty ? _nameCtrl.text[0].toUpperCase() : 'V';
    final tier = _getTierBadge(_points);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: CustomScrollView(slivers: [
            SliverAppBar(
              expandedHeight: 240, pinned: true, backgroundColor: AppColors.primaryDark,
              actions: [
                IconButton(icon: Icon(_editing ? Icons.close : Icons.edit_outlined, color: Colors.white),
                  onPressed: () => setState(() => _editing = !_editing)),
              ],
              flexibleSpace: FlexibleSpaceBar(background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(
                  begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: AppColors.darkGradient)),
                child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(width: 88, height: 88,
                    decoration: BoxDecoration(color: AppColors.gold, shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3)),
                    child: Center(child: Text(initial, style: const TextStyle(
                      fontSize: 36, fontWeight: FontWeight.bold, color: AppColors.deepNavy, fontFamily: 'Nunito')))),
                  const SizedBox(height: 12),
                  Text(_nameCtrl.text.isEmpty ? 'Traveler' : _nameCtrl.text, style: const TextStyle(
                    fontFamily: 'PlayfairDisplay', fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text(email, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: Colors.white70)),
                ])))),
            ),
            SliverToBoxAdapter(child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
              // Stats & Points Row
              Row(children: [
                _statCard('Favorites', _favoritesCount, Icons.favorite),
                const SizedBox(width: 8),
                _statCard('Trips', _tripsCount, Icons.card_travel),
                const SizedBox(width: 8),
                _statCard('Reviews', _reviewsCount, Icons.rate_review),
                const SizedBox(width: 8),
                _statCard('Points', _points, Icons.stars, subtitle: tier.split(' ').first),
              ]),
              const SizedBox(height: 16),

              // Rewards Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.emoji_events, color: AppColors.gold, size: 36),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tier,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Earn points by writing reviews (+20), completing trips (+50), & referrals (+100)!',
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (_editing) ...[
                TextField(controller: _nameCtrl, decoration: InputDecoration(labelText: 'Full Name',
                  filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: _homeCountryCtrl, decoration: InputDecoration(labelText: 'Home Country (Passport)',
                  filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 12),
                TextField(controller: _bioCtrl, maxLines: 3, maxLength: 200, decoration: InputDecoration(labelText: 'Bio',
                  filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)))),
                const SizedBox(height: 16),
                SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _saving ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)))),
              ] else ...[
                Container(padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(14)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(_bioCtrl.text, style: const TextStyle(fontFamily: 'Nunito', fontSize: 14, color: AppColors.charcoal, height: 1.5)),
                      if (_homeCountryCtrl.text.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.flag_outlined, size: 16, color: AppColors.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Home Country: ${_homeCountryCtrl.text}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                            ),
                          ],
                        ),
                      ],
                    ],
                  )),
              ],
              const SizedBox(height: 24),
              _profileMenuTile(
                Icons.analytics_outlined,
                'Travel Stats & Personality Profile',
                () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TravelStatsScreen())),
              ),
              _profileMenuTile(
                Icons.card_giftcard,
                'Referral Program (${_referralCode ?? "Share Code"})',
                _shareReferralCode,
              ),
              _profileMenuTile(Icons.settings_outlined, 'Settings', () => Navigator.pushNamed(context, '/settings')),
              _profileMenuTile(Icons.lock_outline, 'Change Password', _changePassword),
              _profileMenuTile(Icons.help_outline, 'Support & FAQs', () => Navigator.pushNamed(context, '/support')),
              _profileMenuTile(Icons.description_outlined, 'Terms & Conditions', () => Navigator.pushNamed(context, '/terms')),
              _profileMenuTile(Icons.privacy_tip_outlined, 'Privacy Policy', () => Navigator.pushNamed(context, '/privacy')),
              _profileMenuTile(Icons.logout, 'Logout', () async {
                await SupabaseService.signOut();
                if (context.mounted) Navigator.pushNamedAndRemoveUntil(context, '/login', (r) => false);
              }, color: AppColors.error),
            ]))),
          ]),
        ),
    );
  }

  Widget _statCard(String label, int count, IconData icon, {String? subtitle}) => Expanded(
    child: Container(padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8)]),
      child: Column(children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(height: 4),
        Text('$count', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16)),
        Text(subtitle ?? label, style: const TextStyle(fontFamily: 'Nunito', fontSize: 10, color: AppColors.gray)),
      ])));

  Widget _profileMenuTile(IconData icon, String label, VoidCallback onTap, {Color? color}) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
    child: Material(
      color: Colors.white,
      child: ListTile(
        leading: Icon(icon, color: color ?? AppColors.primary),
        title: Text(label, style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, color: color ?? AppColors.charcoal)),
        trailing: const Icon(Icons.chevron_right, color: AppColors.gray),
        onTap: onTap,
      ),
    ));
}

