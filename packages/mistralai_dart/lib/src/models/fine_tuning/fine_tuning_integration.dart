import 'package:meta/meta.dart';

/// Integration configuration for fine-tuning.
///
/// Currently supports Weights & Biases (W&B) integration.
@immutable
class FineTuningIntegration {
  /// The type of integration (e.g., "wandb").
  final String type;

  /// Project name for the integration.
  final String? project;

  /// Custom name for this run.
  final String? name;

  /// API key for the integration.
  final String? apiKey;

  /// Run name for the integration.
  final String? runName;

  /// Creates a [FineTuningIntegration].
  const FineTuningIntegration({
    required this.type,
    this.project,
    this.name,
    this.apiKey,
    this.runName,
  });

  /// Creates a W&B (Weights & Biases) integration.
  factory FineTuningIntegration.wandb({
    required String project,
    String? name,
    String? apiKey,
    String? runName,
  }) {
    return FineTuningIntegration(
      type: 'wandb',
      project: project,
      name: name,
      apiKey: apiKey,
      runName: runName,
    );
  }

  /// Creates a [FineTuningIntegration] from JSON.
  factory FineTuningIntegration.fromJson(Map<String, dynamic> json) =>
      FineTuningIntegration(
        type: json['type'] as String? ?? 'wandb',
        project: json['project'] as String?,
        name: json['name'] as String?,
        apiKey: json['api_key'] as String?,
        runName: json['run_name'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    if (project != null) 'project': project,
    if (name != null) 'name': name,
    if (apiKey != null) 'api_key': apiKey,
    if (runName != null) 'run_name': runName,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningIntegration &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          project == other.project &&
          name == other.name &&
          apiKey == other.apiKey &&
          runName == other.runName;

  @override
  int get hashCode => Object.hash(type, project, name, apiKey, runName);

  @override
  String toString() =>
      'FineTuningIntegration(type: $type, project: $project, name: $name)';
}
