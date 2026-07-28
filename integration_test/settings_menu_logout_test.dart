// integration_test/settings_menu_logout_test.dart
//
// V8 Section 3.1 — proves SettingsMenu's Logout tile clears the Supabase
// session, not just the navigation stack.
//
// STATUS AS OF THIS PACK: the underlying bug (data.md #7) is already fixed
// in lib/screens/settings_menu.dart — the Logout tile now awaits
// SupabaseService.signOut() before navigating. This test verifies that fix
// holds, but requires a REAL Supabase project with a disposable test
// account (email/password) to run — it was not executed as part of this
// pass since no test credentials/environment were available here. Fill in
// the TODOs and run with `flutter test integration_test/` on a device/
// emulator with network access to your Supabase project before trusting
// this as a passing check.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tripline/main.dart';
import 'package:tripline/services/supabase_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SettingsMenu Logout clears the Supabase session', (tester) async {
    // TODO: sign in as a disposable test user before pumping the app, e.g.
    // await SupabaseService.signIn('test-user@example.com', 'TestPassw0rd1');
    await tester.pumpWidget(const TriplineApp());
    await tester.pumpAndSettle();

    // TODO: navigate to a screen that can open the settings bottom sheet
    // (e.g. HomeScreen's settings icon calls showSettingsMenu(context)),
    // then open it:
    // showSettingsMenu(tester.element(find.byType(Scaffold).first));
    // await tester.pumpAndSettle();

    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(SupabaseService.currentUser, isNull,
        reason: 'SettingsMenu Logout must call SupabaseService.signOut() '
            'before navigating — verify the fix in settings_menu.dart holds.');
    // Requires a live Supabase project + disposable test account; fill in TODOs before running.
  }, skip: true);
}
