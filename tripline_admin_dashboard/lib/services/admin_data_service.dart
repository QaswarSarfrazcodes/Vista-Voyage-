import 'package:supabase_flutter/supabase_flutter.dart';
import 'admin_auth_service.dart';

class AdminDataService {
  static SupabaseClient get _db => AdminAuthService.client;
  static String get _adminId => AdminAuthService.currentUser?.id ?? '';

  // ── Metrics Overview ────────────────────────────────────────────────────────
  static Future<Map<String, int>> getDashboardMetrics() async {
    try {
      final destinations = await _db.from('destinations').select('id');
      final trips = await _db.from('trips').select('id');
      final reviews = await _db.from('reviews').select('id');
      final pendingGems = await _db
          .from('hidden_gems')
          .select('id')
          .eq('status', 'pending');
      final pendingReports = await _db.from('reports').select('id');

      return {
        'destinations': (destinations as List).length,
        'trips': (trips as List).length,
        'reviews': (reviews as List).length,
        'pendingGems': (pendingGems as List).length,
        'pendingReports': (pendingReports as List).length,
      };
    } catch (_) {
      return {
        'destinations': 0,
        'trips': 0,
        'reviews': 0,
        'pendingGems': 0,
        'pendingReports': 0,
      };
    }
  }

  // ── Destinations Management ────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getDestinations() async {
    try {
      final data = await _db
          .from('destinations')
          .select()
          .order('name', ascending: true);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  static Future<void> createDestination(Map<String, dynamic> data) async {
    await _db.from('destinations').insert(data);
    await _logAudit('create_destination', 'destinations', data['id']?.toString());
  }

  static Future<void> updateDestination(String id, Map<String, dynamic> data) async {
    await _db.from('destinations').update(data).eq('id', id);
    await _logAudit('update_destination', 'destinations', id);
  }

  static Future<void> deleteDestination(String id) async {
    await _db.from('destinations').delete().eq('id', id);
    await _logAudit('delete_destination', 'destinations', id);
  }

  // ── Moderation Queues ──────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getPendingHiddenGems() async {
    try {
      final data = await _db
          .from('hidden_gems')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  static Future<void> approveHiddenGem(String id) async {
    await _db.from('hidden_gems').update({'status': 'approved'}).eq('id', id);
    await _logAudit('approve_hidden_gem', 'hidden_gems', id);
  }

  static Future<void> rejectHiddenGem(String id) async {
    await _db.from('hidden_gems').update({'status': 'rejected'}).eq('id', id);
    await _logAudit('reject_hidden_gem', 'hidden_gems', id);
  }

  static Future<List<Map<String, dynamic>>> getReportedReviews() async {
    try {
      final data = await _db
          .from('reports')
          .select('*, reviews(*)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  static Future<void> deleteReportedReview(String reviewId, String reportId) async {
    await _db.from('reviews').delete().eq('id', reviewId);
    await _db.from('reports').delete().eq('id', reportId);
    await _logAudit('delete_reported_review', 'reviews', reviewId);
  }

  static Future<void> dismissReport(String reportId) async {
    await _db.from('reports').delete().eq('id', reportId);
    await _logAudit('dismiss_report', 'reports', reportId);
  }

  // ── Audit Logs ─────────────────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getAuditLogs() async {
    try {
      final data = await _db
          .from('admin_audit_log')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(data);
    } catch (_) {
      return [];
    }
  }

  static Future<void> _logAudit(String action, String targetTable, String? targetId) async {
    try {
      await _db.from('admin_audit_log').insert({
        'admin_id': _adminId,
        'action': action,
        'target_table': targetTable,
        'target_id': targetId,
      });
    } catch (_) {}
  }
}
