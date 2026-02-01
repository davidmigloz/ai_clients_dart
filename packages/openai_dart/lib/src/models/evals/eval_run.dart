import 'package:meta/meta.dart';

import 'run_data_source.dart';

/// An evaluation run executing tests against model outputs.
///
/// Each run processes data from the specified data source and evaluates
/// it against the graders defined in the parent evaluation.
@immutable
class EvalRun {
  /// Creates an [EvalRun].
  const EvalRun({
    required this.id,
    required this.evalId,
    required this.createdAt,
    required this.name,
    required this.status,
    required this.model,
    required this.object,
    required this.dataSource,
    this.error,
    this.resultCounts,
    this.perModelUsage,
    this.perTestingCriteriaResults,
    this.reportUrl,
    this.metadata,
  });

  /// Creates an [EvalRun] from JSON.
  factory EvalRun.fromJson(Map<String, dynamic> json) {
    return EvalRun(
      id: json['id'] as String,
      evalId: json['eval_id'] as String,
      createdAt: json['created_at'] as int,
      name: json['name'] as String,
      status: EvalRunStatus.fromJson(json['status'] as String),
      model: json['model'] as String,
      object: json['object'] as String,
      dataSource: EvalRunDataSource.fromJson(
        json['data_source'] as Map<String, dynamic>,
      ),
      error: json['error'] != null
          ? EvalApiError.fromJson(json['error'] as Map<String, dynamic>)
          : null,
      resultCounts: json['result_counts'] != null
          ? EvalRunResultCounts.fromJson(
              json['result_counts'] as Map<String, dynamic>,
            )
          : null,
      perModelUsage: (json['per_model_usage'] as List<dynamic>?)
          ?.map((e) => EvalRunPerModelUsage.fromJson(e as Map<String, dynamic>))
          .toList(),
      perTestingCriteriaResults:
          (json['per_testing_criteria_results'] as List<dynamic>?)
              ?.map(
                (e) => EvalRunPerTestingCriteriaResult.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList(),
      reportUrl: json['report_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// The unique identifier for this run.
  final String id;

  /// The ID of the parent evaluation.
  final String evalId;

  /// The Unix timestamp (in seconds) when this run was created.
  final int createdAt;

  /// The name of this run.
  final String name;

  /// The current status of the run.
  final EvalRunStatus status;

  /// The model being evaluated.
  final String model;

  /// The object type (always "eval.run").
  final String object;

  /// The data source used for this run.
  final EvalRunDataSource dataSource;

  /// Error details if the run failed.
  final EvalApiError? error;

  /// Result counts (passed, failed, errored, total).
  final EvalRunResultCounts? resultCounts;

  /// Token usage broken down by model.
  final List<EvalRunPerModelUsage>? perModelUsage;

  /// Results broken down by testing criterion.
  final List<EvalRunPerTestingCriteriaResult>? perTestingCriteriaResults;

  /// URL to the evaluation report in the OpenAI dashboard.
  final String? reportUrl;

  /// Optional metadata attached to this run.
  final Map<String, dynamic>? metadata;

  /// Whether this run is still in progress.
  bool get isRunning =>
      status == EvalRunStatus.queued || status == EvalRunStatus.inProgress;

  /// Whether this run completed successfully.
  bool get isCompleted => status == EvalRunStatus.completed;

  /// Whether this run failed.
  bool get isFailed => status == EvalRunStatus.failed;

  /// Whether this run was canceled.
  bool get isCanceled => status == EvalRunStatus.canceled;

  /// The pass rate (0.0 to 1.0) if results are available.
  double? get passRate {
    if (resultCounts == null || resultCounts!.total == 0) return null;
    return resultCounts!.passed / resultCounts!.total;
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'eval_id': evalId,
    'created_at': createdAt,
    'name': name,
    'status': status.toJson(),
    'model': model,
    'object': object,
    'data_source': dataSource.toJson(),
    if (error != null) 'error': error!.toJson(),
    if (resultCounts != null) 'result_counts': resultCounts!.toJson(),
    if (perModelUsage != null)
      'per_model_usage': perModelUsage!.map((u) => u.toJson()).toList(),
    if (perTestingCriteriaResults != null)
      'per_testing_criteria_results': perTestingCriteriaResults!
          .map((r) => r.toJson())
          .toList(),
    if (reportUrl != null) 'report_url': reportUrl,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalRun && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'EvalRun(id: $id, status: $status)';
}

/// A paginated list of evaluation runs.
@immutable
class EvalRunList {
  /// Creates an [EvalRunList].
  const EvalRunList({
    required this.object,
    required this.data,
    required this.hasMore,
    this.firstId,
    this.lastId,
  });

  /// Creates an [EvalRunList] from JSON.
  factory EvalRunList.fromJson(Map<String, dynamic> json) {
    return EvalRunList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => EvalRun.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of runs.
  final List<EvalRun> data;

  /// Whether there are more runs available.
  final bool hasMore;

  /// The ID of the first run in this page.
  final String? firstId;

  /// The ID of the last run in this page.
  final String? lastId;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((r) => r.toJson()).toList(),
    'has_more': hasMore,
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalRunList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'EvalRunList(${data.length} runs)';
}

/// Request to create a new evaluation run.
@immutable
class CreateEvalRunRequest {
  /// Creates a [CreateEvalRunRequest].
  const CreateEvalRunRequest({
    required this.dataSource,
    this.name,
    this.metadata,
  });

  /// Creates a [CreateEvalRunRequest] from JSON.
  factory CreateEvalRunRequest.fromJson(Map<String, dynamic> json) {
    return CreateEvalRunRequest(
      dataSource: EvalRunDataSource.fromJson(
        json['data_source'] as Map<String, dynamic>,
      ),
      name: json['name'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// The data source for this run.
  final EvalRunDataSource dataSource;

  /// Optional name for this run.
  final String? name;

  /// Optional metadata to attach to this run.
  final Map<String, dynamic>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data_source': dataSource.toJson(),
    if (name != null) 'name': name,
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateEvalRunRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => dataSource.hashCode;

  @override
  String toString() => 'CreateEvalRunRequest(name: $name)';
}

/// Response from deleting an evaluation run.
@immutable
class DeleteEvalRunResponse {
  /// Creates a [DeleteEvalRunResponse].
  const DeleteEvalRunResponse({
    required this.runId,
    this.object,
    required this.deleted,
  });

  /// Creates a [DeleteEvalRunResponse] from JSON.
  factory DeleteEvalRunResponse.fromJson(Map<String, dynamic> json) {
    return DeleteEvalRunResponse(
      runId: json['run_id'] as String,
      object: json['object'] as String?,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted run.
  final String runId;

  /// The object type (typically "eval.run.deleted").
  final String? object;

  /// Whether the run was successfully deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'run_id': runId,
    if (object != null) 'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteEvalRunResponse &&
          runtimeType == other.runtimeType &&
          runId == other.runId;

  @override
  int get hashCode => runId.hashCode;

  @override
  String toString() =>
      'DeleteEvalRunResponse(runId: $runId, deleted: $deleted)';
}

/// Status of an evaluation run.
enum EvalRunStatus {
  /// The run is queued and waiting to start.
  queued._('queued'),

  /// The run is currently executing.
  inProgress._('in_progress'),

  /// The run completed successfully.
  completed._('completed'),

  /// The run was canceled.
  canceled._('canceled'),

  /// The run failed due to an error.
  failed._('failed');

  const EvalRunStatus._(this._value);

  /// Creates from JSON string.
  factory EvalRunStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown run status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// Result counts for an evaluation run.
@immutable
class EvalRunResultCounts {
  /// Creates an [EvalRunResultCounts].
  const EvalRunResultCounts({
    required this.total,
    required this.passed,
    required this.failed,
    required this.errored,
  });

  /// Creates an [EvalRunResultCounts] from JSON.
  factory EvalRunResultCounts.fromJson(Map<String, dynamic> json) {
    return EvalRunResultCounts(
      total: json['total'] as int,
      passed: json['passed'] as int,
      failed: json['failed'] as int,
      errored: json['errored'] as int,
    );
  }

  /// Total number of items evaluated.
  final int total;

  /// Number of items that passed.
  final int passed;

  /// Number of items that failed.
  final int failed;

  /// Number of items that errored.
  final int errored;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'total': total,
    'passed': passed,
    'failed': failed,
    'errored': errored,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalRunResultCounts &&
          runtimeType == other.runtimeType &&
          total == other.total;

  @override
  int get hashCode => total.hashCode;

  @override
  String toString() =>
      'EvalRunResultCounts(passed: $passed, failed: $failed, total: $total)';
}

/// Token usage for a specific model in an evaluation run.
@immutable
class EvalRunPerModelUsage {
  /// Creates an [EvalRunPerModelUsage].
  const EvalRunPerModelUsage({
    required this.modelName,
    required this.promptTokens,
    required this.completionTokens,
    required this.totalTokens,
    this.cachedTokens,
    this.invocationCount,
  });

  /// Creates an [EvalRunPerModelUsage] from JSON.
  factory EvalRunPerModelUsage.fromJson(Map<String, dynamic> json) {
    return EvalRunPerModelUsage(
      modelName: json['model_name'] as String,
      promptTokens: json['prompt_tokens'] as int,
      completionTokens: json['completion_tokens'] as int,
      totalTokens: json['total_tokens'] as int,
      cachedTokens: json['cached_tokens'] as int?,
      invocationCount: json['invocation_count'] as int?,
    );
  }

  /// The model name.
  final String modelName;

  /// Number of prompt tokens used.
  final int promptTokens;

  /// Number of completion tokens generated.
  final int completionTokens;

  /// Total tokens (prompt + completion).
  final int totalTokens;

  /// Number of cached tokens used.
  final int? cachedTokens;

  /// Number of model invocations.
  final int? invocationCount;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'model_name': modelName,
    'prompt_tokens': promptTokens,
    'completion_tokens': completionTokens,
    'total_tokens': totalTokens,
    if (cachedTokens != null) 'cached_tokens': cachedTokens,
    if (invocationCount != null) 'invocation_count': invocationCount,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalRunPerModelUsage &&
          runtimeType == other.runtimeType &&
          modelName == other.modelName;

  @override
  int get hashCode => modelName.hashCode;

  @override
  String toString() =>
      'EvalRunPerModelUsage(model: $modelName, tokens: $totalTokens)';
}

/// Results for a specific testing criterion (grader) in an evaluation run.
@immutable
class EvalRunPerTestingCriteriaResult {
  /// Creates an [EvalRunPerTestingCriteriaResult].
  const EvalRunPerTestingCriteriaResult({
    required this.testingCriteria,
    required this.passed,
    required this.failed,
  });

  /// Creates an [EvalRunPerTestingCriteriaResult] from JSON.
  factory EvalRunPerTestingCriteriaResult.fromJson(Map<String, dynamic> json) {
    return EvalRunPerTestingCriteriaResult(
      testingCriteria: json['testing_criteria'] as String,
      passed: json['passed'] as int,
      failed: json['failed'] as int,
    );
  }

  /// The name/description of the testing criterion.
  final String testingCriteria;

  /// Number of items that passed this criterion.
  final int passed;

  /// Number of items that failed this criterion.
  final int failed;

  /// Total number of items evaluated with this criterion.
  int get total => passed + failed;

  /// Pass rate for this criterion (0.0 to 1.0).
  double get passRate => total == 0 ? 0.0 : passed / total;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'testing_criteria': testingCriteria,
    'passed': passed,
    'failed': failed,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalRunPerTestingCriteriaResult &&
          runtimeType == other.runtimeType &&
          testingCriteria == other.testingCriteria;

  @override
  int get hashCode => testingCriteria.hashCode;

  @override
  String toString() =>
      'EvalRunPerTestingCriteriaResult($testingCriteria: $passed/$total)';
}

/// An error from the Evals API.
@immutable
class EvalApiError {
  /// Creates an [EvalApiError].
  const EvalApiError({required this.code, required this.message});

  /// Creates an [EvalApiError] from JSON.
  factory EvalApiError.fromJson(Map<String, dynamic> json) {
    return EvalApiError(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  /// The error code.
  final String code;

  /// The error message.
  final String message;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EvalApiError &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'EvalApiError(code: $code, message: $message)';
}
