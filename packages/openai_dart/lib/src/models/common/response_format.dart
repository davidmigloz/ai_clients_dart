import 'package:meta/meta.dart';

import 'copy_with_sentinel.dart';

/// Specifies the format that the model must output.
///
/// Compatible with GPT-4o, GPT-4o mini, GPT-4 Turbo, and all GPT-3.5 Turbo
/// models newer than gpt-3.5-turbo-1106.
///
/// ## Example
///
/// ```dart
/// // Request JSON output
/// final request = ChatCompletionCreateRequest(
///   model: 'gpt-4o',
///   messages: [...],
///   responseFormat: ResponseFormat.jsonObject(),
/// );
///
/// // Request specific JSON schema
/// final request = ChatCompletionCreateRequest(
///   model: 'gpt-4o',
///   messages: [...],
///   responseFormat: ResponseFormat.jsonSchema(
///     name: 'person',
///     schema: {
///       'type': 'object',
///       'properties': {
///         'name': {'type': 'string'},
///         'age': {'type': 'integer'},
///       },
///       'required': ['name', 'age'],
///     },
///   ),
/// );
/// ```
@immutable
sealed class ResponseFormat {
  const ResponseFormat();

  /// Creates a [ResponseFormat] from JSON.
  factory ResponseFormat.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => const TextResponseFormat(),
      'json_object' => const JsonObjectResponseFormat(),
      'json_schema' => JsonSchemaResponseFormat.fromJson(json),
      _ => throw FormatException('Unknown ResponseFormat type: $type'),
    };
  }

  /// Creates a text response format.
  ///
  /// This is the default format where the model outputs plain text.
  static ResponseFormat text() => const TextResponseFormat();

  /// Creates a JSON object response format.
  ///
  /// The model will output a valid JSON object. Note that you must also
  /// instruct the model to output JSON in your system or user prompt.
  static ResponseFormat jsonObject() => const JsonObjectResponseFormat();

  /// Creates a JSON schema response format.
  ///
  /// The model will output JSON conforming to the provided schema.
  /// This is the most structured output format.
  ///
  /// [name] is the name of the response format (for reference).
  /// [schema] is the JSON Schema that the output must conform to.
  /// [strict] enables strict schema adherence (default: true).
  static ResponseFormat jsonSchema({
    required String name,
    required Map<String, dynamic> schema,
    String? description,
    bool strict = true,
  }) => JsonSchemaResponseFormat(
    name: name,
    schema: schema,
    description: description,
    strict: strict,
  );

  /// The type identifier for this format.
  String get type;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Text response format (default).
@immutable
class TextResponseFormat extends ResponseFormat {
  /// Creates a [TextResponseFormat].
  const TextResponseFormat();

  @override
  String get type => 'text';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextResponseFormat && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ResponseFormat.text()';
}

/// JSON object response format.
@immutable
class JsonObjectResponseFormat extends ResponseFormat {
  /// Creates a [JsonObjectResponseFormat].
  const JsonObjectResponseFormat();

  @override
  String get type => 'json_object';

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonObjectResponseFormat && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ResponseFormat.jsonObject()';
}

/// JSON schema response format for structured outputs.
@immutable
class JsonSchemaResponseFormat extends ResponseFormat {
  /// Creates a [JsonSchemaResponseFormat].
  const JsonSchemaResponseFormat({
    required this.name,
    required this.schema,
    this.description,
    this.strict = true,
  });

  /// Creates a [JsonSchemaResponseFormat] from JSON.
  factory JsonSchemaResponseFormat.fromJson(Map<String, dynamic> json) {
    final jsonSchema = json['json_schema'] as Map<String, dynamic>;
    return JsonSchemaResponseFormat(
      name: jsonSchema['name'] as String,
      schema: jsonSchema['schema'] as Map<String, dynamic>,
      description: jsonSchema['description'] as String?,
      strict: jsonSchema['strict'] as bool? ?? true,
    );
  }

  /// The name of the response format.
  final String name;

  /// The JSON Schema that the output must conform to.
  final Map<String, dynamic> schema;

  /// A description of the response format.
  final String? description;

  /// Whether to enable strict schema adherence.
  ///
  /// When true, the model will be constrained to only generate
  /// outputs that conform exactly to the schema.
  final bool strict;

  /// Creates a copy with the given fields replaced.
  JsonSchemaResponseFormat copyWith({
    String? name,
    Map<String, dynamic>? schema,
    Object? description = unsetCopyWithValue,
    bool? strict,
  }) {
    return JsonSchemaResponseFormat(
      name: name ?? this.name,
      schema: schema ?? this.schema,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      strict: strict ?? this.strict,
    );
  }

  @override
  String get type => 'json_schema';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'json_schema': {
      'name': name,
      'schema': schema,
      if (description != null) 'description': description,
      'strict': strict,
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonSchemaResponseFormat &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          strict == other.strict &&
          description == other.description &&
          _mapEquals(schema, other.schema);

  @override
  int get hashCode =>
      Object.hash(name, strict, description, Object.hashAll(schema.entries));

  @override
  String toString() =>
      'ResponseFormat.jsonSchema(name: $name, strict: $strict)';

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key)) return false;
      final aVal = a[key];
      final bVal = b[key];
      if (aVal is Map<String, dynamic> && bVal is Map<String, dynamic>) {
        if (!_mapEquals(aVal, bVal)) return false;
      } else if (aVal != bVal) {
        return false;
      }
    }
    return true;
  }
}
