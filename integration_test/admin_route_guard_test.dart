// integration_test/admin_route_guard_test.dart
//
// V8 Section 3.3 — data.md #9: /admin has no client-side route guard. Any
// authenticated user can open the AdminScreen form; the only real
// enforcement is the server-side RLS insert policy on `destinations`
// (requires profiles.is_admin = true). This test confirms that backstop
// actually rejects a non-admin's submit, rather than silently allowing it
// (which would be a critical security regression, not just a UX gap).
//
// NOT EXECUTED as part of this pass: requires a disposable Supabase test
// account that is confirmed NOT an admin (is_admin = false / absent).
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tripline/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Non-admin user can open /admin UI but the insert is rejected server-side', (tester) async {
    // TODO: sign in as a disposable, confirmed-non-admin test account:
    // await SupabaseService.signIn('non-admin@example.com', 'TestPassw0rd1');

    await tester.pumpWidget(const TriplineApp());
    await tester.pumpAndSettle();

    // TODO: navigate directly to /admin (simulating a deep link / manual
    // route knowledge — deliberately NOT via the UI, which correctly hides
    // this entry point for non-admins):
    // Navigator.of(tester.element(find.byType(Scaffold).first)).pushNamed('/admin');
    // await tester.pumpAndSettle();

    // Confirm the form actually rendered (proves it's UI-reachable despite
    // being hidden from discovery):
    // expect(find.text('Admin — Add Destination'), findsOneWidget);

    // TODO: fill the required fields and tap Submit, then assert an error
    // toast appears (RLS rejection) rather than a success toast:
    // await tester.enterText(find.byType(TextFormField).at(0), 'test_admin_probe');
    // ... fill remaining required fields ...
    // await tester.tap(find.text('Add Destination'));
    // await tester.pumpAndSettle();
    // expect(find.textContaining('Error'), findsOneWidget,
    //   reason: 'A non-admin submit must be rejected by RLS. If a success '
    //     'toast appears instead, this is a critical security regression.');
    // Requires a disposable, confirmed-non-admin Supabase test account; fill in TODOs before running.
  }, skip: true);
}
