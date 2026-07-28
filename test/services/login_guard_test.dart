import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tripline/services/login_guard.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('not locked out with 0-4 failed attempts', () async {
    for (var i = 0; i < 4; i++) {
      await LoginGuard.recordFailedAttempt();
    }
    expect(await LoginGuard.isLockedOut(), false);
  });

  test('locks out at exactly 5 failed attempts', () async {
    for (var i = 0; i < 5; i++) {
      await LoginGuard.recordFailedAttempt();
    }
    expect(await LoginGuard.isLockedOut(), true);
  });

  test('remainingLockoutSeconds is roughly 300s (5 min) right after lockout triggers', () async {
    for (var i = 0; i < 5; i++) {
      await LoginGuard.recordFailedAttempt();
    }
    final remaining = await LoginGuard.remainingLockoutSeconds();
    expect(remaining, greaterThan(290));
    expect(remaining, lessThanOrEqualTo(300));
  });

  test('resetOnSuccess clears both the counter and the lockout', () async {
    for (var i = 0; i < 5; i++) {
      await LoginGuard.recordFailedAttempt();
    }
    await LoginGuard.resetOnSuccess();
    expect(await LoginGuard.isLockedOut(), false);
    expect(await LoginGuard.remainingLockoutSeconds(), 0);
  });
}
