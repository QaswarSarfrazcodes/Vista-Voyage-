// integration_test/home_offline_test.dart
//
// V8 Section 3.5 — data.md #14: HomeScreen's paginated
// SupabaseDataService.getDestinationsPage() has no SharedPreferences cache
// (unlike the unpaginated getDestinations()), so a cold load with no
// connectivity should show NoInternetScreen rather than stale cached data.
// This documents the app's ACTUAL (intentionally partial) offline
// behavior — it is not necessarily a bug to fix, just something to verify
// and decide on.
//
// NOT EXECUTED as part of this pass, for two reasons:
//   1. It requires a real device/emulator with connectivity that can be
//      toggled (airplane mode) or a network-level block, which isn't
//      available in this environment.
//   2. SupabaseDataService has no dependency-injection point (unlike the
//      three HTTP services fixed in this pack) — it calls
//      SupabaseService.client directly, so there is no way to mock a
//      network failure at the unit/widget-test level without a further
//      refactor that was NOT requested for this pack (only
//      CurrencyService/WeatherService/AiService were asked to become
//      injectable). If offline testing of HomeScreen becomes a priority,
//      that refactor (injecting a data-service interface) should be done
//      as its own follow-up, not bundled silently into this fix.
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('HomeScreen shows NoInternetScreen on first cold load with no connectivity', (tester) async {
    // TODO (manual, on-device):
    // 1. Launch the app on a device/emulator with the debugger attached.
    // 2. Sign in, then immediately toggle airplane mode before HomeScreen's
    //    initState fires (or launch already offline).
    // 3. Confirm NoInternetScreen renders, not a blank/stale list.
    // 4. Toggle connectivity back on, tap "Try Again", confirm it recovers.
    // Requires manual on-device connectivity toggling or a SupabaseDataService DI refactor not in scope for this pack.
  }, skip: true);
}
