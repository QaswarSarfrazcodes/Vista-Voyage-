// lib/models/destination_model.dart
// V2: added category, latitude, longitude for Map screen support.

class DestinationModel {
  final String id;
  final String name;
  final String country;
  final String city;
  final String category;
  final String imageUrl;
  final bool isAsset;
  final String description;
  final double rating;
  final List<String> tags;
  final List<String> highlights;
  final String bestTime;
  final String avgBudget;
  final double? latitude;
  final double? longitude;

  const DestinationModel({
    required this.id,
    required this.name,
    required this.country,
    this.city = '',
    this.category = 'City',
    required this.imageUrl,
    this.isAsset = false,
    required this.description,
    required this.rating,
    this.tags = const [],
    this.highlights = const [],
    this.bestTime = '',
    this.avgBudget = '',
    this.latitude,
    this.longitude,
  });

  factory DestinationModel.fromMap(Map<String, dynamic> map) {
    return DestinationModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      country: map['country'] as String? ?? '',
      city: map['city'] as String? ?? '',
      category: map['category'] as String? ?? 'City',
      imageUrl: (map['image_url'] as String? ?? map['imageUrl'] as String?)?.trim().isNotEmpty == true
          ? (map['image_url'] as String? ?? map['imageUrl'] as String?)!
          // Verified, permanent "no photo available" placeholder — guards
          // against a future null/empty image_url causing a broken-image
          // flash even after the data was backfilled.
          : 'https://images.pexels.com/photos/1591373/pexels-photo-1591373.jpeg?auto=compress&cs=tinysrgb&w=800',
      isAsset: map['isAsset'] as bool? ?? false,
      description: map['description'] as String? ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      tags: List<String>.from(map['tags'] ?? []),
      highlights: List<String>.from(map['highlights'] ?? []),
      bestTime: map['best_time'] as String? ?? map['bestTime'] as String? ?? '',
      avgBudget: map['avg_budget'] as String? ?? map['avgBudget'] as String? ?? '',
      latitude: (map['latitude'] as num?)?.toDouble(),
      longitude: (map['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'country': country,
        'city': city,
        'category': category,
        'image_url': imageUrl,
        'isAsset': isAsset,
        'description': description,
        'rating': rating,
        'tags': tags,
        'highlights': highlights,
        'best_time': bestTime,
        'avg_budget': avgBudget,
        'latitude': latitude,
        'longitude': longitude,
      };
}
