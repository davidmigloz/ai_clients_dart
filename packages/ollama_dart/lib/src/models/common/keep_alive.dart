import 'package:meta/meta.dart';

/// Keep-alive duration for a model.
///
/// Controls how long a model stays loaded in memory after a request.
/// Can be either:
/// - [KeepAliveDuration]: A duration string (e.g., `'5m'`, `'1h'`)
/// - [KeepAliveNumber]: A numeric value (e.g., `0` to unload immediately)
///
/// ## Example
///
/// ```dart
/// // Duration string
/// final duration = KeepAlive.duration('5m');
///
/// // Numeric value (0 = unload immediately)
/// final unload = KeepAlive.number(0);
/// ```
@immutable
sealed class KeepAlive {
  const KeepAlive();

  /// Creates a [KeepAlive] with a duration string.
  const factory KeepAlive.duration(String value) = KeepAliveDuration;

  /// Creates a [KeepAlive] with a numeric value.
  const factory KeepAlive.number(num value) = KeepAliveNumber;

  /// Creates a [KeepAlive] from a JSON value.
  ///
  /// Returns `null` for unknown or null values.
  static KeepAlive? fromJson(Object? value) {
    return switch (value) {
      final String s => KeepAliveDuration(s),
      final num n => KeepAliveNumber(n),
      _ => null,
    };
  }

  /// Converts to JSON value.
  Object toJson();
}

/// Keep-alive as a duration string (e.g., `'5m'`, `'1h'`).
@immutable
class KeepAliveDuration extends KeepAlive {
  /// The duration string.
  final String value;

  /// Creates a [KeepAliveDuration].
  const KeepAliveDuration(this.value);

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeepAliveDuration &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'KeepAliveDuration($value)';
}

/// Keep-alive as a numeric value.
@immutable
class KeepAliveNumber extends KeepAlive {
  /// The numeric value.
  final num value;

  /// Creates a [KeepAliveNumber].
  const KeepAliveNumber(this.value);

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeepAliveNumber &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'KeepAliveNumber($value)';
}
