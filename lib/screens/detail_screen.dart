// lib/screens/detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFav = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dest = ModalRoute.of(context)!.settings.arguments as DestinationModel;
      try {
        final fav = await SupabaseDataService().isFavorited(dest.id);
        if (mounted) {
          setState(() {
            _isFav = fav;
            _loading = false;
          });
        }
      } catch (_) {
        if (mounted) setState(() => _loading = false);
      }
    });
  }

  Future<void> _toggleFav(DestinationModel dest) async {
    setState(() => _loading = true);
    try {
      if (_isFav) {
        await SupabaseDataService().removeFavorite(dest.id);
      } else {
        await SupabaseDataService().addFavorite(dest);
      }
      setState(() => _isFav = !_isFav);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isFav ? '❤️ Added to favorites!' : 'Removed from favorites', style: const TextStyle(fontFamily: 'Nunito')),
          duration: const Duration(seconds: 2),
          backgroundColor: _isFav ? AppColors.primary : Colors.grey[700],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Widget _buildImage(DestinationModel dest) {
    if (dest.isAsset) {
      return Image.asset(
        dest.imageUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => Container(color: AppColors.cardTint, child: const Center(child: Icon(Icons.image_outlined, size: 60, color: AppColors.primary))),
      );
    }
    return Image.network(
      dest.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      errorBuilder: (_, __, ___) => Container(color: AppColors.cardTint, child: const Center(child: Icon(Icons.image_outlined, size: 60, color: AppColors.primary))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dest = ModalRoute.of(context)!.settings.arguments as DestinationModel;
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: AppColors.primaryDark,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: _CircleBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context)),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: _CircleBtn(
                icon: _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                iconColor: _isFav ? Colors.redAccent : Colors.white,
                onTap: _loading ? null : () => _toggleFav(dest),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                Hero(
                  tag: 'map-img-${dest.id}',
                  child: _buildImage(dest),
                ),
                // Cinematic top + bottom scrim for legibility & depth
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.45),
                        Colors.transparent,
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.75),
                      ],
                      stops: const [0.0, 0.22, 0.45, 1.0],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 22,
                  left: 20,
                  right: 20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.75)]),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(color: AppColors.gold.withValues(alpha: 0.4), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          const Icon(Icons.star_rounded, color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(dest.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: Colors.white)),
                        ]),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        dest.name,
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'PlayfairDisplay',
                          color: Colors.white,
                          shadows: [Shadow(color: Colors.black54, blurRadius: 10)],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(children: [
                        const Icon(Icons.location_on_rounded, color: Colors.white70, size: 15),
                        const SizedBox(width: 4),
                        Text(dest.country, style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Nunito')),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.gold.withValues(alpha: 0.25)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.star_rounded, color: AppColors.gold, size: 18),
                    const SizedBox(width: 6),
                    Text(dest.rating.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: AppColors.charcoal)),
                    const Text('/5.0', style: TextStyle(fontSize: 12, color: AppColors.gray, fontFamily: 'Nunito')),
                  ]),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: dest.tags.map((t) => _TagPill(label: t)).toList(),
                  ),
                ),
              ]),
              const SizedBox(height: 22),
              Row(children: [
                if (dest.bestTime.isNotEmpty)
                  Expanded(child: _InfoTile(icon: Icons.wb_sunny_rounded, iconColor: AppColors.gold, label: 'Best Time', value: dest.bestTime)),
                if (dest.avgBudget.isNotEmpty)
                  Expanded(child: _InfoTile(icon: Icons.account_balance_wallet_rounded, iconColor: AppColors.primary, label: 'Avg Budget', value: dest.avgBudget)),
              ]),
              const SizedBox(height: 26),
              const _SectionHeader(title: 'About'),
              const SizedBox(height: 10),
              Text(dest.description, style: const TextStyle(fontSize: 15, height: 1.75, color: AppColors.charcoal, fontFamily: 'Nunito')),
              const SizedBox(height: 26),
              if (dest.highlights.isNotEmpty) ...[
                const _SectionHeader(title: 'Top Highlights'),
                const SizedBox(height: 14),
                ...dest.highlights.map((h) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      width: 22,
                      height: 22,
                      margin: const EdgeInsets.only(top: 1),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_rounded, color: Colors.white, size: 14),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(h, style: const TextStyle(fontSize: 14, fontFamily: 'Nunito', color: AppColors.charcoal, height: 1.4)),
                    ),
                  ]),
                )),
                const SizedBox(height: 12),
              ],
              if (dest.latitude != null && dest.longitude != null) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.map_rounded, size: 18),
                    label: const Text('View on Map', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
                    onPressed: () => Navigator.pushNamed(context, '/map', arguments: [dest]),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary, width: 1.4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () => Navigator.pushNamed(context, '/ai', arguments: dest),
                      child: const Center(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome_rounded, size: 20, color: Colors.white),
                            SizedBox(width: 10),
                            Text('Ask AI for Itinerary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: Colors.white)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: _loading ? null : () => _toggleFav(dest),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _isFav ? Colors.redAccent : AppColors.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: Icon(
                          _isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          key: ValueKey(_isFav),
                          color: _isFav ? Colors.redAccent : AppColors.primary,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isFav ? 'Saved to Favorites' : 'Save to Favorites',
                        style: TextStyle(fontSize: 15, fontFamily: 'Nunito', fontWeight: FontWeight.w700, color: _isFav ? Colors.redAccent : AppColors.primary),
                      ),
                    ],
                  ),
                ),
              ),
            ]),
          ),
        ),
      ]),
    );
  }
}

/// Small accent-bar section title, consistent with the app's premium header style.
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
        width: 4,
        height: 18,
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      const SizedBox(width: 8),
      Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, fontFamily: 'Nunito', color: AppColors.charcoal)),
    ]);
  }
}

/// Outlined pill used for destination tags.
class _TagPill extends StatelessWidget {
  final String label;
  const _TagPill({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.cardTint,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.15)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontFamily: 'Nunito', fontWeight: FontWeight.w600, color: AppColors.primary)),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label, value;

  const _InfoTile({required this.icon, required this.iconColor, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.divider),
      boxShadow: [
        BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
      ],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: iconColor, size: 15),
        ),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.gray, fontFamily: 'Nunito')),
      ]),
      const SizedBox(height: 6),
      Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, fontFamily: 'Nunito', color: AppColors.charcoal)),
    ]),
  );
}

/// Frosted-glass circular icon button used in the app bar.
class _CircleBtn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final VoidCallback? onTap;

  const _CircleBtn({required this.icon, this.iconColor = Colors.white, this.onTap});

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(100),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
          ),
          child: Icon(icon, color: iconColor, size: 19),
        ),
      ),
    ),
  );
}