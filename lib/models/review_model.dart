// lib/models/review_model.dart
class ReviewModel {
  final String id;
  final String destId;
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime createdAt;

  ReviewModel({
    required this.id,
    required this.destId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map) => ReviewModel(
    id:        map['id'] as String,
    destId:    map['dest_id'] as String,
    userId:    map['user_id'] as String,
    userName:  map['user_name'] as String? ?? 'Traveler',
    rating:    (map['rating'] as num).toDouble(),
    comment:   map['comment'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
  );
}
