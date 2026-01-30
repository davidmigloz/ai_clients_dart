import 'package:meta/meta.dart';

/// Think level for reasoning models.
enum ThinkLevel {
  /// High level of thinking/reasoning.
  high,

  /// Medium level of thinking/reasoning.
  medium,

  /// Low level of thinking/reasoning.
  low,
}

/// Value for the think parameter.
///
/// Controls whether thinking/reasoning models will think before responding.
/// Can be either a boolean (enabled/disabled) or a level (high/medium/low).
@immutable
sealed class ThinkValue {
  const ThinkValue();

  /// Creates a [ThinkValue] that enables or disables thinking.
  // ignore: avoid_positional_boolean_parameters
  const factory ThinkValue.enabled(bool value) = ThinkEnabled;

  /// Creates a [ThinkValue] with a specific thinking level.
  const factory ThinkValue.level(ThinkLevel level) = ThinkWithLevel;

  /// Creates a [ThinkValue] from a JSON value.
  ///
  /// Returns `null` for unknown or null values.
  static ThinkValue? fromJson(Object? value) {
    return switch (value) {
      final bool b => ThinkEnabled(b),
      'high' => const ThinkWithLevel(ThinkLevel.high),
      'medium' => const ThinkWithLevel(ThinkLevel.medium),
      'low' => const ThinkWithLevel(ThinkLevel.low),
      _ => null,
    };
  }

  /// Converts to JSON value.
  Object toJson();
}

/// Think value that enables or disables thinking.
@immutable
class ThinkEnabled extends ThinkValue {
  /// Whether thinking is enabled.
  final bool value;

  /// Creates a [ThinkEnabled].
  // ignore: avoid_positional_boolean_parameters
  const ThinkEnabled(this.value);

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkEnabled &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ThinkEnabled($value)';
}

/// Think value with a specific level.
@immutable
class ThinkWithLevel extends ThinkValue {
  /// The thinking level.
  final ThinkLevel level;

  /// Creates a [ThinkWithLevel].
  const ThinkWithLevel(this.level);

  @override
  Object toJson() {
    return switch (level) {
      ThinkLevel.high => 'high',
      ThinkLevel.medium => 'medium',
      ThinkLevel.low => 'low',
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkWithLevel &&
          runtimeType == other.runtimeType &&
          level == other.level;

  @override
  int get hashCode => level.hashCode;

  @override
  String toString() => 'ThinkWithLevel($level)';
}
