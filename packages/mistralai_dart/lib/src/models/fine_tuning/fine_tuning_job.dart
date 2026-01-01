import 'package:meta/meta.dart';

import 'checkpoint.dart';
import 'fine_tuning_integration.dart';
import 'fine_tuning_job_status.dart';
import 'hyperparameters.dart';
import 'training_event.dart';
import 'training_file.dart';

/// A fine-tuning job.
@immutable
class FineTuningJob {
  /// Unique identifier for the job.
  final String id;

  /// Object type (always "fine_tuning.job").
  final String object;

  /// The base model being fine-tuned.
  final String model;

  /// Name of the resulting fine-tuned model.
  final String? fineTunedModel;

  /// Current status of the job.
  final FineTuningJobStatus status;

  /// Hyperparameters used for training.
  final Hyperparameters? hyperparameters;

  /// Training files used for the job.
  final List<TrainingFile> trainingFiles;

  /// Validation files used for the job.
  final List<TrainingFile> validationFiles;

  /// Integrations configured for the job.
  final List<FineTuningIntegration> integrations;

  /// Events that occurred during the job.
  final List<TrainingEvent> events;

  /// Checkpoints created during training.
  final List<Checkpoint> checkpoints;

  /// Custom suffix for the model name.
  final String? suffix;

  /// Job metadata.
  final Map<String, dynamic>? metadata;

  /// Timestamp when the job was created.
  final DateTime? createdAt;

  /// Timestamp when the job was last modified.
  final DateTime? modifiedAt;

  /// Whether auto-start is enabled.
  final bool? autoStart;

  /// Number of training tokens processed.
  final int? trainedTokens;

  /// Total number of tokens in the dataset.
  final int? totalTokens;

  /// Creates a [FineTuningJob].
  const FineTuningJob({
    required this.id,
    this.object = 'fine_tuning.job',
    required this.model,
    this.fineTunedModel,
    required this.status,
    this.hyperparameters,
    this.trainingFiles = const [],
    this.validationFiles = const [],
    this.integrations = const [],
    this.events = const [],
    this.checkpoints = const [],
    this.suffix,
    this.metadata,
    this.createdAt,
    this.modifiedAt,
    this.autoStart,
    this.trainedTokens,
    this.totalTokens,
  });

  /// Creates a [FineTuningJob] from JSON.
  factory FineTuningJob.fromJson(Map<String, dynamic> json) => FineTuningJob(
    id: json['id'] as String? ?? '',
    object: json['object'] as String? ?? 'fine_tuning.job',
    model: json['model'] as String? ?? '',
    fineTunedModel: json['fine_tuned_model'] as String?,
    status: FineTuningJobStatus.fromString(
      json['status'] as String? ?? 'QUEUED',
    ),
    hyperparameters: json['hyperparameters'] != null
        ? Hyperparameters.fromJson(
            json['hyperparameters'] as Map<String, dynamic>,
          )
        : null,
    trainingFiles:
        (json['training_files'] as List?)
            ?.map((e) => TrainingFile.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    validationFiles:
        (json['validation_files'] as List?)
            ?.map((e) => TrainingFile.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    integrations:
        (json['integrations'] as List?)
            ?.map(
              (e) => FineTuningIntegration.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [],
    events:
        (json['events'] as List?)
            ?.map((e) => TrainingEvent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    checkpoints:
        (json['checkpoints'] as List?)
            ?.map((e) => Checkpoint.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    suffix: json['suffix'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'].toString()) ??
              (json['created_at'] is int
                  ? DateTime.fromMillisecondsSinceEpoch(
                      (json['created_at'] as int) * 1000,
                    )
                  : null)
        : null,
    modifiedAt: json['modified_at'] != null
        ? DateTime.tryParse(json['modified_at'].toString()) ??
              (json['modified_at'] is int
                  ? DateTime.fromMillisecondsSinceEpoch(
                      (json['modified_at'] as int) * 1000,
                    )
                  : null)
        : null,
    autoStart: json['auto_start'] as bool?,
    trainedTokens: json['trained_tokens'] as int?,
    totalTokens: json['total_tokens'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'model': model,
    if (fineTunedModel != null) 'fine_tuned_model': fineTunedModel,
    'status': status.value,
    if (hyperparameters != null) 'hyperparameters': hyperparameters!.toJson(),
    'training_files': trainingFiles.map((e) => e.toJson()).toList(),
    'validation_files': validationFiles.map((e) => e.toJson()).toList(),
    'integrations': integrations.map((e) => e.toJson()).toList(),
    'events': events.map((e) => e.toJson()).toList(),
    'checkpoints': checkpoints.map((e) => e.toJson()).toList(),
    if (suffix != null) 'suffix': suffix,
    if (metadata != null) 'metadata': metadata,
    if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    if (modifiedAt != null) 'modified_at': modifiedAt!.toIso8601String(),
    if (autoStart != null) 'auto_start': autoStart,
    if (trainedTokens != null) 'trained_tokens': trainedTokens,
    if (totalTokens != null) 'total_tokens': totalTokens,
  };

  /// Whether the job is still running.
  bool get isRunning =>
      status == FineTuningJobStatus.queued ||
      status == FineTuningJobStatus.started ||
      status == FineTuningJobStatus.validating ||
      status == FineTuningJobStatus.validated ||
      status == FineTuningJobStatus.running;

  /// Whether the job has completed (success or failure).
  bool get isComplete =>
      status == FineTuningJobStatus.success ||
      status == FineTuningJobStatus.failed ||
      status == FineTuningJobStatus.cancelled;

  /// Whether the job succeeded.
  bool get isSuccess => status == FineTuningJobStatus.success;

  /// Whether the job failed.
  bool get isFailed => status == FineTuningJobStatus.failed;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningJob &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'FineTuningJob(id: $id, model: $model, status: ${status.value})';
}
