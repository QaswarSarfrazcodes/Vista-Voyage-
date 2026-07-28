import 'package:flutter/material.dart';
import '../services/admin_auth_service.dart';
import '../theme/admin_theme.dart';
import 'dashboard_home_screen.dart';
import 'manage_destinations_screen.dart';
import 'moderation_screen.dart';
import 'audit_log_screen.dart';

class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final userEmail = AdminAuthService.currentUser?.email ?? 'admin@vistavoyage.app';

    final pages = [
      DashboardHomeScreen(onNavigate: (index) => setState(() => _selectedIndex = index)),
      const ManageDestinationsScreen(),
      const ModerationScreen(),
      const AuditLogScreen(),
    ];

    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 260,
            color: AdminColors.sidebarNavy,
            child: Column(
              children: [
                const SizedBox(height: 28),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AdminColors.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.explore,
                            color: AdminColors.deepNavy, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Tripline Web',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Navigation items
                _navTile(0, Icons.dashboard_outlined, 'Dashboard'),
                _navTile(1, Icons.place_outlined, 'Destinations'),
                _navTile(2, Icons.gavel_outlined, 'Moderation Queues'),
                _navTile(3, Icons.history, 'Audit Log'),

                const Spacer(),

                // User Info & Sign Out
                Container(
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'Administrator',
                        style: TextStyle(color: AdminColors.gold, fontSize: 11),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await AdminAuthService.signOut();
                            if (context.mounted) {
                              Navigator.of(context).pushReplacementNamed('/login');
                            }
                          },
                          icon: const Icon(Icons.logout, size: 16),
                          label: const Text('Sign Out'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main View
          Expanded(
            child: Column(
              children: [
                // Header Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: AdminColors.border)),
                  ),
                  child: Row(
                    children: [
                      Text(
                        _selectedIndex == 0
                            ? 'Overview'
                            : _selectedIndex == 1
                                ? 'Destinations Management'
                                : _selectedIndex == 2
                                    ? 'Moderation Queues'
                                    : 'Admin Audit Log',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AdminColors.charcoal,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AdminColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.circle, color: AdminColors.success, size: 8),
                            SizedBox(width: 6),
                            Text(
                              'Supabase Connected',
                              style: TextStyle(
                                fontSize: 12,
                                color: AdminColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Content View
                Expanded(child: pages[_selectedIndex]),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _navTile(int index, IconData icon, String label) {
    final selected = _selectedIndex == index;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: selected ? AdminColors.slateBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(icon, color: selected ? Colors.white : Colors.white70),
        title: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white70,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
        onTap: () => setState(() => _selectedIndex = index),
      ),
    );
  }
}
