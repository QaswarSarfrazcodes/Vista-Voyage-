// lib/utils/image_utils.dart
/// Appends a width hint to remote image URLs so list views request smaller
/// payloads than detail views. No-op for URLs that don't support it (e.g. local assets)
/// or are empty (destinations missing an image_url in the database).
String thumbUrl(String url) => url.isEmpty ? url : (url.contains('?') ? '$url&w=400' : '$url?w=400');
String fullUrl(String url) => url.isEmpty ? url : (url.contains('?') ? '$url&w=1200' : '$url?w=1200');
