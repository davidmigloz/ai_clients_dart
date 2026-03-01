import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/evals/evals.dart';
import 'base_resource.dart';

/// Resource for the Evals API.
///
/// The Evals API allows you to create and manage evaluations to test your
/// LLM integrations. Define testing criteria (graders) and run evaluations
/// against different data sources.
///
/// Access this resource through [OpenAIClient.evals].
///
/// ## Example
///
/// ```dart
/// // Create an evaluation
/// final eval = await client.evals.create(
///   CreateEvalRequest(
///     name: 'My Evaluation',
///     dataSourceConfig: EvalDataSourceConfig.custom(
///       itemSchema: {
///         'type': 'object',
///         'properties': {
///           'prompt': {'type': 'string'},
///           'expected': {'type': 'string'},
///         },
///       },
///     ),
///     testingCriteria: [
///       EvalGrader.stringCheck(
///         name: 'matches_expected',
///         input: '{{sample.output_text}}',
///         operation: StringCheckOperation.ilike,
///         reference: '%{{item.expected}}%',
///       ),
///     ],
///   ),
/// );
///
/// // Run the evaluation
/// final run = await client.evals.runs.create(
///   eval.id,
///   CreateEvalRunRequest(
///     dataSource: EvalRunDataSource.jsonlContent([
///       {'prompt': 'Say hello', 'expected': 'hello'},
///     ]),
///   ),
/// );
/// ```
class EvalsResource extends ResourceBase {
  /// Creates an [EvalsResource].
  EvalsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/evals';

  EvalRunsResource? _runs;

  /// Access to evaluation run operations.
  EvalRunsResource get runs => _runs ??= EvalRunsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Creates a new evaluation.
  Future<Eval> create(CreateEvalRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Eval.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists all evaluations.
  Future<EvalList> list({
    String? after,
    int? limit,
    String? order,
    String? orderBy,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (orderBy != null) queryParams['order_by'] = orderBy;

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return EvalList.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Retrieves an evaluation by ID.
  Future<Eval> retrieve(String evalId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$evalId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return Eval.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Updates an evaluation.
  Future<Eval> update(String evalId, UpdateEvalRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$evalId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Eval.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes an evaluation.
  Future<DeleteEvalResponse> delete(String evalId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$evalId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteEvalResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

/// Resource for evaluation run operations.
class EvalRunsResource extends ResourceBase {
  /// Creates an [EvalRunsResource].
  EvalRunsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  EvalOutputItemsResource? _outputItems;

  /// Access to output item operations.
  EvalOutputItemsResource get outputItems =>
      _outputItems ??= EvalOutputItemsResource(
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
      );

  /// Creates a new evaluation run.
  Future<EvalRun> create(String evalId, CreateEvalRunRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/evals/$evalId/runs');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return EvalRun.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists runs for an evaluation.
  Future<EvalRunList> list(
    String evalId, {
    String? after,
    int? limit,
    String? order,
    EvalRunStatus? status,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (status != null) queryParams['status'] = status.toJson();

    final url = requestBuilder.buildUrl(
      '/evals/$evalId/runs',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return EvalRunList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a run by ID.
  Future<EvalRun> retrieve(String evalId, String runId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/evals/$evalId/runs/$runId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return EvalRun.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Deletes a run.
  Future<DeleteEvalRunResponse> delete(String evalId, String runId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/evals/$evalId/runs/$runId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteEvalRunResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Cancels a running evaluation.
  Future<EvalRun> cancel(String evalId, String runId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/evals/$evalId/runs/$runId/cancel');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});
    final response = await interceptorChain.execute(httpRequest);
    return EvalRun.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}

/// Resource for evaluation output item operations.
class EvalOutputItemsResource extends ResourceBase {
  /// Creates an [EvalOutputItemsResource].
  EvalOutputItemsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists output items for a run.
  Future<EvalOutputItemList> list(
    String evalId,
    String runId, {
    String? after,
    int? limit,
    String? order,
    EvalOutputItemStatus? status,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (after != null) queryParams['after'] = after;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (status != null) queryParams['status'] = status.toJson();

    final url = requestBuilder.buildUrl(
      '/evals/$evalId/runs/$runId/output_items',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return EvalOutputItemList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves an output item by ID.
  Future<EvalOutputItem> retrieve(
    String evalId,
    String runId,
    String outputItemId,
  ) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/evals/$evalId/runs/$runId/output_items/$outputItemId',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return EvalOutputItem.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
