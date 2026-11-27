import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../workflows/principal_type.dart';
import 'evaluation_results.dart';
import 'paginated_result.dart';

/// The ListOptimizationTrialsResponse wire payload.
@immutable
class ListOptimizationTrialsResponse {
  /// Creates a [ListOptimizationTrialsResponse].
  const ListOptimizationTrialsResponse({required this.trials});

  /// The trials field.
  final PaginatedResult<OptimizationTrialWithObservations> trials;

  /// Parses a [ListOptimizationTrialsResponse] from JSON.
  factory ListOptimizationTrialsResponse.fromJson(Map<String, dynamic> json) {
    if (json['trials'] == null) {
      throw const FormatException(
        'ListOptimizationTrialsResponse: missing trials',
      );
    }
    return ListOptimizationTrialsResponse(
      trials: PaginatedResult<OptimizationTrialWithObservations>.fromJson(
        json['trials'] as Map<String, dynamic>,
        OptimizationTrialWithObservations.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'trials': trials.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  ListOptimizationTrialsResponse copyWith({
    PaginatedResult<OptimizationTrialWithObservations>? trials,
  }) => ListOptimizationTrialsResponse(trials: trials ?? this.trials);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListOptimizationTrialsResponse &&
          runtimeType == other.runtimeType &&
          trials == other.trials;

  @override
  int get hashCode => Object.hashAll([trials]);

  @override
  String toString() =>
      'ListOptimizationTrialsResponse('
      'trials: $trials)';
}

/// The ListOptimizationsResponse wire payload.
@immutable
class ListOptimizationsResponse {
  /// Creates a [ListOptimizationsResponse].
  const ListOptimizationsResponse({required this.optimizations});

  /// The optimizations field.
  final PaginatedResult<EvaluationOptimization> optimizations;

  /// Parses a [ListOptimizationsResponse] from JSON.
  factory ListOptimizationsResponse.fromJson(Map<String, dynamic> json) {
    if (json['optimizations'] == null) {
      throw const FormatException(
        'ListOptimizationsResponse: missing optimizations',
      );
    }
    return ListOptimizationsResponse(
      optimizations: PaginatedResult<EvaluationOptimization>.fromJson(
        json['optimizations'] as Map<String, dynamic>,
        EvaluationOptimization.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'optimizations': optimizations.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  ListOptimizationsResponse copyWith({
    PaginatedResult<EvaluationOptimization>? optimizations,
  }) => ListOptimizationsResponse(
    optimizations: optimizations ?? this.optimizations,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListOptimizationsResponse &&
          runtimeType == other.runtimeType &&
          optimizations == other.optimizations;

  @override
  int get hashCode => Object.hashAll([optimizations]);

  @override
  String toString() =>
      'ListOptimizationsResponse('
      'optimizations: $optimizations)';
}

/// The Optimization wire payload.
@immutable
class EvaluationOptimization {
  /// Creates a [EvaluationOptimization].
  const EvaluationOptimization({
    required this.algorithm,
    required this.createdAt,
    required this.creatorId,
    this.creatorType,
    required this.deletedAt,
    this.description,
    this.evaluationId,
    required this.id,
    required this.name,
    this.objectiveSpec,
    this.outcome,
    required this.projectId,
    required this.source,
    required this.status,
    this.steer,
    this.tags,
    required this.updatedAt,
    this.workflowExecutionId,
    this.workflowRunId,
  });

  /// The algorithm field.
  final String algorithm;

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The creator_type field.
  final PrincipalType? creatorType;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The description field.
  final String? description;

  /// The evaluation_id field.
  final String? evaluationId;

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The objective_spec field.
  final Map<String, Object?>? objectiveSpec;

  /// The outcome field.
  final Map<String, Object?>? outcome;

  /// The project_id field.
  final String projectId;

  /// The source field.
  final String source;

  /// The status field.
  final String status;

  /// The steer field.
  final String? steer;

  /// The tags field.
  final List<String>? tags;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The workflow_execution_id field.
  final String? workflowExecutionId;

  /// The workflow_run_id field.
  final String? workflowRunId;

  /// Parses a [EvaluationOptimization] from JSON.
  factory EvaluationOptimization.fromJson(Map<String, dynamic> json) {
    if (json['algorithm'] == null) {
      throw const FormatException('EvaluationOptimization: missing algorithm');
    }
    if (json['created_at'] == null) {
      throw const FormatException('EvaluationOptimization: missing created_at');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('EvaluationOptimization: missing creator_id');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('EvaluationOptimization: missing deleted_at');
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationOptimization: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('EvaluationOptimization: missing name');
    }
    if (json['project_id'] == null) {
      throw const FormatException('EvaluationOptimization: missing project_id');
    }
    if (json['source'] == null) {
      throw const FormatException('EvaluationOptimization: missing source');
    }
    if (json['status'] == null) {
      throw const FormatException('EvaluationOptimization: missing status');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('EvaluationOptimization: missing updated_at');
    }
    return EvaluationOptimization(
      algorithm: json['algorithm'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] as String,
      creatorType: json['creator_type'] == null
          ? null
          : PrincipalType.fromJson(json['creator_type'] as String?),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      evaluationId: json['evaluation_id'] == null
          ? null
          : json['evaluation_id'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      objectiveSpec: json['objective_spec'] == null
          ? null
          : json['objective_spec'] as Map<String, Object?>,
      outcome: json['outcome'] == null
          ? null
          : json['outcome'] as Map<String, Object?>,
      projectId: json['project_id'] as String,
      source: json['source'] as String,
      status: json['status'] as String,
      steer: json['steer'] == null ? null : json['steer'] as String,
      tags: json['tags'] == null
          ? null
          : (json['tags'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      workflowExecutionId: json['workflow_execution_id'] == null
          ? null
          : json['workflow_execution_id'] as String,
      workflowRunId: json['workflow_run_id'] == null
          ? null
          : json['workflow_run_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'algorithm': algorithm,
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    if (creatorType != null) 'creator_type': creatorType!.value,
    'deleted_at': deletedAt?.toIso8601String(),
    'description': ?description,
    'evaluation_id': ?evaluationId,
    'id': id,
    'name': name,
    'objective_spec': ?objectiveSpec,
    'outcome': ?outcome,
    'project_id': projectId,
    'source': source,
    'status': status,
    'steer': ?steer,
    'tags': ?tags,
    'updated_at': updatedAt.toIso8601String(),
    'workflow_execution_id': ?workflowExecutionId,
    'workflow_run_id': ?workflowRunId,
  };

  /// Creates a copy with the given fields replaced.
  EvaluationOptimization copyWith({
    String? algorithm,
    DateTime? createdAt,
    String? creatorId,
    Object? creatorType = unsetCopyWithValue,
    Object? deletedAt = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? evaluationId = unsetCopyWithValue,
    String? id,
    String? name,
    Object? objectiveSpec = unsetCopyWithValue,
    Object? outcome = unsetCopyWithValue,
    String? projectId,
    String? source,
    String? status,
    Object? steer = unsetCopyWithValue,
    Object? tags = unsetCopyWithValue,
    DateTime? updatedAt,
    Object? workflowExecutionId = unsetCopyWithValue,
    Object? workflowRunId = unsetCopyWithValue,
  }) => EvaluationOptimization(
    algorithm: algorithm ?? this.algorithm,
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    creatorType: creatorType == unsetCopyWithValue
        ? this.creatorType
        : creatorType as PrincipalType?,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    evaluationId: evaluationId == unsetCopyWithValue
        ? this.evaluationId
        : evaluationId as String?,
    id: id ?? this.id,
    name: name ?? this.name,
    objectiveSpec: objectiveSpec == unsetCopyWithValue
        ? this.objectiveSpec
        : (objectiveSpec as Map?)?.cast<String, Object>(),
    outcome: outcome == unsetCopyWithValue
        ? this.outcome
        : (outcome as Map?)?.cast<String, Object>(),
    projectId: projectId ?? this.projectId,
    source: source ?? this.source,
    status: status ?? this.status,
    steer: steer == unsetCopyWithValue ? this.steer : steer as String?,
    tags: tags == unsetCopyWithValue
        ? this.tags
        : (tags as List<Object?>?)?.cast<String>(),
    updatedAt: updatedAt ?? this.updatedAt,
    workflowExecutionId: workflowExecutionId == unsetCopyWithValue
        ? this.workflowExecutionId
        : workflowExecutionId as String?,
    workflowRunId: workflowRunId == unsetCopyWithValue
        ? this.workflowRunId
        : workflowRunId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationOptimization &&
          runtimeType == other.runtimeType &&
          algorithm == other.algorithm &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          creatorType == other.creatorType &&
          deletedAt == other.deletedAt &&
          description == other.description &&
          evaluationId == other.evaluationId &&
          id == other.id &&
          name == other.name &&
          valuesDeepEqual(objectiveSpec, other.objectiveSpec) &&
          valuesDeepEqual(outcome, other.outcome) &&
          projectId == other.projectId &&
          source == other.source &&
          status == other.status &&
          steer == other.steer &&
          valuesDeepEqual(tags, other.tags) &&
          updatedAt == other.updatedAt &&
          workflowExecutionId == other.workflowExecutionId &&
          workflowRunId == other.workflowRunId;

  @override
  int get hashCode => Object.hashAll([
    algorithm,
    createdAt,
    creatorId,
    creatorType,
    deletedAt,
    description,
    evaluationId,
    id,
    name,
    valueDeepHashCode(objectiveSpec),
    valueDeepHashCode(outcome),
    projectId,
    source,
    status,
    steer,
    valueDeepHashCode(tags),
    updatedAt,
    workflowExecutionId,
    workflowRunId,
  ]);

  @override
  String toString() =>
      'EvaluationOptimization('
      'algorithm: $algorithm, '
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'creatorType: $creatorType, '
      'deletedAt: $deletedAt, '
      'description: $description, '
      'evaluationId: $evaluationId, '
      'id: $id, '
      'name: $name, '
      'objectiveSpec: ${objectiveSpec?.length}, '
      'outcome: ${outcome?.length}, '
      'projectId: $projectId, '
      'source: $source, '
      'status: $status, '
      'steer: $steer, '
      'tags: ${tags?.length}, '
      'updatedAt: $updatedAt, '
      'workflowExecutionId: $workflowExecutionId, '
      'workflowRunId: $workflowRunId)';
}

/// The OptimizationDetail wire payload.
@immutable
class EvaluationOptimizationDetail {
  /// Creates a [EvaluationOptimizationDetail].
  const EvaluationOptimizationDetail({
    required this.algorithm,
    required this.createdAt,
    required this.creatorId,
    this.creatorType,
    required this.deletedAt,
    this.description,
    this.evaluation,
    this.evaluationId,
    required this.id,
    required this.name,
    this.objectiveSpec,
    this.outcome,
    this.project,
    required this.projectId,
    required this.source,
    required this.status,
    this.steer,
    this.tags,
    required this.updatedAt,
    this.workflowExecutionId,
    this.workflowRunId,
  });

  /// The algorithm field.
  final String algorithm;

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The creator_type field.
  final PrincipalType? creatorType;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The description field.
  final String? description;

  /// The evaluation field.
  final OptimizationReference? evaluation;

  /// The evaluation_id field.
  final String? evaluationId;

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The objective_spec field.
  final Map<String, Object?>? objectiveSpec;

  /// The outcome field.
  final Map<String, Object?>? outcome;

  /// The project field.
  final OptimizationReference? project;

  /// The project_id field.
  final String projectId;

  /// The source field.
  final String source;

  /// The status field.
  final String status;

  /// The steer field.
  final String? steer;

  /// The tags field.
  final List<String>? tags;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The workflow_execution_id field.
  final String? workflowExecutionId;

  /// The workflow_run_id field.
  final String? workflowRunId;

  /// Parses a [EvaluationOptimizationDetail] from JSON.
  factory EvaluationOptimizationDetail.fromJson(Map<String, dynamic> json) {
    if (json['algorithm'] == null) {
      throw const FormatException(
        'EvaluationOptimizationDetail: missing algorithm',
      );
    }
    if (json['created_at'] == null) {
      throw const FormatException(
        'EvaluationOptimizationDetail: missing created_at',
      );
    }
    if (json['creator_id'] == null) {
      throw const FormatException(
        'EvaluationOptimizationDetail: missing creator_id',
      );
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException(
        'EvaluationOptimizationDetail: missing deleted_at',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationOptimizationDetail: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('EvaluationOptimizationDetail: missing name');
    }
    if (json['project_id'] == null) {
      throw const FormatException(
        'EvaluationOptimizationDetail: missing project_id',
      );
    }
    if (json['source'] == null) {
      throw const FormatException(
        'EvaluationOptimizationDetail: missing source',
      );
    }
    if (json['status'] == null) {
      throw const FormatException(
        'EvaluationOptimizationDetail: missing status',
      );
    }
    if (json['updated_at'] == null) {
      throw const FormatException(
        'EvaluationOptimizationDetail: missing updated_at',
      );
    }
    return EvaluationOptimizationDetail(
      algorithm: json['algorithm'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] as String,
      creatorType: json['creator_type'] == null
          ? null
          : PrincipalType.fromJson(json['creator_type'] as String?),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      evaluation: json['evaluation'] == null
          ? null
          : OptimizationReference.fromJson(
              json['evaluation'] as Map<String, dynamic>,
            ),
      evaluationId: json['evaluation_id'] == null
          ? null
          : json['evaluation_id'] as String,
      id: json['id'] as String,
      name: json['name'] as String,
      objectiveSpec: json['objective_spec'] == null
          ? null
          : json['objective_spec'] as Map<String, Object?>,
      outcome: json['outcome'] == null
          ? null
          : json['outcome'] as Map<String, Object?>,
      project: json['project'] == null
          ? null
          : OptimizationReference.fromJson(
              json['project'] as Map<String, dynamic>,
            ),
      projectId: json['project_id'] as String,
      source: json['source'] as String,
      status: json['status'] as String,
      steer: json['steer'] == null ? null : json['steer'] as String,
      tags: json['tags'] == null
          ? null
          : (json['tags'] as List<Object?>)
                .map((item) => item! as String)
                .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      workflowExecutionId: json['workflow_execution_id'] == null
          ? null
          : json['workflow_execution_id'] as String,
      workflowRunId: json['workflow_run_id'] == null
          ? null
          : json['workflow_run_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'algorithm': algorithm,
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    if (creatorType != null) 'creator_type': creatorType!.value,
    'deleted_at': deletedAt?.toIso8601String(),
    'description': ?description,
    if (evaluation != null) 'evaluation': evaluation!.toJson(),
    'evaluation_id': ?evaluationId,
    'id': id,
    'name': name,
    'objective_spec': ?objectiveSpec,
    'outcome': ?outcome,
    if (project != null) 'project': project!.toJson(),
    'project_id': projectId,
    'source': source,
    'status': status,
    'steer': ?steer,
    'tags': ?tags,
    'updated_at': updatedAt.toIso8601String(),
    'workflow_execution_id': ?workflowExecutionId,
    'workflow_run_id': ?workflowRunId,
  };

  /// Creates a copy with the given fields replaced.
  EvaluationOptimizationDetail copyWith({
    String? algorithm,
    DateTime? createdAt,
    String? creatorId,
    Object? creatorType = unsetCopyWithValue,
    Object? deletedAt = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? evaluation = unsetCopyWithValue,
    Object? evaluationId = unsetCopyWithValue,
    String? id,
    String? name,
    Object? objectiveSpec = unsetCopyWithValue,
    Object? outcome = unsetCopyWithValue,
    Object? project = unsetCopyWithValue,
    String? projectId,
    String? source,
    String? status,
    Object? steer = unsetCopyWithValue,
    Object? tags = unsetCopyWithValue,
    DateTime? updatedAt,
    Object? workflowExecutionId = unsetCopyWithValue,
    Object? workflowRunId = unsetCopyWithValue,
  }) => EvaluationOptimizationDetail(
    algorithm: algorithm ?? this.algorithm,
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    creatorType: creatorType == unsetCopyWithValue
        ? this.creatorType
        : creatorType as PrincipalType?,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    evaluation: evaluation == unsetCopyWithValue
        ? this.evaluation
        : evaluation as OptimizationReference?,
    evaluationId: evaluationId == unsetCopyWithValue
        ? this.evaluationId
        : evaluationId as String?,
    id: id ?? this.id,
    name: name ?? this.name,
    objectiveSpec: objectiveSpec == unsetCopyWithValue
        ? this.objectiveSpec
        : (objectiveSpec as Map?)?.cast<String, Object>(),
    outcome: outcome == unsetCopyWithValue
        ? this.outcome
        : (outcome as Map?)?.cast<String, Object>(),
    project: project == unsetCopyWithValue
        ? this.project
        : project as OptimizationReference?,
    projectId: projectId ?? this.projectId,
    source: source ?? this.source,
    status: status ?? this.status,
    steer: steer == unsetCopyWithValue ? this.steer : steer as String?,
    tags: tags == unsetCopyWithValue
        ? this.tags
        : (tags as List<Object?>?)?.cast<String>(),
    updatedAt: updatedAt ?? this.updatedAt,
    workflowExecutionId: workflowExecutionId == unsetCopyWithValue
        ? this.workflowExecutionId
        : workflowExecutionId as String?,
    workflowRunId: workflowRunId == unsetCopyWithValue
        ? this.workflowRunId
        : workflowRunId as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationOptimizationDetail &&
          runtimeType == other.runtimeType &&
          algorithm == other.algorithm &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          creatorType == other.creatorType &&
          deletedAt == other.deletedAt &&
          description == other.description &&
          evaluation == other.evaluation &&
          evaluationId == other.evaluationId &&
          id == other.id &&
          name == other.name &&
          valuesDeepEqual(objectiveSpec, other.objectiveSpec) &&
          valuesDeepEqual(outcome, other.outcome) &&
          project == other.project &&
          projectId == other.projectId &&
          source == other.source &&
          status == other.status &&
          steer == other.steer &&
          valuesDeepEqual(tags, other.tags) &&
          updatedAt == other.updatedAt &&
          workflowExecutionId == other.workflowExecutionId &&
          workflowRunId == other.workflowRunId;

  @override
  int get hashCode => Object.hashAll([
    algorithm,
    createdAt,
    creatorId,
    creatorType,
    deletedAt,
    description,
    evaluation,
    evaluationId,
    id,
    name,
    valueDeepHashCode(objectiveSpec),
    valueDeepHashCode(outcome),
    project,
    projectId,
    source,
    status,
    steer,
    valueDeepHashCode(tags),
    updatedAt,
    workflowExecutionId,
    workflowRunId,
  ]);

  @override
  String toString() =>
      'EvaluationOptimizationDetail('
      'algorithm: $algorithm, '
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'creatorType: $creatorType, '
      'deletedAt: $deletedAt, '
      'description: $description, '
      'evaluation: $evaluation, '
      'evaluationId: $evaluationId, '
      'id: $id, '
      'name: $name, '
      'objectiveSpec: ${objectiveSpec?.length}, '
      'outcome: ${outcome?.length}, '
      'project: $project, '
      'projectId: $projectId, '
      'source: $source, '
      'status: $status, '
      'steer: $steer, '
      'tags: ${tags?.length}, '
      'updatedAt: $updatedAt, '
      'workflowExecutionId: $workflowExecutionId, '
      'workflowRunId: $workflowRunId)';
}

/// The OptimizationReference wire payload.
@immutable
class OptimizationReference {
  /// Creates a [OptimizationReference].
  const OptimizationReference({
    required this.id,
    required this.name,
    required this.slug,
  });

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The slug field.
  final String slug;

  /// Parses a [OptimizationReference] from JSON.
  factory OptimizationReference.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('OptimizationReference: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('OptimizationReference: missing name');
    }
    if (json['slug'] == null) {
      throw const FormatException('OptimizationReference: missing slug');
    }
    return OptimizationReference(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  /// Creates a copy with the given fields replaced.
  OptimizationReference copyWith({String? id, String? name, String? slug}) =>
      OptimizationReference(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptimizationReference &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          slug == other.slug;

  @override
  int get hashCode => Object.hashAll([id, name, slug]);

  @override
  String toString() =>
      'OptimizationReference('
      'id: $id, '
      'name: $name, '
      'slug: $slug)';
}

/// The OptimizationTrialObservation wire payload.
@immutable
class OptimizationTrialObservation {
  /// Creates a [OptimizationTrialObservation].
  const OptimizationTrialObservation({
    this.metadata,
    this.observationType,
    required this.run,
    this.score,
  });

  /// The metadata field.
  final Map<String, Object?>? metadata;

  /// The observation_type field.
  final String? observationType;

  /// The run field.
  final EvaluationRun run;

  /// The score field.
  final double? score;

  /// Parses a [OptimizationTrialObservation] from JSON.
  factory OptimizationTrialObservation.fromJson(Map<String, dynamic> json) {
    if (json['run'] == null) {
      throw const FormatException('OptimizationTrialObservation: missing run');
    }
    return OptimizationTrialObservation(
      metadata: json['metadata'] == null
          ? null
          : json['metadata'] as Map<String, Object?>,
      observationType: json['observation_type'] == null
          ? null
          : json['observation_type'] as String,
      run: EvaluationRun.fromJson(json['run'] as Map<String, dynamic>),
      score: json['score'] == null ? null : (json['score'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'metadata': ?metadata,
    'observation_type': ?observationType,
    'run': run.toJson(),
    'score': ?score,
  };

  /// Creates a copy with the given fields replaced.
  OptimizationTrialObservation copyWith({
    Object? metadata = unsetCopyWithValue,
    Object? observationType = unsetCopyWithValue,
    EvaluationRun? run,
    Object? score = unsetCopyWithValue,
  }) => OptimizationTrialObservation(
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : (metadata as Map?)?.cast<String, Object>(),
    observationType: observationType == unsetCopyWithValue
        ? this.observationType
        : observationType as String?,
    run: run ?? this.run,
    score: score == unsetCopyWithValue
        ? this.score
        : (score as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptimizationTrialObservation &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(metadata, other.metadata) &&
          observationType == other.observationType &&
          run == other.run &&
          score == other.score;

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(metadata),
    observationType,
    run,
    score,
  ]);

  @override
  String toString() =>
      'OptimizationTrialObservation('
      'metadata: ${metadata?.length}, '
      'observationType: $observationType, '
      'run: $run, '
      'score: $score)';
}

/// The OptimizationTrialWithObservations wire payload.
@immutable
class OptimizationTrialWithObservations {
  /// Creates a [OptimizationTrialWithObservations].
  const OptimizationTrialWithObservations({
    required this.algorithmTrialKey,
    required this.createdAt,
    required this.deletedAt,
    this.hypothesis,
    required this.id,
    required this.metadata,
    this.observations,
    required this.optimizationId,
    this.parentTrialId,
    this.resolution,
    required this.status,
    required this.updatedAt,
  });

  /// The algorithm_trial_key field.
  final String algorithmTrialKey;

  /// The created_at field.
  final DateTime createdAt;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The hypothesis field.
  final String? hypothesis;

  /// The id field.
  final String id;

  /// The metadata_ field.
  final Map<String, Object?> metadata;

  /// The observations field.
  final List<OptimizationTrialObservation>? observations;

  /// The optimization_id field.
  final String optimizationId;

  /// The parent_trial_id field.
  final String? parentTrialId;

  /// The resolution field.
  final String? resolution;

  /// The status field.
  final String status;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [OptimizationTrialWithObservations] from JSON.
  factory OptimizationTrialWithObservations.fromJson(
    Map<String, dynamic> json,
  ) {
    if (json['algorithm_trial_key'] == null) {
      throw const FormatException(
        'OptimizationTrialWithObservations: missing algorithm_trial_key',
      );
    }
    if (json['created_at'] == null) {
      throw const FormatException(
        'OptimizationTrialWithObservations: missing created_at',
      );
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException(
        'OptimizationTrialWithObservations: missing deleted_at',
      );
    }
    if (json['id'] == null) {
      throw const FormatException(
        'OptimizationTrialWithObservations: missing id',
      );
    }
    if (json['metadata_'] == null) {
      throw const FormatException(
        'OptimizationTrialWithObservations: missing metadata_',
      );
    }
    if (json['optimization_id'] == null) {
      throw const FormatException(
        'OptimizationTrialWithObservations: missing optimization_id',
      );
    }
    if (json['status'] == null) {
      throw const FormatException(
        'OptimizationTrialWithObservations: missing status',
      );
    }
    if (json['updated_at'] == null) {
      throw const FormatException(
        'OptimizationTrialWithObservations: missing updated_at',
      );
    }
    return OptimizationTrialWithObservations(
      algorithmTrialKey: json['algorithm_trial_key'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      hypothesis: json['hypothesis'] == null
          ? null
          : json['hypothesis'] as String,
      id: json['id'] as String,
      metadata: json['metadata_'] as Map<String, Object?>,
      observations: json['observations'] == null
          ? null
          : (json['observations'] as List<Object?>)
                .map(
                  (item) => OptimizationTrialObservation.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      optimizationId: json['optimization_id'] as String,
      parentTrialId: json['parent_trial_id'] == null
          ? null
          : json['parent_trial_id'] as String,
      resolution: json['resolution'] == null
          ? null
          : json['resolution'] as String,
      status: json['status'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'algorithm_trial_key': algorithmTrialKey,
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'hypothesis': ?hypothesis,
    'id': id,
    'metadata_': metadata,
    if (observations != null)
      'observations': observations!.map((item) => item.toJson()).toList(),
    'optimization_id': optimizationId,
    'parent_trial_id': ?parentTrialId,
    'resolution': ?resolution,
    'status': status,
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  OptimizationTrialWithObservations copyWith({
    String? algorithmTrialKey,
    DateTime? createdAt,
    Object? deletedAt = unsetCopyWithValue,
    Object? hypothesis = unsetCopyWithValue,
    String? id,
    Map<String, Object?>? metadata,
    Object? observations = unsetCopyWithValue,
    String? optimizationId,
    Object? parentTrialId = unsetCopyWithValue,
    Object? resolution = unsetCopyWithValue,
    String? status,
    DateTime? updatedAt,
  }) => OptimizationTrialWithObservations(
    algorithmTrialKey: algorithmTrialKey ?? this.algorithmTrialKey,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    hypothesis: hypothesis == unsetCopyWithValue
        ? this.hypothesis
        : hypothesis as String?,
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    observations: observations == unsetCopyWithValue
        ? this.observations
        : (observations as List<Object?>?)
              ?.cast<OptimizationTrialObservation>(),
    optimizationId: optimizationId ?? this.optimizationId,
    parentTrialId: parentTrialId == unsetCopyWithValue
        ? this.parentTrialId
        : parentTrialId as String?,
    resolution: resolution == unsetCopyWithValue
        ? this.resolution
        : resolution as String?,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OptimizationTrialWithObservations &&
          runtimeType == other.runtimeType &&
          algorithmTrialKey == other.algorithmTrialKey &&
          createdAt == other.createdAt &&
          deletedAt == other.deletedAt &&
          hypothesis == other.hypothesis &&
          id == other.id &&
          valuesDeepEqual(metadata, other.metadata) &&
          valuesDeepEqual(observations, other.observations) &&
          optimizationId == other.optimizationId &&
          parentTrialId == other.parentTrialId &&
          resolution == other.resolution &&
          status == other.status &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    algorithmTrialKey,
    createdAt,
    deletedAt,
    hypothesis,
    id,
    valueDeepHashCode(metadata),
    valueDeepHashCode(observations),
    optimizationId,
    parentTrialId,
    resolution,
    status,
    updatedAt,
  ]);

  @override
  String toString() =>
      'OptimizationTrialWithObservations('
      'algorithmTrialKey: $algorithmTrialKey, '
      'createdAt: $createdAt, '
      'deletedAt: $deletedAt, '
      'hypothesis: $hypothesis, '
      'id: $id, '
      'metadata: ${metadata.length}, '
      'observations: ${observations?.length}, '
      'optimizationId: $optimizationId, '
      'parentTrialId: $parentTrialId, '
      'resolution: $resolution, '
      'status: $status, '
      'updatedAt: $updatedAt)';
}
