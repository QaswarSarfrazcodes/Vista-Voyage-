import 'package:flutter/material.dart';
import '../services/admin_data_service.dart';
import '../theme/admin_theme.dart';

class ModerationScreen extends StatefulWidget {
  const ModerationScreen({super.key});

  @override
  State<ModerationScreen> createState() => _ModerationScreenState();
}

class _ModerationScreenState extends State<ModerationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _pendingGems = [];
  List<Map<String, dynamic>> _reportedReviews = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadQueues();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadQueues() async {
    setState(() => _loading = true);
    final gems = await AdminDataService.getPendingHiddenGems();
    final reports = await AdminDataService.getReportedReviews();
    if (mounted) {
      setState(() {
        _pendingGems = gems;
        _reportedReviews = reports;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Moderation Queues',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.charcoal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Approve community submissions & enforce content guidelines',
                    style: TextStyle(fontSize: 14, color: AdminColors.gray),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AdminColors.slateBlue),
                onPressed: _loadQueues,
              ),
            ],
          ),
          const SizedBox(height: 24),

          TabBar(
            controller: _tabController,
            isScrollable: true,
            labelColor: AdminColors.deepNavy,
            unselectedLabelColor: AdminColors.gray,
            indicatorColor: AdminColors.deepNavy,
            indicatorWeight: 3,
            tabs: [
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.diamond_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Pending Hidden Gems (${_pendingGems.length})'),
                  ],
                ),
              ),
              Tab(
                child: Row(
                  children: [
                    const Icon(Icons.report_problem_outlined, size: 18),
                    const SizedBox(width: 8),
                    Text('Reported Reviews (${_reportedReviews.length})'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildPendingGemsTab(),
                      _buildReportedReviewsTab(),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingGemsTab() {
    if (_pendingGems.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 64, color: AdminColors.success),
            SizedBox(height: 16),
            Text(
              'No pending hidden gems for approval!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _pendingGems.length,
      itemBuilder: (ctx, i) {
        final gem = _pendingGems[i];
        final id = gem['id'].toString();
        final name = gem['name']?.toString() ?? 'Unnamed';
        final desc = gem['description']?.toString() ?? '';
        final nearDest = gem['near_dest_id']?.toString() ?? 'N/A';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.gold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.diamond_outlined,
                      color: AdminColors.deepNavy, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AdminColors.charcoal),
                      ),
                      const SizedBox(height: 4),
                      Text('Near Destination ID: $nearDest',
                          style: const TextStyle(
                              fontSize: 12, color: AdminColors.gray)),
                      const SizedBox(height: 10),
                      Text(desc,
                          style: const TextStyle(
                              fontSize: 14, color: AdminColors.charcoal)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await AdminDataService.approveHiddenGem(id);
                        _loadQueues();
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Approve'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.success),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await AdminDataService.rejectHiddenGem(id);
                        _loadQueues();
                      },
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Reject'),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: AdminColors.danger,
                          side: const BorderSide(color: AdminColors.danger)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReportedReviewsTab() {
    if (_reportedReviews.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.shield_outlined, size: 64, color: AdminColors.success),
            SizedBox(height: 16),
            Text(
              'No reported reviews requiring moderation!',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _reportedReviews.length,
      itemBuilder: (ctx, i) {
        final report = _reportedReviews[i];
        final reportId = report['id'].toString();
        final reason = report['reason']?.toString() ?? 'No reason specified';
        final review = report['reviews'] as Map<String, dynamic>?;
        final reviewId = report['reported_review_id']?.toString() ?? '';
        final comment = review?['comment']?.toString() ?? 'Review deleted or unreadable';
        final userName = review?['user_name']?.toString() ?? 'Anonymous';

        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AdminColors.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flag_outlined,
                      color: AdminColors.danger, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Author: $userName',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: AdminColors.danger.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Reason: $reason',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AdminColors.danger,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Review Content: "$comment"',
                          style: const TextStyle(
                              fontSize: 14,
                              fontStyle: FontStyle.italic,
                              color: AdminColors.charcoal)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () async {
                        await AdminDataService.deleteReportedReview(reviewId, reportId);
                        _loadQueues();
                      },
                      icon: const Icon(Icons.delete_forever, size: 16),
                      label: const Text('Delete Review'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AdminColors.danger),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await AdminDataService.dismissReport(reportId);
                        _loadQueues();
                      },
                      icon: const Icon(Icons.check, size: 16),
                      label: const Text('Dismiss Report'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
