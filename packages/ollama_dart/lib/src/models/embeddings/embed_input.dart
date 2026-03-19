import 'package:meta/meta.dart';

/// Input for an embedding request.
///
/// Embed input can be either:
/// - [EmbedInputString]: A single text string
/// - [EmbedInputList]: A list of text strings
///
/// ## Example
///
/// ```dart
/// // Single string
/// final single = EmbedInput.string('Hello!');
///
/// // Multiple strings
/// final batch = EmbedInput.list(['Hello!', 'World!']);
/// ```
@immutable
sealed class EmbedInput {
  const EmbedInput();

  /// Creates [EmbedInput] from JSON.
  ///
  /// Accepts either a [String] or a [List] of strings.
  factory EmbedInput.fromJson(Object json) {
    if (json is String) return EmbedInputString(json);
    if (json is List) return EmbedInputList(json.cast<String>());
    throw FormatException(
      'Expected String or List for EmbedInput, got ${json.runtimeType}',
    );
  }

  /// Creates input from a single string.
  const factory EmbedInput.string(String value) = EmbedInputString;

  /// Creates input from a list of strings.
  const factory EmbedInput.list(List<String> values) = EmbedInputList;

  /// Converts to JSON format expected by the API.
  Object toJson();
}

/// Single string input for embeddings.
@immutable
class EmbedInputString extends EmbedInput {
  /// Creates a single string input.
  const EmbedInputString(this.value);

  /// The input text.
  final String value;

  @override
  Object toJson() => value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbedInputString &&
          runtimeType == other.runtimeType &&
          value == other.value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'EmbedInputString($value)';
}

/// List of string inputs for batch embeddings.
@immutable
class EmbedInputList extends EmbedInput {
  /// Creates a list input.
  const EmbedInputList(this.values);

  /// The input texts.
  final List<String> values;

  @override
  Object toJson() => values;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! EmbedInputList || runtimeType != other.runtimeType) {
      return false;
    }
    if (values.length != other.values.length) return false;
    for (var i = 0; i < values.length; i++) {
      if (values[i] != other.values[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hashAll(values);

  @override
  String toString() => 'EmbedInputList(${values.length} values)';
}
