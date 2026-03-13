import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../metadata/verbosity.dart';

/// Configuration for text output.
@immutable
class TextConfig {
  /// The output format.
  final TextFormat? format;

  /// The verbosity level for text output.
  final Verbosity? verbosity;

  /// Creates a [TextConfig].
  const TextConfig({this.format, this.verbosity});

  /// Creates a [TextConfig] from JSON.
  factory TextConfig.fromJson(Map<String, dynamic> json) {
    return TextConfig(
      format: json['format'] != null
          ? TextFormat.fromJson(json['format'] as Map<String, dynamic>)
          : null,
      verbosity: json['verbosity'] != null
          ? Verbosity.fromJson(json['verbosity'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (format != null) 'format': format!.toJson(),
    if (verbosity != null) 'verbosity': verbosity!.toJson(),
  };

  /// Creates a copy with replaced values.
  TextConfig copyWith({
    Object? format = unsetCopyWithValue,
    Object? verbosity = unsetCopyWithValue,
  }) {
    return TextConfig(
      format: format == unsetCopyWithValue
          ? this.format
          : format as TextFormat?,
      verbosity: verbosity == unsetCopyWithValue
          ? this.verbosity
          : verbosity as Verbosity?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextConfig &&
          runtimeType == other.runtimeType &&
          format == other.format &&
          verbosity == other.verbosity;

  @override
  int get hashCode => Object.hash(format, verbosity);

  @override
  String toString() => 'TextConfig(format: $format, verbosity: $verbosity)';
}

/// Text output format.
sealed class TextFormat {
  /// Creates a [TextFormat].
  const TextFormat();

  /// Creates a [TextFormat] from JSON.
  factory TextFormat.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'text' => const TextResponseFormat(),
      'json_object' => const JsonObjectFormat(),
      'json_schema' => JsonSchemaFormat.fromJson(json),
      _ => throw FormatException('Unknown TextFormat type: $type'),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// Plain text response format.
@immutable
class TextResponseFormat extends TextFormat {
  /// Creates a [TextResponseFormat].
  const TextResponseFormat();

  @override
  Map<String, dynamic> toJson() => {'type': 'text'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextResponseFormat && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'TextResponseFormat()';
}

/// JSON object response format.
@immutable
class JsonObjectFormat extends TextFormat {
  /// Creates a [JsonObjectFormat].
  const JsonObjectFormat();

  @override
  Map<String, dynamic> toJson() => {'type': 'json_object'};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonObjectFormat && runtimeType == other.runtimeType;

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  String toString() => 'JsonObjectFormat()';
}

/// JSON schema response format.
@immutable
class JsonSchemaFormat extends TextFormat {
  /// The name of the schema.
  final String name;

  /// Optional description of the schema.
  final String? description;

  /// The JSON Schema.
  final Map<String, dynamic> schema;

  /// Whether to enforce strict schema adherence.
  final bool? strict;

  /// Creates a [JsonSchemaFormat].
  const JsonSchemaFormat({
    required this.name,
    this.description,
    required this.schema,
    this.strict,
  });

  /// Creates a [JsonSchemaFormat] from JSON.
  factory JsonSchemaFormat.fromJson(Map<String, dynamic> json) {
    return JsonSchemaFormat(
      name: json['name'] as String,
      description: json['description'] as String?,
      schema: json['schema'] as Map<String, dynamic>,
      strict: json['strict'] as bool?,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': 'json_schema',
    'name': name,
    if (description != null) 'description': description,
    'schema': schema,
    if (strict != null) 'strict': strict,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonSchemaFormat &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          description == other.description &&
          mapsEqual(schema, other.schema) &&
          strict == other.strict;

  @override
  int get hashCode => Object.hash(name, description, mapHash(schema), strict);

  @override
  String toString() =>
      'JsonSchemaFormat(name: $name, description: $description, schema: $schema, strict: $strict)';
}
