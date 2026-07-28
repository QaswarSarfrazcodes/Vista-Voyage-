import 'package:flutter_test/flutter_test.dart';
import 'package:tripline/models/review_model.dart';

void main() {
  group('ReviewModel.fromMap', () {
    test('parses a valid review row', () {
      final review = ReviewModel.fromMap({
        'id': 'r1', 'dest_id': 'paris', 'user_id': 'u1', 'user_name': 'Alice',
        'rating': 4.5, 'comment': 'Loved it!', 'created_at': '2026-01-15T10:00:00Z',
      });
      expect(review.userName, 'Alice');
      expect(review.rating, 4.5);
    });

    test('defaults user_name to "Traveler" when missing', () {
      final review = ReviewModel.fromMap({
        'id': 'r1', 'dest_id': 'paris', 'user_id': 'u1',
        'rating': 4.5, 'comment': 'Nice', 'created_at': '2026-01-15T10:00:00Z',
      });
      expect(review.userName, 'Traveler');
    });

    test('throws if id is missing (not null-safe — documents real fragility)', () {
      expect(
        () => ReviewModel.fromMap({
          'dest_id': 'paris', 'user_id': 'u1', 'rating': 4.5,
          'comment': 'Nice', 'created_at': '2026-01-15T10:00:00Z',
        }),
        throwsA(anything),
      );
    });

    test('throws a FormatException if created_at is not a valid ISO date', () {
      expect(
        () => ReviewModel.fromMap({
          'id': 'r1', 'dest_id': 'paris', 'user_id': 'u1',
          'rating': 4.5, 'comment': 'Nice', 'created_at': 'not-a-date',
        }),
        throwsFormatException,
      );
    });
  });
}
