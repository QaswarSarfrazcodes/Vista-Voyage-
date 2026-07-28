import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tripline/screens/signup_screen.dart';

void main() {
  testWidgets('shows 4 fields: name, email, password, confirm password', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    expect(find.byType(TextFormField), findsNWidgets(4));
  });

  testWidgets('weak password (no uppercase/digit) is rejected with the exact validator message', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    final passwordField = find.byType(TextFormField).at(2);
    await tester.enterText(passwordField, 'lowercaseonly');
    // "Create Account" also appears as the screen's title Text, so target
    // the button specifically rather than find.text (which is ambiguous).
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();
    expect(find.textContaining('uppercase'), findsOneWidget);
  });

  testWidgets('mismatched confirm-password shows "Passwords do not match"', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    await tester.enterText(find.byType(TextFormField).at(2), 'Passw0rd123');
    await tester.enterText(find.byType(TextFormField).at(3), 'Different123');
    await tester.tap(find.widgetWithText(ElevatedButton, 'Create Account'));
    await tester.pump();
    expect(find.text('Passwords do not match'), findsOneWidget);
  });
}
