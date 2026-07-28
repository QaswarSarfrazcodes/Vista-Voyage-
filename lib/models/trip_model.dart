// lib/models/trip_model.dart
import 'destination_model.dart';

class TripModel {
  final String id;
  final String title;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<DestinationModel> items;

  TripModel({
    required this.id,
    required this.title,
    this.startDate,
    this.endDate,
    this.items = const [],
  });

  factory TripModel.fromMap(Map<String, dynamic> map, List<DestinationModel> items) => TripModel(
    id:        map['id'] as String,
    title:     map['title'] as String,
    startDate: map['start_date'] != null ? DateTime.tryParse(map['start_date']) : null,
    endDate:   map['end_date'] != null ? DateTime.tryParse(map['end_date']) : null,
    items:     items,
  );
}
