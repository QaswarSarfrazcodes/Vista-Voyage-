// lib/utils/result.dart
/// Lightweight success/failure wrapper for data-layer calls that need to
/// distinguish "genuinely no data" from "the request failed" — used where
/// that distinction actually changes what the UI shows (e.g. no-internet
/// retry screen vs. an empty-state message).
sealed class Result<T> {
  const Result();
}

class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

class Err<T> extends Result<T> {
  final String message;
  const Err(this.message);
}
