// lib/services/supabase_data_service.dart
// V2: destinations now live in Supabase — app is lightweight, no hardcoded data.

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination_model.dart';
import 'supabase_service.dart';

class SupabaseDataService {
  static SupabaseClient get _db => SupabaseService.client;
  static String get _uid => SupabaseService.currentUserId!;

  static final List<DestinationModel> _emergencyFallback = [
    const DestinationModel(
      id: 'islamabad',
      name: 'Islamabad',
      country: 'Pakistan',
      city: 'Islamabad',
      category: 'City',
      imageUrl: 'https://images.unsplash.com/photo-1626621341169-a0e77534ee59?w=800',
      description: "Pakistan's green, planned capital at the foot of the Margalla Hills.",
      rating: 4.6,
      tags: ['Capital', 'Nature'],
    ),
    const DestinationModel(
      id: 'paris',
      name: 'Paris',
      country: 'France',
      city: 'Paris',
      category: 'City',
      imageUrl: 'https://images.unsplash.com/photo-1502602898657-3e91760cbb34?w=800',
      description: 'The City of Light — Eiffel Tower, cuisine, and art.',
      rating: 4.9,
      tags: ['Romance', 'Art'],
    ),
  ];

  Future<List<DestinationModel>> getDestinations() async {
    try {
      final data = await _db
          .from('destinations')
          .select()
          .order('rating', ascending: false)
          .timeout(const Duration(seconds: 10));
      if (data.isEmpty) return _emergencyFallback;
      return data.map((d) => DestinationModel.fromMap(d)).toList();
    } catch (_) {
      return _emergencyFallback;
    }
  }

  Future<List<DestinationModel>> getDestinationsByCategory(String category) async {
    if (category == 'All') return getDestinations();
    try {
      final data = await _db
          .from('destinations')
          .select()
          .eq('category', category)
          .order('rating', ascending: false);
      return data.map((d) => DestinationModel.fromMap(d)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> addFavorite(DestinationModel dest) async {
    await _db.from('favorites').upsert({
      'user_id': _uid,
      'dest_id': dest.id,
      'dest_data': dest.toMap(),
    });
  }

  Future<void> removeFavorite(String destId) async {
    await _db.from('favorites').delete().eq('user_id', _uid).eq('dest_id', destId);
  }

  Future<List<DestinationModel>> getUserFavorites() async {
    try {
      final data = await _db.from('favorites').select('dest_data').eq('user_id', _uid);
      return data
          .map((row) => DestinationModel.fromMap(Map<String, dynamic>.from(row['dest_data'])))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> isFavorited(String destId) async {
    try {
      final data = await _db.from('favorites').select('dest_id').eq('user_id', _uid).eq('dest_id', destId);
      return data.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final data = await _db.from('profiles').select().eq('id', _uid).maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  Future<void> upsertProfile({required String fullName, String? bio, String? avatarUrl}) async {
    await _db.from('profiles').upsert({
      'id': _uid,
      'full_name': fullName,
      'bio': bio ?? '',
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }
}