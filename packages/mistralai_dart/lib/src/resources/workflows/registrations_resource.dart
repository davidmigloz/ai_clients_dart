import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/workflow_execution_request.dart';
import '../../models/workflows/workflow_execution_response.dart';
import '../../models/workflows/workflow_execution_sync_response.dart';
import '../../models/workflows/workflow_registration_get_response.dart';
import '../../models/workflows/workflow_registration_list_response.dart';
import '../base_resource.dart';

/// Resource for workflow registration operations.
///
/// Provides methods to list, get, and execute workflow registrations.
class RegistrationsResource extends ResourceBase {
  /// Creates a [RegistrationsResource].
  RegistrationsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists workflow registrations.
  ///
  /// Supports filtering by workflow ID, task queue, active status, and more.
  Future<WorkflowRegistrationListResponse> list({
    String? workflowId,
    String? taskQueue,
    bool? activeOnly,
    bool? includeShared,
    String? workflowSearch,
    bool? archived,
    bool? withWorkflow,
    bool? availableInChatAssistant,
    int? limit,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (workflowId != null) queryParams['workflow_id'] = workflowId;
    if (taskQueue != null) queryParams['task_queue'] = taskQueue;
    if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();
    if (includeShared != null) {
      queryParams['include_shared'] = includeShared.toString();
    }
    if (workflowSearch != null) queryParams['workflow_search'] = workflowSearch;
    if (archived != null) queryParams['archived'] = archived.toString();
    if (withWorkflow != null) {
      queryParams['with_workflow'] = withWorkflow.toString();
    }
    if (availableInChatAssistant != null) {
      queryParams['available_in_chat_assistant'] = availableInChatAssistant
          .toString();
    }
    if (limit != null) queryParams['limit'] = limit.toString();
    if (cursor != null) queryParams['cursor'] = cursor;

    final url = requestBuilder.buildUrl(
      '/v1/workflows/registrations',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowRegistrationListResponse.fromJson(responseBody);
  }

  /// Gets a workflow registration by ID.
  Future<WorkflowRegistrationGetResponse> get({
    required String workflowRegistrationId,
    bool? withWorkflow,
    bool? includeShared,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (withWorkflow != null) {
      queryParams['with_workflow'] = withWorkflow.toString();
    }
    if (includeShared != null) {
      queryParams['include_shared'] = includeShared.toString();
    }

    final url = requestBuilder.buildUrl(
      '/v1/workflows/registrations/$workflowRegistrationId',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowRegistrationGetResponse.fromJson(responseBody);
  }

  /// Executes a workflow registration.
  ///
  /// Returns raw JSON as the response may be either a
  /// [WorkflowExecutionResponse] or [WorkflowExecutionSyncResponse] depending
  /// on the [WorkflowExecutionRequest.waitForResult] flag.
  Future<Map<String, dynamic>> execute({
    required String workflowRegistrationId,
    required WorkflowExecutionRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/registrations/$workflowRegistrationId/execute',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Executes a workflow registration and returns a typed response.
  ///
  /// When [WorkflowExecutionRequest.waitForResult] is false (default),
  /// returns a [WorkflowExecutionResponse].
  Future<WorkflowExecutionResponse> executeAsync({
    required String workflowRegistrationId,
    required WorkflowExecutionRequest request,
  }) async {
    final json = await execute(
      workflowRegistrationId: workflowRegistrationId,
      request: request.copyWith(waitForResult: false),
    );
    return WorkflowExecutionResponse.fromJson(json);
  }

  /// Executes a workflow registration and waits for the result.
  ///
  /// Returns a [WorkflowExecutionSyncResponse] with the execution result.
  Future<WorkflowExecutionSyncResponse> executeSync({
    required String workflowRegistrationId,
    required WorkflowExecutionRequest request,
  }) async {
    final json = await execute(
      workflowRegistrationId: workflowRegistrationId,
      request: request.copyWith(waitForResult: true),
    );
    return WorkflowExecutionSyncResponse.fromJson(json);
  }
}
