import 'package:meta/meta.dart';

/// Stop sequence configuration for text generation.
///
/// Stop sequences can be either:
/// - [StopString]: A single stop string
/// - [StopList]: A list of stop strings
///
/// ## Example
///
/// ```dart
/// // Single stop sequence
/// final single = StopSequence.string('\n');
///
/// // Multiple stop sequences
/// final multiple = StopSequence.list(['\n', 'END']);
/// ```
@immutable
sealed class StopSequence {
  const StopSequence();

  /// Creates a [StopSequence] with a single string.
  const factory StopSequence.string(String value) = StopString;

  /// Creates a [StopSequence] with a list of strings.
  const factory StopSequence.list(List<String> values) = StopList;

  /// Creates a [StopSequence] from a JSON value.
  ///
  /// Returns `null` for unknown or null values.
  static StopSequence? fromJson(Object? value) {
    return switch (value) {
      final String s => StopString(s),
      final List<dynamic> l => StopList(l.cast<String>()),
      _ => null,
    };
  }

  /// Converts to JSON value.
  Object toJson();
}

/// A single stop string.
@immutable
class StopString extends StopSequence {
  /// The stop string.
  final String value;

  /// Creates a [StopString].
  const StopString(this.value);

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StopString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'StopString($value)';
}

/// A list of stop strings.
@immutable
class StopList extends StopSequence {
  /// The stop strings.
  final List<String> values;

  /// Creates a [StopList].
  const StopList(this.values);

  @override
  Object toJson() => values;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! StopList || runtimeType != other.runtimeType) return false;
    if (values.length != other.values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (values[i] != other.values[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(values);

  @override
  String toString() => 'StopList(${values.length} values)';
}
