import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripline/models/destination_model.dart';
import 'package:tripline/widgets/destination_card.dart';

void main() {
  const dest = DestinationModel(
    id: 'test', name: 'Test City', country: 'Testland',
    imageUrl: 'https://example.com/test.jpg', description: 'A test place', rating: 4.5);

  testWidgets('displays name and rating', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: DestinationCard(destination: dest, onTap: () {}))));
    expect(find.text('Test City'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
  });

  testWidgets('tapping the card OR the "View Details" button both trigger onTap', (tester) async {
    int tapCount = 0;
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: DestinationCard(destination: dest, onTap: () => tapCount++))));
    await tester.tap(find.text('View Details'));
    expect(tapCount, 1);
  });
}
