import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'DOCUMENTS KNOWN BUG: scheduleDaily(hour, minute) ignores its parameters '
    'and fires immediately instead of at the given time (data.md Section 9, item 4). '
    'This test is a placeholder reminder — scheduleDaily is not currently called '
    "from any screen, so there is no reachable UI path to test end-to-end today. "
    "If a future screen wires this up, replace this with a real test using the "
    "timezone package's zonedSchedule and assert the notification does NOT fire "
    'before the specified time.',
    () {
      expect(true, true); // intentional placeholder — see description above
    },
    skip: 'Documents a known no-op bug; not user-reachable yet, so not blocking.',
  );
}
