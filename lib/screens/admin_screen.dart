// lib/screens/admin_screen.dart
import 'package:flutter/material.dart';
import '../models/destination_model.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';
import '../utils/app_toast.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _idCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();
  final _countryCtrl = TextEditingController();
  final _imageCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _ratingCtrl = TextEditingController(text: '4.5');
  bool _saving = false;
  Future<List<Map<String, dynamic>>>? _pendingGemsFuture;

  void _reloadPendingGems() {
    setState(() => _pendingGemsFuture = SupabaseDataService().getPendingHiddenGems());
  }

  Future<void> _reviewGem(String gemId, bool approve) async {
    if (approve) {
      await SupabaseDataService().approveHiddenGem(gemId);
    } else {
      await SupabaseDataService().rejectHiddenGem(gemId);
    }
    if (mounted) {
      AppToast.show(context, approve ? 'Gem approved' : 'Gem rejected', type: ToastType.success);
      _reloadPendingGems();
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final dest = DestinationModel(
      id: _idCtrl.text.trim().toLowerCase().replaceAll(' ', '_'),
      name: _nameCtrl.text.trim(),
      country: _countryCtrl.text.trim(),
      imageUrl: _imageCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      rating: double.tryParse(_ratingCtrl.text) ?? 4.5,
    );
    try {
      await SupabaseDataService().adminAddDestination(dest);
      if (mounted) {
        AppToast.show(context, 'Destination added!', type: ToastType.success);
        _formKey.currentState!.reset();
      }
    } catch (e) {
      if (mounted) AppToast.show(context, 'Error: $e', type: ToastType.error);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildPendingGemsSection() {
    // Reuses the same isCurrentUserAdmin() gate as SettingsMenu's Admin Panel
    // tile — a defense-in-depth UI gate on top of the server-side RLS policy,
    // and only queried here (not eagerly elsewhere) since this whole screen
    // is the admin surface.
    return FutureBuilder<bool>(
      future: SupabaseDataService().isCurrentUserAdmin(),
      builder: (ctx, adminSnap) {
        if (adminSnap.data != true) return const SizedBox.shrink();
        _pendingGemsFuture ??= SupabaseDataService().getPendingHiddenGems();
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Divider(height: 40),
          const Text('Pending Hidden Gems', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 12),
          FutureBuilder<List<Map<String, dynamic>>>(
            future: _pendingGemsFuture,
            builder: (ctx, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.primary));
              final gems = snap.data!;
              if (gems.isEmpty) {
                return const Text('No pending submissions.', style: TextStyle(fontFamily: 'Nunito', color: AppColors.gray));
              }
              return Column(children: gems.map((g) => Container(
                margin: const EdgeInsets.only(bottom: 10), padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.cardTint, borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(g['name'] as String? ?? '', style: const TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(g['description'] as String? ?? '', style: const TextStyle(fontFamily: 'Nunito', fontSize: 13)),
                  const SizedBox(height: 8),
                  Row(children: [
                    TextButton(onPressed: () => _reviewGem(g['id'] as String, true), child: const Text('Approve')),
                    TextButton(onPressed: () => _reviewGem(g['id'] as String, false), child: const Text('Reject')),
                  ]),
                ]))).toList());
            },
          ),
        ]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white,
        title: const Text('Admin — Add Destination', style: TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.bold))),
      body: Padding(padding: const EdgeInsets.all(20), child: Form(key: _formKey, child: ListView(children: [
        TextFormField(controller: _idCtrl, decoration: const InputDecoration(labelText: 'ID (e.g. quetta)'),
          validator: (v) => v!.isEmpty ? 'Required' : null),
        TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name'),
          validator: (v) => v!.isEmpty ? 'Required' : null),
        TextFormField(controller: _countryCtrl, decoration: const InputDecoration(labelText: 'Country'),
          validator: (v) => v!.isEmpty ? 'Required' : null),
        TextFormField(controller: _imageCtrl, decoration: const InputDecoration(labelText: 'Image URL'),
          validator: (v) => v!.isEmpty ? 'Required' : null),
        TextFormField(controller: _descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Description'),
          validator: (v) => v!.isEmpty ? 'Required' : null),
        TextFormField(controller: _ratingCtrl, decoration: const InputDecoration(labelText: 'Rating (1-5)')),
        const SizedBox(height: 20),
        ElevatedButton(onPressed: _saving ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
          child: _saving ? const CircularProgressIndicator(color: Colors.white) : const Text('Add Destination')),
        _buildPendingGemsSection(),
      ]))),
    );
  }
}
