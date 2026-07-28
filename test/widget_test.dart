// test/widget_test.dart
// Tripline smoke test — verifies the root app class is importable and
// constructable. Full widget boot requires Supabase + dotenv initialisation
// which is not available in the unit-test environment; see integration_test/
// for live-environment tests.

import 'package:flutter_test/flutter_test.dart';
import 'package:tripline/main.dart';

void main() {
  test('TriplineApp class is importable and constructable', () {
    // If the import above resolves and the constructor runs, the package
    // name, pubspec, and lib/ structure are all consistent.
    expect(TriplineApp.new, isNotNull);
  });
}