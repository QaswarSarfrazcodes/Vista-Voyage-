// test/widget_test.dart
// VistaVoyage smoke test — verifies app boots without crashing.

import 'package:flutter_test/flutter_test.dart';
import 'package:vistavoyage/main.dart';

void main() {
  testWidgets('App launches without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const VistaVoyageApp());
    expect(find.text('VistaVoyage'), findsOneWidget);
  });
}