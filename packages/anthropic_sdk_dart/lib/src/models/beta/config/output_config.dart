import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// Response effort level for model generation.
enum EffortLevel {
  /// Minimal effort.
  low('low'),

  /// Balanced effort.
  medium('medium'),

  /// Higher effort.
  high('high'),

  /// Maximum effort.
  max('max');

  const EffortLevel(this.value);

  /// JSON value for this level.
  final String value;

  /// Parses [EffortLevel] from JSON.
  static EffortLevel fromJson(String value) => switch (value) {
    'low' => EffortLevel.low,
    'medium' => EffortLevel.medium,
    'high' => EffortLevel.high,
    'max' => EffortLevel.max,
    _ => throw FormatException('Unknown EffortLevel: $value'),
  };

  /// Converts to JSON.
  String toJson() => value;
}

/// Configuration for model output behavior.
@immutable
class OutputConfig {
  /// Optional effort setting for response depth and latency tradeoff.
  final EffortLevel? effort;

  /// Optional structured output format configuration.
  final JsonOutputFormat? format;

  /// Creates an [OutputConfig].
  const OutputConfig({this.effort, this.format});

  /// Creates an [OutputConfig] from JSON.
  factory OutputConfig.fromJson(Map<String, dynamic> json) {
    return OutputConfig(
      effort: json['effort'] != null
          ? EffortLevel.fromJson(json['effort'] as String)
          : null,
      format: json['format'] != null
          ? JsonOutputFormat.fromJson(json['format'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (effort != null) 'effort': effort!.toJson(),
    if (format != null) 'format': format!.toJson(),
  };

  /// Creates a copy with replaced values.
  OutputConfig copyWith({
    Object? effort = unsetCopyWithValue,
    Object? format = unsetCopyWithValue,
  }) {
    return OutputConfig(
      effort: effort == unsetCopyWithValue
          ? this.effort
          : effort as EffortLevel?,
      format: format == unsetCopyWithValue
          ? this.format
          : format as JsonOutputFormat?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OutputConfig &&
          runtimeType == other.runtimeType &&
          effort == other.effort &&
          format == other.format;

  @override
  int get hashCode => Object.hash(effort, format);

  @override
  String toString() => 'OutputConfig(effort: $effort, format: $format)';
}

/// JSON schema output format for structured outputs.
@immutable
class JsonOutputFormat {
  /// The type (always "json_schema").
  final String type;

  /// The JSON schema for the output.
  final Map<String, dynamic> schema;

  /// Creates a [JsonOutputFormat].
  const JsonOutputFormat({this.type = 'json_schema', required this.schema});

  /// Creates a [JsonOutputFormat] from JSON.
  factory JsonOutputFormat.fromJson(Map<String, dynamic> json) {
    return JsonOutputFormat(
      type: json['type'] as String? ?? 'json_schema',
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
          mapsEqual(schema, other.schema);

  @override
  int get hashCode => Object.hash(type, mapHash(schema));

  @override
  String toString() => 'JsonOutputFormat(type: $type, schema: $schema)';
}
