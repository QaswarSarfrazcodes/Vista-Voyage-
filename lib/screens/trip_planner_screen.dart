// lib/screens/trip_planner_screen.dart
import 'package:flutter/material.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});
  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  List<Map<String, dynamic>> _trips = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final trips = await SupabaseDataService().getUserTrips();
    if (mounted) setState(() { _trips = trips; _loading = false; });
  }

  Future<void> _scanQr() async {
    final imported = await Navigator.pushNamed(context, '/qr-scan');
    if (imported == true) _load();
  }

  Future<void> _confirmDelete(Map<String, dynamic> trip) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete trip?', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700)),
        content: Text('Delete "${trip['title']}" and all its saved destinations?', style: const TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray))),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(fontFamily: 'Nunito', color: AppColors.error, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (confirmed == true) {
      await SupabaseDataService().deleteTrip(trip['id']);
      _load();
    }
  }

  Future<void> _createTrip() async {
    final titleCtrl = TextEditingController();
    await showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('New Trip', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      content: TextField(controller: titleCtrl, maxLength: 60,
        decoration: const InputDecoration(hintText: 'e.g. Summer Pakistan Tour', border: OutlineInputBorder())),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
        ElevatedButton(onPressed: () async {
          if (titleCtrl.text.trim().isEmpty) return;
          await SupabaseDataService().createTrip(titleCtrl.text.trim(), null, null);
          if (ctx.mounted) Navigator.pop(ctx);
          _load();
        }, child: const Text('Create')),
      ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, elevation: 0,
        title: const Text('My Trips', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(icon: const Icon(Icons.qr_code_scanner_rounded), tooltip: 'Scan Trip QR Code', onPressed: _scanQr),
        ]),
      floatingActionButton: FloatingActionButton(onPressed: _createTrip,
        backgroundColor: AppColors.primary, child: const Icon(Icons.add)),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : _trips.isEmpty
          ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.card_travel, size: 80, color: Colors.grey[300]),
              const SizedBox(height: 16),
              const Text('No trips planned yet.\nTap + to create your first trip!',
                textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray)),
            ]))
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _load,
              child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: _trips.length,
                itemBuilder: (ctx, i) {
                  final trip = _trips[i];
                  return Card(margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: ListTile(
                      leading: const Icon(Icons.flight_takeoff, color: AppColors.primary),
                      title: Text(trip['title'], style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                      subtitle: Text('Created ${trip['created_at'].toString().split('T').first}',
                        style: const TextStyle(fontFamily: 'Nunito', fontSize: 12)),
                      trailing: IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.coral),
                        onPressed: () => _confirmDelete(trip)),
                      onTap: () => Navigator.pushNamed(context, '/trip-detail', arguments: trip),
                    ));
                }),
            ),
    );
  }
}
