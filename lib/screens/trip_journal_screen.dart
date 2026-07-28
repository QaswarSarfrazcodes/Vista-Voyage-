import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../services/supabase_data_service.dart';
import '../theme/app_colors.dart';

class TripJournalScreen extends StatefulWidget {
  final String tripId;
  final String tripTitle;

  const TripJournalScreen({
    super.key,
    required this.tripId,
    required this.tripTitle,
  });

  @override
  State<TripJournalScreen> createState() => _TripJournalScreenState();
}

class _TripJournalScreenState extends State<TripJournalScreen> {
  final SupabaseDataService _dataService = SupabaseDataService();
  bool _loading = true;
  List<Map<String, dynamic>> _entries = [];

  @override
  void initState() {
    super.initState();
    _loadJournal();
  }

  Future<void> _loadJournal() async {
    setState(() => _loading = true);
    final data = await _dataService.getJournalEntries(widget.tripId);
    if (mounted) {
      setState(() {
        _entries = data;
        _loading = false;
      });
    }
  }

  Future<void> _addEntryDialog() async {
    final noteCtrl = TextEditingController();
    final photoCtrl = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Journal Entry', style: TextStyle(fontFamily: 'PlayfairDisplay')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: noteCtrl,
              maxLines: 4,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText: 'Share memories, thoughts, or highlights from this stop...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: photoCtrl,
              decoration: const InputDecoration(
                labelText: 'Photo URL (optional)',
                prefixIcon: Icon(Icons.image_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (noteCtrl.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await _dataService.addJournalEntry(
                widget.tripId,
                '',
                noteCtrl.text.trim(),
                photoUrl: photoCtrl.text.trim().isNotEmpty ? photoCtrl.text.trim() : null,
              );
              _loadJournal();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Save Entry'),
          ),
        ],
      ),
    );
  }

  void _shareJournal() {
    if (_entries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No journal entries to share yet!')),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('📖 Digital Travel Journal: ${widget.tripTitle}');
    buffer.writeln('----------------------------------------');
    for (int i = 0; i < _entries.length; i++) {
      final entry = _entries[i];
      final dateStr = entry['created_at'] != null
          ? DateTime.tryParse(entry['created_at'].toString())?.toLocal().toString().split(' ').first ?? ''
          : '';
      buffer.writeln('\nStop #${i + 1} ($dateStr):');
      buffer.writeln(entry['note'] ?? '');
      if (entry['photo_url'] != null && entry['photo_url'].toString().isNotEmpty) {
        buffer.writeln('Photo: ${entry['photo_url']}');
      }
    }
    buffer.writeln('\nShared via Tripline');

    Share.share(buffer.toString(), subject: 'My Travel Journal - ${widget.tripTitle}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.tripTitle} Journal',
          style: const TextStyle(fontFamily: 'PlayfairDisplay', color: Colors.white),
        ),
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'Share Journal',
            onPressed: _shareJournal,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addEntryDialog,
        backgroundColor: AppColors.gold,
        icon: const Icon(Icons.add, color: AppColors.deepNavy),
        label: const Text(
          'Add Entry',
          style: TextStyle(color: AppColors.deepNavy, fontWeight: FontWeight.bold),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.menu_book_outlined, size: 72, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      const Text(
                        'No memories captured yet.',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap "Add Entry" to record your trip moments!',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    final photoUrl = entry['photo_url'] as String?;
                    final dateStr = entry['created_at'] != null
                        ? DateTime.tryParse(entry['created_at'].toString())?.toLocal().toString().split(' ').first ?? ''
                        : '';

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Entry #${index + 1}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                Text(
                                  dateStr,
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              entry['note'] ?? '',
                              style: const TextStyle(fontSize: 14, height: 1.4),
                            ),
                            if (photoUrl != null && photoUrl.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.network(
                                  photoUrl,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    height: 120,
                                    color: Colors.grey.shade200,
                                    child: const Center(
                                      child: Icon(Icons.broken_image, color: Colors.grey),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
