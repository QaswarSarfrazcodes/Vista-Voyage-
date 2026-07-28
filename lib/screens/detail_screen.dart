// lib/screens/detail_screen.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import '../models/destination_model.dart';
import '../models/review_model.dart';
import '../services/supabase_data_service.dart';
import '../services/audio_tour_service.dart';
import '../services/currency_service.dart';
import '../services/local_pulse_service.dart';
import '../services/weather_service.dart';
import '../services/visa_checklist_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';

class DetailScreen extends StatefulWidget {
  const DetailScreen({super.key});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isFav = false;
  bool _loading = true;
  DestinationModel? _fullDest;
  // Held in state instead of created inline in build() — a FutureBuilder
  // resubscribes (and re-hits Supabase) whenever its `future` is a new
  // instance, and build() reruns on every setState (favorite toggle, etc).
  Future<List<ReviewModel>>? _reviewsFuture;
  Future<List<Map<String, dynamic>>>? _gemsFuture;
  Future<List<Map<String, dynamic>>>? _questionsFuture;
  String _homeCountry = 'Pakistan';
  final Set<String> _checkedPacking = {};
  bool _isPlayingTour = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final dest = ModalRoute.of(context)!.settings.arguments as DestinationModel;
      _reviewsFuture = SupabaseDataService().getReviews(dest.id);
      _gemsFuture = SupabaseDataService().getHiddenGems(dest.id);
      _questionsFuture = SupabaseDataService().getDestinationQuestions(dest.id);
      try {
        final profile = await SupabaseDataService().getProfile();
        if (profile?['home_country'] != null && (profile!['home_country'] as String).isNotEmpty) {
          _homeCountry = profile['home_country'] as String;
        }
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
      final full = await SupabaseDataService().getDestinationById(dest.id);
      if (mounted && full != null) setState(() => _fullDest = full);
    });
    AudioTourService.setCompletionHandler(() {
      if (mounted) setState(() => _isPlayingTour = false);
    });
  }

  @override
  void dispose() {
    // Avoid a dangling audio session if the user navigates away mid-playback.
    if (_isPlayingTour) AudioTourService.stop();
    super.dispose();
  }

  Future<void> _toggleAudioTour(DestinationModel dest) async {
    if (_isPlayingTour) {
      await AudioTourService.stop();
      if (mounted) setState(() => _isPlayingTour = false);
      return;
    }
    final script = [dest.description, ...dest.highlights].where((s) => s.isNotEmpty).join('. ');
    if (script.isEmpty) return;
    setState(() => _isPlayingTour = true);
    // TTS initializes lazily on this first tap (AudioTourService._ensureInit),
    // never in main() or initState — no cost unless the user actually presses play.
    await AudioTourService.playDestinationTour(script);
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
        AppToast.show(context, _isFav ? '❤️ Added to favorites!' : 'Removed from favorites',
          type: _isFav ? ToastType.success : ToastType.info);
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
    return CachedNetworkImage(
      imageUrl: dest.imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      memCacheWidth: 1000,
      fadeInDuration: const Duration(milliseconds: 150),
      placeholder: (_, __) => Container(color: AppColors.cardTint, child: const Center(child: CircularProgressIndicator(color: AppColors.primary))),
      errorWidget: (_, __, ___) => Container(color: AppColors.cardTint, child: const Center(child: Icon(Icons.image_outlined, size: 60, color: AppColors.primary))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final routeDest = ModalRoute.of(context)!.settings.arguments as DestinationModel;
    final dest = _fullDest ?? routeDest;
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
                icon: Icons.share_outlined,
                onTap: () => Share.share(
                  'Check out ${dest.name}, ${dest.country} on Tripline! ${dest.description}'),
              ),
            ),
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
              // "Local Pulse" — extends the existing weather FutureBuilder with one more
              // lightweight, no-key API call (air quality), gated by the same lat/lon
              // check and firing only when this widget builds — not a new hot path.
              FutureBuilder<List<dynamic>>(
                future: (dest.latitude != null && dest.longitude != null)
                    ? Future.wait([
                        WeatherService.getCurrentWeather(dest.latitude!, dest.longitude!),
                        LocalPulseService.getSafetySnapshot(dest.latitude!, dest.longitude!),
                      ])
                    : Future.value([null, null]),
                builder: (ctx, snap) {
                  if (!snap.hasData) return const SizedBox.shrink();
                  final w = snap.data![0] as WeatherInfo?;
                  final safety = snap.data![1] as Map<String, dynamic>?;
                  if (w == null) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.only(top: 16),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(14)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Icon(_weatherIcon(w.icon), color: AppColors.primary, size: 28),
                        const SizedBox(width: 12),
                        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('${w.tempC.round()}°C', style: const TextStyle(
                            fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.charcoal)),
                          Text(w.description, style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.gray)),
                        ]),
                        if (safety != null && safety['aqiLabel'] != null) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.air_rounded, color: AppColors.slateBlue, size: 22),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text('Air quality: ${safety['aqiLabel']}',
                              style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.gray)),
                          ),
                        ],
                      ]),
                      if (dest.bestTime.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Row(children: [
                          const Icon(Icons.wb_twilight_rounded, color: AppColors.gold, size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text('Best time to visit: ${dest.bestTime}',
                              style: const TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.gray)),
                          ),
                        ]),
                      ],
                    ]),
                  );
                },
              ),
              Wrap(spacing: 4, children: [
                if (dest.avgBudget.isNotEmpty)
                  TextButton.icon(
                    icon: const Icon(Icons.currency_exchange, size: 16),
                    label: const Text('Convert Budget', style: TextStyle(fontFamily: 'Nunito')),
                    onPressed: () => _showCurrencyConverter(context, dest.avgBudget),
                  ),
                TextButton.icon(
                  icon: const Icon(Icons.add_task, size: 16),
                  label: const Text('Add to Trip', style: TextStyle(fontFamily: 'Nunito')),
                  onPressed: () => _showAddToTripSheet(context, dest),
                ),
              ]),
              const SizedBox(height: 10),
              // Visa & Document Checklist Card
              // Hide entirely when travelling within the same country (no visa needed).
              Builder(builder: (ctx) {
                final sameCountry = _homeCountry.trim().toLowerCase() == dest.country.trim().toLowerCase();
                final visaNote = sameCountry
                    ? null
                    : VisaChecklistService.checkRequirement(_homeCountry, dest.country);
                final packingList = VisaChecklistService.generatePackingList(dest.category, dest.bestTime);
                return Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.15)),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // FIX: wrap title in Flexible to prevent RenderFlex overflow
                      Row(
                        children: [
                          const Icon(Icons.flight_takeoff, color: AppColors.primary, size: 20),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              sameCountry
                                  ? 'Travel Requirements ($_homeCountry)'
                                  : 'Travel Requirements ($_homeCountry → ${dest.country})',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'Nunito'),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.cardTint,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                sameCountry
                                    ? 'No visa required — you are travelling within $_homeCountry. Just carry a valid CNIC or passport.'
                                    : (visaNote ?? 'Passport valid for 6+ months required. Verify entry rules with embassy before departure.'),
                                style: const TextStyle(fontSize: 12, fontFamily: 'Nunito'),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Auto Packing List',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, fontFamily: 'Nunito'),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: packingList.map((item) {
                          final isChecked = _checkedPacking.contains(item);
                          return FilterChip(
                            label: Text(item, style: TextStyle(fontSize: 11, color: isChecked ? Colors.white : AppColors.charcoal)),
                            selected: isChecked,
                            selectedColor: AppColors.primary,
                            onSelected: (val) {
                              setState(() {
                                if (val) {
                                  _checkedPacking.add(item);
                                } else {
                                  _checkedPacking.remove(item);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 10),
              const _SectionHeader(title: 'About'),
              const SizedBox(height: 10),
              Text(dest.description, style: const TextStyle(fontSize: 15, height: 1.75, color: AppColors.charcoal, fontFamily: 'Nunito')),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(14)),
                child: Row(children: [
                  IconButton(
                    icon: Icon(_isPlayingTour ? Icons.stop_circle_rounded : Icons.headphones_rounded, color: AppColors.primary),
                    onPressed: () => _toggleAudioTour(dest),
                  ),
                  Expanded(
                    child: Text(
                      _isPlayingTour ? 'Playing audio guide… (tap to stop)' : '🎧 Listen to Audio Guide',
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.charcoal),
                    ),
                  ),
                ]),
              ),
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
                      decoration: const BoxDecoration(
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
                    gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
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
              const SizedBox(height: 24),
              Row(children: [
                const Text('Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: AppColors.charcoal)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, size: 20, color: AppColors.gray),
                  tooltip: 'Retry',
                  onPressed: () => setState(() => _reviewsFuture = SupabaseDataService().getReviews(dest.id)),
                ),
              ]),
              const SizedBox(height: 4),
              FutureBuilder<List<ReviewModel>>(
                future: _reviewsFuture,
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  final reviews = snap.data!;
                  if (reviews.isEmpty) {
                    return const Text('No reviews yet — be the first!', style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray));
                  }
                  return Column(children: reviews.map((r) => Container(
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(r.userName, style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                        const Spacer(),
                        const Icon(Icons.star, color: AppColors.gold, size: 16),
                        Text(r.rating.toStringAsFixed(1), style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.flag_outlined, size: 16, color: AppColors.gray),
                          tooltip: 'Report',
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _showReportDialog(context, r.id),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Text(r.comment, style: const TextStyle(fontFamily: 'Nunito', fontSize: 13)),
                    ]))).toList());
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.rate_review_outlined, size: 18),
                label: const Text('Write a Review', style: TextStyle(fontFamily: 'Nunito')),
                onPressed: () => _showAddReviewDialog(context, dest.id),
                style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary)),
              ),
              const SizedBox(height: 26),
              Row(children: [
                const Text('Hidden Gems Nearby', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: AppColors.charcoal)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_location_alt_outlined, size: 20, color: AppColors.primary),
                  tooltip: 'Submit a Hidden Gem',
                  onPressed: () => _showSubmitGemDialog(context, dest.id),
                ),
              ]),
              const SizedBox(height: 4),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _gemsFuture,
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  final gems = snap.data!;
                  if (gems.isEmpty) {
                    return const Text('No hidden gems submitted here yet — be the first local tip!',
                        style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray));
                  }
                  return Column(children: gems.map((g) => Container(
                    margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.divider)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        const Icon(Icons.diamond_outlined, color: AppColors.gold, size: 16),
                        const SizedBox(width: 6),
                        Expanded(child: Text(g['name'] as String? ?? '', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold))),
                      ]),
                      const SizedBox(height: 6),
                      Text(g['description'] as String? ?? '', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13)),
                    ]))).toList());
                },
              ),
              const SizedBox(height: 26),
              Row(children: [
                const Text('Ask Locals Q&A Board', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: AppColors.charcoal)),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.question_answer_outlined, size: 20, color: AppColors.primary),
                  tooltip: 'Ask a Question',
                  onPressed: () => _showAskQuestionDialog(context, dest.id),
                ),
              ]),
              const SizedBox(height: 4),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: _questionsFuture,
                builder: (ctx, snap) {
                  if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                  final questions = snap.data!;
                  if (questions.isEmpty) {
                    return const Text('No questions asked for this destination yet. Ask locals anything!',
                        style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray));
                  }
                  return Column(
                    children: questions.map((q) {
                      final answers = (q['destination_answers'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.help_outline, color: AppColors.primary, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    q['question'] as String? ?? '',
                                    style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${answers.length} answer(s)',
                              style: const TextStyle(fontSize: 11, color: AppColors.gray),
                            ),
                            if (answers.isNotEmpty) ...[
                              const Divider(height: 16),
                              ...answers.map((ans) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.mode_comment_outlined, size: 14, color: AppColors.primary),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        ans['answer'] as String? ?? '',
                                        style: const TextStyle(fontSize: 12, fontFamily: 'Nunito'),
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                            ],
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                icon: const Icon(Icons.reply, size: 14),
                                label: const Text('Answer Question', style: TextStyle(fontSize: 12)),
                                onPressed: () => _showAnswerQuestionDialog(context, dest.id, q['id'] as String),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ]),
          ),
        ),
      ]),
    );
  }

  IconData _weatherIcon(IconDataCode code) {
    switch (code) {
      case IconDataCode.sunny: return Icons.wb_sunny;
      case IconDataCode.cloudy: return Icons.cloud;
      case IconDataCode.rainy: return Icons.grain;
      case IconDataCode.snowy: return Icons.ac_unit;
      case IconDataCode.stormy: return Icons.thunderstorm;
      default: return Icons.wb_cloudy;
    }
  }

  void _showCurrencyConverter(BuildContext context, String avgBudget) {
    final amountCtrl = TextEditingController(text: '100');
    String toCurrency = 'PKR';
    double? result;

    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) => Padding(
        padding: EdgeInsets.only(left: 20, right: 20, top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Currency Converter', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: TextField(controller: amountCtrl, keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount (USD)', border: OutlineInputBorder()))),
            const SizedBox(width: 12),
            DropdownButton<String>(value: toCurrency,
              items: ['PKR', 'EUR', 'GBP', 'JPY', 'AED', 'INR'].map((c) =>
                DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setSheetState(() => toCurrency = v!)),
          ]),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final amt = double.tryParse(amountCtrl.text) ?? 0;
              final converted = await CurrencyService.convert(amt, 'USD', toCurrency);
              setSheetState(() => result = converted);
            },
            child: const Text('Convert')),
          if (result != null) Padding(padding: const EdgeInsets.only(top: 16),
            child: Text('${amountCtrl.text} USD ≈ ${result!.toStringAsFixed(2)} $toCurrency',
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16))),
        ]),
      )));
  }

  void _showAddReviewDialog(BuildContext context, String destId) {
    double rating = 5.0;
    final commentCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: const Text('Write a Review', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Slider(value: rating, min: 1, max: 5, divisions: 8, label: rating.toStringAsFixed(1),
            onChanged: (v) => setDialogState(() => rating = v)),
          TextField(controller: commentCtrl, maxLines: 3, maxLength: 500,
            decoration: const InputDecoration(hintText: 'Share your experience...', border: OutlineInputBorder())),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(onPressed: () async {
            await SupabaseDataService().addReview(destId, rating, commentCtrl.text.trim());
            await SupabaseDataService().awardPoints(20);
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) {
              AppToast.show(context, 'Review submitted (+20 Points)!', type: ToastType.success);
              setState(() => _reviewsFuture = SupabaseDataService().getReviews(destId));
            }
          }, child: const Text('Submit')),
        ],
      )));
  }

  void _showAskQuestionDialog(BuildContext context, String destId) {
    final qCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Ask Locals a Question', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      content: TextField(controller: qCtrl, maxLines: 3, maxLength: 300,
        decoration: const InputDecoration(hintText: 'e.g. Is it safe to visit in December? Best spots for kids?', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (qCtrl.text.trim().isEmpty) return;
          try {
            await SupabaseDataService().askQuestion(destId, qCtrl.text.trim());
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) {
              AppToast.show(context, 'Question posted!', type: ToastType.success);
              setState(() => _questionsFuture = SupabaseDataService().getDestinationQuestions(destId));
            }
          } catch (e) {
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) AppToast.show(context, 'Could not post question. Please try again.', type: ToastType.error);
          }
        }, child: const Text('Post Question')),
      ],
    ));
  }

  void _showAnswerQuestionDialog(BuildContext context, String destId, String questionId) {
    final aCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Answer Question', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      content: TextField(controller: aCtrl, maxLines: 3, maxLength: 500,
        decoration: const InputDecoration(hintText: 'Share your local advice...', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (aCtrl.text.trim().isEmpty) return;
          try {
            await SupabaseDataService().answerQuestion(questionId, aCtrl.text.trim());
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) {
              AppToast.show(context, 'Answer posted!', type: ToastType.success);
              setState(() => _questionsFuture = SupabaseDataService().getDestinationQuestions(destId));
            }
          } catch (e) {
            if (ctx.mounted) Navigator.pop(ctx);
            if (mounted) AppToast.show(context, 'Could not post answer. Please try again.', type: ToastType.error);
          }
        }, child: const Text('Post Answer')),
      ],
    ));
  }

  void _showReportDialog(BuildContext context, String reviewId) {
    final reasonCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Report Review', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      content: TextField(controller: reasonCtrl, maxLines: 2, maxLength: 200,
        decoration: const InputDecoration(hintText: 'Why are you reporting this review?', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (reasonCtrl.text.trim().isEmpty) return;
          await SupabaseDataService().reportReview(reviewId, reasonCtrl.text.trim());
          if (ctx.mounted) Navigator.pop(ctx);
          if (mounted) AppToast.show(context, 'Report submitted — thank you.', type: ToastType.success);
        }, child: const Text('Submit')),
      ],
    ));
  }

  void _showSubmitGemDialog(BuildContext context, String destId) {
    final nameCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Submit a Hidden Gem', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nameCtrl,
          decoration: const InputDecoration(hintText: 'Name of the spot', border: OutlineInputBorder())),
        const SizedBox(height: 12),
        TextField(controller: descCtrl, maxLines: 3, maxLength: 300,
          decoration: const InputDecoration(hintText: 'Why is it worth visiting?', border: OutlineInputBorder())),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (nameCtrl.text.trim().isEmpty || descCtrl.text.trim().isEmpty) return;
          await SupabaseDataService().submitHiddenGem(destId, nameCtrl.text.trim(), descCtrl.text.trim());
          if (ctx.mounted) Navigator.pop(ctx);
          if (mounted) {
            AppToast.show(context, 'Submitted! It will appear once an admin approves it.', type: ToastType.success);
          }
        }, child: const Text('Submit')),
      ],
    ));
  }

  void _showAddToTripSheet(BuildContext context, DestinationModel dest) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => FutureBuilder<List<Map<String, dynamic>>>(
        future: SupabaseDataService().getUserTrips(),
        builder: (ctx, snap) {
          final trips = snap.data ?? [];
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Add to Trip', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                if (!snap.hasData)
                  const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: AppColors.primary)))
                else if (trips.isEmpty)
                  const Padding(padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text('No trips yet. Create one first from My Trips.', style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray)))
                else
                  ...trips.map((trip) => ListTile(
                    leading: const Icon(Icons.flight_takeoff, color: AppColors.primary),
                    title: Text(trip['title'], style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600)),
                    onTap: () async {
                      await SupabaseDataService().addTripItem(trip['id'], dest, 0);
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        AppToast.show(context, 'Added to "${trip['title']}"', type: ToastType.success);
                      }
                    },
                  )),
                const SizedBox(height: 8),
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Go to My Trips', style: TextStyle(fontFamily: 'Nunito')),
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pushNamed(context, '/trips');
                  },
                ),
              ]),
            ),
          );
        },
      ));
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
          gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]),
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