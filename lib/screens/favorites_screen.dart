// lib/screens/favorites_screen.dart
import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/supabase_data_service.dart';
import '../widgets/destination_card.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});
  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<DestinationModel> _favorites = [];
  bool _loading = true;

  static const _blue     = Color(0xFF3B82F6);
  static const _gray     = Color(0xFF9E9E9E);
  static const _charcoal = Color(0xFF2D2D2D);

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    final result = await SupabaseDataService().getUserFavorites();
    setState(() { _favorites = result; _loading = false; });
  }

  Future<void> _remove(DestinationModel dest) async {
    await SupabaseDataService().removeFavorite(dest.id);
    setState(() => _favorites.removeWhere((d) => d.id == dest.id));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${dest.name} removed from favorites',
              style: const TextStyle(fontFamily: 'Nunito')),
          action: SnackBarAction(label: 'Undo', onPressed: () async {
            await SupabaseDataService().addFavorite(dest);
            _load();
          }),
          duration: const Duration(seconds: 3)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
          backgroundColor: const Color(0xFF2563EB),
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
          ? const Center(child: CircularProgressIndicator(color: _blue))
          : _favorites.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Image.asset('assets/images/empty_favorites.png', width: 180, height: 180,
            errorBuilder: (_, __, ___) => const Icon(Icons.favorite_border,
                size: 100, color: Color(0xFFDBEAFE))),
        const SizedBox(height: 20),
        const Text('No favorites yet', style: TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold,
            fontFamily: 'Nunito', color: _charcoal)),
        const SizedBox(height: 8),
        const Text('Tap the heart on any destination\nto save it here.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: _gray,
                fontFamily: 'Nunito', height: 1.5)),
        const SizedBox(height: 24),
        ElevatedButton.icon(
            icon: const Icon(Icons.explore_outlined, size: 18),
            label: const Text('Go Explore!', style: TextStyle(
                fontSize: 15, fontWeight: FontWeight.bold, fontFamily: 'Nunito')),
            onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            style: ElevatedButton.styleFrom(
                backgroundColor: _blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)))),
      ]))
          : RefreshIndicator(
          color: _blue,
          onRefresh: _load,
          child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: _favorites.length,
              itemBuilder: (ctx, i) {
                final dest = _favorites[i];
                return Dismissible(
                    key: Key(dest.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 24),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete_outline,
                            color: Colors.white, size: 28)),
                    onDismissed: (_) => _remove(dest),
                    child: DestinationCard(
                        destination: dest,
                        onTap: () => Navigator.pushNamed(context, '/detail',
                            arguments: dest)));
              })),
    );
  }
}