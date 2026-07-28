// lib/screens/map_screen_tab.dart
import 'package:flutter/material.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import 'map_screen.dart';

/// Persistent Map tab inside MainShell — fetches destinations itself
/// instead of requiring route arguments.
class MapScreenTab extends StatelessWidget {
  const MapScreenTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryDark,
      body: FutureBuilder(
        future: SupabaseDataService().getDestinations(),
        builder: (ctx, snap) => snap.hasData
            ? MapScreenBody(destinations: snap.data!, showBackButton: false)
            : const Center(child: CircularProgressIndicator(color: AppColors.gold)),
      ),
    );
  }
}
