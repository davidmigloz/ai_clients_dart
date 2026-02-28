import 'package:meta/meta.dart';

import '../common/auto_or_value.dart';

/// A fine-tuning job for customizing a model.
///
/// Fine-tuning allows you to train a model on your own data to
/// improve its performance on specific tasks.
@immutable
class FineTuningJob {
  /// Creates a [FineTuningJob].
  const FineTuningJob({
    required this.id,
    required this.object,
    required this.createdAt,
    this.error,
    required this.fineTunedModel,
    this.finishedAt,
    required this.hyperparameters,
    required this.model,
    required this.organizationId,
    required this.resultFiles,
    required this.status,
    this.trainedTokens,
    required this.trainingFile,
    this.validationFile,
    this.integrations,
    required this.seed,
    this.estimatedFinish,
  });

  /// Creates a [FineTuningJob] from JSON.
  factory FineTuningJob.fromJson(Map<String, dynamic> json) {
    return FineTuningJob(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      error: json['error'] != null
          ? FineTuningError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      fineTunedModel: json['fine_tuned_model'] as String?,
      finishedAt: json['finished_at'] as int?,
      hyperparameters: Hyperparameters.fromJson(
        json['hyperparameters'] as Map<String, dynamic>,
      ),
      model: json['model'] as String,
      organizationId: json['organization_id'] as String,
      resultFiles: (json['result_files'] as List<dynamic>).cast<String>(),
      status: FineTuningStatus.fromJson(json['status'] as String),
      trainedTokens: json['trained_tokens'] as int?,
      trainingFile: json['training_file'] as String,
      validationFile: json['validation_file'] as String?,
      integrations: (json['integrations'] as List<dynamic>?)
          ?.map(
            (e) => FineTuningIntegration.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      seed: json['seed'] as int,
      estimatedFinish: json['estimated_finish'] as int?,
    );
  }

  /// The job identifier.
  final String id;

  /// The object type (always "fine_tuning.job").
  final String object;

  /// The Unix timestamp when the job was created.
  final int createdAt;

  /// Error details if the job failed.
  final FineTuningError? error;

  /// The name of the fine-tuned model (when complete).
  final String? fineTunedModel;

  /// The Unix timestamp when the job finished.
  final int? finishedAt;

  /// The hyperparameters used.
  final Hyperparameters hyperparameters;

  /// The base model being fine-tuned.
  final String model;

  /// The organization ID.
  final String organizationId;

  /// The result file IDs.
  final List<String> resultFiles;

  /// The job status.
  final FineTuningStatus status;

  /// The number of tokens trained.
  final int? trainedTokens;

  /// The training file ID.
  final String trainingFile;

  /// The validation file ID.
  final String? validationFile;

  /// Integrations (e.g., Weights & Biases).
  final List<FineTuningIntegration>? integrations;

  /// The random seed used.
  final int seed;

  /// Estimated finish time.
  final int? estimatedFinish;

  /// Whether the job is still running.
  bool get isRunning =>
      status == FineTuningStatus.validatingFiles ||
      status == FineTuningStatus.queued ||
      status == FineTuningStatus.running;

  /// Whether the job succeeded.
  bool get isSucceeded => status == FineTuningStatus.succeeded;

  /// Whether the job failed.
  bool get isFailed => status == FineTuningStatus.failed;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    if (error != null) 'error': error!.toJson(),
    if (fineTunedModel != null) 'fine_tuned_model': fineTunedModel,
    if (finishedAt != null) 'finished_at': finishedAt,
    'hyperparameters': hyperparameters.toJson(),
    'model': model,
    'organization_id': organizationId,
    'result_files': resultFiles,
    'status': status.toJson(),
    if (trainedTokens != null) 'trained_tokens': trainedTokens,
    'training_file': trainingFile,
    if (validationFile != null) 'validation_file': validationFile,
    if (integrations != null)
      'integrations': integrations!.map((i) => i.toJson()).toList(),
    'seed': seed,
    if (estimatedFinish != null) 'estimated_finish': estimatedFinish,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningJob &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FineTuningJob(id: $id, status: $status)';
}

/// A list of fine-tuning jobs.
@immutable
class FineTuningJobList {
  /// Creates a [FineTuningJobList].
  const FineTuningJobList({
    required this.object,
    required this.data,
    required this.hasMore,
  });

  /// Creates a [FineTuningJobList] from JSON.
  factory FineTuningJobList.fromJson(Map<String, dynamic> json) {
    return FineTuningJobList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => FineTuningJob.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of jobs.
  final List<FineTuningJob> data;

  /// Whether there are more jobs.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((j) => j.toJson()).toList(),
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningJobList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'FineTuningJobList(${data.length} jobs)';
}

/// A request to create a fine-tuning job.
@immutable
class CreateFineTuningJobRequest {
  /// Creates a [CreateFineTuningJobRequest].
  const CreateFineTuningJobRequest({
    required this.model,
    required this.trainingFile,
    this.hyperparameters,
    this.suffix,
    this.validationFile,
    this.integrations,
    this.seed,
  });

  /// Creates a [CreateFineTuningJobRequest] from JSON.
  factory CreateFineTuningJobRequest.fromJson(Map<String, dynamic> json) {
    return CreateFineTuningJobRequest(
      model: json['model'] as String,
      trainingFile: json['training_file'] as String,
      hyperparameters: json['hyperparameters'] != null
          ? HyperparametersRequest.fromJson(
              json['hyperparameters'] as Map<String, dynamic>,
            )
          : null,
      suffix: json['suffix'] as String?,
      validationFile: json['validation_file'] as String?,
      integrations: (json['integrations'] as List<dynamic>?)
          ?.map(
            (e) =>
                CreateFineTuningIntegration.fromJson(e as Map<String, dynamic>),
          )
          .toList(),
      seed: json['seed'] as int?,
    );
  }

  /// The base model to fine-tune.
  final String model;

  /// The training file ID.
  final String trainingFile;

  /// The hyperparameters to use.
  final HyperparametersRequest? hyperparameters;

  /// A suffix for the fine-tuned model name.
  final String? suffix;

  /// The validation file ID.
  final String? validationFile;

  /// Integrations to enable.
  final List<CreateFineTuningIntegration>? integrations;

  /// The random seed.
  final int? seed;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model': model,
    'training_file': trainingFile,
    if (hyperparameters != null) 'hyperparameters': hyperparameters!.toJson(),
    if (suffix != null) 'suffix': suffix,
    if (validationFile != null) 'validation_file': validationFile,
    if (integrations != null)
      'integrations': integrations!.map((i) => i.toJson()).toList(),
    if (seed != null) 'seed': seed,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateFineTuningJobRequest &&
          runtimeType == other.runtimeType &&
          model == other.model &&
          trainingFile == other.trainingFile;

  @override
  int get hashCode => Object.hash(model, trainingFile);

  @override
  String toString() =>
      'CreateFineTuningJobRequest(model: $model, trainingFile: $trainingFile)';
}

/// Fine-tuning job status values.
enum FineTuningStatus {
  /// Validating training files.
  validatingFiles._('validating_files'),

  /// Job is queued.
  queued._('queued'),

  /// Job is running.
  running._('running'),

  /// Job succeeded.
  succeeded._('succeeded'),

  /// Job failed.
  failed._('failed'),

  /// Job was cancelled.
  cancelled._('cancelled');

  const FineTuningStatus._(this._value);

  /// Creates from JSON string.
  factory FineTuningStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Hyperparameters for a fine-tuning job.
@immutable
class Hyperparameters {
  /// Creates a [Hyperparameters].
  const Hyperparameters({
    this.nEpochs,
    this.batchSize,
    this.learningRateMultiplier,
  });

  /// Creates a [Hyperparameters] from JSON.
  factory Hyperparameters.fromJson(Map<String, dynamic> json) {
    return Hyperparameters(
      nEpochs: json['n_epochs'] != null
          ? AutoOrInt.fromJson(json['n_epochs'] as Object)
          : null,
      batchSize: json['batch_size'] != null
          ? AutoOrInt.fromJson(json['batch_size'] as Object)
          : null,
      learningRateMultiplier: json['learning_rate_multiplier'] != null
          ? AutoOrDouble.fromJson(json['learning_rate_multiplier'] as Object)
          : null,
    );
  }

  /// The number of epochs ("auto" or a specific integer).
  final AutoOrInt? nEpochs;

  /// The batch size ("auto" or a specific integer).
  final AutoOrInt? batchSize;

  /// The learning rate multiplier ("auto" or a specific double).
  final AutoOrDouble? learningRateMultiplier;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (nEpochs != null) 'n_epochs': nEpochs!.toJson(),
    if (batchSize != null) 'batch_size': batchSize!.toJson(),
    if (learningRateMultiplier != null)
      'learning_rate_multiplier': learningRateMultiplier!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hyperparameters &&
          runtimeType == other.runtimeType &&
          nEpochs == other.nEpochs &&
          batchSize == other.batchSize &&
          learningRateMultiplier == other.learningRateMultiplier;

  @override
  int get hashCode => Object.hash(nEpochs, batchSize, learningRateMultiplier);

  @override
  String toString() => 'Hyperparameters(nEpochs: $nEpochs)';
}

/// Hyperparameters request for creating a fine-tuning job.
@immutable
class HyperparametersRequest {
  /// Creates a [HyperparametersRequest].
  const HyperparametersRequest({
    this.nEpochs,
    this.batchSize,
    this.learningRateMultiplier,
  });

  /// Creates a [HyperparametersRequest] from JSON.
  factory HyperparametersRequest.fromJson(Map<String, dynamic> json) {
    return HyperparametersRequest(
      nEpochs: json['n_epochs'] != null
          ? AutoOrInt.fromJson(json['n_epochs'] as Object)
          : null,
      batchSize: json['batch_size'] != null
          ? AutoOrInt.fromJson(json['batch_size'] as Object)
          : null,
      learningRateMultiplier: json['learning_rate_multiplier'] != null
          ? AutoOrDouble.fromJson(json['learning_rate_multiplier'] as Object)
          : null,
    );
  }

  /// The number of epochs ("auto" or a specific integer).
  final AutoOrInt? nEpochs;

  /// The batch size ("auto" or a specific integer).
  final AutoOrInt? batchSize;

  /// The learning rate multiplier ("auto" or a specific double).
  final AutoOrDouble? learningRateMultiplier;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (nEpochs != null) 'n_epochs': nEpochs!.toJson(),
    if (batchSize != null) 'batch_size': batchSize!.toJson(),
    if (learningRateMultiplier != null)
      'learning_rate_multiplier': learningRateMultiplier!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HyperparametersRequest &&
          runtimeType == other.runtimeType &&
          nEpochs == other.nEpochs &&
          batchSize == other.batchSize &&
          learningRateMultiplier == other.learningRateMultiplier;

  @override
  int get hashCode => Object.hash(nEpochs, batchSize, learningRateMultiplier);

  @override
  String toString() => 'HyperparametersRequest(nEpochs: $nEpochs)';
}

/// An error from fine-tuning.
@immutable
class FineTuningError {
  /// Creates a [FineTuningError].
  const FineTuningError({this.code, this.message, this.param});

  /// Creates a [FineTuningError] from JSON.
  factory FineTuningError.fromJson(Map<String, dynamic> json) {
    return FineTuningError(
      code: json['code'] as String?,
      message: json['message'] as String?,
      param: json['param'] as String?,
    );
  }

  /// The error code.
  final String? code;

  /// The error message.
  final String? message;

  /// The parameter that caused the error.
  final String? param;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (code != null) 'code': code,
    if (message != null) 'message': message,
    if (param != null) 'param': param,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningError &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'FineTuningError(code: $code)';
}

/// A fine-tuning integration (e.g., Weights & Biases).
@immutable
class FineTuningIntegration {
  /// Creates a [FineTuningIntegration].
  const FineTuningIntegration({required this.type, required this.wandb});

  /// Creates a [FineTuningIntegration] from JSON.
  factory FineTuningIntegration.fromJson(Map<String, dynamic> json) {
    return FineTuningIntegration(
      type: json['type'] as String,
      wandb: WandbIntegration.fromJson(json['wandb'] as Map<String, dynamic>),
    );
  }

  /// The integration type.
  final String type;

  /// Weights & Biases configuration.
  final WandbIntegration wandb;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'wandb': wandb.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningIntegration &&
          runtimeType == other.runtimeType &&
          type == other.type;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'FineTuningIntegration(type: $type)';
}

/// Weights & Biases integration configuration.
@immutable
class WandbIntegration {
  /// Creates a [WandbIntegration].
  const WandbIntegration({
    required this.project,
    this.name,
    this.entity,
    this.tags,
  });

  /// Creates a [WandbIntegration] from JSON.
  factory WandbIntegration.fromJson(Map<String, dynamic> json) {
    return WandbIntegration(
      project: json['project'] as String,
      name: json['name'] as String?,
      entity: json['entity'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// The W&B project name.
  final String project;

  /// The run name.
  final String? name;

  /// The W&B entity.
  final String? entity;

  /// Tags for the run.
  final List<String>? tags;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'project': project,
    if (name != null) 'name': name,
    if (entity != null) 'entity': entity,
    if (tags != null) 'tags': tags,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WandbIntegration &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;

  @override
  String toString() => 'WandbIntegration(project: $project)';
}

/// A request to create a fine-tuning integration.
@immutable
class CreateFineTuningIntegration {
  /// Creates a [CreateFineTuningIntegration].
  const CreateFineTuningIntegration({required this.type, required this.wandb});

  /// Creates a [CreateFineTuningIntegration] from JSON.
  factory CreateFineTuningIntegration.fromJson(Map<String, dynamic> json) {
    return CreateFineTuningIntegration(
      type: json['type'] as String,
      wandb: CreateWandbIntegration.fromJson(
        json['wandb'] as Map<String, dynamic>,
      ),
    );
  }

  /// The integration type (always "wandb").
  final String type;

  /// Weights & Biases configuration.
  final CreateWandbIntegration wandb;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'wandb': wandb.toJson()};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateFineTuningIntegration && runtimeType == other.runtimeType;

  @override
  int get hashCode => type.hashCode;

  @override
  String toString() => 'CreateFineTuningIntegration(type: $type)';
}

/// A request to create a W&B integration.
@immutable
class CreateWandbIntegration {
  /// Creates a [CreateWandbIntegration].
  const CreateWandbIntegration({
    required this.project,
    this.name,
    this.entity,
    this.tags,
  });

  /// Creates a [CreateWandbIntegration] from JSON.
  factory CreateWandbIntegration.fromJson(Map<String, dynamic> json) {
    return CreateWandbIntegration(
      project: json['project'] as String,
      name: json['name'] as String?,
      entity: json['entity'] as String?,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
    );
  }

  /// The W&B project name.
  final String project;

  /// The run name.
  final String? name;

  /// The W&B entity.
  final String? entity;

  /// Tags for the run.
  final List<String>? tags;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'project': project,
    if (name != null) 'name': name,
    if (entity != null) 'entity': entity,
    if (tags != null) 'tags': tags,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateWandbIntegration &&
          runtimeType == other.runtimeType &&
          project == other.project;

  @override
  int get hashCode => project.hashCode;

  @override
  String toString() => 'CreateWandbIntegration(project: $project)';
}

/// A fine-tuning job event.
@immutable
class FineTuningEvent {
  /// Creates a [FineTuningEvent].
  const FineTuningEvent({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.level,
    required this.message,
  });

  /// Creates a [FineTuningEvent] from JSON.
  factory FineTuningEvent.fromJson(Map<String, dynamic> json) {
    return FineTuningEvent(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      level: json['level'] as String,
      message: json['message'] as String,
    );
  }

  /// The event ID.
  final String id;

  /// The object type (always "fine_tuning.job.event").
  final String object;

  /// The Unix timestamp.
  final int createdAt;

  /// The log level ("info", "warn", "error").
  final String level;

  /// The event message.
  final String message;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'level': level,
    'message': message,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningEvent &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FineTuningEvent(id: $id, level: $level)';
}

/// A list of fine-tuning events.
@immutable
class FineTuningEventList {
  /// Creates a [FineTuningEventList].
  const FineTuningEventList({
    required this.object,
    required this.data,
    required this.hasMore,
  });

  /// Creates a [FineTuningEventList] from JSON.
  factory FineTuningEventList.fromJson(Map<String, dynamic> json) {
    return FineTuningEventList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => FineTuningEvent.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of events.
  final List<FineTuningEvent> data;

  /// Whether there are more events.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningEventList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'FineTuningEventList(${data.length} events)';
}

/// A fine-tuning checkpoint.
@immutable
class FineTuningCheckpoint {
  /// Creates a [FineTuningCheckpoint].
  const FineTuningCheckpoint({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.fineTunedModelCheckpoint,
    required this.stepNumber,
    required this.metrics,
    required this.fineTuningJobId,
  });

  /// Creates a [FineTuningCheckpoint] from JSON.
  factory FineTuningCheckpoint.fromJson(Map<String, dynamic> json) {
    return FineTuningCheckpoint(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      fineTunedModelCheckpoint: json['fine_tuned_model_checkpoint'] as String,
      stepNumber: json['step_number'] as int,
      metrics: CheckpointMetrics.fromJson(
        json['metrics'] as Map<String, dynamic>,
      ),
      fineTuningJobId: json['fine_tuning_job_id'] as String,
    );
  }

  /// The checkpoint ID.
  final String id;

  /// The object type (always "fine_tuning.job.checkpoint").
  final String object;

  /// The Unix timestamp.
  final int createdAt;

  /// The checkpoint model name.
  final String fineTunedModelCheckpoint;

  /// The step number.
  final int stepNumber;

  /// The training metrics.
  final CheckpointMetrics metrics;

  /// The fine-tuning job ID.
  final String fineTuningJobId;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'fine_tuned_model_checkpoint': fineTunedModelCheckpoint,
    'step_number': stepNumber,
    'metrics': metrics.toJson(),
    'fine_tuning_job_id': fineTuningJobId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningCheckpoint &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'FineTuningCheckpoint(id: $id, step: $stepNumber)';
}

/// Training metrics for a checkpoint.
@immutable
class CheckpointMetrics {
  /// Creates a [CheckpointMetrics].
  const CheckpointMetrics({
    this.step,
    this.trainLoss,
    this.trainMeanTokenAccuracy,
    this.validLoss,
    this.validMeanTokenAccuracy,
    this.fullValidLoss,
    this.fullValidMeanTokenAccuracy,
  });

  /// Creates a [CheckpointMetrics] from JSON.
  factory CheckpointMetrics.fromJson(Map<String, dynamic> json) {
    return CheckpointMetrics(
      step: json['step'] as int?,
      trainLoss: (json['train_loss'] as num?)?.toDouble(),
      trainMeanTokenAccuracy: (json['train_mean_token_accuracy'] as num?)
          ?.toDouble(),
      validLoss: (json['valid_loss'] as num?)?.toDouble(),
      validMeanTokenAccuracy: (json['valid_mean_token_accuracy'] as num?)
          ?.toDouble(),
      fullValidLoss: (json['full_valid_loss'] as num?)?.toDouble(),
      fullValidMeanTokenAccuracy:
          (json['full_valid_mean_token_accuracy'] as num?)?.toDouble(),
    );
  }

  /// The step number.
  final int? step;

  /// Training loss.
  final double? trainLoss;

  /// Training mean token accuracy.
  final double? trainMeanTokenAccuracy;

  /// Validation loss.
  final double? validLoss;

  /// Validation mean token accuracy.
  final double? validMeanTokenAccuracy;

  /// Full validation loss.
  final double? fullValidLoss;

  /// Full validation mean token accuracy.
  final double? fullValidMeanTokenAccuracy;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (step != null) 'step': step,
    if (trainLoss != null) 'train_loss': trainLoss,
    if (trainMeanTokenAccuracy != null)
      'train_mean_token_accuracy': trainMeanTokenAccuracy,
    if (validLoss != null) 'valid_loss': validLoss,
    if (validMeanTokenAccuracy != null)
      'valid_mean_token_accuracy': validMeanTokenAccuracy,
    if (fullValidLoss != null) 'full_valid_loss': fullValidLoss,
    if (fullValidMeanTokenAccuracy != null)
      'full_valid_mean_token_accuracy': fullValidMeanTokenAccuracy,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckpointMetrics && runtimeType == other.runtimeType;

  @override
  int get hashCode => step.hashCode;

  @override
  String toString() => 'CheckpointMetrics(step: $step)';
}

/// A list of fine-tuning checkpoints.
@immutable
class FineTuningCheckpointList {
  /// Creates a [FineTuningCheckpointList].
  const FineTuningCheckpointList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [FineTuningCheckpointList] from JSON.
  factory FineTuningCheckpointList.fromJson(Map<String, dynamic> json) {
    return FineTuningCheckpointList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => FineTuningCheckpoint.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of checkpoints.
  final List<FineTuningCheckpoint> data;

  /// The ID of the first checkpoint.
  final String? firstId;

  /// The ID of the last checkpoint.
  final String? lastId;

  /// Whether there are more checkpoints.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((c) => c.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FineTuningCheckpointList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'FineTuningCheckpointList(${data.length} checkpoints)';
}
