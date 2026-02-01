import 'package:meta/meta.dart';

/// Configuration for the data source used in evaluations.
///
/// The data source config defines where evaluation data comes from and
/// what schema it follows. There are two types of data sources:
/// - [CustomDataSourceConfig] - Custom data with a user-defined schema
/// - [LogsDataSourceConfig] - Data from stored logs
@immutable
sealed class EvalDataSourceConfig {
  const EvalDataSourceConfig();

  /// Creates an [EvalDataSourceConfig] from JSON.
  factory EvalDataSourceConfig.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String;
    return switch (type) {
      'custom' => CustomDataSourceConfig.fromJson(json),
      'logs' => LogsDataSourceConfig.fromJson(json),
      _ => throw FormatException('Unknown data source config type: $type'),
    };
  }

  /// Creates a custom data source config.
  static CustomDataSourceConfig custom({
    Map<String, dynamic>? itemSchema,
    bool? includeSampleSchema,
  }) {
    return CustomDataSourceConfig(
      itemSchema: itemSchema,
      includeSampleSchema: includeSampleSchema,
    );
  }

  /// Creates a logs data source config.
  static LogsDataSourceConfig logs({
    Map<String, dynamic>? schema,
    Map<String, dynamic>? metadata,
  }) {
    return LogsDataSourceConfig(schema: schema, metadata: metadata);
  }

  /// The type of data source configuration.
  String get type;

  /// Converts this to JSON.
  Map<String, dynamic> toJson();
}

/// Custom data source configuration with user-defined schema.
///
/// Use this when you want to define your own item schema for evaluation data.
/// The schema uses JSON Schema format to define the structure of evaluation items.
@immutable
class CustomDataSourceConfig extends EvalDataSourceConfig {
  /// Creates a [CustomDataSourceConfig].
  const CustomDataSourceConfig({this.itemSchema, this.includeSampleSchema});

  /// Creates a [CustomDataSourceConfig] from JSON.
  factory CustomDataSourceConfig.fromJson(Map<String, dynamic> json) {
    return CustomDataSourceConfig(
      itemSchema: json['item_schema'] as Map<String, dynamic>?,
      includeSampleSchema: json['include_sample_schema'] as bool?,
    );
  }

  /// The JSON schema defining the structure of evaluation items.
  ///
  /// This schema determines what fields are available in the `{{item.*}}`
  /// namespace for graders.
  final Map<String, dynamic>? itemSchema;

  /// Whether to include the sample schema in the evaluation.
  ///
  /// When true, the `{{sample.*}}` namespace is populated with model outputs.
  final bool? includeSampleSchema;

  @override
  String get type => 'custom';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (itemSchema != null) 'item_schema': itemSchema,
    if (includeSampleSchema != null)
      'include_sample_schema': includeSampleSchema,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomDataSourceConfig &&
          runtimeType == other.runtimeType &&
          itemSchema.toString() == other.itemSchema.toString() &&
          includeSampleSchema == other.includeSampleSchema;

  @override
  int get hashCode => Object.hash(itemSchema.toString(), includeSampleSchema);

  @override
  String toString() => 'CustomDataSourceConfig(itemSchema: $itemSchema)';
}

/// Logs-based data source configuration.
///
/// Use this to run evaluations on data from stored logs.
@immutable
class LogsDataSourceConfig extends EvalDataSourceConfig {
  /// Creates a [LogsDataSourceConfig].
  const LogsDataSourceConfig({this.schema, this.metadata});

  /// Creates a [LogsDataSourceConfig] from JSON.
  factory LogsDataSourceConfig.fromJson(Map<String, dynamic> json) {
    return LogsDataSourceConfig(
      schema: json['schema'] as Map<String, dynamic>?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// The schema for log items.
  final Map<String, dynamic>? schema;

  /// Metadata filters to apply when selecting logs.
  ///
  /// Only logs matching these metadata key-value pairs will be included.
  final Map<String, dynamic>? metadata;

  @override
  String get type => 'logs';

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (schema != null) 'schema': schema,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LogsDataSourceConfig && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'LogsDataSourceConfig(metadata: $metadata)';
}
