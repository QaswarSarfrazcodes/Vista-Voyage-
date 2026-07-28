import 'package:flutter_test/flutter_test.dart';
import 'package:tripline/models/destination_model.dart';

void main() {
  group('DestinationModel.fromMap', () {
    test('parses snake_case keys (current schema convention)', () {
      final dest = DestinationModel.fromMap({
        'id': 'lahore', 'name': 'Lahore', 'country': 'Pakistan',
        'image_url': 'https://example.com/lahore.jpg', 'description': 'Historic city.',
        'rating': 4.7, 'best_time': 'Oct-March', 'avg_budget': 'PKR 5,000/day',
      });
      expect(dest.imageUrl, 'https://example.com/lahore.jpg');
      expect(dest.bestTime, 'Oct-March');
      expect(dest.avgBudget, 'PKR 5,000/day');
    });

    test('parses legacy camelCase keys as a fallback (supabase_setup.sql schema)', () {
      final dest = DestinationModel.fromMap({
        'id': 'lahore', 'name': 'Lahore', 'country': 'Pakistan',
        'imageUrl': 'https://example.com/lahore.jpg', 'description': 'Historic city.',
        'rating': 4.7, 'bestTime': 'Oct-March', 'avgBudget': 'PKR 5,000/day',
      });
      expect(dest.imageUrl, 'https://example.com/lahore.jpg');
      expect(dest.bestTime, 'Oct-March');
      expect(dest.avgBudget, 'PKR 5,000/day');
    });

    test('falls back to the Pexels placeholder when image_url is null', () {
      final dest = DestinationModel.fromMap({
        'id': 'x', 'name': 'X', 'country': 'Y', 'description': 'Z', 'rating': 4.0, 'image_url': null,
      });
      expect(dest.imageUrl, 'https://images.pexels.com/photos/1591373/pexels-photo-1591373.jpeg?auto=compress&cs=tinysrgb&w=800');
    });

    test('falls back to the placeholder when image_url is an empty string', () {
      final dest = DestinationModel.fromMap({
        'id': 'x', 'name': 'X', 'country': 'Y', 'description': 'Z', 'rating': 4.0, 'image_url': '',
      });
      expect(dest.imageUrl.startsWith('https://images.pexels.com'), true);
    });

    test('rating coerces from an int (Postgres numeric can arrive as int)', () {
      final dest = DestinationModel.fromMap({
        'id': 'x', 'name': 'X', 'country': 'Y', 'description': 'Z', 'rating': 4, 'image_url': 'https://x.com/a.jpg',
      });
      expect(dest.rating, 4.0);
    });

    test('missing tags/highlights default to empty lists, not null/throw', () {
      final dest = DestinationModel.fromMap({
        'id': 'x', 'name': 'X', 'country': 'Y', 'description': 'Z', 'rating': 4.0, 'image_url': 'https://x.com/a.jpg',
      });
      expect(dest.tags, isEmpty);
      expect(dest.highlights, isEmpty);
    });

    test('malformed tags (not a list of strings) throws — documents current fragile behavior', () {
      expect(
        () => DestinationModel.fromMap({
          'id': 'x', 'name': 'X', 'country': 'Y', 'description': 'Z', 'rating': 4.0,
          'image_url': 'https://x.com/a.jpg', 'tags': 'not-a-list',
        }),
        throwsA(anything), // List<String>.from() on a String throws — this is a real fragility, not a false negative
      );
    });

    test('toMap -> fromMap round-trips id/name/rating/coords correctly', () {
      const dest = DestinationModel(
        id: 'paris', name: 'Paris', country: 'France',
        imageUrl: 'https://x.com/paris.jpg', description: 'City of Light', rating: 4.9,
        latitude: 48.8566, longitude: 2.3522,
      );
      final restored = DestinationModel.fromMap(dest.toMap());
      expect(restored.id, dest.id);
      expect(restored.latitude, dest.latitude);
      expect(restored.longitude, dest.longitude);
    });
  });
}
