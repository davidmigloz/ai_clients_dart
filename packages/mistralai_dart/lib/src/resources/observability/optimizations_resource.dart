import '../../models/observability/evaluation_optimizations.dart';
import '../base_resource.dart';
import 'observability_http.dart';

/// Read prompt optimizations and their trials.
class OptimizationsResource extends ResourceBase {
  /// Creates an [OptimizationsResource].
  OptimizationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists matching optimizations.
  Future<ListOptimizationsResponse> list({
    String? project,
    String? evaluation,
    String? status,
    String? algorithm,
    List<String>? tags,
    int? pageSize,
    int? page,
  }) => readObservability(
    'GET',
    'optimizations',
    ListOptimizationsResponse.fromJson,
    query: {
      'project': ?project,
      'evaluation': ?evaluation,
      'status': ?status,
      'algorithm': ?algorithm,
      'tags': ?tags,
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    },
  );

  /// Gets an optimization and its references.
  Future<EvaluationOptimizationDetail> get({required String optimizationId}) =>
      readObservability(
        'GET',
        'optimizations/${Uri.encodeComponent(optimizationId)}',
        EvaluationOptimizationDetail.fromJson,
      );

  /// Lists the optimization trials and their observations.
  Future<ListOptimizationTrialsResponse> listTrials({
    required String optimizationId,
    int? pageSize,
    int? page,
  }) => readObservability(
    'GET',
    'optimizations/${Uri.encodeComponent(optimizationId)}/trials',
    ListOptimizationTrialsResponse.fromJson,
    query: {
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (page != null) 'page': page.toString(),
    },
  );
}
