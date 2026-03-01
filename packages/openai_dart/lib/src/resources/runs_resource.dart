import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/runs/runs.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for Runs API operations (Beta).
///
/// Runs represent an invocation of an assistant on a thread.
///
/// Access this resource through [OpenAIClient.beta.threads.runs].
///
/// ## Example
///
/// ```dart
/// // Create a run
/// final run = await client.beta.threads.runs.create(
///   'thread_abc123',
///   CreateRunRequest(assistantId: 'asst_xyz'),
/// );
///
/// // Poll until complete
/// while (run.status == RunStatus.queued || run.status == RunStatus.inProgress) {
///   await Future.delayed(Duration(seconds: 1));
///   run = await client.beta.threads.runs.retrieve('thread_abc123', run.id);
/// }
/// ```
class RunsResource extends ResourceBase with StreamingResource {
  /// Creates a [RunsResource].
  RunsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  static const _betaFeature = 'assistants=v2';

  String _endpoint(String threadId) => '/threads/$threadId/runs';

  /// Creates a new run.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to run.
  /// - [request] - The run creation request.
  ///
  /// ## Returns
  ///
  /// A [Run] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final run = await client.beta.threads.runs.create(
  ///   'thread_abc123',
  ///   CreateRunRequest(
  ///     assistantId: 'asst_xyz',
  ///     instructions: 'Please be helpful.',
  ///   ),
  /// );
  /// ```
  Future<Run> create(String threadId, CreateRunRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint(threadId));
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Run.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Creates a run with streaming.
  ///
  /// Returns a stream of assistant events as the run progresses.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread to run.
  /// - [request] - The run creation request.
  /// - [abortTrigger] - Optional future that cancels the stream when completed.
  ///
  /// ## Returns
  ///
  /// A stream of run events.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final stream = client.beta.threads.runs.createStream(
  ///   'thread_abc123',
  ///   CreateRunRequest(assistantId: 'asst_xyz'),
  /// );
  ///
  /// await for (final event in stream) {
  ///   print('Event: ${event.event}');
  /// }
  /// ```
  Stream<Map<String, dynamic>> createStream(
    String threadId,
    CreateRunRequest request, {
    Future<void>? abortTrigger,
  }) {
    // Ensure stream is enabled in the request body
    final requestBody = request.toJson();
    requestBody['stream'] = true;

    return streamSseEvents(
      endpoint: _endpoint(threadId),
      body: requestBody,
      additionalHeaders: {'OpenAI-Beta': _betaFeature},
      abortTrigger: abortTrigger,
    );
  }

  /// Lists runs in a thread.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [limit] - Maximum number of runs to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc', default 'desc').
  /// - [after] - Cursor for pagination.
  /// - [before] - Cursor for pagination.
  ///
  /// ## Returns
  ///
  /// A [RunList] containing the runs.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final runs = await client.beta.threads.runs.list('thread_abc123');
  ///
  /// for (final run in runs.data) {
  ///   print('${run.id}: ${run.status}');
  /// }
  /// ```
  Future<RunList> list(
    String threadId, {
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final url = requestBuilder.buildUrl(
      _endpoint(threadId),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return RunList.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Retrieves a run by ID.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [runId] - The ID of the run to retrieve.
  ///
  /// ## Returns
  ///
  /// A [Run] with the run information.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final run = await client.beta.threads.runs.retrieve(
  ///   'thread_abc123',
  ///   'run_xyz789',
  /// );
  /// print('Status: ${run.status}');
  /// ```
  Future<Run> retrieve(String threadId, String runId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('${_endpoint(threadId)}/$runId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return Run.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Modifies a run.
  ///
  /// Only allows modifying metadata.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [runId] - The ID of the run to modify.
  /// - [metadata] - New metadata for the run.
  ///
  /// ## Returns
  ///
  /// A [Run] with the updated information.
  Future<Run> update(
    String threadId,
    String runId, {
    required Map<String, String> metadata,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('${_endpoint(threadId)}/$runId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode({'metadata': metadata});
    final response = await interceptorChain.execute(httpRequest);
    return Run.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Cancels a run.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [runId] - The ID of the run to cancel.
  ///
  /// ## Returns
  ///
  /// A [Run] with the updated status.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final cancelled = await client.beta.threads.runs.cancel(
  ///   'thread_abc123',
  ///   'run_xyz789',
  /// );
  /// print('Status: ${cancelled.status}');
  /// ```
  Future<Run> cancel(String threadId, String runId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('${_endpoint(threadId)}/$runId/cancel');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});
    final response = await interceptorChain.execute(httpRequest);
    return Run.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Submits tool outputs for a run.
  ///
  /// Call this when a run has `requires_action` status with tool calls.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [runId] - The ID of the run.
  /// - [request] - The tool outputs to submit.
  ///
  /// ## Returns
  ///
  /// A [Run] with the updated status.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final run = await client.beta.threads.runs.submitToolOutputs(
  ///   'thread_abc123',
  ///   'run_xyz789',
  ///   SubmitToolOutputsRequest(
  ///     toolOutputs: [
  ///       ToolOutput(
  ///         toolCallId: 'call_abc',
  ///         output: '{"result": 42}',
  ///       ),
  ///     ],
  ///   ),
  /// );
  /// ```
  Future<Run> submitToolOutputs(
    String threadId,
    String runId,
    SubmitToolOutputsRequest request,
  ) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '${_endpoint(threadId)}/$runId/submit_tool_outputs',
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return Run.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists run steps.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [runId] - The ID of the run.
  /// - [limit] - Maximum number of steps to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc', default 'desc').
  /// - [after] - Cursor for pagination.
  /// - [before] - Cursor for pagination.
  ///
  /// ## Returns
  ///
  /// A [RunStepList] containing the run steps.
  Future<RunStepList> listSteps(
    String threadId,
    String runId, {
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final url = requestBuilder.buildUrl(
      '${_endpoint(threadId)}/$runId/steps',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return RunStepList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a run step.
  ///
  /// ## Parameters
  ///
  /// - [threadId] - The ID of the thread.
  /// - [runId] - The ID of the run.
  /// - [stepId] - The ID of the step to retrieve.
  ///
  /// ## Returns
  ///
  /// A [RunStep] with the step information.
  Future<RunStep> retrieveStep(
    String threadId,
    String runId,
    String stepId,
  ) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '${_endpoint(threadId)}/$runId/steps/$stepId',
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return RunStep.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
