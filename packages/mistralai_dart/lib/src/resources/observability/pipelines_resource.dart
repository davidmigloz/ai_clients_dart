import '../../models/observability/online_evaluation.dart';
import '../base_resource.dart';
import 'observability_http.dart';

/// Manage live evaluations and query their results.
class PipelinesResource extends ResourceBase {
  /// Creates an [PipelinesResource].
  PipelinesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists Live Eval pipelines.
  Future<PipelinesResponse> list({
    bool? enabled,
    DateTime? from,
    DateTime? to,
    int? pageSize,
    int? page,
    String? q,
  }) => readObservability(
    'GET',
    'pipelines',
    PipelinesResponse.fromJson,
    query: {
      if (enabled != null) 'enabled': enabled.toString(),
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      if (page != null) 'page': page.toString(),
      'q': ?q,
    },
  );

  /// Creates a Live Eval pipeline.
  Future<Pipeline> create({required CreatePipelineRequest request}) =>
      readObservability(
        'POST',
        'pipelines',
        Pipeline.fromJson,
        body: request.toJson(),
      );

  /// Gets a pipeline and its configurations.
  Future<Pipeline> get({required String pipelineId}) => readObservability(
    'GET',
    'pipelines/${Uri.encodeComponent(pipelineId)}',
    Pipeline.fromJson,
  );

  /// Updates the supplied pipeline fields.
  Future<Pipeline> update({
    required String pipelineId,
    required UpdatePipelineRequest request,
  }) => readObservability(
    'PUT',
    'pipelines/${Uri.encodeComponent(pipelineId)}',
    Pipeline.fromJson,
    body: request.toJson(),
  );

  /// Deletes a pipeline.
  Future<void> delete({required String pipelineId}) async {
    await sendObservability(
      'DELETE',
      'pipelines/${Uri.encodeComponent(pipelineId)}',
    );
  }

  /// Discovers the fields for pipeline result filtering and aggregation.
  Future<GetPipelineResultFields> getResultFields({
    required String pipelineId,
  }) => readObservability(
    'GET',
    'pipelines/${Uri.encodeComponent(pipelineId)}/results/fields',
    GetPipelineResultFields.fromJson,
  );

  /// Searches results across pipeline configurations.
  Future<GetPipelineResults> searchResults({
    DateTime? from,
    DateTime? to,
    int? pageSize,
    String? cursor,
    required PipelineResultsRequest request,
  }) => readObservability(
    'POST',
    'pipeline-results/search',
    GetPipelineResults.fromJson,
    query: {
      if (from != null) 'from': from.toUtc().toIso8601String(),
      if (to != null) 'to': to.toUtc().toIso8601String(),
      if (pageSize != null) 'page_size': pageSize.toString(),
      'cursor': ?cursor,
    },
    body: request.toJson(),
  );
}
