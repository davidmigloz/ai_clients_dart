import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../workflows/principal_type.dart';
import 'evaluation_statistics.dart';
import 'paginated_result.dart';

/// The EvaluationRunGenerationV2 wire payload.
@immutable
class EvaluationRunGeneration {
  /// Creates a [EvaluationRunGeneration].
  const EvaluationRunGeneration({
    required this.createdAt,
    required this.deletedAt,
    this.error,
    this.goalResults,
    required this.id,
    required this.metadata,
    required this.output,
    this.scores,
    this.statistics,
    required this.status,
    required this.updatedAt,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The error field.
  final String? error;

  /// The goal_results field.
  final Map<String, GoalResult>? goalResults;

  /// The id field.
  final String id;

  /// The metadata_ field.
  final Map<String, Object?> metadata;

  /// The output field.
  final Object? output;

  /// The scores field.
  final Map<String, List<EvaluationRecordScore>>? scores;

  /// The statistics field.
  final Map<String, EvaluatorStatistics>? statistics;

  /// The status field.
  final String status;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [EvaluationRunGeneration] from JSON.
  factory EvaluationRunGeneration.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException(
        'EvaluationRunGeneration: missing created_at',
      );
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException(
        'EvaluationRunGeneration: missing deleted_at',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationRunGeneration: missing id');
    }
    if (json['metadata_'] == null) {
      throw const FormatException('EvaluationRunGeneration: missing metadata_');
    }
    if (!json.containsKey('output')) {
      throw const FormatException('EvaluationRunGeneration: missing output');
    }
    if (json['status'] == null) {
      throw const FormatException('EvaluationRunGeneration: missing status');
    }
    if (json['updated_at'] == null) {
      throw const FormatException(
        'EvaluationRunGeneration: missing updated_at',
      );
    }
    return EvaluationRunGeneration(
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      error: json['error'] == null ? null : json['error'] as String,
      goalResults: json['goal_results'] == null
          ? null
          : (json['goal_results'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                GoalResult.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      id: json['id'] as String,
      metadata: json['metadata_'] as Map<String, Object?>,
      output: json['output'],
      scores: json['scores'] == null
          ? null
          : (json['scores'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                (item! as List<Object?>)
                    .map(
                      (item) => EvaluationRecordScore.fromJson(
                        item! as Map<String, dynamic>,
                      ),
                    )
                    .toList(),
              ),
            ),
      statistics: json['statistics'] == null
          ? null
          : (json['statistics'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                EvaluatorStatistics.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      status: json['status'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'error': ?error,
    if (goalResults != null)
      'goal_results': goalResults!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'id': id,
    'metadata_': metadata,
    'output': output,
    if (scores != null)
      'scores': scores!.map(
        (key, item) =>
            MapEntry(key, item.map((item) => item.toJson()).toList()),
      ),
    if (statistics != null)
      'statistics': statistics!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'status': status,
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  EvaluationRunGeneration copyWith({
    DateTime? createdAt,
    Object? deletedAt = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    Object? goalResults = unsetCopyWithValue,
    String? id,
    Map<String, Object?>? metadata,
    Object? output = unsetCopyWithValue,
    Object? scores = unsetCopyWithValue,
    Object? statistics = unsetCopyWithValue,
    String? status,
    DateTime? updatedAt,
  }) => EvaluationRunGeneration(
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    error: error == unsetCopyWithValue ? this.error : error as String?,
    goalResults: goalResults == unsetCopyWithValue
        ? this.goalResults
        : (goalResults as Map?)?.cast<String, GoalResult>(),
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    output: output == unsetCopyWithValue ? this.output : output,
    scores: scores == unsetCopyWithValue
        ? this.scores
        : (scores as Map?)?.cast<String, List<EvaluationRecordScore>>(),
    statistics: statistics == unsetCopyWithValue
        ? this.statistics
        : (statistics as Map?)?.cast<String, EvaluatorStatistics>(),
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRunGeneration &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          deletedAt == other.deletedAt &&
          error == other.error &&
          valuesDeepEqual(goalResults, other.goalResults) &&
          id == other.id &&
          valuesDeepEqual(metadata, other.metadata) &&
          output == other.output &&
          valuesDeepEqual(scores, other.scores) &&
          valuesDeepEqual(statistics, other.statistics) &&
          status == other.status &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    deletedAt,
    error,
    valueDeepHashCode(goalResults),
    id,
    valueDeepHashCode(metadata),
    output,
    valueDeepHashCode(scores),
    valueDeepHashCode(statistics),
    status,
    updatedAt,
  ]);

  @override
  String toString() =>
      'EvaluationRunGeneration('
      'createdAt: $createdAt, '
      'deletedAt: $deletedAt, '
      'error: $error, '
      'goalResults: ${goalResults?.length}, '
      'id: $id, '
      'metadata: ${metadata.length}, '
      'output: $output, '
      'scores: ${scores?.length}, '
      'statistics: ${statistics?.length}, '
      'status: $status, '
      'updatedAt: $updatedAt)';
}

/// The EvaluationRunOutputRecordV2 wire payload.
@immutable
class EvaluationRunOutputRecord {
  /// Creates a [EvaluationRunOutputRecord].
  const EvaluationRunOutputRecord({
    required this.createdAt,
    required this.deletedAt,
    this.generations,
    this.goalResults,
    required this.id,
    required this.metadata,
    this.recordInfo,
    this.statistics,
    required this.updatedAt,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The generations field.
  final List<EvaluationRunGeneration>? generations;

  /// The goal_results field.
  final Map<String, GoalResult>? goalResults;

  /// The id field.
  final String id;

  /// The metadata_ field.
  final Map<String, Object?> metadata;

  /// The record_info field.
  final Map<String, Object?>? recordInfo;

  /// The statistics field.
  final Map<String, EvaluatorStatistics>? statistics;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [EvaluationRunOutputRecord] from JSON.
  factory EvaluationRunOutputRecord.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException(
        'EvaluationRunOutputRecord: missing created_at',
      );
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException(
        'EvaluationRunOutputRecord: missing deleted_at',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationRunOutputRecord: missing id');
    }
    if (json['metadata_'] == null) {
      throw const FormatException(
        'EvaluationRunOutputRecord: missing metadata_',
      );
    }
    if (json['updated_at'] == null) {
      throw const FormatException(
        'EvaluationRunOutputRecord: missing updated_at',
      );
    }
    return EvaluationRunOutputRecord(
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      generations: json['generations'] == null
          ? null
          : (json['generations'] as List<Object?>)
                .map(
                  (item) => EvaluationRunGeneration.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      goalResults: json['goal_results'] == null
          ? null
          : (json['goal_results'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                GoalResult.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      id: json['id'] as String,
      metadata: json['metadata_'] as Map<String, Object?>,
      recordInfo: json['record_info'] == null
          ? null
          : json['record_info'] as Map<String, Object?>,
      statistics: json['statistics'] == null
          ? null
          : (json['statistics'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                EvaluatorStatistics.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    if (generations != null)
      'generations': generations!.map((item) => item.toJson()).toList(),
    if (goalResults != null)
      'goal_results': goalResults!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'id': id,
    'metadata_': metadata,
    'record_info': ?recordInfo,
    if (statistics != null)
      'statistics': statistics!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  EvaluationRunOutputRecord copyWith({
    DateTime? createdAt,
    Object? deletedAt = unsetCopyWithValue,
    Object? generations = unsetCopyWithValue,
    Object? goalResults = unsetCopyWithValue,
    String? id,
    Map<String, Object?>? metadata,
    Object? recordInfo = unsetCopyWithValue,
    Object? statistics = unsetCopyWithValue,
    DateTime? updatedAt,
  }) => EvaluationRunOutputRecord(
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    generations: generations == unsetCopyWithValue
        ? this.generations
        : (generations as List<Object?>?)?.cast<EvaluationRunGeneration>(),
    goalResults: goalResults == unsetCopyWithValue
        ? this.goalResults
        : (goalResults as Map?)?.cast<String, GoalResult>(),
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    recordInfo: recordInfo == unsetCopyWithValue
        ? this.recordInfo
        : (recordInfo as Map?)?.cast<String, Object>(),
    statistics: statistics == unsetCopyWithValue
        ? this.statistics
        : (statistics as Map?)?.cast<String, EvaluatorStatistics>(),
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRunOutputRecord &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          deletedAt == other.deletedAt &&
          valuesDeepEqual(generations, other.generations) &&
          valuesDeepEqual(goalResults, other.goalResults) &&
          id == other.id &&
          valuesDeepEqual(metadata, other.metadata) &&
          valuesDeepEqual(recordInfo, other.recordInfo) &&
          valuesDeepEqual(statistics, other.statistics) &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    deletedAt,
    valueDeepHashCode(generations),
    valueDeepHashCode(goalResults),
    id,
    valueDeepHashCode(metadata),
    valueDeepHashCode(recordInfo),
    valueDeepHashCode(statistics),
    updatedAt,
  ]);

  @override
  String toString() =>
      'EvaluationRunOutputRecord('
      'createdAt: $createdAt, '
      'deletedAt: $deletedAt, '
      'generations: ${generations?.length}, '
      'goalResults: ${goalResults?.length}, '
      'id: $id, '
      'metadata: ${metadata.length}, '
      'recordInfo: ${recordInfo?.length}, '
      'statistics: ${statistics?.length}, '
      'updatedAt: $updatedAt)';
}

/// The EvaluationRunRecordV2Response wire payload.
@immutable
class EvaluationRunRecord {
  /// Creates a [EvaluationRunRecord].
  const EvaluationRunRecord({
    required this.createdAt,
    this.datasetRecordId,
    required this.deletedAt,
    required this.id,
    required this.input,
    this.outputRecord,
    required this.updatedAt,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The dataset_record_id field.
  final String? datasetRecordId;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The id field.
  final String id;

  /// The input field.
  final Object? input;

  /// The output_record field.
  final EvaluationRunOutputRecord? outputRecord;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [EvaluationRunRecord] from JSON.
  factory EvaluationRunRecord.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('EvaluationRunRecord: missing created_at');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('EvaluationRunRecord: missing deleted_at');
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationRunRecord: missing id');
    }
    if (!json.containsKey('input')) {
      throw const FormatException('EvaluationRunRecord: missing input');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('EvaluationRunRecord: missing updated_at');
    }
    return EvaluationRunRecord(
      createdAt: DateTime.parse(json['created_at'] as String),
      datasetRecordId: json['dataset_record_id'] == null
          ? null
          : json['dataset_record_id'] as String,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      id: json['id'] as String,
      input: json['input'],
      outputRecord: json['output_record'] == null
          ? null
          : EvaluationRunOutputRecord.fromJson(
              json['output_record'] as Map<String, dynamic>,
            ),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'dataset_record_id': ?datasetRecordId,
    'deleted_at': deletedAt?.toIso8601String(),
    'id': id,
    'input': input,
    if (outputRecord != null) 'output_record': outputRecord!.toJson(),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  EvaluationRunRecord copyWith({
    DateTime? createdAt,
    Object? datasetRecordId = unsetCopyWithValue,
    Object? deletedAt = unsetCopyWithValue,
    String? id,
    Object? input = unsetCopyWithValue,
    Object? outputRecord = unsetCopyWithValue,
    DateTime? updatedAt,
  }) => EvaluationRunRecord(
    createdAt: createdAt ?? this.createdAt,
    datasetRecordId: datasetRecordId == unsetCopyWithValue
        ? this.datasetRecordId
        : datasetRecordId as String?,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    id: id ?? this.id,
    input: input == unsetCopyWithValue ? this.input : input,
    outputRecord: outputRecord == unsetCopyWithValue
        ? this.outputRecord
        : outputRecord as EvaluationRunOutputRecord?,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRunRecord &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          datasetRecordId == other.datasetRecordId &&
          deletedAt == other.deletedAt &&
          id == other.id &&
          input == other.input &&
          outputRecord == other.outputRecord &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    datasetRecordId,
    deletedAt,
    id,
    input,
    outputRecord,
    updatedAt,
  ]);

  @override
  String toString() =>
      'EvaluationRunRecord('
      'createdAt: $createdAt, '
      'datasetRecordId: $datasetRecordId, '
      'deletedAt: $deletedAt, '
      'id: $id, '
      'input: $input, '
      'outputRecord: $outputRecord, '
      'updatedAt: $updatedAt)';
}

/// A run evaluator's score: a per-record score plus its metrics.
@immutable
class EvaluationRunSummaryScore {
  /// Creates a [EvaluationRunSummaryScore].
  const EvaluationRunSummaryScore({
    required this.createdAt,
    required this.deletedAt,
    this.error,
    required this.id,
    required this.metadata,
    this.metrics,
    this.rationale,
    required this.status,
    required this.updatedAt,
    required this.value,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The error field.
  final String? error;

  /// The id field.
  final String id;

  /// The metadata_ field.
  final Map<String, Object?> metadata;

  /// The metrics field.
  final List<ScoreMetric>? metrics;

  /// The rationale field.
  final String? rationale;

  /// The status field.
  final String status;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The value field.
  final Object? value;

  /// Parses a [EvaluationRunSummaryScore] from JSON.
  factory EvaluationRunSummaryScore.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException(
        'EvaluationRunSummaryScore: missing created_at',
      );
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException(
        'EvaluationRunSummaryScore: missing deleted_at',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationRunSummaryScore: missing id');
    }
    if (json['metadata_'] == null) {
      throw const FormatException(
        'EvaluationRunSummaryScore: missing metadata_',
      );
    }
    if (json['status'] == null) {
      throw const FormatException('EvaluationRunSummaryScore: missing status');
    }
    if (json['updated_at'] == null) {
      throw const FormatException(
        'EvaluationRunSummaryScore: missing updated_at',
      );
    }
    if (!json.containsKey('value')) {
      throw const FormatException('EvaluationRunSummaryScore: missing value');
    }
    return EvaluationRunSummaryScore(
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      error: json['error'] == null ? null : json['error'] as String,
      id: json['id'] as String,
      metadata: json['metadata_'] as Map<String, Object?>,
      metrics: json['metrics'] == null
          ? null
          : (json['metrics'] as List<Object?>)
                .map(
                  (item) => ScoreMetric.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
      rationale: json['rationale'] == null ? null : json['rationale'] as String,
      status: json['status'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      value: json['value'],
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'error': ?error,
    'id': id,
    'metadata_': metadata,
    if (metrics != null)
      'metrics': metrics!.map((item) => item.toJson()).toList(),
    'rationale': ?rationale,
    'status': status,
    'updated_at': updatedAt.toIso8601String(),
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  EvaluationRunSummaryScore copyWith({
    DateTime? createdAt,
    Object? deletedAt = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    String? id,
    Map<String, Object?>? metadata,
    Object? metrics = unsetCopyWithValue,
    Object? rationale = unsetCopyWithValue,
    String? status,
    DateTime? updatedAt,
    Object? value = unsetCopyWithValue,
  }) => EvaluationRunSummaryScore(
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    error: error == unsetCopyWithValue ? this.error : error as String?,
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    metrics: metrics == unsetCopyWithValue
        ? this.metrics
        : (metrics as List<Object?>?)?.cast<ScoreMetric>(),
    rationale: rationale == unsetCopyWithValue
        ? this.rationale
        : rationale as String?,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
    value: value == unsetCopyWithValue ? this.value : value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRunSummaryScore &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          deletedAt == other.deletedAt &&
          error == other.error &&
          id == other.id &&
          valuesDeepEqual(metadata, other.metadata) &&
          valuesDeepEqual(metrics, other.metrics) &&
          rationale == other.rationale &&
          status == other.status &&
          updatedAt == other.updatedAt &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    deletedAt,
    error,
    id,
    valueDeepHashCode(metadata),
    valueDeepHashCode(metrics),
    rationale,
    status,
    updatedAt,
    value,
  ]);

  @override
  String toString() =>
      'EvaluationRunSummaryScore('
      'createdAt: $createdAt, '
      'deletedAt: $deletedAt, '
      'error: $error, '
      'id: $id, '
      'metadata: ${metadata.length}, '
      'metrics: ${metrics?.length}, '
      'rationale: $rationale, '
      'status: $status, '
      'updatedAt: $updatedAt, '
      'value: $value)';
}

/// The EvaluationRunScoreV2 wire payload.
@immutable
class EvaluationRecordScore {
  /// Creates a [EvaluationRecordScore].
  const EvaluationRecordScore({
    required this.createdAt,
    required this.deletedAt,
    this.error,
    required this.id,
    required this.metadata,
    this.rationale,
    required this.status,
    required this.updatedAt,
    required this.value,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The error field.
  final String? error;

  /// The id field.
  final String id;

  /// The metadata_ field.
  final Map<String, Object?> metadata;

  /// The rationale field.
  final String? rationale;

  /// The status field.
  final String status;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The value field.
  final Object? value;

  /// Parses a [EvaluationRecordScore] from JSON.
  factory EvaluationRecordScore.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('EvaluationRecordScore: missing created_at');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('EvaluationRecordScore: missing deleted_at');
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationRecordScore: missing id');
    }
    if (json['metadata_'] == null) {
      throw const FormatException('EvaluationRecordScore: missing metadata_');
    }
    if (json['status'] == null) {
      throw const FormatException('EvaluationRecordScore: missing status');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('EvaluationRecordScore: missing updated_at');
    }
    if (!json.containsKey('value')) {
      throw const FormatException('EvaluationRecordScore: missing value');
    }
    return EvaluationRecordScore(
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      error: json['error'] == null ? null : json['error'] as String,
      id: json['id'] as String,
      metadata: json['metadata_'] as Map<String, Object?>,
      rationale: json['rationale'] == null ? null : json['rationale'] as String,
      status: json['status'] as String,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      value: json['value'],
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'error': ?error,
    'id': id,
    'metadata_': metadata,
    'rationale': ?rationale,
    'status': status,
    'updated_at': updatedAt.toIso8601String(),
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  EvaluationRecordScore copyWith({
    DateTime? createdAt,
    Object? deletedAt = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    String? id,
    Map<String, Object?>? metadata,
    Object? rationale = unsetCopyWithValue,
    String? status,
    DateTime? updatedAt,
    Object? value = unsetCopyWithValue,
  }) => EvaluationRecordScore(
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    error: error == unsetCopyWithValue ? this.error : error as String?,
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    rationale: rationale == unsetCopyWithValue
        ? this.rationale
        : rationale as String?,
    status: status ?? this.status,
    updatedAt: updatedAt ?? this.updatedAt,
    value: value == unsetCopyWithValue ? this.value : value,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRecordScore &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          deletedAt == other.deletedAt &&
          error == other.error &&
          id == other.id &&
          valuesDeepEqual(metadata, other.metadata) &&
          rationale == other.rationale &&
          status == other.status &&
          updatedAt == other.updatedAt &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    deletedAt,
    error,
    id,
    valueDeepHashCode(metadata),
    rationale,
    status,
    updatedAt,
    value,
  ]);

  @override
  String toString() =>
      'EvaluationRecordScore('
      'createdAt: $createdAt, '
      'deletedAt: $deletedAt, '
      'error: $error, '
      'id: $id, '
      'metadata: ${metadata.length}, '
      'rationale: $rationale, '
      'status: $status, '
      'updatedAt: $updatedAt, '
      'value: $value)';
}

/// The EvaluationRunV2Response wire payload.
@immutable
class EvaluationRun {
  /// Creates a [EvaluationRun].
  const EvaluationRun({
    required this.createdAt,
    required this.creatorId,
    this.creatorType,
    this.datasetId,
    required this.deletedAt,
    required this.description,
    required this.evaluationId,
    required this.evaluators,
    this.failedRecordCount,
    this.goalResults,
    required this.id,
    required this.metadata,
    required this.name,
    required this.numGenerations,
    this.optimization,
    this.passed,
    this.recordCount,
    this.runEvaluators,
    this.runInfo,
    this.runScores,
    this.statistics,
    this.status,
    this.system,
    required this.tags,
    required this.updatedAt,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The creator_type field.
  final PrincipalType? creatorType;

  /// The dataset_id field.
  final String? datasetId;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The description field.
  final String? description;

  /// The evaluation_id field.
  final String evaluationId;

  /// The evaluators field.
  final List<ObservabilityEvaluator> evaluators;

  /// Records whose task or at least one score failed, out of `record_count`. Failed tasks and scores are left out of `statistics`, `goal_results` and `passed`. Null for runs created before this counter existed.
  final int? failedRecordCount;

  /// The goal_results field.
  final Map<String, GoalResult>? goalResults;

  /// The id field.
  final String id;

  /// The metadata_ field.
  final Map<String, Object?> metadata;

  /// The name field.
  final String name;

  /// The num_generations field.
  final int numGenerations;

  /// The optimization field.
  final RunOptimizationRef? optimization;

  /// The passed field.
  final bool? passed;

  /// Records whose results were uploaded so far, failed or not. Null for runs created before this counter existed.
  final int? recordCount;

  /// The run_evaluators field.
  final List<ObservabilityEvaluator>? runEvaluators;

  /// The run_info field.
  final Map<String, Object?>? runInfo;

  /// The run_scores field.
  final Map<String, EvaluationRunSummaryScore>? runScores;

  /// The statistics field.
  final Map<String, EvaluatorStatistics>? statistics;

  /// The status field.
  final String? status;

  /// The system field.
  final EvaluationSystem? system;

  /// The tags field.
  final List<String> tags;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [EvaluationRun] from JSON.
  factory EvaluationRun.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('EvaluationRun: missing created_at');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('EvaluationRun: missing creator_id');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('EvaluationRun: missing deleted_at');
    }
    if (!json.containsKey('description')) {
      throw const FormatException('EvaluationRun: missing description');
    }
    if (json['evaluation_id'] == null) {
      throw const FormatException('EvaluationRun: missing evaluation_id');
    }
    if (json['evaluators'] == null) {
      throw const FormatException('EvaluationRun: missing evaluators');
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationRun: missing id');
    }
    if (json['metadata_'] == null) {
      throw const FormatException('EvaluationRun: missing metadata_');
    }
    if (json['name'] == null) {
      throw const FormatException('EvaluationRun: missing name');
    }
    if (json['num_generations'] == null) {
      throw const FormatException('EvaluationRun: missing num_generations');
    }
    if (json['tags'] == null) {
      throw const FormatException('EvaluationRun: missing tags');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('EvaluationRun: missing updated_at');
    }
    return EvaluationRun(
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] as String,
      creatorType: json['creator_type'] == null
          ? null
          : PrincipalType.fromJson(json['creator_type'] as String?),
      datasetId: json['dataset_id'] == null
          ? null
          : json['dataset_id'] as String,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      evaluationId: json['evaluation_id'] as String,
      evaluators: (json['evaluators'] as List<Object?>)
          .map(
            (item) =>
                ObservabilityEvaluator.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
      failedRecordCount: json['failed_record_count'] == null
          ? null
          : json['failed_record_count'] as int,
      goalResults: json['goal_results'] == null
          ? null
          : (json['goal_results'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                GoalResult.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      id: json['id'] as String,
      metadata: json['metadata_'] as Map<String, Object?>,
      name: json['name'] as String,
      numGenerations: json['num_generations'] as int,
      optimization: json['optimization'] == null
          ? null
          : RunOptimizationRef.fromJson(
              json['optimization'] as Map<String, dynamic>,
            ),
      passed: json['passed'] == null ? null : json['passed'] as bool,
      recordCount: json['record_count'] == null
          ? null
          : json['record_count'] as int,
      runEvaluators: json['run_evaluators'] == null
          ? null
          : (json['run_evaluators'] as List<Object?>)
                .map(
                  (item) => ObservabilityEvaluator.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      runInfo: json['run_info'] == null
          ? null
          : json['run_info'] as Map<String, Object?>,
      runScores: json['run_scores'] == null
          ? null
          : (json['run_scores'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                EvaluationRunSummaryScore.fromJson(
                  item! as Map<String, dynamic>,
                ),
              ),
            ),
      statistics: json['statistics'] == null
          ? null
          : (json['statistics'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                EvaluatorStatistics.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      status: json['status'] == null ? null : json['status'] as String,
      system: json['system'] == null
          ? null
          : EvaluationSystem.fromJson(json['system'] as Map<String, dynamic>),
      tags: (json['tags'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    if (creatorType != null) 'creator_type': creatorType!.value,
    'dataset_id': ?datasetId,
    'deleted_at': deletedAt?.toIso8601String(),
    'description': description,
    'evaluation_id': evaluationId,
    'evaluators': evaluators.map((item) => item.toJson()).toList(),
    'failed_record_count': ?failedRecordCount,
    if (goalResults != null)
      'goal_results': goalResults!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'id': id,
    'metadata_': metadata,
    'name': name,
    'num_generations': numGenerations,
    if (optimization != null) 'optimization': optimization!.toJson(),
    'passed': ?passed,
    'record_count': ?recordCount,
    if (runEvaluators != null)
      'run_evaluators': runEvaluators!.map((item) => item.toJson()).toList(),
    'run_info': ?runInfo,
    if (runScores != null)
      'run_scores': runScores!.map((key, item) => MapEntry(key, item.toJson())),
    if (statistics != null)
      'statistics': statistics!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'status': ?status,
    if (system != null) 'system': system!.toJson(),
    'tags': tags,
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  EvaluationRun copyWith({
    DateTime? createdAt,
    String? creatorId,
    Object? creatorType = unsetCopyWithValue,
    Object? datasetId = unsetCopyWithValue,
    Object? deletedAt = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    String? evaluationId,
    List<ObservabilityEvaluator>? evaluators,
    Object? failedRecordCount = unsetCopyWithValue,
    Object? goalResults = unsetCopyWithValue,
    String? id,
    Map<String, Object?>? metadata,
    String? name,
    int? numGenerations,
    Object? optimization = unsetCopyWithValue,
    Object? passed = unsetCopyWithValue,
    Object? recordCount = unsetCopyWithValue,
    Object? runEvaluators = unsetCopyWithValue,
    Object? runInfo = unsetCopyWithValue,
    Object? runScores = unsetCopyWithValue,
    Object? statistics = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    List<String>? tags,
    DateTime? updatedAt,
  }) => EvaluationRun(
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    creatorType: creatorType == unsetCopyWithValue
        ? this.creatorType
        : creatorType as PrincipalType?,
    datasetId: datasetId == unsetCopyWithValue
        ? this.datasetId
        : datasetId as String?,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    evaluationId: evaluationId ?? this.evaluationId,
    evaluators: evaluators ?? this.evaluators,
    failedRecordCount: failedRecordCount == unsetCopyWithValue
        ? this.failedRecordCount
        : failedRecordCount as int?,
    goalResults: goalResults == unsetCopyWithValue
        ? this.goalResults
        : (goalResults as Map?)?.cast<String, GoalResult>(),
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    name: name ?? this.name,
    numGenerations: numGenerations ?? this.numGenerations,
    optimization: optimization == unsetCopyWithValue
        ? this.optimization
        : optimization as RunOptimizationRef?,
    passed: passed == unsetCopyWithValue ? this.passed : passed as bool?,
    recordCount: recordCount == unsetCopyWithValue
        ? this.recordCount
        : recordCount as int?,
    runEvaluators: runEvaluators == unsetCopyWithValue
        ? this.runEvaluators
        : (runEvaluators as List<Object?>?)?.cast<ObservabilityEvaluator>(),
    runInfo: runInfo == unsetCopyWithValue
        ? this.runInfo
        : (runInfo as Map?)?.cast<String, Object>(),
    runScores: runScores == unsetCopyWithValue
        ? this.runScores
        : (runScores as Map?)?.cast<String, EvaluationRunSummaryScore>(),
    statistics: statistics == unsetCopyWithValue
        ? this.statistics
        : (statistics as Map?)?.cast<String, EvaluatorStatistics>(),
    status: status == unsetCopyWithValue ? this.status : status as String?,
    system: system == unsetCopyWithValue
        ? this.system
        : system as EvaluationSystem?,
    tags: tags ?? this.tags,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationRun &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          creatorType == other.creatorType &&
          datasetId == other.datasetId &&
          deletedAt == other.deletedAt &&
          description == other.description &&
          evaluationId == other.evaluationId &&
          valuesDeepEqual(evaluators, other.evaluators) &&
          failedRecordCount == other.failedRecordCount &&
          valuesDeepEqual(goalResults, other.goalResults) &&
          id == other.id &&
          valuesDeepEqual(metadata, other.metadata) &&
          name == other.name &&
          numGenerations == other.numGenerations &&
          optimization == other.optimization &&
          passed == other.passed &&
          recordCount == other.recordCount &&
          valuesDeepEqual(runEvaluators, other.runEvaluators) &&
          valuesDeepEqual(runInfo, other.runInfo) &&
          valuesDeepEqual(runScores, other.runScores) &&
          valuesDeepEqual(statistics, other.statistics) &&
          status == other.status &&
          system == other.system &&
          valuesDeepEqual(tags, other.tags) &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    creatorId,
    creatorType,
    datasetId,
    deletedAt,
    description,
    evaluationId,
    valueDeepHashCode(evaluators),
    failedRecordCount,
    valueDeepHashCode(goalResults),
    id,
    valueDeepHashCode(metadata),
    name,
    numGenerations,
    optimization,
    passed,
    recordCount,
    valueDeepHashCode(runEvaluators),
    valueDeepHashCode(runInfo),
    valueDeepHashCode(runScores),
    valueDeepHashCode(statistics),
    status,
    system,
    valueDeepHashCode(tags),
    updatedAt,
  ]);

  @override
  String toString() =>
      'EvaluationRun('
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'creatorType: $creatorType, '
      'datasetId: $datasetId, '
      'deletedAt: $deletedAt, '
      'description: $description, '
      'evaluationId: $evaluationId, '
      'evaluators: ${evaluators.length}, '
      'failedRecordCount: $failedRecordCount, '
      'goalResults: ${goalResults?.length}, '
      'id: $id, '
      'metadata: ${metadata.length}, '
      'name: $name, '
      'numGenerations: $numGenerations, '
      'optimization: $optimization, '
      'passed: $passed, '
      'recordCount: $recordCount, '
      'runEvaluators: ${runEvaluators?.length}, '
      'runInfo: ${runInfo?.length}, '
      'runScores: ${runScores?.length}, '
      'statistics: ${statistics?.length}, '
      'status: $status, '
      'system: $system, '
      'tags: ${tags.length}, '
      'updatedAt: $updatedAt)';
}

/// The EvaluationRunV2WithRefsResponse wire payload.
@immutable
class SearchEvaluationRun {
  /// Creates a [SearchEvaluationRun].
  const SearchEvaluationRun({
    required this.createdAt,
    required this.creatorId,
    this.creatorType,
    this.datasetId,
    required this.deletedAt,
    required this.description,
    this.evaluation,
    required this.evaluationId,
    required this.evaluators,
    this.failedRecordCount,
    this.goalResults,
    required this.id,
    required this.metadata,
    required this.name,
    required this.numGenerations,
    this.optimization,
    this.passed,
    this.project,
    this.recordCount,
    this.runEvaluators,
    this.runInfo,
    this.runScores,
    this.statistics,
    this.status,
    this.system,
    required this.tags,
    required this.updatedAt,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The creator_type field.
  final PrincipalType? creatorType;

  /// The dataset_id field.
  final String? datasetId;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The description field.
  final String? description;

  /// The evaluation field.
  final RunEvaluationSummary? evaluation;

  /// The evaluation_id field.
  final String evaluationId;

  /// The evaluators field.
  final List<ObservabilityEvaluator> evaluators;

  /// Records whose task or at least one score failed, out of `record_count`. Failed tasks and scores are left out of `statistics`, `goal_results` and `passed`. Null for runs created before this counter existed.
  final int? failedRecordCount;

  /// The goal_results field.
  final Map<String, GoalResult>? goalResults;

  /// The id field.
  final String id;

  /// The metadata_ field.
  final Map<String, Object?> metadata;

  /// The name field.
  final String name;

  /// The num_generations field.
  final int numGenerations;

  /// The optimization field.
  final RunOptimizationRef? optimization;

  /// The passed field.
  final bool? passed;

  /// The project field.
  final RunProjectSummary? project;

  /// Records whose results were uploaded so far, failed or not. Null for runs created before this counter existed.
  final int? recordCount;

  /// The run_evaluators field.
  final List<ObservabilityEvaluator>? runEvaluators;

  /// The run_info field.
  final Map<String, Object?>? runInfo;

  /// The run_scores field.
  final Map<String, EvaluationRunSummaryScore>? runScores;

  /// The statistics field.
  final Map<String, EvaluatorStatistics>? statistics;

  /// The status field.
  final String? status;

  /// The system field.
  final EvaluationSystem? system;

  /// The tags field.
  final List<String> tags;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [SearchEvaluationRun] from JSON.
  factory SearchEvaluationRun.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('SearchEvaluationRun: missing created_at');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('SearchEvaluationRun: missing creator_id');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('SearchEvaluationRun: missing deleted_at');
    }
    if (!json.containsKey('description')) {
      throw const FormatException('SearchEvaluationRun: missing description');
    }
    if (json['evaluation_id'] == null) {
      throw const FormatException('SearchEvaluationRun: missing evaluation_id');
    }
    if (json['evaluators'] == null) {
      throw const FormatException('SearchEvaluationRun: missing evaluators');
    }
    if (json['id'] == null) {
      throw const FormatException('SearchEvaluationRun: missing id');
    }
    if (json['metadata_'] == null) {
      throw const FormatException('SearchEvaluationRun: missing metadata_');
    }
    if (json['name'] == null) {
      throw const FormatException('SearchEvaluationRun: missing name');
    }
    if (json['num_generations'] == null) {
      throw const FormatException(
        'SearchEvaluationRun: missing num_generations',
      );
    }
    if (json['tags'] == null) {
      throw const FormatException('SearchEvaluationRun: missing tags');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('SearchEvaluationRun: missing updated_at');
    }
    return SearchEvaluationRun(
      createdAt: DateTime.parse(json['created_at'] as String),
      creatorId: json['creator_id'] as String,
      creatorType: json['creator_type'] == null
          ? null
          : PrincipalType.fromJson(json['creator_type'] as String?),
      datasetId: json['dataset_id'] == null
          ? null
          : json['dataset_id'] as String,
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      evaluation: json['evaluation'] == null
          ? null
          : RunEvaluationSummary.fromJson(
              json['evaluation'] as Map<String, dynamic>,
            ),
      evaluationId: json['evaluation_id'] as String,
      evaluators: (json['evaluators'] as List<Object?>)
          .map(
            (item) =>
                ObservabilityEvaluator.fromJson(item! as Map<String, dynamic>),
          )
          .toList(),
      failedRecordCount: json['failed_record_count'] == null
          ? null
          : json['failed_record_count'] as int,
      goalResults: json['goal_results'] == null
          ? null
          : (json['goal_results'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                GoalResult.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      id: json['id'] as String,
      metadata: json['metadata_'] as Map<String, Object?>,
      name: json['name'] as String,
      numGenerations: json['num_generations'] as int,
      optimization: json['optimization'] == null
          ? null
          : RunOptimizationRef.fromJson(
              json['optimization'] as Map<String, dynamic>,
            ),
      passed: json['passed'] == null ? null : json['passed'] as bool,
      project: json['project'] == null
          ? null
          : RunProjectSummary.fromJson(json['project'] as Map<String, dynamic>),
      recordCount: json['record_count'] == null
          ? null
          : json['record_count'] as int,
      runEvaluators: json['run_evaluators'] == null
          ? null
          : (json['run_evaluators'] as List<Object?>)
                .map(
                  (item) => ObservabilityEvaluator.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      runInfo: json['run_info'] == null
          ? null
          : json['run_info'] as Map<String, Object?>,
      runScores: json['run_scores'] == null
          ? null
          : (json['run_scores'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                EvaluationRunSummaryScore.fromJson(
                  item! as Map<String, dynamic>,
                ),
              ),
            ),
      statistics: json['statistics'] == null
          ? null
          : (json['statistics'] as Map<String, Object?>).map(
              (key, item) => MapEntry(
                key,
                EvaluatorStatistics.fromJson(item! as Map<String, dynamic>),
              ),
            ),
      status: json['status'] == null ? null : json['status'] as String,
      system: json['system'] == null
          ? null
          : EvaluationSystem.fromJson(json['system'] as Map<String, dynamic>),
      tags: (json['tags'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'creator_id': creatorId,
    if (creatorType != null) 'creator_type': creatorType!.value,
    'dataset_id': ?datasetId,
    'deleted_at': deletedAt?.toIso8601String(),
    'description': description,
    if (evaluation != null) 'evaluation': evaluation!.toJson(),
    'evaluation_id': evaluationId,
    'evaluators': evaluators.map((item) => item.toJson()).toList(),
    'failed_record_count': ?failedRecordCount,
    if (goalResults != null)
      'goal_results': goalResults!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'id': id,
    'metadata_': metadata,
    'name': name,
    'num_generations': numGenerations,
    if (optimization != null) 'optimization': optimization!.toJson(),
    'passed': ?passed,
    if (project != null) 'project': project!.toJson(),
    'record_count': ?recordCount,
    if (runEvaluators != null)
      'run_evaluators': runEvaluators!.map((item) => item.toJson()).toList(),
    'run_info': ?runInfo,
    if (runScores != null)
      'run_scores': runScores!.map((key, item) => MapEntry(key, item.toJson())),
    if (statistics != null)
      'statistics': statistics!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    'status': ?status,
    if (system != null) 'system': system!.toJson(),
    'tags': tags,
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  SearchEvaluationRun copyWith({
    DateTime? createdAt,
    String? creatorId,
    Object? creatorType = unsetCopyWithValue,
    Object? datasetId = unsetCopyWithValue,
    Object? deletedAt = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? evaluation = unsetCopyWithValue,
    String? evaluationId,
    List<ObservabilityEvaluator>? evaluators,
    Object? failedRecordCount = unsetCopyWithValue,
    Object? goalResults = unsetCopyWithValue,
    String? id,
    Map<String, Object?>? metadata,
    String? name,
    int? numGenerations,
    Object? optimization = unsetCopyWithValue,
    Object? passed = unsetCopyWithValue,
    Object? project = unsetCopyWithValue,
    Object? recordCount = unsetCopyWithValue,
    Object? runEvaluators = unsetCopyWithValue,
    Object? runInfo = unsetCopyWithValue,
    Object? runScores = unsetCopyWithValue,
    Object? statistics = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
    List<String>? tags,
    DateTime? updatedAt,
  }) => SearchEvaluationRun(
    createdAt: createdAt ?? this.createdAt,
    creatorId: creatorId ?? this.creatorId,
    creatorType: creatorType == unsetCopyWithValue
        ? this.creatorType
        : creatorType as PrincipalType?,
    datasetId: datasetId == unsetCopyWithValue
        ? this.datasetId
        : datasetId as String?,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    evaluation: evaluation == unsetCopyWithValue
        ? this.evaluation
        : evaluation as RunEvaluationSummary?,
    evaluationId: evaluationId ?? this.evaluationId,
    evaluators: evaluators ?? this.evaluators,
    failedRecordCount: failedRecordCount == unsetCopyWithValue
        ? this.failedRecordCount
        : failedRecordCount as int?,
    goalResults: goalResults == unsetCopyWithValue
        ? this.goalResults
        : (goalResults as Map?)?.cast<String, GoalResult>(),
    id: id ?? this.id,
    metadata: metadata ?? this.metadata,
    name: name ?? this.name,
    numGenerations: numGenerations ?? this.numGenerations,
    optimization: optimization == unsetCopyWithValue
        ? this.optimization
        : optimization as RunOptimizationRef?,
    passed: passed == unsetCopyWithValue ? this.passed : passed as bool?,
    project: project == unsetCopyWithValue
        ? this.project
        : project as RunProjectSummary?,
    recordCount: recordCount == unsetCopyWithValue
        ? this.recordCount
        : recordCount as int?,
    runEvaluators: runEvaluators == unsetCopyWithValue
        ? this.runEvaluators
        : (runEvaluators as List<Object?>?)?.cast<ObservabilityEvaluator>(),
    runInfo: runInfo == unsetCopyWithValue
        ? this.runInfo
        : (runInfo as Map?)?.cast<String, Object>(),
    runScores: runScores == unsetCopyWithValue
        ? this.runScores
        : (runScores as Map?)?.cast<String, EvaluationRunSummaryScore>(),
    statistics: statistics == unsetCopyWithValue
        ? this.statistics
        : (statistics as Map?)?.cast<String, EvaluatorStatistics>(),
    status: status == unsetCopyWithValue ? this.status : status as String?,
    system: system == unsetCopyWithValue
        ? this.system
        : system as EvaluationSystem?,
    tags: tags ?? this.tags,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchEvaluationRun &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          creatorType == other.creatorType &&
          datasetId == other.datasetId &&
          deletedAt == other.deletedAt &&
          description == other.description &&
          evaluation == other.evaluation &&
          evaluationId == other.evaluationId &&
          valuesDeepEqual(evaluators, other.evaluators) &&
          failedRecordCount == other.failedRecordCount &&
          valuesDeepEqual(goalResults, other.goalResults) &&
          id == other.id &&
          valuesDeepEqual(metadata, other.metadata) &&
          name == other.name &&
          numGenerations == other.numGenerations &&
          optimization == other.optimization &&
          passed == other.passed &&
          project == other.project &&
          recordCount == other.recordCount &&
          valuesDeepEqual(runEvaluators, other.runEvaluators) &&
          valuesDeepEqual(runInfo, other.runInfo) &&
          valuesDeepEqual(runScores, other.runScores) &&
          valuesDeepEqual(statistics, other.statistics) &&
          status == other.status &&
          system == other.system &&
          valuesDeepEqual(tags, other.tags) &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    creatorId,
    creatorType,
    datasetId,
    deletedAt,
    description,
    evaluation,
    evaluationId,
    valueDeepHashCode(evaluators),
    failedRecordCount,
    valueDeepHashCode(goalResults),
    id,
    valueDeepHashCode(metadata),
    name,
    numGenerations,
    optimization,
    passed,
    project,
    recordCount,
    valueDeepHashCode(runEvaluators),
    valueDeepHashCode(runInfo),
    valueDeepHashCode(runScores),
    valueDeepHashCode(statistics),
    status,
    system,
    valueDeepHashCode(tags),
    updatedAt,
  ]);

  @override
  String toString() =>
      'SearchEvaluationRun('
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'creatorType: $creatorType, '
      'datasetId: $datasetId, '
      'deletedAt: $deletedAt, '
      'description: $description, '
      'evaluation: $evaluation, '
      'evaluationId: $evaluationId, '
      'evaluators: ${evaluators.length}, '
      'failedRecordCount: $failedRecordCount, '
      'goalResults: ${goalResults?.length}, '
      'id: $id, '
      'metadata: ${metadata.length}, '
      'name: $name, '
      'numGenerations: $numGenerations, '
      'optimization: $optimization, '
      'passed: $passed, '
      'project: $project, '
      'recordCount: $recordCount, '
      'runEvaluators: ${runEvaluators?.length}, '
      'runInfo: ${runInfo?.length}, '
      'runScores: ${runScores?.length}, '
      'statistics: ${statistics?.length}, '
      'status: $status, '
      'system: $system, '
      'tags: ${tags.length}, '
      'updatedAt: $updatedAt)';
}

/// The EvaluatorV2 wire payload.
@immutable
class ObservabilityEvaluator {
  /// Creates a [ObservabilityEvaluator].
  const ObservabilityEvaluator({
    this.aggregateGoal,
    required this.createdAt,
    required this.deletedAt,
    required this.description,
    this.direction,
    this.display,
    this.goal,
    this.goals,
    required this.id,
    this.maxValue,
    this.metricDirections,
    this.minValue,
    required this.name,
    required this.numScores,
    this.statistics,
    required this.tags,
    required this.updatedAt,
    this.weight,
  });

  /// The aggregate_goal field.
  final GoalSpec? aggregateGoal;

  /// The created_at field.
  final DateTime createdAt;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The description field.
  final String? description;

  /// The direction field.
  final String? direction;

  /// The display field.
  final List<DisplaySpec>? display;

  /// The goal field.
  final GoalSpec? goal;

  /// The goals field.
  final List<GoalSpec>? goals;

  /// The id field.
  final String id;

  /// The max_value field.
  final double? maxValue;

  /// The metric_directions field.
  final List<MetricDirectionSpec>? metricDirections;

  /// The min_value field.
  final double? minValue;

  /// The name field.
  final String name;

  /// The num_scores field.
  final int numScores;

  /// The statistics field.
  final List<EvaluatorStatisticSpec>? statistics;

  /// The tags field.
  final List<String> tags;

  /// The updated_at field.
  final DateTime updatedAt;

  /// The weight field.
  final double? weight;

  /// Parses a [ObservabilityEvaluator] from JSON.
  factory ObservabilityEvaluator.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('ObservabilityEvaluator: missing created_at');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('ObservabilityEvaluator: missing deleted_at');
    }
    if (!json.containsKey('description')) {
      throw const FormatException(
        'ObservabilityEvaluator: missing description',
      );
    }
    if (json['id'] == null) {
      throw const FormatException('ObservabilityEvaluator: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('ObservabilityEvaluator: missing name');
    }
    if (json['num_scores'] == null) {
      throw const FormatException('ObservabilityEvaluator: missing num_scores');
    }
    if (json['tags'] == null) {
      throw const FormatException('ObservabilityEvaluator: missing tags');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('ObservabilityEvaluator: missing updated_at');
    }
    return ObservabilityEvaluator(
      aggregateGoal: json['aggregate_goal'] == null
          ? null
          : GoalSpec.fromJson(json['aggregate_goal'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      description: json['description'] == null
          ? null
          : json['description'] as String,
      direction: json['direction'] == null ? null : json['direction'] as String,
      display: json['display'] == null
          ? null
          : (json['display'] as List<Object?>)
                .map(
                  (item) => DisplaySpec.fromJson(item! as Map<String, dynamic>),
                )
                .toList(),
      goal: json['goal'] == null
          ? null
          : GoalSpec.fromJson(json['goal'] as Map<String, dynamic>),
      goals: json['goals'] == null
          ? null
          : (json['goals'] as List<Object?>)
                .map((item) => GoalSpec.fromJson(item! as Map<String, dynamic>))
                .toList(),
      id: json['id'] as String,
      maxValue: json['max_value'] == null
          ? null
          : (json['max_value'] as num).toDouble(),
      metricDirections: json['metric_directions'] == null
          ? null
          : (json['metric_directions'] as List<Object?>)
                .map(
                  (item) => MetricDirectionSpec.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      minValue: json['min_value'] == null
          ? null
          : (json['min_value'] as num).toDouble(),
      name: json['name'] as String,
      numScores: json['num_scores'] as int,
      statistics: json['statistics'] == null
          ? null
          : (json['statistics'] as List<Object?>)
                .map(
                  (item) => EvaluatorStatisticSpec.fromJson(
                    item! as Map<String, dynamic>,
                  ),
                )
                .toList(),
      tags: (json['tags'] as List<Object?>)
          .map((item) => item! as String)
          .toList(),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      weight: json['weight'] == null
          ? null
          : (json['weight'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (aggregateGoal != null) 'aggregate_goal': aggregateGoal!.toJson(),
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'description': description,
    'direction': ?direction,
    if (display != null)
      'display': display!.map((item) => item.toJson()).toList(),
    if (goal != null) 'goal': goal!.toJson(),
    if (goals != null) 'goals': goals!.map((item) => item.toJson()).toList(),
    'id': id,
    'max_value': ?maxValue,
    if (metricDirections != null)
      'metric_directions': metricDirections!
          .map((item) => item.toJson())
          .toList(),
    'min_value': ?minValue,
    'name': name,
    'num_scores': numScores,
    if (statistics != null)
      'statistics': statistics!.map((item) => item.toJson()).toList(),
    'tags': tags,
    'updated_at': updatedAt.toIso8601String(),
    'weight': ?weight,
  };

  /// Creates a copy with the given fields replaced.
  ObservabilityEvaluator copyWith({
    Object? aggregateGoal = unsetCopyWithValue,
    DateTime? createdAt,
    Object? deletedAt = unsetCopyWithValue,
    Object? description = unsetCopyWithValue,
    Object? direction = unsetCopyWithValue,
    Object? display = unsetCopyWithValue,
    Object? goal = unsetCopyWithValue,
    Object? goals = unsetCopyWithValue,
    String? id,
    Object? maxValue = unsetCopyWithValue,
    Object? metricDirections = unsetCopyWithValue,
    Object? minValue = unsetCopyWithValue,
    String? name,
    int? numScores,
    Object? statistics = unsetCopyWithValue,
    List<String>? tags,
    DateTime? updatedAt,
    Object? weight = unsetCopyWithValue,
  }) => ObservabilityEvaluator(
    aggregateGoal: aggregateGoal == unsetCopyWithValue
        ? this.aggregateGoal
        : aggregateGoal as GoalSpec?,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    description: description == unsetCopyWithValue
        ? this.description
        : description as String?,
    direction: direction == unsetCopyWithValue
        ? this.direction
        : direction as String?,
    display: display == unsetCopyWithValue
        ? this.display
        : (display as List<Object?>?)?.cast<DisplaySpec>(),
    goal: goal == unsetCopyWithValue ? this.goal : goal as GoalSpec?,
    goals: goals == unsetCopyWithValue
        ? this.goals
        : (goals as List<Object?>?)?.cast<GoalSpec>(),
    id: id ?? this.id,
    maxValue: maxValue == unsetCopyWithValue
        ? this.maxValue
        : (maxValue as num?)?.toDouble(),
    metricDirections: metricDirections == unsetCopyWithValue
        ? this.metricDirections
        : (metricDirections as List<Object?>?)?.cast<MetricDirectionSpec>(),
    minValue: minValue == unsetCopyWithValue
        ? this.minValue
        : (minValue as num?)?.toDouble(),
    name: name ?? this.name,
    numScores: numScores ?? this.numScores,
    statistics: statistics == unsetCopyWithValue
        ? this.statistics
        : (statistics as List<Object?>?)?.cast<EvaluatorStatisticSpec>(),
    tags: tags ?? this.tags,
    updatedAt: updatedAt ?? this.updatedAt,
    weight: weight == unsetCopyWithValue
        ? this.weight
        : (weight as num?)?.toDouble(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ObservabilityEvaluator &&
          runtimeType == other.runtimeType &&
          aggregateGoal == other.aggregateGoal &&
          createdAt == other.createdAt &&
          deletedAt == other.deletedAt &&
          description == other.description &&
          direction == other.direction &&
          valuesDeepEqual(display, other.display) &&
          goal == other.goal &&
          valuesDeepEqual(goals, other.goals) &&
          id == other.id &&
          maxValue == other.maxValue &&
          valuesDeepEqual(metricDirections, other.metricDirections) &&
          minValue == other.minValue &&
          name == other.name &&
          numScores == other.numScores &&
          valuesDeepEqual(statistics, other.statistics) &&
          valuesDeepEqual(tags, other.tags) &&
          updatedAt == other.updatedAt &&
          weight == other.weight;

  @override
  int get hashCode => Object.hashAll([
    aggregateGoal,
    createdAt,
    deletedAt,
    description,
    direction,
    valueDeepHashCode(display),
    goal,
    valueDeepHashCode(goals),
    id,
    maxValue,
    valueDeepHashCode(metricDirections),
    minValue,
    name,
    numScores,
    valueDeepHashCode(statistics),
    valueDeepHashCode(tags),
    updatedAt,
    weight,
  ]);

  @override
  String toString() =>
      'ObservabilityEvaluator('
      'aggregateGoal: $aggregateGoal, '
      'createdAt: $createdAt, '
      'deletedAt: $deletedAt, '
      'description: $description, '
      'direction: $direction, '
      'display: ${display?.length}, '
      'goal: $goal, '
      'goals: ${goals?.length}, '
      'id: $id, '
      'maxValue: $maxValue, '
      'metricDirections: ${metricDirections?.length}, '
      'minValue: $minValue, '
      'name: $name, '
      'numScores: $numScores, '
      'statistics: ${statistics?.length}, '
      'tags: ${tags.length}, '
      'updatedAt: $updatedAt, '
      'weight: $weight)';
}

/// The ListEvaluationRunRecordsResponse wire payload.
@immutable
class ListEvaluationRunRecordsResponse {
  /// Creates a [ListEvaluationRunRecordsResponse].
  const ListEvaluationRunRecordsResponse({required this.records});

  /// The records field.
  final PaginatedResult<EvaluationRunRecord> records;

  /// Parses a [ListEvaluationRunRecordsResponse] from JSON.
  factory ListEvaluationRunRecordsResponse.fromJson(Map<String, dynamic> json) {
    if (json['records'] == null) {
      throw const FormatException(
        'ListEvaluationRunRecordsResponse: missing records',
      );
    }
    return ListEvaluationRunRecordsResponse(
      records: PaginatedResult<EvaluationRunRecord>.fromJson(
        json['records'] as Map<String, dynamic>,
        EvaluationRunRecord.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'records': records.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  ListEvaluationRunRecordsResponse copyWith({
    PaginatedResult<EvaluationRunRecord>? records,
  }) => ListEvaluationRunRecordsResponse(records: records ?? this.records);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListEvaluationRunRecordsResponse &&
          runtimeType == other.runtimeType &&
          records == other.records;

  @override
  int get hashCode => Object.hashAll([records]);

  @override
  String toString() =>
      'ListEvaluationRunRecordsResponse('
      'records: $records)';
}

/// The ListEvaluationRunsResponse wire payload.
@immutable
class ListEvaluationRunsResponse {
  /// Creates a [ListEvaluationRunsResponse].
  const ListEvaluationRunsResponse({required this.runs});

  /// The runs field.
  final PaginatedResult<EvaluationRun> runs;

  /// Parses a [ListEvaluationRunsResponse] from JSON.
  factory ListEvaluationRunsResponse.fromJson(Map<String, dynamic> json) {
    if (json['runs'] == null) {
      throw const FormatException('ListEvaluationRunsResponse: missing runs');
    }
    return ListEvaluationRunsResponse(
      runs: PaginatedResult<EvaluationRun>.fromJson(
        json['runs'] as Map<String, dynamic>,
        EvaluationRun.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'runs': runs.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  ListEvaluationRunsResponse copyWith({PaginatedResult<EvaluationRun>? runs}) =>
      ListEvaluationRunsResponse(runs: runs ?? this.runs);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListEvaluationRunsResponse &&
          runtimeType == other.runtimeType &&
          runs == other.runs;

  @override
  int get hashCode => Object.hashAll([runs]);

  @override
  String toString() =>
      'ListEvaluationRunsResponse('
      'runs: $runs)';
}

/// The RunEvaluationSummary wire payload.
@immutable
class RunEvaluationSummary {
  /// Creates a [RunEvaluationSummary].
  const RunEvaluationSummary({
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

  /// Parses a [RunEvaluationSummary] from JSON.
  factory RunEvaluationSummary.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('RunEvaluationSummary: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('RunEvaluationSummary: missing name');
    }
    if (json['slug'] == null) {
      throw const FormatException('RunEvaluationSummary: missing slug');
    }
    return RunEvaluationSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  /// Creates a copy with the given fields replaced.
  RunEvaluationSummary copyWith({String? id, String? name, String? slug}) =>
      RunEvaluationSummary(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunEvaluationSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          slug == other.slug;

  @override
  int get hashCode => Object.hashAll([id, name, slug]);

  @override
  String toString() =>
      'RunEvaluationSummary('
      'id: $id, '
      'name: $name, '
      'slug: $slug)';
}

/// Typed run→optimization back-ref, derived at read from the optimization_run link. Not stored on the run (single source of truth = optimization_run); lets a run row show its optimization (id + name) without an extra request per run.
@immutable
class RunOptimizationRef {
  /// Creates a [RunOptimizationRef].
  const RunOptimizationRef({required this.name, required this.optimizationId});

  /// The name field.
  final String name;

  /// The optimization_id field.
  final String optimizationId;

  /// Parses a [RunOptimizationRef] from JSON.
  factory RunOptimizationRef.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null) {
      throw const FormatException('RunOptimizationRef: missing name');
    }
    if (json['optimization_id'] == null) {
      throw const FormatException(
        'RunOptimizationRef: missing optimization_id',
      );
    }
    return RunOptimizationRef(
      name: json['name'] as String,
      optimizationId: json['optimization_id'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'name': name,
    'optimization_id': optimizationId,
  };

  /// Creates a copy with the given fields replaced.
  RunOptimizationRef copyWith({String? name, String? optimizationId}) =>
      RunOptimizationRef(
        name: name ?? this.name,
        optimizationId: optimizationId ?? this.optimizationId,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunOptimizationRef &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          optimizationId == other.optimizationId;

  @override
  int get hashCode => Object.hashAll([name, optimizationId]);

  @override
  String toString() =>
      'RunOptimizationRef('
      'name: $name, '
      'optimizationId: $optimizationId)';
}

/// The RunProjectSummary wire payload.
@immutable
class RunProjectSummary {
  /// Creates a [RunProjectSummary].
  const RunProjectSummary({
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

  /// Parses a [RunProjectSummary] from JSON.
  factory RunProjectSummary.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('RunProjectSummary: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('RunProjectSummary: missing name');
    }
    if (json['slug'] == null) {
      throw const FormatException('RunProjectSummary: missing slug');
    }
    return RunProjectSummary(
      id: json['id'] as String,
      name: json['name'] as String,
      slug: json['slug'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};

  /// Creates a copy with the given fields replaced.
  RunProjectSummary copyWith({String? id, String? name, String? slug}) =>
      RunProjectSummary(
        id: id ?? this.id,
        name: name ?? this.name,
        slug: slug ?? this.slug,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RunProjectSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          slug == other.slug;

  @override
  int get hashCode => Object.hashAll([id, name, slug]);

  @override
  String toString() =>
      'RunProjectSummary('
      'id: $id, '
      'name: $name, '
      'slug: $slug)';
}

/// One named number of a run evaluator score. Stored and sent as an ordered list (JSONB keeps no key order).
@immutable
class ScoreMetric {
  /// Creates a [ScoreMetric].
  const ScoreMetric({required this.name, required this.value});

  /// The name field.
  final String name;

  /// The value field.
  final num value;

  /// Parses a [ScoreMetric] from JSON.
  factory ScoreMetric.fromJson(Map<String, dynamic> json) {
    if (json['name'] == null) {
      throw const FormatException('ScoreMetric: missing name');
    }
    if (json['value'] == null) {
      throw const FormatException('ScoreMetric: missing value');
    }
    return ScoreMetric(
      name: json['name'] as String,
      value: json['value'] as num,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'name': name, 'value': value};

  /// Creates a copy with the given fields replaced.
  ScoreMetric copyWith({String? name, num? value}) =>
      ScoreMetric(name: name ?? this.name, value: value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScoreMetric &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          value == other.value;

  @override
  int get hashCode => Object.hashAll([name, value]);

  @override
  String toString() =>
      'ScoreMetric('
      'name: $name, '
      'value: $value)';
}

/// The SearchAllEvaluationRunsResponse wire payload.
@immutable
class SearchAllEvaluationRunsResponse {
  /// Creates a [SearchAllEvaluationRunsResponse].
  const SearchAllEvaluationRunsResponse({required this.runs});

  /// The runs field.
  final PaginatedResult<SearchEvaluationRun> runs;

  /// Parses a [SearchAllEvaluationRunsResponse] from JSON.
  factory SearchAllEvaluationRunsResponse.fromJson(Map<String, dynamic> json) {
    if (json['runs'] == null) {
      throw const FormatException(
        'SearchAllEvaluationRunsResponse: missing runs',
      );
    }
    return SearchAllEvaluationRunsResponse(
      runs: PaginatedResult<SearchEvaluationRun>.fromJson(
        json['runs'] as Map<String, dynamic>,
        SearchEvaluationRun.fromJson,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'runs': runs.toJson((item) => item.toJson()),
  };

  /// Creates a copy with the given fields replaced.
  SearchAllEvaluationRunsResponse copyWith({
    PaginatedResult<SearchEvaluationRun>? runs,
  }) => SearchAllEvaluationRunsResponse(runs: runs ?? this.runs);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchAllEvaluationRunsResponse &&
          runtimeType == other.runtimeType &&
          runs == other.runs;

  @override
  int get hashCode => Object.hashAll([runs]);

  @override
  String toString() =>
      'SearchAllEvaluationRunsResponse('
      'runs: $runs)';
}

/// The SystemV2 wire payload.
@immutable
class EvaluationSystem {
  /// Creates a [EvaluationSystem].
  const EvaluationSystem({
    required this.createdAt,
    required this.deletedAt,
    required this.id,
    this.kind,
    required this.name,
    required this.params,
    this.spec,
    required this.updatedAt,
  });

  /// The created_at field.
  final DateTime createdAt;

  /// The deleted_at field.
  final DateTime? deletedAt;

  /// The id field.
  final String id;

  /// The kind field.
  final String? kind;

  /// The name field.
  final String name;

  /// The params field.
  final Map<String, Object> params;

  /// The spec field.
  final Map<String, Object?>? spec;

  /// The updated_at field.
  final DateTime updatedAt;

  /// Parses a [EvaluationSystem] from JSON.
  factory EvaluationSystem.fromJson(Map<String, dynamic> json) {
    if (json['created_at'] == null) {
      throw const FormatException('EvaluationSystem: missing created_at');
    }
    if (!json.containsKey('deleted_at')) {
      throw const FormatException('EvaluationSystem: missing deleted_at');
    }
    if (json['id'] == null) {
      throw const FormatException('EvaluationSystem: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('EvaluationSystem: missing name');
    }
    if (json['params'] == null) {
      throw const FormatException('EvaluationSystem: missing params');
    }
    if (json['updated_at'] == null) {
      throw const FormatException('EvaluationSystem: missing updated_at');
    }
    return EvaluationSystem(
      createdAt: DateTime.parse(json['created_at'] as String),
      deletedAt: json['deleted_at'] == null
          ? null
          : DateTime.parse(json['deleted_at'] as String),
      id: json['id'] as String,
      kind: json['kind'] == null ? null : json['kind'] as String,
      name: json['name'] as String,
      params: (json['params'] as Map<String, Object?>).map(
        (key, item) => MapEntry(key, item!),
      ),
      spec: json['spec'] == null ? null : json['spec'] as Map<String, Object?>,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'created_at': createdAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'id': id,
    'kind': ?kind,
    'name': name,
    'params': params,
    'spec': ?spec,
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Creates a copy with the given fields replaced.
  EvaluationSystem copyWith({
    DateTime? createdAt,
    Object? deletedAt = unsetCopyWithValue,
    String? id,
    Object? kind = unsetCopyWithValue,
    String? name,
    Map<String, Object>? params,
    Object? spec = unsetCopyWithValue,
    DateTime? updatedAt,
  }) => EvaluationSystem(
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt == unsetCopyWithValue
        ? this.deletedAt
        : deletedAt as DateTime?,
    id: id ?? this.id,
    kind: kind == unsetCopyWithValue ? this.kind : kind as String?,
    name: name ?? this.name,
    params: params ?? this.params,
    spec: spec == unsetCopyWithValue
        ? this.spec
        : (spec as Map?)?.cast<String, Object>(),
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvaluationSystem &&
          runtimeType == other.runtimeType &&
          createdAt == other.createdAt &&
          deletedAt == other.deletedAt &&
          id == other.id &&
          kind == other.kind &&
          name == other.name &&
          valuesDeepEqual(params, other.params) &&
          valuesDeepEqual(spec, other.spec) &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hashAll([
    createdAt,
    deletedAt,
    id,
    kind,
    name,
    valueDeepHashCode(params),
    valueDeepHashCode(spec),
    updatedAt,
  ]);

  @override
  String toString() =>
      'EvaluationSystem('
      'createdAt: $createdAt, '
      'deletedAt: $deletedAt, '
      'id: $id, '
      'kind: $kind, '
      'name: $name, '
      'params: ${params.length}, '
      'spec: ${spec?.length}, '
      'updatedAt: $updatedAt)';
}
