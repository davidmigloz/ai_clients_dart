import 'package:meta/meta.dart';

/// Configuration for structured output (JSON mode).
@immutable
class OutputConfig {
  /// The output format.
  final JsonOutputFormat format;

  /// Creates an [OutputConfig].
  const OutputConfig({required this.format});

  /// Creates an [OutputConfig] from JSON.
  factory OutputConfig.fromJson(Map<String, dynamic> json) {
    return OutputConfig(
      format: JsonOutputFormat.fromJson(json['format'] as Map<String, dynamic>),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'format': format.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputConfig &&
          runtimeType == other.runtimeType &&
          format == other.format;

  @override
  int get hashCode => format.hashCode;

  @override
  String toString() => 'OutputConfig(format: $format)';
}

/// JSON output format for structured outputs.
@immutable
class JsonOutputFormat {
  /// The type (always "json").
  final String type;

  /// The JSON schema for the output.
  final Map<String, dynamic> schema;

  /// Creates a [JsonOutputFormat].
  const JsonOutputFormat({this.type = 'json', required this.schema});

  /// Creates a [JsonOutputFormat] from JSON.
  factory JsonOutputFormat.fromJson(Map<String, dynamic> json) {
    return JsonOutputFormat(
      type: json['type'] as String? ?? 'json',
      schema: json['schema'] as Map<String, dynamic>,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'schema': schema};

  /// Creates a copy with replaced values.
  JsonOutputFormat copyWith({String? type, Map<String, dynamic>? schema}) {
    return JsonOutputFormat(
      type: type ?? this.type,
      schema: schema ?? this.schema,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JsonOutputFormat &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          _mapsEqual(schema, other.schema);

  @override
  int get hashCode => Object.hash(type, schema);

  @override
  String toString() => 'JsonOutputFormat(type: $type, schema: $schema)';
}

bool _mapsEqual<K, V>(Map<K, V> a, Map<K, V> b) {
  if (a.length != b.length) return false;
  for (final key in a.keys) {
    if (!b.containsKey(key) || a[key] != b[key]) return false;
  }
  return true;
}
