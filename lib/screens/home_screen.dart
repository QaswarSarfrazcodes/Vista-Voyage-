// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/supabase_service.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../widgets/destination_card.dart';
import 'settings_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DestinationModel> _all = [];
  List<DestinationModel> _filtered = [];
  bool _loading = true;
  String _query = '';
  String _category = 'All';
  final _searchCtrl = TextEditingController();

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
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await SupabaseDataService().getDestinationsByCategory(_category);
    setState(() {
      _all = result;
      _applySearch();
      _loading = false;
    });
  }

  void _applySearch() {
    final low = _query.toLowerCase();
    _filtered = _all.where((d) {
      return d.name.toLowerCase().contains(low) || d.country.toLowerCase().contains(low);
    }).toList();
  }

  void _onSearch(String q) {
    setState(() {
      _query = q;
      _applySearch();
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

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
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
    return Scaffold(
      backgroundColor: AppColors.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'VistaVoyage ✈',
          style: TextStyle(
            fontFamily: 'PlayfairDisplay',
            fontWeight: FontWeight.bold,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          _AppBarIconButton(
            icon: Icons.map_outlined,
            tooltip: 'Map',
            onTap: () => Navigator.pushNamed(context, '/map', arguments: _all),
          ),
          _AppBarIconButton(
            icon: Icons.settings_outlined,
            tooltip: 'Settings',
            onTap: () => showSettingsMenu(context),
          ),
          _AppBarIconButton(
            icon: Icons.favorite_border_rounded,
            tooltip: 'Favorites',
            onTap: () => Navigator.pushNamed(context, '/favorites'),
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
        child: CustomScrollView(slivers: [
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
                                Text(_greeting,
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
                          const Text(
                            'Explore Destinations!',
                            style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              letterSpacing: 0.1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find your next unforgettable trip',
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
                                hintText: 'Search destinations or countries…',
                                hintStyle: const TextStyle(
                                    color: AppColors.gray, fontSize: 14, fontFamily: 'Nunito'),
                                prefixIcon: Container(
                                  margin: const EdgeInsets.all(9),
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
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
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
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
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.primaryDark],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _query.isEmpty ? 'Popular Destinations' : 'Results (${_filtered.length})',
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
                        '${_all.length} places',
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
                      _query.isEmpty ? 'No destinations found.\nPull to refresh.' : 'No results for "$_query"',
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
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (ctx, i) => DestinationCard(
                    destination: _filtered[i],
                    onTap: () => Navigator.pushNamed(context, '/detail', arguments: _filtered[i]),
                  ),
                  childCount: _filtered.length,
                ),
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
                ? LinearGradient(colors: [AppColors.primary, AppColors.primaryDark])
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