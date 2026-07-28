// lib/screens/trip_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../models/destination_model.dart';
import '../services/ai_service.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';
import '../widgets/destination_card.dart';
import 'trip_blueprint_screen.dart';
import 'trip_buddies_screen.dart';
import 'trip_journal_screen.dart';

class TripDetailScreen extends StatefulWidget {
  const TripDetailScreen({super.key});
  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

const _expenseCategories = ['Food', 'Transport', 'Lodging', 'Activities', 'Other'];

class _TripDetailScreenState extends State<TripDetailScreen> {
  List<DestinationModel> _items = [];
  bool _loading = true;
  bool _generatingBlueprint = false;

  List<Map<String, dynamic>> _expenses = [];
  double _expenseTotal = 0.0;
  bool _expensesLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    final trip = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final items = await SupabaseDataService().getTripItems(trip['id']);
    if (mounted) setState(() { _items = items; _loading = false; });
    _loadExpenses(trip['id']); // sequenced after items, not concurrent
  }

  // Sums client-side from the already-fetched list instead of also calling
  // getTripExpenseTotal() (which would re-query trip_expenses a second time
  // for the same trip_id — the exact redundant-query pattern V7 fixed on Home).
  Future<void> _loadExpenses(String tripId) async {
    final expenses = await SupabaseDataService().getTripExpenses(tripId);
    if (mounted) {
      setState(() {
        _expenses = expenses;
        _expenseTotal = expenses.fold<double>(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
        _expensesLoading = false;
      });
    }
  }

  /// Rough numeric benchmark parsed from the destination's `avgBudget` text
  /// (e.g. "$500-800" -> 650). Returns null if no digits are found.
  double? _budgetBenchmark() {
    if (_items.isEmpty) return null;
    final matches = RegExp(r'\d+').allMatches(_items.first.avgBudget).map((m) => double.parse(m.group(0)!)).toList();
    if (matches.isEmpty) return null;
    return matches.reduce((a, b) => a + b) / matches.length;
  }

  void _showAddExpenseDialog(BuildContext context, String tripId) {
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    String category = _expenseCategories.first;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Expense', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            DropdownButtonFormField<String>(
              initialValue: category,
              decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder()),
              items: _expenseCategories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
              onChanged: (v) => setDialogState(() => category = v ?? category),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: descCtrl,
              decoration: const InputDecoration(labelText: 'Description (optional)', border: OutlineInputBorder()),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text);
                if (amount == null || amount <= 0) return;
                try {
                  await SupabaseDataService().addExpense(tripId, category, amount, descCtrl.text.trim());
                  if (ctx.mounted) Navigator.pop(ctx);
                  _loadExpenses(tripId);
                } catch (e) {
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (mounted) AppToast.show(context, 'Could not add expense. Please try again.', type: ToastType.error);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesSection(String tripId) {
    final benchmark = _budgetBenchmark();
    final progress = benchmark != null && benchmark > 0 ? (_expenseTotal / benchmark).clamp(0.0, 1.0) : null;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Expenses', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.charcoal)),
          const Spacer(),
          TextButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add', style: TextStyle(fontFamily: 'Nunito')),
            onPressed: () => _showAddExpenseDialog(context, tripId),
          ),
        ]),
        if (_expensesLoading)
          const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: LinearProgressIndicator())
        else ...[
          Text('Total spent: \$${_expenseTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.primary)),
          if (progress != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: AppColors.cardTint,
                color: progress >= 1.0 ? AppColors.error : AppColors.gold,
              ),
            ),
            const SizedBox(height: 4),
            Text('vs. avg budget benchmark (~\$${benchmark!.toStringAsFixed(0)})',
                style: const TextStyle(fontFamily: 'Nunito', fontSize: 11, color: AppColors.gray)),
          ],
          if (_expenses.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._expenses.map((e) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(children: [
                    Expanded(
                      child: Text('${e['category']}${(e['description'] as String? ?? '').isNotEmpty ? ' — ${e['description']}' : ''}',
                          style: const TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.charcoal)),
                    ),
                    Text('\$${(e['amount'] as num).toDouble().toStringAsFixed(2)}',
                        style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w600, fontSize: 13)),
                  ]),
                )),
          ],
        ],
      ]),
    );
  }

  void _showBlueprintDialog(BuildContext context) {
    if (_items.isEmpty) {
      AppToast.show(context, 'Add some destinations to this trip first.', type: ToastType.info);
      return;
    }
    final daysCtrl = TextEditingController(text: '3');
    String travelStyle = 'budget';
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('AI Trip Blueprint', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
              controller: daysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of days', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: travelStyle,
              decoration: const InputDecoration(labelText: 'Travel style', border: OutlineInputBorder()),
              items: const ['budget', 'luxury', 'family', 'adventure']
                  .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                  .toList(),
              onChanged: (v) => setDialogState(() => travelStyle = v ?? travelStyle),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () {
                final days = int.tryParse(daysCtrl.text) ?? 3;
                Navigator.pop(ctx);
                _generateBlueprint(days, travelStyle);
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }

  // Only fires on this explicit button tap (never in initState) — a single
  // on-demand network call, so it adds zero cost to this screen's normal load.
  Future<void> _generateBlueprint(int days, String travelStyle) async {
    setState(() => _generatingBlueprint = true);
    try {
      final blueprint = await AiService().generateTripBlueprint(
        destinations: _items,
        days: days,
        travelStyle: travelStyle,
      );
      if (!mounted) return;
      if (blueprint == null) {
        AppToast.show(context, "Couldn't generate a blueprint, try again.", type: ToastType.error);
        return;
      }
      Navigator.pushNamed(
        context,
        '/trip-blueprint',
        arguments: TripBlueprintArgs(destinations: _items, blueprint: blueprint),
      );
    } finally {
      if (mounted) setState(() => _generatingBlueprint = false);
    }
  }

  void _showQrCode(BuildContext context, Map<String, dynamic> trip) {
    showModalBottomSheet(context: context, isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Share "${trip['title']}"', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 18)),
          const SizedBox(height: 8),
          const Text('Have a friend scan this to import your trip.',
            style: TextStyle(fontFamily: 'Nunito', fontSize: 13, color: AppColors.gray)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.divider)),
            child: QrImageView(
              data: 'tripline://trip/${trip['id']}',
              size: 220,
              backgroundColor: Colors.white,
              foregroundColor: AppColors.deepNavy,
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final trip = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, elevation: 0,
        title: Text(trip['title'], style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          IconButton(
            icon: _generatingBlueprint
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.auto_awesome_rounded),
            tooltip: 'AI Trip Blueprint',
            onPressed: _generatingBlueprint ? null : () => _showBlueprintDialog(context),
          ),
          IconButton(icon: const Icon(Icons.qr_code_rounded), tooltip: 'Share via QR',
            onPressed: () => _showQrCode(context, trip)),
        ]),
      body: _loading
        ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
        : ListView(
            padding: const EdgeInsets.only(bottom: 16),
            children: [
              _buildExpensesSection(trip['id']),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.menu_book, size: 18),
                        label: const Text('Trip Journal', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TripJournalScreen(
                              tripId: trip['id'] as String,
                              tripTitle: trip['title'] as String? ?? 'Trip',
                            ),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.verified, size: 18, color: AppColors.gold),
                        label: const Text('Complete (+50 pts)', style: TextStyle(fontFamily: 'Nunito', fontSize: 12)),
                        onPressed: () async {
                          await SupabaseDataService().awardPoints(50);
                          if (context.mounted) {
                            AppToast.show(context, 'Trip Completed! +50 Points awarded!', type: ToastType.success);
                          }
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.gold, width: 1.5),
                          minimumSize: const Size.fromHeight(44),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (_items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.groups_outlined, size: 18),
                    label: const Text('Find Travel Buddies for this Trip', style: TextStyle(fontFamily: 'Nunito')),
                    onPressed: () => Navigator.pushNamed(context, '/trip-buddies', arguments: TripBuddiesArgs(
                      destination: _items.first,
                      start: trip['start_date'] != null ? DateTime.tryParse(trip['start_date']) : null,
                      end: trip['end_date'] != null ? DateTime.tryParse(trip['end_date']) : null,
                    )),
                    style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.primary), minimumSize: const Size.fromHeight(44)),
                  ),
                ),
              const SizedBox(height: 8),
              if (_items.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.card_travel, size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('No destinations in this trip yet.\nAdd some from a destination\'s detail page!',
                      textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray)),
                  ]),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: _items.map((item) => DestinationCard(
                      destination: item,
                      onTap: () => Navigator.pushNamed(context, '/detail', arguments: item),
                    )).toList(),
                  ),
                ),
            ],
          ),
    );
  }
}
