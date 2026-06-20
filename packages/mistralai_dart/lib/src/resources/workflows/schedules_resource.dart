import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/schedule_definition_output.dart';
import '../../models/workflows/schedule_overlap_policy.dart';
import '../../models/workflows/workflow_schedule_list_response.dart';
import '../../models/workflows/workflow_schedule_pause_request.dart';
import '../../models/workflows/workflow_schedule_request.dart';
import '../../models/workflows/workflow_schedule_response.dart';
import '../../models/workflows/workflow_schedule_trigger_request.dart';
import '../../models/workflows/workflow_schedule_update_request.dart';
import '../base_resource.dart';

/// Resource for workflow schedule operations.
///
/// Provides methods to create, list, get, update, and delete workflow
/// schedules.
class SchedulesResource extends ResourceBase {
  /// Creates a [SchedulesResource].
  SchedulesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists workflow schedules.
  ///
  /// - [workflowName] filters by workflow name.
  /// - [userId] filters by user ID (pass `current` for the authenticated user).
  /// - [status] filters by schedule status (`active` or `paused`).
  /// - [pageSize] is the number of items per page.
  /// - [nextPageToken] is the token for the next page of results.
  Future<WorkflowScheduleListResponse> list({
    String? workflowName,
    String? userId,
    String? status,
    int? pageSize,
    String? nextPageToken,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (workflowName != null) queryParams['workflow_name'] = workflowName;
    if (userId != null) queryParams['user_id'] = userId;
    if (status != null) queryParams['status'] = status;
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (nextPageToken != null) queryParams['next_page_token'] = nextPageToken;

    final url = requestBuilder.buildUrl(
      '/v1/workflows/schedules',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowScheduleListResponse.fromJson(responseBody);
  }

  /// Gets a workflow schedule by ID.
  Future<ScheduleDefinitionOutput> get({required String scheduleId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/schedules/$scheduleId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ScheduleDefinitionOutput.fromJson(responseBody);
  }

  /// Updates a workflow schedule.
  ///
  /// Maps to the official Python SDK's `schedules.update_schedule`
  /// (`PATCH /v1/workflows/schedules/{schedule_id}`).
  Future<WorkflowScheduleResponse> update({
    required String scheduleId,
    required WorkflowScheduleUpdateRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/schedules/$scheduleId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowScheduleResponse.fromJson(responseBody);
  }

  /// Creates a workflow schedule.
  Future<WorkflowScheduleResponse> create({
    required WorkflowScheduleRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/schedules');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowScheduleResponse.fromJson(responseBody);
  }

  /// Pauses a workflow schedule.
  ///
  /// Maps to the official Python SDK's `schedules.pause_schedule`
  /// (`POST /v1/workflows/schedules/{schedule_id}/pause`).
  ///
  /// - [note] is an optional note recorded in Temporal when pausing.
  Future<void> pause({required String scheduleId, String? note}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/schedules/$scheduleId/pause',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final request = WorkflowSchedulePauseRequest(note: note);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    await interceptorChain.execute(httpRequest);
  }

  /// Resumes a workflow schedule.
  ///
  /// Maps to the official Python SDK's `schedules.resume_schedule`
  /// (`POST /v1/workflows/schedules/{schedule_id}/resume`).
  ///
  /// - [note] is an optional note recorded in Temporal when resuming.
  Future<void> resume({required String scheduleId, String? note}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/schedules/$scheduleId/resume',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final request = WorkflowSchedulePauseRequest(note: note);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    await interceptorChain.execute(httpRequest);
  }

  /// Immediately triggers a workflow schedule.
  ///
  /// Maps to the official Python SDK's `schedules.trigger_schedule`
  /// (`POST /v1/workflows/schedules/{schedule_id}/trigger`).
  ///
  /// - [overlap] is an optional overlap policy override for the trigger.
  Future<void> trigger({
    required String scheduleId,
    ScheduleOverlapPolicy? overlap,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/schedules/$scheduleId/trigger',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final request = WorkflowScheduleTriggerRequest(overlap: overlap);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    await interceptorChain.execute(httpRequest);
  }

  /// Deletes a workflow schedule.
  Future<void> delete({required String scheduleId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/schedules/$scheduleId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    await interceptorChain.execute(httpRequest);
  }
}
