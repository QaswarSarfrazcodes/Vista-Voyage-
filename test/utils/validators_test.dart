import 'package:flutter_test/flutter_test.dart';
import 'package:tripline/utils/validators.dart';

void main() {
  group('strongPasswordValidator', () {
    test('rejects empty/null', () {
      expect(strongPasswordValidator(null), isNotNull);
      expect(strongPasswordValidator(''), isNotNull);
    });

    test('rejects under 8 characters', () {
      expect(strongPasswordValidator('Ab1'), 'Minimum 8 characters');
    });

    test('rejects missing uppercase', () {
      expect(strongPasswordValidator('lowercase1'), 'Add at least one uppercase letter');
    });

    test('rejects missing digit', () {
      expect(strongPasswordValidator('NoDigitsHere'), 'Add at least one number');
    });

    test('accepts a valid password (used identically by Signup and Change Password)', () {
      expect(strongPasswordValidator('Passw0rd123'), null);
    });
  });
}
