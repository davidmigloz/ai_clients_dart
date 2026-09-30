import 'package:meta/meta.dart';

/// Think level for reasoning models.
enum ThinkLevel {
  /// High level of thinking/reasoning.
  high,

  /// Medium level of thinking/reasoning.
  medium,

  /// Low level of thinking/reasoning.
  low,

  /// Maximum level of thinking/reasoning.
  max,
}

/// Value for the think parameter.
///
/// Controls whether thinking/reasoning models will think before responding.
/// Supports [ThinkEnabled] for a boolean, [ThinkWithLevel] for a known level,
/// and [ThinkWithString] for a model-defined named level such as `xhigh`.
/// String variants compare by their serialized level name, so a known level
/// created with either factory remains equal after a JSON round-trip.
@immutable
sealed class ThinkValue {
  const ThinkValue();

  /// Creates a [ThinkValue] that enables or disables thinking.
  // ignore: avoid_positional_boolean_parameters
  const factory ThinkValue.enabled(bool value) = ThinkEnabled;

  /// Creates a [ThinkValue] with a specific thinking level.
  const factory ThinkValue.level(ThinkLevel level) = ThinkWithLevel;

  /// Creates a [ThinkValue] with a model-defined named thinking level.
  ///
  /// The server resolves supported names for the selected model.
  const factory ThinkValue.string(String value) = ThinkWithString;

  /// Creates a [ThinkValue] from a JSON value.
  ///
  /// Known level strings retain their [ThinkWithLevel] representation; other
  /// strings are preserved as [ThinkWithString]. Returns `null` for null or
  /// values that are neither booleans nor strings.
  static ThinkValue? fromJson(Object? value) {
    return switch (value) {
      final bool b => ThinkEnabled(b),
      'high' => const ThinkWithLevel(ThinkLevel.high),
      'medium' => const ThinkWithLevel(ThinkLevel.medium),
      'low' => const ThinkWithLevel(ThinkLevel.low),
      'max' => const ThinkWithLevel(ThinkLevel.max),
      final String s => ThinkWithString(s),
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
      ThinkLevel.max => 'max',
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkWithLevel && level == other.level ||
      other is ThinkWithString && toJson() == other.value;

  @override
  int get hashCode => toJson().hashCode;

  @override
  String toString() => 'ThinkWithLevel($level)';
}

/// A model-defined named thinking level.
@immutable
class ThinkWithString extends ThinkValue {
  /// The level name sent to the model without normalization.
  final String value;

  /// Creates a [ThinkWithString].
  const ThinkWithString(this.value);

  @override
  Object toJson() => value;

  /// Creates a copy with a replaced level name.
  ThinkWithString copyWith({String? value}) =>
      ThinkWithString(value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ThinkWithString && value == other.value ||
      other is ThinkWithLevel && other.toJson() == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'ThinkWithString($value)';
}
