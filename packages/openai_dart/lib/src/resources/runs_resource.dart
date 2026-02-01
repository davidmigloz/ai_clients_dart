import 'dart:convert';

import '../errors/exceptions.dart';
import '../models/runs/runs.dart';
import '../utils/streaming_parser.dart';
import 'beta_base_resource.dart';

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
class RunsResource extends BetaBaseResource {
  /// Creates a [RunsResource] with the given client.
  RunsResource(super.client);

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
    final json = await postJson(_endpoint(threadId), body: request.toJson());
    return Run.fromJson(json);
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
  }) async* {
    // Ensure stream is enabled in the request body
    final requestBody = request.toJson();
    requestBody['stream'] = true;

    final response = await client.sendStream(
      endpoint: _endpoint(threadId),
      body: requestBody,
      headers: {'OpenAI-Beta': betaVersion},
      abortTrigger: abortTrigger,
    );

    // Extract request ID from response headers for error reporting
    final requestId =
        response.headers['x-request-id'] ??
        response.request?.headers['X-Request-ID'] ??
        'unknown';

    try {
      if (response.statusCode >= 400) {
        final body = await response.stream.bytesToString();
        throw _parseStreamError(response.statusCode, body, requestId);
      }

      const parser = SseParser();
      await for (final json in parser.parse(response.stream)) {
        yield json;
      }
    } on AbortedException {
      rethrow;
    }
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
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final json = await getJson(
      _endpoint(threadId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return RunList.fromJson(json);
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
    final json = await getJson('${_endpoint(threadId)}/$runId');
    return Run.fromJson(json);
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
    final json = await postJson(
      '${_endpoint(threadId)}/$runId',
      body: {'metadata': metadata},
    );
    return Run.fromJson(json);
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
    final json = await postJson(
      '${_endpoint(threadId)}/$runId/cancel',
      body: {},
    );
    return Run.fromJson(json);
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
    final json = await postJson(
      '${_endpoint(threadId)}/$runId/submit_tool_outputs',
      body: request.toJson(),
    );
    return Run.fromJson(json);
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
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final json = await getJson(
      '${_endpoint(threadId)}/$runId/steps',
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return RunStepList.fromJson(json);
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
    final json = await getJson('${_endpoint(threadId)}/$runId/steps/$stepId');
    return RunStep.fromJson(json);
  }

  /// Parses an error response from a streaming request.
  ApiException _parseStreamError(
    int statusCode,
    String body,
    String requestId,
  ) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return createApiException(
        statusCode: statusCode,
        message: error?['message'] as String? ?? 'Unknown error',
        type: error?['type'] as String?,
        code: error?['code'] as String?,
        requestId: requestId,
        body: json,
      );
    } catch (_) {
      return ApiException(
        message: body.isNotEmpty ? body : 'HTTP $statusCode error',
        statusCode: statusCode,
        requestId: requestId,
      );
    }
  }
}
