// integration_test/password_rule_consistency_test.dart
//
// V8 Section 3.4 — data.md #5 originally documented a real inconsistency:
// Signup required >=8 chars + uppercase + digit, while Change Password only
// required >=6 chars with no character-class checks. This pack fixed that
// by extracting both to the single lib/utils/validators.dart
// strongPasswordValidator, used by both SignupScreen and the shared
// showChangePasswordDialog. This test is now a REGRESSION GUARD proving
// the two stay in sync, rather than a bug-documentation test.
//
// Unlike 3.1-3.3, this one does NOT require a live Supabase account or
// network access: both screens run their password validator client-side,
// before any Supabase call, so a rejected password never reaches the
// network. It runs as a normal (non-skipped) test.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tripline/screens/signup_screen.dart';
import 'package:tripline/widgets/change_password_dialog.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Signup rejects a 6-char password with no uppercase/digit', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));
    await tester.enterText(find.byType(TextFormField).at(2), 'abcdef');
    await tester.tap(find.text('Create Account'));
    await tester.pump();
    expect(find.text('Minimum 8 characters'), findsOneWidget);
  });

  testWidgets('Change Password dialog rejects the SAME 6-char password (previously it did not)', (tester) async {
    await tester.pumpWidget(MaterialApp(home: Scaffold(
      body: Builder(builder: (context) => ElevatedButton(
        onPressed: () => showChangePasswordDialog(context),
        child: const Text('Open'),
      )),
    )));
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'abcdef');
    await tester.tap(find.text('Update'));
    await tester.pump();

    expect(find.text('Minimum 8 characters'), findsOneWidget,
        reason: 'Change Password must now reject the same weak password Signup '
            'rejects — both use lib/utils/validators.dart strongPasswordValidator.');
  });
}
