// lib/services/supabase_data_service.dart
// V2: destinations now live in Supabase — app is lightweight, no hardcoded data.

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/destination_model.dart';
import '../models/review_model.dart';
import '../utils/result.dart';
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

  // Lightweight column set for list/map views — excludes the heavier
  // description/highlights/best_time/avg_budget fields only needed on Detail.
  static const _listColumns = 'id,name,country,city,category,image_url,rating,tags,latitude,longitude';

  Future<List<DestinationModel>> getDestinations() async {
    try {
      final data = await _db
          .from('destinations')
          .select(_listColumns)
          .order('rating', ascending: false)
          .timeout(const Duration(seconds: 10));
      final list = (data as List).map((d) => DestinationModel.fromMap(d as Map<String, dynamic>)).toList();
      if (list.isNotEmpty) {
        _cacheDestinations(list); // fire-and-forget cache write
        return list;
      }
      return await _getCachedDestinations();
    } catch (_) {
      return await _getCachedDestinations();
    }
  }

  Future<void> _cacheDestinations(List<DestinationModel> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = list.map((d) => d.toMap()).toList();
    await prefs.setString('cached_destinations', jsonEncode(jsonList));
  }

  Future<List<DestinationModel>> _getCachedDestinations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_destinations');
      if (raw == null) return _emergencyFallback;
      final jsonList = jsonDecode(raw) as List;
      return jsonList.map((m) => DestinationModel.fromMap(Map<String, dynamic>.from(m))).toList();
    } catch (_) {
      return _emergencyFallback;
    }
  }

  Future<List<DestinationModel>> getDestinationsByCategory(String category) async {
    if (category == 'All') return getDestinations();
    try {
      final data = await _db
          .from('destinations')
          .select(_listColumns)
          .eq('category', category)
          .order('rating', ascending: false);
      return data.map((d) => DestinationModel.fromMap(d)).toList();
    } catch (_) {
      return [];
    }
  }

  static const pageSize = 10;

  /// Paginated fetch for Home's infinite scroll — [page] is 0-indexed.
  /// Returns a [Result] so callers can tell "request failed" (show a retry
  /// screen) apart from "this page/category genuinely has no more rows".
  Future<Result<List<DestinationModel>>> getDestinationsPage(int page, {String category = 'All'}) async {
    try {
      final from = page * pageSize;
      final to = from + pageSize - 1;
      final builder = category == 'All'
          ? _db.from('destinations').select(_listColumns)
          : _db.from('destinations').select(_listColumns).eq('category', category);
      final data = await builder.order('rating', ascending: false).range(from, to)
          .timeout(const Duration(seconds: 10));
      final list = (data as List).map((d) => DestinationModel.fromMap(d as Map<String, dynamic>)).toList();
      return Ok(list);
    } catch (e) {
      return Err(e.toString());
    }
  }

  Future<DestinationModel?> getDestinationById(String id) async {
    try {
      final data = await _db.from('destinations').select().eq('id', id).maybeSingle();
      return data != null ? DestinationModel.fromMap(data) : null;
    } catch (_) {
      return null;
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

  /// [candidates] is the destination pool to recommend from — pass in a list
  /// the caller already fetched (e.g. Home's loaded page) instead of this
  /// method re-querying the whole table, which used to fire a second,
  /// redundant `destinations` fetch in parallel with Home's own load.
  Future<List<DestinationModel>> getRecommendations(List<DestinationModel> candidates) async {
    final favs = await getUserFavorites();
    if (favs.isEmpty) return [];
    final favTags = favs.expand((d) => d.tags).toSet();
    final notFavorited = candidates.where((d) => !favs.any((f) => f.id == d.id));
    // Simple content-based scoring: rank by shared tags with favorites
    final scored = notFavorited.map((d) {
      final overlap = d.tags.where((t) => favTags.contains(t)).length;
      return MapEntry(d, overlap);
    }).where((e) => e.value > 0).toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return scored.map((e) => e.key).take(5).toList();
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

  /// Marks the account for deletion — actual removal of the `auth.users` row
  /// requires the service-role key and must be run server-side (see
  /// VISTAVOYAGE_V6_SECURITY.md Section 5), never on-device.
  Future<void> requestAccountDeletion() async {
    await _db.from('profiles').update({
      'deletion_requested_at': DateTime.now().toIso8601String(),
    }).eq('id', _uid);
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

  // ── Reviews (Feature 2) ────────────────────────────────────────────────
  Future<List<ReviewModel>> getReviews(String destId) async {
    try {
      final data = await _db.from('reviews').select()
          .eq('dest_id', destId).order('created_at', ascending: false);
      return (data as List).map((r) => ReviewModel.fromMap(r as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<int> getUserReviewsCount() async {
    try {
      final data = await _db.from('reviews').select('id').eq('user_id', _uid);
      return (data as List).length;
    } catch (_) {
      return 0;
    }
  }

  Future<void> reportReview(String reviewId, String reason) async {
    await _db.from('reports').insert({
      'reporter_id': _uid,
      'reported_review_id': reviewId,
      'reason': reason,
    });
  }

  Future<void> addReview(String destId, double rating, String comment) async {
    final user = SupabaseService.currentUser;
    final name = user?.userMetadata?['full_name'] as String? ?? user?.email?.split('@').first ?? 'Traveler';
    await _db.from('reviews').insert({
      'dest_id': destId, 'user_id': _uid, 'user_name': name,
      'rating': rating, 'comment': comment,
    });
  }

  // ── Trips / Itinerary Planner (Feature 1) ──────────────────────────────
  Future<String> createTrip(String title, DateTime? start, DateTime? end) async {
    final data = await _db.from('trips').insert({
      'user_id': _uid, 'title': title,
      'start_date': start?.toIso8601String(), 'end_date': end?.toIso8601String(),
    }).select().single();
    return data['id'] as String;
  }

  Future<List<Map<String, dynamic>>> getUserTrips() async {
    try {
      final data = await _db.from('trips').select().eq('user_id', _uid).order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> addTripItem(String tripId, DestinationModel dest, int position) async {
    await _db.from('trip_items').insert({
      'trip_id': tripId, 'dest_id': dest.id, 'dest_data': dest.toMap(), 'position': position,
    });
  }

  Future<List<DestinationModel>> getTripItems(String tripId) async {
    try {
      final data = await _db.from('trip_items').select().eq('trip_id', tripId).order('position');
      return (data as List)
          .map((row) => DestinationModel.fromMap(Map<String, dynamic>.from(row['dest_data'])))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteTrip(String tripId) async {
    await _db.from('trips').delete().eq('id', tripId);
  }

  /// Looks up any trip by ID for QR-code sharing (relies on the "trips are
  /// publicly readable by id" policy — the UUID itself acts as the secret,
  /// like an unguessable share link; writes stay owner-only).
  Future<Map<String, dynamic>?> getTripById(String tripId) async {
    try {
      final data = await _db.from('trips').select().eq('id', tripId).maybeSingle();
      return data;
    } catch (_) {
      return null;
    }
  }

  /// Imports a shared trip's destinations into a new trip owned by the
  /// current user (used by the QR "Scan" flow).
  Future<String> importTrip(String sourceTripId) async {
    final sourceTrip = await getTripById(sourceTripId);
    if (sourceTrip == null) throw Exception('Trip not found or no longer shared.');
    final items = await getTripItems(sourceTripId);
    final newTripId = await createTrip('${sourceTrip['title']} (Imported)', null, null);
    for (var i = 0; i < items.length; i++) {
      await addTripItem(newTripId, items[i], i);
    }
    return newTripId;
  }

  // ── Group Trip Cost Splitting (V9 Feature 7) ────────────────────────────
  // All reads are scoped to a single trip_id (indexed FK, small result set) —
  // no aggregate SQL needed for MVP scale.
  Future<void> addExpense(String tripId, String category, double amount, String description) async {
    await _db.from('trip_expenses').insert({
      'trip_id': tripId, 'paid_by': _uid, 'category': category,
      'amount': amount, 'description': description,
    });
  }

  Future<List<Map<String, dynamic>>> getTripExpenses(String tripId) async {
    try {
      final data = await _db.from('trip_expenses').select().eq('trip_id', tripId).order('created_at');
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<double> getTripExpenseTotal(String tripId) async {
    final expenses = await getTripExpenses(tripId);
    return expenses.fold<double>(0.0, (sum, e) => sum + (e['amount'] as num).toDouble());
  }

  // ── Community Hidden Gems (V9 Feature 3) ────────────────────────────────
  // Scoped to a single near_dest_id, matching the partial index on
  // (near_dest_id) where status='approved' — never a full-table scan.
  Future<List<Map<String, dynamic>>> getHiddenGems(String destId) async {
    try {
      final data = await _db.from('hidden_gems').select()
          .eq('near_dest_id', destId).eq('status', 'approved').order('upvotes', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> submitHiddenGem(String destId, String name, String description, {double? lat, double? lon}) async {
    await _db.from('hidden_gems').insert({
      'submitted_by': _uid, 'near_dest_id': destId, 'name': name,
      'description': description, 'latitude': lat, 'longitude': lon,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingHiddenGems() async {
    try {
      final data = await _db.from('hidden_gems').select().eq('status', 'pending').order('created_at');
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> approveHiddenGem(String gemId) async {
    await _db.from('hidden_gems').update({'status': 'approved'}).eq('id', gemId);
  }

  Future<void> rejectHiddenGem(String gemId) async {
    await _db.from('hidden_gems').update({'status': 'rejected'}).eq('id', gemId);
  }

  // ── Trip Buddy Matching (V9 Feature 6) ──────────────────────────────────
  // The `.eq('dest_id', ...)` here is just query scoping (mirrors every
  // other per-destination query in this file) — the actual matching logic
  // (date-overlap, opt-in-only visibility) lives entirely in the RLS select
  // policy on trip_buddy_listings, not duplicated here client-side.
  Future<void> createBuddyListing(String destId, DateTime start, DateTime end, String note) async {
    await _db.from('trip_buddy_listings').insert({
      'user_id': _uid,
      'dest_id': destId,
      'travel_start': start.toIso8601String().split('T').first,
      'travel_end': end.toIso8601String().split('T').first,
      'note': note,
    });
  }

  Future<List<Map<String, dynamic>>> getBuddyMatches(String destId) async {
    try {
      final data = await _db.from('trip_buddy_listings').select().eq('dest_id', destId);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteBuddyListing(String listingId) async {
    await _db.from('trip_buddy_listings').delete().eq('id', listingId);
  }

  // ── Admin (Feature 10) ──────────────────────────────────────────────────
  Future<bool> isCurrentUserAdmin() async {
    try {
      final data = await _db.from('profiles').select('is_admin').eq('id', _uid).maybeSingle();
      return data?['is_admin'] == true;
    } catch (_) {
      return false;
    }
  }

  Future<void> adminAddDestination(DestinationModel dest) async {
    await _db.from('destinations').insert(dest.toMap());
    await _db.from('admin_audit_log').insert({
      'admin_id': _uid,
      'action': 'add_destination',
      'target_table': 'destinations',
      'target_id': dest.id,
    });
  }

  // ── Digital Travel Journal (V10 Feature 1) ──────────────────────────────────
  Future<void> addJournalEntry(String tripId, String destId, String note, {String? photoUrl}) async {
    await _db.from('trip_journal_entries').insert({
      'trip_id': tripId,
      'dest_id': destId,
      'note': note,
      'photo_url': photoUrl,
    });
  }

  Future<List<Map<String, dynamic>>> getJournalEntries(String tripId) async {
    try {
      final data = await _db.from('trip_journal_entries').select().eq('trip_id', tripId).order('created_at');
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  // ── Visa & Document Checklist Home Country (V10 Feature 2) ───────────────
  Future<void> updateHomeCountry(String homeCountry) async {
    await _db.from('profiles').upsert({
      'id': _uid,
      'home_country': homeCountry,
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ── Travel Stats & Personality (V10 Feature 3) ───────────────────────────
  Future<Map<String, dynamic>> getTravelStats() async {
    final favorites = await getUserFavorites();
    final trips = await getUserTrips();
    final countriesVisited = favorites.map((d) => d.country).toSet();
    final topTags = <String, int>{};
    for (final dest in favorites) {
      for (final tag in dest.tags) {
        topTags[tag] = (topTags[tag] ?? 0) + 1;
      }
    }
    final sortedTags = topTags.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return {
      'countriesCount': countriesVisited.length,
      'countries': countriesVisited.toList(),
      'tripsCount': trips.length,
      'favoritesCount': favorites.length,
      'topTag': sortedTags.isNotEmpty ? sortedTags.first.key : null,
    };
  }

  // ── Loyalty & Referral Rewards (V10 Feature 4) ────────────────────────────
  Future<int> getPoints() async {
    try {
      final data = await _db.from('user_points').select('points').eq('user_id', _uid).maybeSingle();
      return data?['points'] as int? ?? 0;
    } catch (_) {
      return 0;
    }
  }

  Future<void> awardPoints(int amount) async {
    try {
      await _db.rpc('increment_user_points', params: {'p_user_id': _uid, 'p_amount': amount});
    } catch (_) {}
  }

  Future<void> recordReferral(String referrerCode) async {
    try {
      final referrer = await _db.from('profiles').select('id').eq('referral_code', referrerCode).maybeSingle();
      if (referrer == null) return;
      await _db.from('referrals').insert({'referrer_id': referrer['id'], 'referred_user_id': _uid});
      await _db.rpc('increment_user_points', params: {'p_user_id': referrer['id'], 'p_amount': 100});
    } catch (_) {}
  }

  // ── Ask Locals Q&A Board (V10 Feature 5) ──────────────────────────────────
  Future<List<Map<String, dynamic>>> getDestinationQuestions(String destId) async {
    try {
      final data = await _db
          .from('destination_questions')
          .select('*, destination_answers(*)')
          .eq('dest_id', destId)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  Future<void> askQuestion(String destId, String question) async {
    await _db.from('destination_questions').insert({
      'dest_id': destId,
      'asked_by': _uid,
      'question': question,
    });
  }

  Future<void> answerQuestion(String questionId, String answer) async {
    await _db.from('destination_answers').insert({
      'question_id': questionId,
      'answered_by': _uid,
      'answer': answer,
    });
  }
}