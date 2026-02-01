import 'package:meta/meta.dart';

/// Format for structured output responses.
///
/// Controls how the model formats its response. Can be either JSON mode
/// (unstructured JSON) or a specific JSON schema for structured output.
@immutable
sealed class ResponseFormat {
  const ResponseFormat();

  /// Creates a [ResponseFormat] for JSON mode (unstructured JSON output).
  const factory ResponseFormat.json() = JsonFormat;

  /// Creates a [ResponseFormat] with a specific JSON schema.
  ///
  /// The schema map is copied and stored as unmodifiable to ensure immutability.
  factory ResponseFormat.schema(Map<String, dynamic> schema) =
      SchemaFormat;

  /// Creates a [ResponseFormat] from a JSON value.
  ///
  /// Returns `null` for unknown or null values.
  static ResponseFormat? fromJson(Object? value) {
    return switch (value) {
      'json' => const JsonFormat(),
      final Map<String, dynamic> schema => SchemaFormat(schema),
      _ => null,
    };
  }

  /// Converts to JSON value.
  Object toJson();
}

/// JSON format mode (unstructured JSON output).
@immutable
class JsonFormat extends ResponseFormat {
  /// Creates a [JsonFormat].
  const JsonFormat();

  @override
  Object toJson() => 'json';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonFormat && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'JsonFormat()';
}

/// Schema format mode (structured JSON output following a schema).
@immutable
class SchemaFormat extends ResponseFormat {
  /// The JSON schema that the response must follow.
  ///
  /// This map is unmodifiable to ensure immutability.
  final Map<String, dynamic> schema;

  /// Creates a [SchemaFormat].
  ///
  /// The schema map is deeply copied and stored as unmodifiable.
  SchemaFormat(Map<String, dynamic> schema)
      : schema = _deepUnmodifiable(schema);

  @override
  Object toJson() => schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchemaFormat &&
          runtimeType == other.runtimeType &&
          _deepEquals(schema, other.schema);

  @override
  int get hashCode => _deepHashCode(schema);

  @override
  String toString() => 'SchemaFormat($schema)';
}

/// Creates an unmodifiable deep copy of a map.
Map<String, dynamic> _deepUnmodifiable(Map<String, dynamic> map) {
  return Map<String, dynamic>.unmodifiable(
    map.map((key, value) => MapEntry(key, _deepUnmodifiableValue(value))),
  );
}

/// Recursively makes a value unmodifiable.
dynamic _deepUnmodifiableValue(dynamic value) {
  if (value is Map<String, dynamic>) {
    return _deepUnmodifiable(value);
  } else if (value is List) {
    return List<dynamic>.unmodifiable(value.map(_deepUnmodifiableValue));
  }
  return value;
}

/// Deep equality check for maps that handles nested maps and lists.
bool _deepEquals(Object? a, Object? b) {
  if (identical(a, b)) return true;
  if (a is Map && b is Map) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || !_deepEquals(a[key], b[key])) return false;
    }
    return true;
  }
  if (a is List && b is List) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (!_deepEquals(a[i], b[i])) return false;
    }
    return true;
  }
  return a == b;
}

/// Computes a deep hash code for a value (map, list, or primitive).
int _deepHashCode(Object? value) {
  if (value is Map) {
    // Sort keys for consistent hashing
    final sortedKeys = value.keys.toList()..sort((a, b) => '$a'.compareTo('$b'));
    return Object.hashAll(
      sortedKeys.expand((k) => [k, _deepHashCode(value[k])]),
    );
  }
  if (value is List) {
    return Object.hashAll(value.map(_deepHashCode));
  }
  return value.hashCode;
}
