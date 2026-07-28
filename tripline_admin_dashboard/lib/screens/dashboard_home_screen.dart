import 'package:flutter/material.dart';
import '../services/admin_data_service.dart';
import '../theme/admin_theme.dart';

class DashboardHomeScreen extends StatefulWidget {
  final Function(int)? onNavigate;

  const DashboardHomeScreen({super.key, this.onNavigate});

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  late Future<Map<String, int>> _metricsFuture;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    setState(() {
      _metricsFuture = AdminDataService.getDashboardMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
                    'System Overview',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.charcoal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Real-time metrics and operational queues from Supabase',
                    style: TextStyle(fontSize: 14, color: AdminColors.gray),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AdminColors.slateBlue),
                tooltip: 'Refresh Metrics',
                onPressed: _reload,
              ),
            ],
          ),
          const SizedBox(height: 32),
          FutureBuilder<Map<String, int>>(
            future: _metricsFuture,
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(40),
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              if (snap.hasError || !snap.hasData) {
                return const Text('Failed to load metrics.');
              }

              final m = snap.data!;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Metrics Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final count = width > 1200
                          ? 5
                          : width > 800
                              ? 3
                              : 1;
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: count,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 1.4,
                        children: [
                          _MetricCard(
                            title: 'Destinations',
                            value: m['destinations']!,
                            icon: Icons.place_outlined,
                            color: Colors.blue,
                            onTap: () => widget.onNavigate?.call(1),
                          ),
                          _MetricCard(
                            title: 'Trips Created',
                            value: m['trips']!,
                            icon: Icons.flight_takeoff,
                            color: Colors.teal,
                          ),
                          _MetricCard(
                            title: 'User Reviews',
                            value: m['reviews']!,
                            icon: Icons.rate_review_outlined,
                            color: Colors.indigo,
                          ),
                          _MetricCard(
                            title: 'Pending Hidden Gems',
                            value: m['pendingGems']!,
                            icon: Icons.diamond_outlined,
                            color: Colors.orange,
                            urgent: m['pendingGems']! > 0,
                            onTap: () => widget.onNavigate?.call(2),
                          ),
                          _MetricCard(
                            title: 'Pending Reports',
                            value: m['pendingReports']!,
                            icon: Icons.report_problem_outlined,
                            color: Colors.red,
                            urgent: m['pendingReports']! > 0,
                            onTap: () => widget.onNavigate?.call(2),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 40),

                  // Quick Action Cards
                  const Text(
                    'Quick Management Actions',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.charcoal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _ActionCard(
                          title: 'Manage Catalog',
                          description:
                              'Add, edit, or delete travel destinations, update budget benchmarks, images, and geolocation coordinates.',
                          icon: Icons.map_outlined,
                          buttonLabel: 'Go to Destinations',
                          onPressed: () => widget.onNavigate?.call(1),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: _ActionCard(
                          title: 'Moderation Queue',
                          description:
                              'Review community submitted hidden gems and resolve reported reviews to ensure content safety.',
                          icon: Icons.gavel_outlined,
                          buttonLabel: 'Go to Moderation',
                          onPressed: () => widget.onNavigate?.call(2),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int value;
  final IconData icon;
  final Color color;
  final bool urgent;
  final VoidCallback? onTap;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.urgent = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: urgent ? AdminColors.danger : AdminColors.border,
            width: urgent ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                if (urgent)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AdminColors.danger.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Action Needed',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.danger,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$value',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AdminColors.charcoal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, color: AdminColors.gray),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _ActionCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AdminColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AdminColors.deepNavy, size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AdminColors.charcoal,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: const TextStyle(fontSize: 13, color: AdminColors.gray, height: 1.4),
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.arrow_forward, size: 16),
            label: Text(buttonLabel),
            style: OutlinedButton.styleFrom(
              foregroundColor: AdminColors.deepNavy,
              side: const BorderSide(color: AdminColors.deepNavy),
            ),
          ),
        ],
      ),
    );
  }
}
