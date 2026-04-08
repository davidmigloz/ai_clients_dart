import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/list_workflow_event_response.dart';
import '../../models/workflows/stream_event_sse_payload.dart';
import '../../models/workflows/workflow_event_type.dart';
import '../../utils/streaming_parser.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for workflow event operations.
///
/// Provides methods to list and stream workflow events.
class EventsResource extends ResourceBase with StreamingResource {
  /// Creates an [EventsResource].
  EventsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists workflow events.
  ///
  /// Retrieves historical workflow events with optional filtering by execution
  /// IDs and pagination.
  Future<ListWorkflowEventResponse> list({
    String? rootWorkflowExecId,
    String? workflowExecId,
    String? workflowRunId,
    int? limit,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (rootWorkflowExecId != null) {
      queryParams['root_workflow_exec_id'] = rootWorkflowExecId;
    }
    if (workflowExecId != null) {
      queryParams['workflow_exec_id'] = workflowExecId;
    }
    if (workflowRunId != null) {
      queryParams['workflow_run_id'] = workflowRunId;
    }
    if (limit != null) queryParams['limit'] = limit.toString();
    if (cursor != null) queryParams['cursor'] = cursor;

    final url = requestBuilder.buildUrl(
      '/v1/workflows/events/list',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListWorkflowEventResponse.fromJson(responseBody);
  }

  /// Streams workflow events in real-time.
  ///
  /// Returns a stream of [StreamEventSsePayload] for live workflow events.
  /// Multiple filter parameters can be combined.
  Stream<StreamEventSsePayload> stream({
    String? scope,
    String? activityName,
    String? activityId,
    String? workflowName,
    String? workflowExecId,
    String? rootWorkflowExecId,
    String? parentWorkflowExecId,
    String? streamName,
    int? startSeq,
    String? metadataFilters,
    List<WorkflowEventType>? workflowEventTypes,
    String? lastEventId,
  }) async* {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (scope != null) queryParams['scope'] = scope;
    if (activityName != null) queryParams['activity_name'] = activityName;
    if (activityId != null) queryParams['activity_id'] = activityId;
    if (workflowName != null) queryParams['workflow_name'] = workflowName;
    if (workflowExecId != null) {
      queryParams['workflow_exec_id'] = workflowExecId;
    }
    if (rootWorkflowExecId != null) {
      queryParams['root_workflow_exec_id'] = rootWorkflowExecId;
    }
    if (parentWorkflowExecId != null) {
      queryParams['parent_workflow_exec_id'] = parentWorkflowExecId;
    }
    if (streamName != null) queryParams['stream'] = streamName;
    if (startSeq != null) queryParams['start_seq'] = startSeq.toString();
    if (metadataFilters != null) {
      queryParams['metadata_filters'] = metadataFilters;
    }
    if (workflowEventTypes != null && workflowEventTypes.isNotEmpty) {
      queryParams['workflow_event_types'] = workflowEventTypes
          .map((e) => e.toJson())
          .join(',');
    }

    final url = requestBuilder.buildUrl(
      '/v1/workflows/events/stream',
      queryParams: queryParams,
    );

    final additionalHeaders = <String, String>{};
    if (lastEventId != null) {
      additionalHeaders['last-event-id'] = lastEventId;
    }

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: additionalHeaders,
    );

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
}
