import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/workflow_archive_response.dart';
import '../../models/workflows/workflow_execution_request.dart';
import '../../models/workflows/workflow_execution_response.dart';
import '../../models/workflows/workflow_execution_sync_response.dart';
import '../../models/workflows/workflow_get_response.dart';
import '../../models/workflows/workflow_registration_list_response.dart';
import '../../models/workflows/workflow_unarchive_response.dart';
import '../../models/workflows/workflow_update_request.dart';
import '../../models/workflows/workflow_update_response.dart';
import '../base_resource.dart';

/// Resource for core workflow operations.
///
/// Provides methods to list, get, update, archive/unarchive, and execute
/// workflows.
class WorkflowCoreResource extends ResourceBase {
  /// Creates a [WorkflowCoreResource].
  WorkflowCoreResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists workflows.
  ///
  /// Use [archived] to filter by archive status, [search] for text search,
  /// and [cursor]/[limit] for pagination.
  Future<WorkflowRegistrationListResponse> list({
    bool? archived,
    String? search,
    int? limit,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (archived != null) queryParams['archived'] = archived.toString();
    if (search != null) queryParams['workflow_search'] = search;
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

  /// Gets a workflow by identifier.
  Future<WorkflowGetResponse> get({required String workflowIdentifier}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/$workflowIdentifier');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowGetResponse.fromJson(responseBody);
  }

  /// Updates a workflow.
  Future<WorkflowUpdateResponse> update({
    required String workflowIdentifier,
    required WorkflowUpdateRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/$workflowIdentifier');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowUpdateResponse.fromJson(responseBody);
  }

  /// Archives a workflow.
  Future<WorkflowArchiveResponse> archive({
    required String workflowIdentifier,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/$workflowIdentifier/archive',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('PUT', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowArchiveResponse.fromJson(responseBody);
  }

  /// Unarchives a workflow.
  Future<WorkflowUnarchiveResponse> unarchive({
    required String workflowIdentifier,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/$workflowIdentifier/unarchive',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('PUT', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowUnarchiveResponse.fromJson(responseBody);
  }

  /// Executes a workflow.
  ///
  /// If [WorkflowExecutionRequest.waitForResult] is true, returns a
  /// [WorkflowExecutionSyncResponse] with the result. Otherwise returns a
  /// [WorkflowExecutionResponse] with status information.
  Future<Map<String, dynamic>> execute({
    required String workflowIdentifier,
    required WorkflowExecutionRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/$workflowIdentifier/execute',
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

  /// Executes a workflow and returns a typed response.
  ///
  /// When [WorkflowExecutionRequest.waitForResult] is false (default),
  /// returns a [WorkflowExecutionResponse].
  Future<WorkflowExecutionResponse> executeAsync({
    required String workflowIdentifier,
    required WorkflowExecutionRequest request,
  }) async {
    final json = await execute(
      workflowIdentifier: workflowIdentifier,
      request: request.copyWith(waitForResult: false),
    );
    return WorkflowExecutionResponse.fromJson(json);
  }

  /// Executes a workflow and waits for the result.
  ///
  /// Returns a [WorkflowExecutionSyncResponse] with the execution result.
  Future<WorkflowExecutionSyncResponse> executeSync({
    required String workflowIdentifier,
    required WorkflowExecutionRequest request,
  }) async {
    final json = await execute(
      workflowIdentifier: workflowIdentifier,
      request: request.copyWith(waitForResult: true),
    );
    return WorkflowExecutionSyncResponse.fromJson(json);
  }
}
