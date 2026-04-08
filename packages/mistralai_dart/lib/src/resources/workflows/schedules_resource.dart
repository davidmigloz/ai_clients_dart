import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/workflow_schedule_list_response.dart';
import '../../models/workflows/workflow_schedule_request.dart';
import '../../models/workflows/workflow_schedule_response.dart';
import '../base_resource.dart';

/// Resource for workflow schedule operations.
///
/// Provides methods to create, list, and delete workflow schedules.
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
  Future<WorkflowScheduleListResponse> list() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/schedules');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowScheduleListResponse.fromJson(responseBody);
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

  /// Deletes a workflow schedule.
  Future<void> delete({required String scheduleId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/schedules/$scheduleId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    await interceptorChain.execute(httpRequest);
  }
}
