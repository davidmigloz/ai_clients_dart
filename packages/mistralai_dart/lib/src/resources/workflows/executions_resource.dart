import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/batch_execution_body.dart';
import '../../models/workflows/batch_execution_response.dart';
import '../../models/workflows/event_source.dart';
import '../../models/workflows/query_invocation_body.dart';
import '../../models/workflows/query_workflow_response.dart';
import '../../models/workflows/reset_invocation_body.dart';
import '../../models/workflows/signal_invocation_body.dart';
import '../../models/workflows/signal_workflow_response.dart';
import '../../models/workflows/stream_event_sse_payload.dart';
import '../../models/workflows/update_invocation_body.dart';
import '../../models/workflows/update_workflow_response.dart';
import '../../models/workflows/workflow_execution_response.dart';
import '../../models/workflows/workflow_execution_trace_events_response.dart';
import '../../models/workflows/workflow_execution_trace_o_tel_response.dart';
import '../../models/workflows/workflow_execution_trace_summary_response.dart';
import '../../utils/streaming_parser.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for workflow execution operations.
///
/// Provides methods to get, stream, cancel, terminate, reset, query, signal,
/// update, and view history/traces of workflow executions.
class ExecutionsResource extends ResourceBase with StreamingResource {
  /// Creates an [ExecutionsResource].
  ExecutionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets a workflow execution by ID.
  Future<WorkflowExecutionResponse> get({required String executionId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowExecutionResponse.fromJson(responseBody);
  }

  /// Streams workflow execution events.
  ///
  /// Returns a stream of [StreamEventSsePayload] containing real-time
  /// workflow execution events.
  Stream<StreamEventSsePayload> stream({
    required String executionId,
    EventSource? eventSource,
    String? lastEventId,
  }) async* {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (eventSource != null) {
      queryParams['event_source'] = eventSource.toJson();
    }
    if (lastEventId != null) queryParams['last_event_id'] = lastEventId;

    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/stream',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    var httpRequest = http.Request('GET', url)..headers.addAll(headers);
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    await for (final json in parseSSE(streamedResponse.stream)) {
      final sseEvent = json['_event'] as String?;
      final error = json['error'];
      if (sseEvent == 'error' || error != null) {
        throwInlineStreamError(json, sseEvent, error);
      }
      yield StreamEventSsePayload.fromJson(json);
    }
  }

  /// Cancels a single workflow execution.
  Future<void> cancel({required String executionId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/cancel',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)..headers.addAll(headers);
    await interceptorChain.execute(httpRequest);
  }

  /// Terminates a single workflow execution.
  Future<void> terminate({required String executionId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/terminate',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)..headers.addAll(headers);
    await interceptorChain.execute(httpRequest);
  }

  /// Batch cancels multiple workflow executions.
  Future<BatchExecutionResponse> batchCancel({
    required BatchExecutionBody request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/executions/cancel');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchExecutionResponse.fromJson(responseBody);
  }

  /// Batch terminates multiple workflow executions.
  Future<BatchExecutionResponse> batchTerminate({
    required BatchExecutionBody request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/executions/terminate');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return BatchExecutionResponse.fromJson(responseBody);
  }

  /// Resets a workflow execution to a specific event.
  Future<void> reset({
    required String executionId,
    required ResetInvocationBody request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/reset',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    await interceptorChain.execute(httpRequest);
  }

  /// Queries a workflow execution.
  Future<QueryWorkflowResponse> query({
    required String executionId,
    required QueryInvocationBody request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/queries',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return QueryWorkflowResponse.fromJson(responseBody);
  }

  /// Signals a workflow execution.
  Future<SignalWorkflowResponse> signal({
    required String executionId,
    required SignalInvocationBody request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/signals',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SignalWorkflowResponse.fromJson(responseBody);
  }

  /// Updates a workflow execution.
  Future<UpdateWorkflowResponse> update({
    required String executionId,
    required UpdateInvocationBody request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/updates',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return UpdateWorkflowResponse.fromJson(responseBody);
  }

  /// Gets the history of a workflow execution.
  ///
  /// Returns raw JSON as the response schema is unspecified.
  Future<Map<String, dynamic>> history({
    required String executionId,
    bool? decodePayloads,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (decodePayloads != null) {
      queryParams['decode_payloads'] = decodePayloads.toString();
    }
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/history',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Gets trace events for a workflow execution.
  Future<WorkflowExecutionTraceEventsResponse> traceEvents({
    required String executionId,
    bool? mergeSameIdEvents,
    bool? includeInternalEvents,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (mergeSameIdEvents != null) {
      queryParams['merge_same_id_events'] = mergeSameIdEvents.toString();
    }
    if (includeInternalEvents != null) {
      queryParams['include_internal_events'] = includeInternalEvents.toString();
    }
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/trace/events',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowExecutionTraceEventsResponse.fromJson(responseBody);
  }

  /// Gets OpenTelemetry trace data for a workflow execution.
  Future<WorkflowExecutionTraceOTelResponse> traceOTel({
    required String executionId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/trace/otel',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowExecutionTraceOTelResponse.fromJson(responseBody);
  }

  /// Gets a trace summary for a workflow execution.
  Future<WorkflowExecutionTraceSummaryResponse> traceSummary({
    required String executionId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/executions/$executionId/trace/summary',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowExecutionTraceSummaryResponse.fromJson(responseBody);
  }
}
