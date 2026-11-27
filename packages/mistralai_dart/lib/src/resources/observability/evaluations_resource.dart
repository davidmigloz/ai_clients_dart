import '../../models/observability/evaluation_filters.dart';
import '../../models/observability/evaluation_projects.dart';
import '../../models/observability/evaluation_results.dart';
import '../../models/observability/evaluation_statistics.dart';
import '../base_resource.dart';
import 'observability_http.dart';

/// Read offline evaluation definitions, runs, and records.
class EvaluationsResource extends ResourceBase {
  /// Creates an [EvaluationsResource].
  EvaluationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets an evaluation by slug.
  Future<ObservabilityEvaluation> get({required String evaluationSlug}) =>
      readObservability(
        'GET',
        'evaluations_v2/${Uri.encodeComponent(evaluationSlug)}',
        ObservabilityEvaluation.fromJson,
      );

  /// Searches runs for one evaluation.
  Future<ListEvaluationRunsResponse> searchRuns({
    required String evaluationSlug,
    int? pageSize,
    int? page,
    EvaluationRunFilterInput? filters,
  }) => readObservability(
    'POST',
    'evaluations_v2/${Uri.encodeComponent(evaluationSlug)}/runs/search',
    ListEvaluationRunsResponse.fromJson,
    query: {
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    },
    body: filters?.toJson(),
  );

  /// Searches runs across evaluations.
  Future<SearchAllEvaluationRunsResponse> searchAllRuns({
    int? pageSize,
    int? page,
    EvaluationRunFilterInput? filters,
  }) => readObservability(
    'POST',
    'evaluation-runs_v2/search',
    SearchAllEvaluationRunsResponse.fromJson,
    query: {
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    },
    body: filters?.toJson(),
  );

  /// Gets an evaluation run.
  Future<EvaluationRun> getRun({required String runId}) => readObservability(
    'GET',
    'evaluation-runs_v2/${Uri.encodeComponent(runId)}',
    EvaluationRun.fromJson,
  );

  /// Searches records for a run.
  Future<ListEvaluationRunRecordsResponse> searchRecords({
    required String runId,
    int? pageSize,
    int? page,
    EvaluationRunRecordFilterInput? filters,
  }) => readObservability(
    'POST',
    'evaluation-runs_v2/${Uri.encodeComponent(runId)}/records/search',
    ListEvaluationRunRecordsResponse.fromJson,
    query: {
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    },
    body: filters?.toJson(),
  );

  /// Gets one record in a run.
  Future<EvaluationRunRecord> getRecord({
    required String runId,
    required String recordId,
  }) => readObservability(
    'GET',
    'evaluation-runs_v2/${Uri.encodeComponent(runId)}/records/${Uri.encodeComponent(recordId)}',
    EvaluationRunRecord.fromJson,
  );

  /// Gets stored statistics for a run.
  Future<RunStatisticsResponse> getStatistics({required String runId}) =>
      readObservability(
        'GET',
        'evaluation-runs_v2/${Uri.encodeComponent(runId)}/statistics',
        RunStatisticsResponse.fromJson,
      );

  /// Computes statistics using the supplied record filters.
  Future<RunStatisticsResponse> computeStatistics({
    required String runId,
    EvaluationRunRecordFilterInput? filters,
  }) => readObservability(
    'POST',
    'evaluation-runs_v2/${Uri.encodeComponent(runId)}/statistics/compute',
    RunStatisticsResponse.fromJson,
    body: filters?.toJson(),
  );
}
