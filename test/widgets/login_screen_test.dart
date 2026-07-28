import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripline/screens/login_screen.dart';

void main() {
  // LoginScreen's Sign In button calls LoginGuard.isLockedOut() before form
  // validation, which reads SharedPreferences — must be mocked or the async
  // gap never resolves in a widget test (no real platform channel available).
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('shows exactly 2 fields (email, password) and a Sign In button', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Create New Account'), findsOneWidget);
  });

  testWidgets('empty-form submit shows the exact validator messages from the code', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Email required'), findsOneWidget);
  });

  testWidgets('invalid email (no @) shows "Enter valid email"', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.enterText(find.byType(TextFormField).first, 'notanemail');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();
    expect(find.text('Enter valid email'), findsOneWidget);
  });
}
