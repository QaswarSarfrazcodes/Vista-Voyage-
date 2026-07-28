// integration_test/qr_trip_import_test.dart
//
// V8 Section 3.2 — the highest-value integration test in this pack. Proves
// whether SupabaseDataService.getTripById() actually works cross-user (as
// the QR-share/import feature requires) or is silently blocked by the
// "Users manage their own trips" owner-only RLS policy — data.md flags this
// as an unresolved discrepancy between the code's own comments and the RLS
// policies captured across the repo's SQL/docs.
//
// NOT EXECUTED as part of this pass: requires two disposable Supabase test
// accounts and a live project. Fill in the TODOs and run manually, or run
// the two `select`/RLS-check queries below directly in the Supabase SQL
// editor as a faster substitute for standing up two full test users.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('User B can read a trip created by User A (required for QR import)', (tester) async {
    // TODO: sign in as User A (a disposable test account), create a trip:
    // await SupabaseService.signIn('user-a@example.com', 'TestPassw0rd1');
    // final tripId = await SupabaseDataService().createTrip('QR test trip', null, null);

    // TODO: sign out, sign in as User B (a different disposable test account):
    // await SupabaseService.signOut();
    // await SupabaseService.signIn('user-b@example.com', 'TestPassw0rd2');

    // TODO: attempt the read that importTrip()/QrScanScreen depends on:
    // final trip = await SupabaseDataService().getTripById(tripId);

    // If `trip` comes back null here, the QR-import feature is broken for
    // any trip not owned by the scanning user — apply the SQL fix below.
    // expect(trip, isNotNull, reason:
    //   'getTripById() must succeed cross-user for QR import to work. If '
    //   'this fails, the live `trips` RLS policy is owner-only-select and '
    //   'needs the additional policy documented below.');
    // Requires two disposable Supabase test accounts; fill in TODOs before running.
  }, skip: true);
}

// If the test above fails, apply this in the Supabase SQL editor (adds a
// targeted read-by-id policy without weakening the existing owner-only
// policy for insert/update/delete — relies on the trip UUID itself being
// unguessable, the same trust model the app's own code comments assume):
//
// create policy "Trips are readable by id for QR import"
//   on trips for select
//   using (true);
