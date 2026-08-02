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
  /// Supports filtering by workflow identifier, search query, status,
  /// deployment, time ranges, user, sorting, and pagination.
  ///
  /// - [deploymentName] filters by deployment name.
  /// - [sortBy] is the field to sort by (`start_time` or `end_time`).
  /// - [order] is the sort order.
  /// - [startTimeAfter]/[startTimeBefore] bound the start time (ISO 8601).
  /// - [endTimeAfter]/[endTimeBefore] bound the end time (ISO 8601).
  /// - [userId] filters by user ID (`current` for the authenticated user).
  /// - [rootExecutionId] filters by root execution ID, returning the whole
  ///   execution tree (the root and all its descendant sub-workflows).
  /// - [includeInternal] includes runs of internal/technical workflows (e.g.
  ///   `parallel-execution`); defaults to `true` server-side.
  /// - [searchKey] filters executions by search key as repeated `key:value`
  ///   entries; entries are AND'd together (max 3).
  /// - [workflowTags] filters to runs of workflows tagged with all listed
  ///   tags (AND); max 20.
  Future<WorkflowExecutionListResponse> list({
    String? workflowIdentifier,
    String? search,
    String? status,
    String? deploymentName,
    String? sortBy,
    String? order,
    String? startTimeAfter,
    String? startTimeBefore,
    String? endTimeAfter,
    String? endTimeBefore,
    String? userId,
    int? pageSize,
    String? nextPageToken,
    String? rootExecutionId,
    bool? includeInternal,
    List<String>? searchKey,
    List<String>? workflowTags,
  }) async {
    ensureNotClosed?.call();
    // Array query params (search_key/workflow_tags) use form/explode
    // serialization — each value is sent as a repeated parameter, not
    // comma-joined.
    final queryParams = <String, dynamic>{};
    if (workflowIdentifier != null) {
      queryParams['workflow_identifier'] = workflowIdentifier;
    }
    if (search != null) queryParams['search'] = search;
    if (status != null) queryParams['status'] = status;
    if (deploymentName != null) queryParams['deployment_name'] = deploymentName;
    if (sortBy != null) queryParams['sort_by'] = sortBy;
    if (order != null) queryParams['order'] = order;
    if (startTimeAfter != null) {
      queryParams['start_time_after'] = startTimeAfter;
    }
    if (startTimeBefore != null) {
      queryParams['start_time_before'] = startTimeBefore;
    }
    if (endTimeAfter != null) queryParams['end_time_after'] = endTimeAfter;
    if (endTimeBefore != null) queryParams['end_time_before'] = endTimeBefore;
    if (userId != null) queryParams['user_id'] = userId;
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (nextPageToken != null) queryParams['next_page_token'] = nextPageToken;
    if (rootExecutionId != null) {
      queryParams['root_execution_id'] = rootExecutionId;
    }
    if (includeInternal != null) {
      queryParams['include_internal'] = includeInternal.toString();
    }
    if (searchKey != null) queryParams['search_key'] = searchKey;
    if (workflowTags != null) queryParams['workflow_tags'] = workflowTags;

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
