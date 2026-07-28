// lib/screens/trip_blueprint_screen.dart
import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';

/// Route arguments for [TripBlueprintScreen].
class TripBlueprintArgs {
  final List<DestinationModel> destinations;
  final Map<String, dynamic> blueprint;
  const TripBlueprintArgs({required this.destinations, required this.blueprint});
}

class TripBlueprintScreen extends StatefulWidget {
  const TripBlueprintScreen({super.key});
  @override
  State<TripBlueprintScreen> createState() => _TripBlueprintScreenState();
}

class _TripBlueprintScreenState extends State<TripBlueprintScreen> {
  bool _saving = false;

  Future<void> _saveToMyTrips(TripBlueprintArgs args) async {
    setState(() => _saving = true);
    try {
      final title = args.destinations.map((d) => d.name).join(' + ');
      final tripId = await SupabaseDataService().createTrip(
        title.isEmpty ? 'AI Trip Blueprint' : title,
        null,
        null,
      );
      for (var i = 0; i < args.destinations.length; i++) {
        await SupabaseDataService().addTripItem(tripId, args.destinations[i], i);
      }
      if (mounted) {
        AppToast.show(context, 'Saved to My Trips!', type: ToastType.success);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) AppToast.show(context, 'Could not save trip: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TripBlueprintArgs;
    final days = (args.blueprint['days'] as List?) ?? const [];

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('AI Trip Blueprint',
            style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
      ),
      body: days.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  "Couldn't generate a blueprint. Please go back and try again.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: days.length,
              itemBuilder: (ctx, i) {
                final day = Map<String, dynamic>.from(days[i] as Map);
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: ExpansionTile(
                    title: Text(
                      'Day ${day['day'] ?? i + 1}: ${day['title'] ?? ''}',
                      style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold),
                    ),
                    childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    children: [
                      if ((day['morning'] as String?)?.isNotEmpty == true)
                        _BlueprintRow(icon: Icons.wb_sunny_outlined, label: 'Morning', value: day['morning']),
                      if ((day['afternoon'] as String?)?.isNotEmpty == true)
                        _BlueprintRow(icon: Icons.wb_cloudy_outlined, label: 'Afternoon', value: day['afternoon']),
                      if ((day['evening'] as String?)?.isNotEmpty == true)
                        _BlueprintRow(icon: Icons.nightlight_outlined, label: 'Evening', value: day['evening']),
                      if ((day['estimatedCost'] as String?)?.isNotEmpty == true)
                        _BlueprintRow(icon: Icons.account_balance_wallet_outlined, label: 'Est. Cost', value: day['estimatedCost']),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: days.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    icon: _saving
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.bookmark_add_outlined),
                    label: Text(_saving ? 'Saving…' : 'Save to My Trips',
                        style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                    onPressed: _saving ? null : () => _saveToMyTrips(args),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}

class _BlueprintRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _BlueprintRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.charcoal, height: 1.4),
                children: [
                  TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ]),
      );
}
