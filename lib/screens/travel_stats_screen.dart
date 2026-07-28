import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';

String travelPersonalityFromTag(String? topTag) {
  const personalities = {
    'Mountains': '🏔️ Mountain Explorer',
    'Beach': '🏖️ Beach Wanderer',
    'History': '🏛️ History Buff',
    'Adventure': '⚡ Adventure Seeker',
    'Food': '🍜 Culinary Traveler',
    'Culture': '🎭 Culture Enthusiast',
    'Nature': '🌿 Nature Lover',
    'Luxury': '✨ Luxury Traveler',
    'Capital': '🏛️ Capital Explorer',
    'City': '🏙️ Urban Explorer',
  };
  return personalities[topTag] ?? '🧭 Curious Wanderer';
}

class TravelStatsScreen extends StatefulWidget {
  const TravelStatsScreen({super.key});

  @override
  State<TravelStatsScreen> createState() => _TravelStatsScreenState();
}

class _TravelStatsScreenState extends State<TravelStatsScreen> {
  final SupabaseDataService _dataService = SupabaseDataService();
  bool _loading = true;
  Map<String, dynamic>? _stats;

  // Capital/major markers map
  static const Map<String, LatLng> _countryCapitals = {
    'Pakistan': LatLng(33.6844, 73.0479),
    'France': LatLng(48.8566, 2.3522),
    'Japan': LatLng(35.6762, 139.6503),
    'UAE': LatLng(25.2048, 55.2708),
    'United States': LatLng(40.7128, -74.0060),
    'Italy': LatLng(41.9028, 12.4964),
    'Maldives': LatLng(4.1755, 73.5093),
    'South Africa': LatLng(-33.9249, 18.4241),
    'Turkey': LatLng(41.0082, 28.9784),
    'Indonesia': LatLng(-8.4095, 115.1889),
  };

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    final stats = await _dataService.getTravelStats();
    if (mounted) {
      setState(() {
        _stats = stats;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Travel Stats & Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final countriesCount = _stats?['countriesCount'] as int? ?? 0;
    final tripsCount = _stats?['tripsCount'] as int? ?? 0;
    final favoritesCount = _stats?['favoritesCount'] as int? ?? 0;
    final countries = (_stats?['countries'] as List?)?.cast<String>() ?? [];
    final topTag = _stats?['topTag'] as String?;
    final personality = travelPersonalityFromTag(topTag);

    // Build markers for visited countries
    final markers = <Marker>[];
    for (final country in countries) {
      if (_countryCapitals.containsKey(country)) {
        markers.add(
          Marker(
            point: _countryCapitals[country]!,
            width: 40,
            height: 40,
            child: const Icon(
              Icons.location_on,
              color: AppColors.gold,
              size: 36,
            ),
          ),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Travel Stats & Profile',
          style: TextStyle(fontFamily: 'PlayfairDisplay', color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Hero Personality Badge
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepNavy, Color(0xFF1E3A5F)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'YOUR TRAVEL PERSONALITY',
                    style: TextStyle(
                      color: AppColors.gold,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    personality,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'PlayfairDisplay',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    topTag != null
                        ? 'Based on your preference for $topTag destinations'
                        : 'Explore and favorite destinations to discover your style!',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Stat Cards Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Countries', '$countriesCount', Icons.public, Colors.blue),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Trips', '$tripsCount', Icons.flight_takeoff, Colors.orange),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard('Saved', '$favoritesCount', Icons.favorite, Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // World Map of Destinations
            const Text(
              'Your Visited Map',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                fontFamily: 'PlayfairDisplay',
                color: AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 240,
                child: FlutterMap(
                  options: const MapOptions(
                    initialCenter: LatLng(25.0, 10.0),
                    initialZoom: 1.5,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.tripline.app',
                    ),
                    MarkerLayer(markers: markers),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.deepNavy),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
