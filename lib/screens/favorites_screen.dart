// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';
import '../widgets/destination_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<DestinationModel> _favorites = [];
  bool _loading = true;
  bool _dismissedBanner = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await SupabaseDataService().getUserFavorites();
    setState(() { _favorites = result; _loading = false; });
  }

  List<String> _checkBestTimeAlerts(List<DestinationModel> favorites) {
    final now = DateTime.now();
    final months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final currentMonth = months[now.month - 1];
    final alerts = <String>[];
    for (final dest in favorites) {
      if (dest.bestTime.isNotEmpty &&
          dest.bestTime.toLowerCase().contains(currentMonth.toLowerCase())) {
        alerts.add('${dest.name} ($currentMonth)');
      }
    }
    return alerts;
  }

  Future<void> _remove(DestinationModel dest) async {
    await SupabaseDataService().removeFavorite(dest.id);
    setState(() => _favorites.removeWhere((d) => d.id == dest.id));
    if (mounted) {
      AppToast.show(context, '${dest.name} removed from favorites',
        action: SnackBarAction(label: 'Undo', onPressed: () async {
          await SupabaseDataService().addFavorite(dest);
          _load();
        }));
    }
  }

  Future<bool> _confirmRemove(DestinationModel dest) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Remove favorite?', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
        content: Text('Remove "${dest.name}" from your favorites?', style: const TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Remove', style: TextStyle(fontFamily: 'Nunito', color: AppColors.error, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final alerts = _checkBestTimeAlerts(_favorites);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
          backgroundColor: AppColors.primaryDark,
          foregroundColor: Colors.white, elevation: 0,
          title: const Text('My Favorites', style: TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20)),
          actions: [
            if (_favorites.isNotEmpty)
              Center(child: Padding(padding: const EdgeInsets.only(right: 16),
                  child: Text('${_favorites.length} saved', style: const TextStyle(
                      fontFamily: 'Nunito', fontSize: 13, color: Colors.white70))))
          ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _favorites.isEmpty
          ? RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView(children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Image.asset('assets/images/empty_favorites.png', width: 180, height: 180,
                        errorBuilder: (_, __, ___) => const Icon(Icons.favorite_border,
                            size: 100, color: AppColors.cardTint)),
                    const SizedBox(height: 20),
                    const Text('No favorites yet', style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito', color: AppColors.charcoal)),
                    const SizedBox(height: 8),
                    const Text('Tap the heart on any destination\nto save it here.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: AppColors.gray,
                            fontFamily: 'Nunito', height: 1.5)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                        icon: const Icon(Icons.explore_outlined, size: 18),
                        label: const Text('Go Explore!', style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
                        onPressed: () {
                          if (Navigator.canPop(context)) Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)))),
                  ])),
                ),
              ]),
            )
          : RefreshIndicator(
          color: AppColors.primary,
          onRefresh: _load,
          child: Column(
            children: [
              if (!_dismissedBanner && alerts.isNotEmpty)
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gold, Color(0xFFFF8C00)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(color: AppColors.gold.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.wb_sunny_rounded, color: Colors.white, size: 22),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '☀️ ${alerts.length} of your favorites in season now: ${alerts.join(", ")}',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _dismissedBanner = true),
                        child: const Icon(Icons.close, color: Colors.white, size: 18),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: _favorites.length,
                    itemBuilder: (ctx, i) {
                      final dest = _favorites[i];
                      return Dismissible(
                          key: Key(dest.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (_) => _confirmRemove(dest),
                          background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(right: 24),
                              margin: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                  color: AppColors.error,
                                  borderRadius: BorderRadius.circular(16)),
                              child: const Icon(Icons.delete_outline,
                                  color: Colors.white, size: 28)),
                          onDismissed: (_) => _remove(dest),
                          child: DestinationCard(
                              destination: dest,
                              onTap: () => Navigator.pushNamed(context, '/detail',
                                  arguments: dest)));
                    }),
              ),
            ],
          )),
    );
  }
}
