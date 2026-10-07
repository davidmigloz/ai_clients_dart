import 'package:meta/meta.dart';

/// A string or boolean option value in a Decisions question or answer.
///
/// Values retain their JSON type: `true` and `"true"` are different choices.
@immutable
sealed class DecisionChoiceValue {
  const DecisionChoiceValue();

  /// Creates a string choice value.
  const factory DecisionChoiceValue.string(String value) =
      StringDecisionChoiceValue;

  /// Creates a boolean choice value.
  // The union value is positional, matching the string variant.
  // ignore: avoid_positional_boolean_parameters
  const factory DecisionChoiceValue.boolean(bool value) =
      BooleanDecisionChoiceValue;

  /// Reads a string or boolean, rejecting numeric and null values.
  factory DecisionChoiceValue.fromJson(Object? json) => switch (json) {
    final String value => StringDecisionChoiceValue(value),
    final bool value => BooleanDecisionChoiceValue(value),
    _ => throw const FormatException(
      'DecisionChoiceValue: expected a string or boolean',
    ),
  };

  /// The primitive choice value.
  Object get value;

  /// Returns the primitive JSON string or boolean.
  Object toJson();
}

/// A string-valued Decisions option.
@immutable
class StringDecisionChoiceValue extends DecisionChoiceValue {
  /// Creates a string choice value.
  const StringDecisionChoiceValue(this.value);

  /// The string value.
  @override
  final String value;

  /// Creates a string value from JSON.
  factory StringDecisionChoiceValue.fromJson(Object? json) {
    if (json is! String) {
      throw const FormatException(
        'StringDecisionChoiceValue: expected a string',
      );
    }
    return StringDecisionChoiceValue(json);
  }

  @override
  String toJson() => value;

  /// Creates a copy with a replaced value.
  StringDecisionChoiceValue copyWith({String? value}) =>
      StringDecisionChoiceValue(value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StringDecisionChoiceValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'StringDecisionChoiceValue(value: $value)';
}

/// A boolean-valued Decisions option.
@immutable
class BooleanDecisionChoiceValue extends DecisionChoiceValue {
  /// Creates a boolean choice value.
  // The union value is positional, matching the string variant.
  // ignore: avoid_positional_boolean_parameters
  const BooleanDecisionChoiceValue(this.value);

  /// The boolean value.
  @override
  final bool value;

  /// Creates a boolean value from JSON.
  factory BooleanDecisionChoiceValue.fromJson(Object? json) {
    if (json is! bool) {
      throw const FormatException(
        'BooleanDecisionChoiceValue: expected a boolean',
      );
    }
    return BooleanDecisionChoiceValue(json);
  }

  @override
  bool toJson() => value;

  /// Creates a copy with a replaced value.
  BooleanDecisionChoiceValue copyWith({bool? value}) =>
      BooleanDecisionChoiceValue(value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooleanDecisionChoiceValue &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => Object.hash(runtimeType, value);

  @override
  String toString() => 'BooleanDecisionChoiceValue(value: $value)';
}
