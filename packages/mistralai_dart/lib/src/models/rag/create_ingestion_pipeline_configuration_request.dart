import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Request body to register a new ingestion pipeline configuration (beta).
@immutable
class CreateIngestionPipelineConfigurationRequest {
  /// The human-readable name of the configuration.
  final String name;

  /// The composition of the pipeline, mapping stage names to component names.
  final Map<String, String>? pipelineComposition;

  /// Creates a [CreateIngestionPipelineConfigurationRequest].
  const CreateIngestionPipelineConfigurationRequest({
    required this.name,
    this.pipelineComposition,
  });

  /// Creates a [CreateIngestionPipelineConfigurationRequest] from JSON.
  factory CreateIngestionPipelineConfigurationRequest.fromJson(
    Map<String, dynamic> json,
  ) => CreateIngestionPipelineConfigurationRequest(
    name: json['name'] as String,
    pipelineComposition: (json['pipeline_composition'] as Map<String, dynamic>?)
        ?.map((k, v) => MapEntry(k, v as String)),
  );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (pipelineComposition != null)
      'pipeline_composition': pipelineComposition,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  CreateIngestionPipelineConfigurationRequest copyWith({
    String? name,
    Object? pipelineComposition = unsetCopyWithValue,
  }) => CreateIngestionPipelineConfigurationRequest(
    name: name ?? this.name,
    pipelineComposition: pipelineComposition == unsetCopyWithValue
        ? this.pipelineComposition
        : pipelineComposition as Map<String, String>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateIngestionPipelineConfigurationRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          mapsEqual(pipelineComposition, other.pipelineComposition);

  @override
  int get hashCode => Object.hash(name, mapHash(pipelineComposition));

  @override
  String toString() =>
      'CreateIngestionPipelineConfigurationRequest('
      'name: $name, pipelineComposition: $pipelineComposition)';
}
