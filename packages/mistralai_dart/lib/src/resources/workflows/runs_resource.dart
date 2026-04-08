import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/workflow_execution_list_response.dart';
import '../../models/workflows/workflow_execution_response.dart';
import '../base_resource.dart';

/// Resource for workflow run operations.
///
/// Provides methods to list, get, and view history of workflow runs.
class RunsResource extends ResourceBase {
  /// Creates a [RunsResource].
  RunsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists workflow runs.
  ///
  /// Supports filtering by workflow identifier, search query, status, and
  /// pagination.
  Future<WorkflowExecutionListResponse> list({
    String? workflowIdentifier,
    String? search,
    String? status,
    int? pageSize,
    String? nextPageToken,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (workflowIdentifier != null) {
      queryParams['workflow_identifier'] = workflowIdentifier;
    }
    if (search != null) queryParams['search'] = search;
    if (status != null) queryParams['status'] = status;
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (nextPageToken != null) queryParams['next_page_token'] = nextPageToken;

    final url = requestBuilder.buildUrl(
      '/v1/workflows/runs',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowExecutionListResponse.fromJson(responseBody);
  }

  /// Gets a run by ID.
  Future<WorkflowExecutionResponse> get({required String runId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/runs/$runId');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return WorkflowExecutionResponse.fromJson(responseBody);
  }

  /// Gets the history of a run.
  ///
  /// Returns raw JSON as the response schema is unspecified.
  Future<Map<String, dynamic>> history({
    required String runId,
    bool? decodePayloads,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (decodePayloads != null) {
      queryParams['decode_payloads'] = decodePayloads.toString();
    }
    final url = requestBuilder.buildUrl(
      '/v1/workflows/runs/$runId/history',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}
