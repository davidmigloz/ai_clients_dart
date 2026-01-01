import 'package:meta/meta.dart';

import 'fine_tuning_integration.dart';
import 'hyperparameters.dart';
import 'training_file.dart';

/// Request to create a fine-tuning job.
@immutable
class CreateFineTuningJobRequest {
  /// The base model to fine-tune.
  final String model;

  /// Training files.
  final List<TrainingFile> trainingFiles;

  /// Optional validation files.
  final List<TrainingFile>? validationFiles;

  /// Hyperparameters for training.
  final Hyperparameters? hyperparameters;

  /// Optional suffix for the fine-tuned model name.
  final String? suffix;

  /// Integrations to enable (e.g., W&B).
  final List<FineTuningIntegration>? integrations;

  /// Whether to auto-start the job after creation.
  final bool? autoStart;

  /// Optional metadata for the job.
  final Map<String, dynamic>? metadata;

  /// Creates a [CreateFineTuningJobRequest].
  const CreateFineTuningJobRequest({
    required this.model,
    required this.trainingFiles,
    this.validationFiles,
    this.hyperparameters,
    this.suffix,
    this.integrations,
    this.autoStart,
    this.metadata,
  });

  /// Creates a [CreateFineTuningJobRequest] with a single training file.
  factory CreateFineTuningJobRequest.single({
    required String model,
    required String trainingFileId,
    String? validationFileId,
    Hyperparameters? hyperparameters,
    String? suffix,
    List<FineTuningIntegration>? integrations,
    bool? autoStart,
    Map<String, dynamic>? metadata,
  }) {
    return CreateFineTuningJobRequest(
      model: model,
      trainingFiles: [TrainingFile(fileId: trainingFileId)],
      validationFiles: validationFileId != null
          ? [TrainingFile(fileId: validationFileId)]
          : null,
      hyperparameters: hyperparameters,
      suffix: suffix,
      integrations: integrations,
      autoStart: autoStart,
      metadata: metadata,
    );
  }

  /// Creates a [CreateFineTuningJobRequest] from JSON.
  factory CreateFineTuningJobRequest.fromJson(Map<String, dynamic> json) =>
      CreateFineTuningJobRequest(
        model: json['model'] as String? ?? '',
        trainingFiles:
            (json['training_files'] as List?)
                ?.map((e) => TrainingFile.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        validationFiles: (json['validation_files'] as List?)
            ?.map((e) => TrainingFile.fromJson(e as Map<String, dynamic>))
            .toList(),
        hyperparameters: json['hyperparameters'] != null
            ? Hyperparameters.fromJson(
                json['hyperparameters'] as Map<String, dynamic>,
              )
            : null,
        suffix: json['suffix'] as String?,
        integrations: (json['integrations'] as List?)
            ?.map(
              (e) => FineTuningIntegration.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        autoStart: json['auto_start'] as bool?,
        metadata: json['metadata'] as Map<String, dynamic>?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'training_files': trainingFiles.map((e) => e.toJson()).toList(),
    if (validationFiles != null)
      'validation_files': validationFiles!.map((e) => e.toJson()).toList(),
    if (hyperparameters != null) 'hyperparameters': hyperparameters!.toJson(),
    if (suffix != null) 'suffix': suffix,
    if (integrations != null)
      'integrations': integrations!.map((e) => e.toJson()).toList(),
    if (autoStart != null) 'auto_start': autoStart,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateFineTuningJobRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          suffix == other.suffix;

  @override
  int get hashCode => Object.hash(model, trainingFiles, suffix);

  @override
  String toString() =>
      'CreateFineTuningJobRequest(model: $model, '
      'trainingFiles: ${trainingFiles.length})';
}
