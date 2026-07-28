import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../services/admin_data_service.dart';
import '../theme/admin_theme.dart';

class AuditLogScreen extends StatefulWidget {
  const AuditLogScreen({super.key});

  @override
  State<AuditLogScreen> createState() => _AuditLogScreenState();
}

class _AuditLogScreenState extends State<AuditLogScreen> {
  List<Map<String, dynamic>> _logs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    setState(() => _loading = true);
    final logs = await AdminDataService.getAuditLogs();
    if (mounted) {
      setState(() {
        _logs = logs;
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
                    'Admin Audit Log',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AdminColors.charcoal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Immutable audit trail of all administrative actions',
                    style: TextStyle(fontSize: 14, color: AdminColors.gray),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: AdminColors.slateBlue),
                onPressed: _loadLogs,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminColors.border),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _logs.isEmpty
                      ? const Center(
                          child: Text(
                            'No audit logs recorded yet.',
                            style: TextStyle(color: AdminColors.gray),
                          ),
                        )
                      : DataTable2(
                          columnSpacing: 16,
                          horizontalMargin: 20,
                          minWidth: 800,
                          columns: const [
                            DataColumn2(label: Text('Timestamp'), size: ColumnSize.M),
                            DataColumn2(label: Text('Admin ID'), size: ColumnSize.M),
                            DataColumn2(label: Text('Action'), size: ColumnSize.S),
                            DataColumn2(label: Text('Target Table'), size: ColumnSize.S),
                            DataColumn2(label: Text('Target ID'), size: ColumnSize.S),
                          ],
                          rows: _logs.map((log) {
                            final dateStr = log['created_at'] != null
                                ? DateTime.tryParse(log['created_at'].toString())
                                        ?.toLocal()
                                        .toString()
                                        .split('.')
                                        .first ??
                                    ''
                                : '';
                            final adminId = log['admin_id']?.toString() ?? 'N/A';
                            final action = log['action']?.toString() ?? 'N/A';
                            final table = log['target_table']?.toString() ?? 'N/A';
                            final targetId = log['target_id']?.toString() ?? 'N/A';

                            return DataRow(cells: [
                              DataCell(Text(dateStr,
                                  style: const TextStyle(fontSize: 12))),
                              DataCell(Text(adminId,
                                  style: const TextStyle(
                                      fontFamily: 'monospace', fontSize: 12))),
                              DataCell(Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AdminColors.deepNavy.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  action,
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: AdminColors.deepNavy),
                                ),
                              )),
                              DataCell(Text(table)),
                              DataCell(Text(targetId,
                                  style: const TextStyle(
                                      fontFamily: 'monospace', fontSize: 12))),
                            ]);
                          }).toList(),
                        ),
            ),
          ),
        ],
      ),
    );
  }
}
