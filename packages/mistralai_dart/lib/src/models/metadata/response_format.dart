import 'package:meta/meta.dart';

/// Sealed class for response format options.
///
/// Controls how the model formats its response output.
sealed class ResponseFormat {
  const ResponseFormat();

  /// The type of response format.
  String get type;

  /// Creates a [ResponseFormat] from JSON.
  factory ResponseFormat.fromJson(Map<String, dynamic> json) {
    return switch (json['type']) {
      'text' => const ResponseFormatText(),
      'json_object' => const ResponseFormatJsonObject(),
      'json_schema' => ResponseFormatJsonSchema.fromJson(json),
      _ => throw FormatException(
        'Unknown response format type: ${json['type']}',
      ),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();

  /// Plain text response format.
  static const text = ResponseFormatText();

  /// JSON object response format.
  static const jsonObject = ResponseFormatJsonObject();

  /// JSON schema response format for structured outputs.
  static ResponseFormatJsonSchema jsonSchema({
    required String name,
    required Map<String, dynamic> schema,
    String? description,
    bool? strict,
  }) => ResponseFormatJsonSchema(
    name: name,
    schema: schema,
    description: description,
    strict: strict,
  );
}

/// Plain text response format.
@immutable
class ResponseFormatText extends ResponseFormat {
  @override
  String get type => 'text';

  /// Creates a [ResponseFormatText].
  const ResponseFormatText();

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFormatText && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ResponseFormatText()';
}

/// JSON object response format.
///
/// Forces the model to return a valid JSON object.
@immutable
class ResponseFormatJsonObject extends ResponseFormat {
  @override
  String get type => 'json_object';

  /// Creates a [ResponseFormatJsonObject].
  const ResponseFormatJsonObject();

  @override
  Map<String, dynamic> toJson() => {'type': type};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFormatJsonObject && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'ResponseFormatJsonObject()';
}

/// JSON schema response format for structured outputs.
///
/// Forces the model to return JSON that conforms to the specified schema.
@immutable
class ResponseFormatJsonSchema extends ResponseFormat {
  @override
  String get type => 'json_schema';

  /// Name of the schema.
  final String name;

  /// Optional description of what the schema represents.
  final String? description;

  /// The JSON schema the response must conform to.
  final Map<String, dynamic> schema;

  /// Whether to enforce strict schema adherence.
  final bool? strict;

  /// Creates a [ResponseFormatJsonSchema].
  const ResponseFormatJsonSchema({
    required this.name,
    required this.schema,
    this.description,
    this.strict,
  });

  /// Creates a [ResponseFormatJsonSchema] from JSON.
  factory ResponseFormatJsonSchema.fromJson(Map<String, dynamic> json) {
    final jsonSchema = json['json_schema'] as Map<String, dynamic>? ?? json;
    return ResponseFormatJsonSchema(
      name: jsonSchema['name'] as String? ?? '',
      description: jsonSchema['description'] as String?,
      schema: jsonSchema['schema'] as Map<String, dynamic>? ?? {},
      strict: jsonSchema['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'json_schema': {
      'name': name,
      if (description != null) 'description': description,
      'schema': schema,
      if (strict != null) 'strict': strict,
    },
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ResponseFormatJsonSchema &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          strict == other.strict;

  @override
  int get hashCode => Object.hash(type, name, description, strict);

  @override
  String toString() =>
      'ResponseFormatJsonSchema(name: $name, description: $description, '
      'strict: $strict)';
}
