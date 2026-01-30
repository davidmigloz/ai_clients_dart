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
  const factory ResponseFormat.schema(Map<String, dynamic> schema) =
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
  final Map<String, dynamic> schema;

  /// Creates a [SchemaFormat].
  const SchemaFormat(this.schema);

  @override
  Object toJson() => schema;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchemaFormat &&
          runtimeType == other.runtimeType &&
          _mapsEqual(schema, other.schema);

  @override
  int get hashCode => Object.hashAll(schema.entries);

  @override
  String toString() => 'SchemaFormat($schema)';
}

bool _mapsEqual(Map<String, dynamic> a, Map<String, dynamic> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
