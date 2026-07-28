import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import '../services/admin_data_service.dart';
import '../theme/admin_theme.dart';

class ManageDestinationsScreen extends StatefulWidget {
  const ManageDestinationsScreen({super.key});

  @override
  State<ManageDestinationsScreen> createState() =>
      _ManageDestinationsScreenState();
}

class _ManageDestinationsScreenState extends State<ManageDestinationsScreen> {
  List<Map<String, dynamic>> _destinations = [];
  List<Map<String, dynamic>> _filtered = [];
  bool _loading = true;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    final data = await AdminDataService.getDestinations();
    if (mounted) {
      setState(() {
        _destinations = data;
        _filtered = data;
        _loading = false;
      });
    }
  }

  void _onSearch() {
    final q = _searchCtrl.text.toLowerCase().trim();
    setState(() {
      if (q.isEmpty) {
        _filtered = _destinations;
      } else {
        _filtered = _destinations.where((d) {
          final name = (d['name'] ?? '').toString().toLowerCase();
          final country = (d['country'] ?? '').toString().toLowerCase();
          final category = (d['category'] ?? '').toString().toLowerCase();
          return name.contains(q) || country.contains(q) || category.contains(q);
        }).toList();
      }
    });
  }

  void _showDestinationModal([Map<String, dynamic>? initialData]) {
    final isEdit = initialData != null;
    final idCtrl = TextEditingController(text: initialData?['id']?.toString() ?? '');
    final nameCtrl = TextEditingController(text: initialData?['name']?.toString() ?? '');
    final countryCtrl = TextEditingController(text: initialData?['country']?.toString() ?? '');
    final categoryCtrl = TextEditingController(text: initialData?['category']?.toString() ?? 'City');
    final imageCtrl = TextEditingController(text: initialData?['image_url']?.toString() ?? '');
    final descCtrl = TextEditingController(text: initialData?['description']?.toString() ?? '');
    final ratingCtrl = TextEditingController(text: initialData?['rating']?.toString() ?? '4.5');
    final bestTimeCtrl = TextEditingController(text: initialData?['best_time']?.toString() ?? '');
    final avgBudgetCtrl = TextEditingController(text: initialData?['avg_budget']?.toString() ?? '');
    final latCtrl = TextEditingController(text: initialData?['latitude']?.toString() ?? '');
    final lonCtrl = TextEditingController(text: initialData?['longitude']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEdit ? 'Edit Destination' : 'Add Destination',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (!isEdit)
                  TextField(
                    controller: idCtrl,
                    decoration: const InputDecoration(
                      labelText: 'ID (slug, e.g. "paris" or "tokyo")',
                    ),
                  ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(labelText: 'Name'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: countryCtrl,
                        decoration: const InputDecoration(labelText: 'Country'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: categoryCtrl,
                        decoration: const InputDecoration(
                            labelText: 'Category (City, Beach, Mountain, etc.)'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: ratingCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Rating (1.0 - 5.0)'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: bestTimeCtrl,
                        decoration: const InputDecoration(labelText: 'Best Time to Visit'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: avgBudgetCtrl,
                        decoration: const InputDecoration(labelText: 'Avg Budget (e.g. "\$500-800")'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: latCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Latitude'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: lonCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Longitude'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (nameCtrl.text.trim().isEmpty || countryCtrl.text.trim().isEmpty) return;

              final payload = <String, dynamic>{
                'name': nameCtrl.text.trim(),
                'country': countryCtrl.text.trim(),
                'category': categoryCtrl.text.trim(),
                'image_url': imageCtrl.text.trim(),
                'description': descCtrl.text.trim(),
                'rating': double.tryParse(ratingCtrl.text.trim()) ?? 4.5,
                'best_time': bestTimeCtrl.text.trim(),
                'avg_budget': avgBudgetCtrl.text.trim(),
                'latitude': double.tryParse(latCtrl.text.trim()),
                'longitude': double.tryParse(lonCtrl.text.trim()),
              };

              Navigator.pop(ctx);
              if (isEdit) {
                await AdminDataService.updateDestination(
                    initialData['id'].toString(), payload);
              } else {
                payload['id'] = idCtrl.text.trim().isNotEmpty
                    ? idCtrl.text.trim()
                    : nameCtrl.text.trim().toLowerCase().replaceAll(' ', '-');
                await AdminDataService.createDestination(payload);
              }
              _loadData();
            },
            child: Text(isEdit ? 'Save Changes' : 'Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String id, String name) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Destination'),
        content: Text('Are you sure you want to delete "$name" ($id)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AdminColors.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await AdminDataService.deleteDestination(id);
      _loadData();
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
                    'Destinations Catalog',
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AdminColors.charcoal),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Full CRUD management over all global travel spots',
                    style: TextStyle(fontSize: 14, color: AdminColors.gray),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showDestinationModal(),
                icon: const Icon(Icons.add),
                label: const Text('Add Destination'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Search by name, country, category...',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Showing ${_filtered.length} of ${_destinations.length} destinations',
                style: const TextStyle(color: AdminColors.gray, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AdminColors.border),
              ),
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : DataTable2(
                      columnSpacing: 16,
                      horizontalMargin: 20,
                      minWidth: 900,
                      columns: const [
                        DataColumn2(label: Text('ID'), size: ColumnSize.S),
                        DataColumn2(label: Text('Name'), size: ColumnSize.M),
                        DataColumn2(label: Text('Country'), size: ColumnSize.S),
                        DataColumn2(label: Text('Category'), size: ColumnSize.S),
                        DataColumn2(label: Text('Rating'), size: ColumnSize.S),
                        DataColumn2(label: Text('Best Time'), size: ColumnSize.M),
                        DataColumn2(label: Text('Actions'), size: ColumnSize.S),
                      ],
                      rows: _filtered.map((d) {
                        final id = d['id']?.toString() ?? '';
                        final name = d['name']?.toString() ?? '';
                        final country = d['country']?.toString() ?? '';
                        final category = d['category']?.toString() ?? '';
                        final rating = d['rating']?.toString() ?? '';
                        final bestTime = d['best_time']?.toString() ?? '';

                        return DataRow(cells: [
                          DataCell(Text(id,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 12))),
                          DataCell(Text(name)),
                          DataCell(Text(country)),
                          DataCell(Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AdminColors.slateBlue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(category,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: AdminColors.slateBlue,
                                    fontWeight: FontWeight.bold)),
                          )),
                          DataCell(Row(
                            children: [
                              const Icon(Icons.star,
                                  color: AdminColors.gold, size: 16),
                              const SizedBox(width: 4),
                              Text(rating),
                            ],
                          )),
                          DataCell(Text(bestTime)),
                          DataCell(Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    size: 18, color: AdminColors.slateBlue),
                                tooltip: 'Edit',
                                onPressed: () => _showDestinationModal(d),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline,
                                    size: 18, color: AdminColors.danger),
                                tooltip: 'Delete',
                                onPressed: () => _confirmDelete(id, name),
                              ),
                            ],
                          )),
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
