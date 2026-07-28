// lib/utils/validators.dart
// Shared validation rules — single source of truth so password strength
// requirements can't drift between Signup and Change Password (V8 fix:
// these were previously inconsistent — 8-char+uppercase+digit at signup vs.
// a bare 6-char check when changing password later).

/// Minimum 8 characters, at least one uppercase letter, at least one digit.
String? strongPasswordValidator(String? v) {
  if (v == null || v.isEmpty) return 'Password is required';
  if (v.length < 8) return 'Minimum 8 characters';
  if (!RegExp(r'[A-Z]').hasMatch(v)) return 'Add at least one uppercase letter';
  if (!RegExp(r'[0-9]').hasMatch(v)) return 'Add at least one number';
  return null;
}
