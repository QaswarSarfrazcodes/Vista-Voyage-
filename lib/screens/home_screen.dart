// lib/screens/home_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../l10n/gen/app_localizations.dart';
import '../models/destination_model.dart';
import '../services/supabase_service.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';
import '../utils/result.dart';
import '../widgets/destination_card.dart';
import '../widgets/no_internet_screen.dart';
import '../widgets/vista_logo.dart';
import 'settings_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DestinationModel> _all = [];
  List<DestinationModel> _filtered = [];
  List<DestinationModel> _recommendations = [];
  bool _loading = true;
  String _query = '';
  String _category = 'All';
  double _minRating = 0;
  bool _bannerDismissed = false;
  Timer? _searchDebounce;
  final _searchCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  int _page = 0;
  bool _hasMore = true;
  bool _loadingMore = false;
  bool _connectionError = false;

  static const _categories = ['All', 'City', 'Beach', 'Mountain', 'Historic', 'Nature'];

  static const Map<String, IconData> _categoryIcons = {
    'All': Icons.grid_view_rounded,
    'City': Icons.location_city_rounded,
    'Beach': Icons.beach_access_rounded,
    'Mountain': Icons.terrain_rounded,
    'Historic': Icons.account_balance_rounded,
    'Nature': Icons.eco_rounded,
  };

  @override
  void initState() {
    super.initState();
    _load();
    _scrollCtrl.addListener(_onScroll);
  }

  Future<void> _loadRecommendations() async {
    final recs = await SupabaseDataService().getRecommendations(_all);
    if (mounted) setState(() => _recommendations = recs);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchCtrl.dispose();
    _scrollCtrl.removeListener(_onScroll);
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_query.isNotEmpty || _loadingMore || !_hasMore) return;
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 300) {
      _loadMore();
    }
  }

  Future<void> _load() async {
    setState(() { _loading = true; _connectionError = false; });
    _page = 0;
    _hasMore = true;
    final result = await SupabaseDataService().getDestinationsPage(0, category: _category);
    switch (result) {
      case Ok(value: final list):
        setState(() {
          _all = list;
          _hasMore = list.length == SupabaseDataService.pageSize;
          _applySearch();
          _loading = false;
        });
        _loadRecommendations();
      case Err():
        setState(() { _connectionError = true; _loading = false; });
    }
  }

  Future<void> _loadMore() async {
    setState(() => _loadingMore = true);
    final nextPage = _page + 1;
    final result = await SupabaseDataService().getDestinationsPage(nextPage, category: _category);
    setState(() {
      switch (result) {
        case Ok(value: final list):
          if (list.isEmpty) {
            _hasMore = false;
          } else {
            _page = nextPage;
            _all.addAll(list);
            _hasMore = list.length == SupabaseDataService.pageSize;
            _applySearch();
          }
        case Err():
          _hasMore = false; // stop trying further pages; pull-to-refresh retries
      }
      _loadingMore = false;
    });
  }

  void _applySearch() {
    final low = _query.toLowerCase();
    _filtered = _all.where((d) {
      final matchesQuery = d.name.toLowerCase().contains(low) || d.country.toLowerCase().contains(low);
      return matchesQuery && d.rating >= _minRating;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Filter Destinations', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 20),
          Align(alignment: Alignment.centerLeft,
            child: Text('Minimum Rating: ${_minRating.toStringAsFixed(1)}', style: const TextStyle(fontFamily: 'Nunito'))),
          Slider(value: _minRating, min: 0, max: 5, divisions: 10,
            activeColor: AppColors.primary,
            onChanged: (v) => setSheetState(() => _minRating = v)),
          const SizedBox(height: 12),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () {
              setState(_applySearch);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Apply Filters', style: TextStyle(fontFamily: 'Nunito')))),
        ]),
      )));
  }

  void _onSearch(String q) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _query = q;
        _applySearch();
      });
    });
  }

  void _onCategoryTap(String cat) {
    setState(() => _category = cat);
    _load();
  }

  Future<void> _logout() async {
    await SupabaseService.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  String _greeting(AppLocalizations l10n) {
    final h = DateTime.now().hour;
    if (h < 12) return l10n.goodMorning;
    if (h < 17) return l10n.goodAfternoon;
    return l10n.goodEvening;
  }

  String get _userName {
    final user = SupabaseService.currentUser;
    final name = user?.userMetadata?['full_name'] as String?;
    if (name != null && name.isNotEmpty) return name.split(' ').first;
    final email = user?.email ?? '';
    return email.isNotEmpty ? email.split('@').first : 'Traveler';
  }

  @override
  Widget build(BuildContext context) {
    if (_connectionError && _all.isEmpty) {
      return NoInternetScreen(onRetry: _load);
    }
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const VistaWordmark(),
        actions: [
          _AppBarIconButton(
            icon: Icons.tune,
            tooltip: 'Filters',
            onTap: _showFilterSheet,
          ),
          _AppBarIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onTap: () => showSettingsMenu(context),
          ),
          _AppBarIconButton(
            icon: Icons.logout_rounded,
            tooltip: 'Logout',
            onTap: _logout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _load,
        child: CustomScrollView(controller: _scrollCtrl, slivers: [
          SliverToBoxAdapter(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primaryDark,
                      AppColors.primaryDark.withValues(alpha: 0.88),
                      AppColors.primary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryDark.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Decorative soft glow circles for depth
                    Positioned(
                      top: -40,
                      right: -30,
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.06),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 60,
                      right: 60,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(
                        20,
                        MediaQuery.of(context).padding.top + kToolbarHeight + 4,
                        20,
                        24,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.all(2.5),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.white.withValues(alpha: 0.9),
                                    Colors.white.withValues(alpha: 0.3),
                                  ],
                                ),
                              ),
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.white.withValues(alpha: 0.18),
                                child: Text(
                                  _userName.isNotEmpty ? _userName[0].toUpperCase() : 'V',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_greeting(l10n),
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 12, fontFamily: 'Nunito')),
                                Text(
                                  _userName,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      fontFamily: 'Nunito'),
                                ),
                              ],
                            ),
                          ]),
                          const SizedBox(height: 18),
                          Text(
                            l10n.exploreDestinations,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            l10n.findNextTrip,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Nunito',
                              color: Colors.white.withValues(alpha: 0.75),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(26),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.18),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchCtrl,
                              onChanged: _onSearch,
                              style: const TextStyle(
                                  fontFamily: 'Nunito', fontSize: 14, color: AppColors.charcoal),
                              decoration: InputDecoration(
                                hintText: l10n.searchHint,
                                hintStyle: const TextStyle(
                                    color: AppColors.gray, fontSize: 14, fontFamily: 'Nunito'),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(9),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [AppColors.primary, AppColors.primaryDark],
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.search, color: Colors.white, size: 16),
                                ),
                                suffixIcon: _query.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.clear, color: AppColors.gray, size: 18),
                                  onPressed: () {
                                    _searchCtrl.clear();
                                    _onSearch('');
                                  },
                                )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!_bannerDismissed && SupabaseService.currentUser?.emailConfirmedAt == null)
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.gold.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
                ),
                child: Row(children: [
                  const Icon(Icons.mark_email_unread_outlined, color: AppColors.deepNavy, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('Please verify your email address.',
                      style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.charcoal)),
                  ),
                  TextButton(
                    onPressed: () async {
                      final email = SupabaseService.currentUser?.email;
                      if (email != null) await SupabaseService.resendConfirmationEmail(email);
                      if (mounted) {
                        AppToast.show(context, 'Confirmation email sent!', type: ToastType.success);
                      }
                    },
                    child: const Text('Resend', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18, color: AppColors.gray),
                    onPressed: () => setState(() => _bannerDismissed = true),
                  ),
                ]),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 64,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                itemCount: _categories.length,
                itemBuilder: (ctx, i) {
                  final cat = _categories[i];
                  final selected = cat == _category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: _CategoryPill(
                      label: cat,
                      icon: _categoryIcons[cat] ?? Icons.place_rounded,
                      selected: selected,
                      onTap: () => _onCategoryTap(cat),
                    ),
                  );
                },
              ),
            ),
          ),
          if (_query.isEmpty && _recommendations.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
                child: Row(children: [
                  Container(
                    width: 4,
                    height: 18,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [AppColors.gold, AppColors.gold.withValues(alpha: 0.7)]),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(l10n.recommendedForYou,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, fontFamily: 'Nunito', color: AppColors.charcoal)),
                ]),
              ),
            ),
          if (_query.isEmpty && _recommendations.isNotEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 210,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  itemCount: _recommendations.length,
                  itemBuilder: (ctx, i) {
                    final dest = _recommendations[i];
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: SizedBox(
                        width: 160,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: dest),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: Stack(fit: StackFit.expand, children: [
                              if (dest.imageUrl.isEmpty)
                                Container(color: AppColors.cardTint,
                                  child: const Icon(Icons.image_outlined, color: AppColors.primary))
                              else
                                CachedNetworkImage(imageUrl: dest.imageUrl, fit: BoxFit.cover,
                                  memCacheWidth: 320,
                                  fadeInDuration: const Duration(milliseconds: 150),
                                  placeholder: (_, __) => Container(color: AppColors.cardTint),
                                  errorWidget: (_, __, ___) => Container(color: AppColors.cardTint,
                                    child: const Icon(Icons.image_outlined, color: AppColors.primary))),
                              DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(
                                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                                colors: [Colors.transparent, Colors.black.withValues(alpha: 0.55)]))),
                              Positioned(left: 10, right: 10, bottom: 10,
                                child: Text(dest.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Nunito', fontSize: 14))),
                            ]),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 18,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _query.isEmpty ? l10n.popularDestinations : '${l10n.results} (${_filtered.length})',
                        style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Nunito',
                            color: AppColors.charcoal),
                      ),
                    ],
                  ),
                  if (_query.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_all.length} ${l10n.places}',
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_loading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else if (_filtered.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.08),
                      ),
                      child: Icon(Icons.search_off_rounded, size: 44, color: AppColors.primary.withValues(alpha: 0.5)),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _query.isEmpty ? l10n.noDestinationsFound : l10n.noResultsFor(_query),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, color: AppColors.gray, fontFamily: 'Nunito'),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverLayoutBuilder(
                builder: (ctx, constraints) {
                  // Tablets/landscape get a 2-column grid; phones keep the single list.
                  final isWide = constraints.crossAxisExtent >= 600;
                  if (!isWide) {
                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                            (ctx, i) => DestinationCard(
                          destination: _filtered[i],
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: _filtered[i]),
                        ),
                        childCount: _filtered.length,
                      ),
                    );
                  }
                  return SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 4, childAspectRatio: 0.62),
                    delegate: SliverChildBuilderDelegate(
                          (ctx, i) => DestinationCard(
                        destination: _filtered[i],
                        onTap: () => Navigator.pushNamed(context, '/detail', arguments: _filtered[i]),
                      ),
                      childCount: _filtered.length,
                    ),
                  );
                },
              ),
            ),
          if (_loadingMore)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2)),
              ),
            ),
        ]),
      ),
    );
  }
}

/// Small frosted-style circular icon button for the app bar actions.
class _AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _AppBarIconButton({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: Colors.white.withValues(alpha: 0.12),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Icon(icon, size: 19, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

/// Premium pill-style category selector chip.
class _CategoryPill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _CategoryPill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: selected ? Colors.transparent : AppColors.divider,
            ),
            boxShadow: selected
                ? [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: selected ? Colors.white : AppColors.charcoal),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.charcoal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}