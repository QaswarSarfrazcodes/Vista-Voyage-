// lib/screens/trip_buddies_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/destination_model.dart';
import '../services/supabase_data_service.dart';
import '../services/supabase_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';

/// Route arguments for [TripBuddiesScreen] — destination + the trip's dates
/// (auto-filled from TripDetailScreen; dates may be null if the trip has none).
class TripBuddiesArgs {
  final DestinationModel destination;
  final DateTime? start;
  final DateTime? end;
  const TripBuddiesArgs({required this.destination, this.start, this.end});
}

class TripBuddiesScreen extends StatefulWidget {
  const TripBuddiesScreen({super.key});
  @override
  State<TripBuddiesScreen> createState() => _TripBuddiesScreenState();
}

class _TripBuddiesScreenState extends State<TripBuddiesScreen> {
  Future<List<Map<String, dynamic>>>? _matchesFuture;
  DateTime? _start;
  DateTime? _end;
  final _noteCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  void _load(String destId) {
    // No polling/realtime subscription for MVP — a manual refresh triggers
    // this, the RLS policy itself already keeps the result set small.
    setState(() => _matchesFuture = SupabaseDataService().getBuddyMatches(destId));
  }

  Future<void> _createListing(String destId) async {
    if (_start == null || _end == null) {
      AppToast.show(context, 'Pick your travel dates first.', type: ToastType.info);
      return;
    }
    setState(() => _submitting = true);
    try {
      await SupabaseDataService().createBuddyListing(destId, _start!, _end!, _noteCtrl.text.trim());
      if (mounted) {
        AppToast.show(context, 'Listing created!', type: ToastType.success);
        _load(destId);
      }
    } catch (e) {
      if (mounted) AppToast.show(context, 'Could not create listing: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  Future<void> _pickDateRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
      initialDateRange: (_start != null && _end != null) ? DateTimeRange(start: _start!, end: _end!) : null,
    );
    if (range != null) setState(() { _start = range.start; _end = range.end; });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TripBuddiesArgs;
    _start ??= args.start;
    _end ??= args.end;
    _matchesFuture ??= SupabaseDataService().getBuddyMatches(args.destination.id);
    final myId = SupabaseService.currentUserId;
    final dateFmt = DateFormat('MMM d, yyyy');

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text('Travel Buddies — ${args.destination.name}',
            style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16)),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), tooltip: 'Refresh', onPressed: () => _load(args.destination.id)),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(16)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Create Your Listing', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 15)),
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _pickDateRange(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.divider)),
                  child: Row(children: [
                    const Icon(Icons.date_range, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      _start != null && _end != null
                          ? '${dateFmt.format(_start!)} → ${dateFmt.format(_end!)}'
                          : 'Select travel dates',
                      style: const TextStyle(fontFamily: 'Nunito', fontSize: 13),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _noteCtrl,
                maxLength: 200,
                decoration: const InputDecoration(hintText: 'Note (optional) — e.g. "looking for hiking buddies"', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitting ? null : () => _createListing(args.destination.id),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                  child: _submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Post Listing', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 20),
          const Text('Your Matches', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.charcoal)),
          const SizedBox(height: 4),
          const Text('Only travelers who opted into this destination during an overlapping date range appear here.',
              style: TextStyle(fontFamily: 'Nunito', fontSize: 12, color: AppColors.gray)),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _matchesFuture,
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              final others = snap.data!.where((m) => m['user_id'] != myId).toList();
              if (others.isEmpty) {
                return const Text('No matches yet — post a listing above so other opted-in travelers can find you.',
                    style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray));
              }
              return Column(children: others.map((m) => Container(
                margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.divider)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.person_outline, size: 18, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text('${dateFmt.format(DateTime.parse(m['travel_start']))} → ${dateFmt.format(DateTime.parse(m['travel_end']))}',
                        style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                  if ((m['note'] as String? ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(m['note'], style: const TextStyle(fontFamily: 'Nunito', fontSize: 13)),
                  ],
                ]))).toList());
            },
          ),
        ],
      ),
    );
  }
}
