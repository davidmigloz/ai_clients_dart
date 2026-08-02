import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/create_deployment_request.dart';
import '../../models/workflows/deployment_detail_response.dart';
import '../../models/workflows/deployment_list_response.dart';
import '../../models/workflows/deployment_log_record.dart';
import '../../models/workflows/deployment_log_search_response.dart';
import '../../models/workflows/managed_deployment_response.dart';
import '../../models/workflows/update_deployment_request.dart';
import '../../utils/streaming_parser.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for workflow deployment operations.
///
/// Provides methods to list, get, create, update, delete, and control
/// (start/stop/restart) managed workflow deployments, plus log retrieval.
class DeploymentsResource extends ResourceBase with StreamingResource {
  /// Creates a [DeploymentsResource].
  DeploymentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists deployments.
  ///
  /// - [activeOnly] filters for active deployments.
  /// - [workflowName] filters by workflow name.
  /// - [isHardened] filters by hardened status.
  /// - [search] filters by name or ID prefix.
  /// - [limit] is the maximum number of deployments to return.
  /// - [cursor] is the pagination cursor from a previous response.
  /// - [workspaceId] scopes the request to a workspace.
  Future<DeploymentListResponse> list({
    bool? activeOnly,
    String? workflowName,
    bool? isHardened,
    String? search,
    int? limit,
    String? cursor,
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();
    if (workflowName != null) queryParams['workflow_name'] = workflowName;
    if (isHardened != null) queryParams['is_hardened'] = isHardened.toString();
    if (search != null) queryParams['search'] = search;
    if (limit != null) queryParams['limit'] = limit.toString();
    if (cursor != null) queryParams['cursor'] = cursor;
    if (workspaceId != null) queryParams['workspace_id'] = workspaceId;

    final url = requestBuilder.buildUrl(
      '/v1/workflows/deployments',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DeploymentListResponse.fromJson(responseBody);
  }

  /// Gets deployment details by name.
  Future<DeploymentDetailResponse> get({required String name}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/deployments/$name');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DeploymentDetailResponse.fromJson(responseBody);
  }

  /// Creates a managed workflow deployment.
  ///
  /// The server responds with `202 Accepted`; the returned
  /// [ManagedDeploymentResponse] reflects the deployment's initial state
  /// while it builds and rolls out.
  Future<ManagedDeploymentResponse> create({
    required CreateDeploymentRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/deployments');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ManagedDeploymentResponse.fromJson(responseBody);
  }

  /// Updates a managed workflow deployment.
  ///
  /// The server responds with `202 Accepted`.
  Future<ManagedDeploymentResponse> update({
    required String name,
    required UpdateDeploymentRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/deployments/$name');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );
    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ManagedDeploymentResponse.fromJson(responseBody);
  }

  /// Deletes a managed workflow deployment.
  ///
  /// The server responds with `202 Accepted`.
  Future<ManagedDeploymentResponse> delete({required String name}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/deployments/$name');
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ManagedDeploymentResponse.fromJson(responseBody);
  }

  /// Starts a managed workflow deployment.
  ///
  /// The server responds with `202 Accepted`.
  Future<ManagedDeploymentResponse> start({required String name}) =>
      _control(name: name, action: 'start');

  /// Stops a managed workflow deployment.
  ///
  /// The server responds with `202 Accepted`.
  Future<ManagedDeploymentResponse> stop({required String name}) =>
      _control(name: name, action: 'stop');

  /// Restarts a managed workflow deployment.
  ///
  /// The server responds with `202 Accepted`.
  Future<ManagedDeploymentResponse> restart({required String name}) =>
      _control(name: name, action: 'restart');

  Future<ManagedDeploymentResponse> _control({
    required String name,
    required String action,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/deployments/$name/$action',
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ManagedDeploymentResponse.fromJson(responseBody);
  }

  /// Retrieves logs for a deployment (across all of its workers).
  ///
  /// Use [after]/[before]/[order] on the first request to set the time range
  /// and sort order; for later pages pass the [cursor] from a previous
  /// response (which carries the window and order, so [after]/[before]/[order]
  /// are then ignored).
  ///
  /// - [workerName] filters logs by worker name.
  /// - [workflowName] filters logs by workflow name.
  /// - [after] only returns logs at or after this timestamp.
  /// - [before] only returns logs before this timestamp.
  /// - [order] is the first-page sort order (`asc` or `desc`, default `asc`).
  /// - [cursor] is the pagination cursor from a previous `next_cursor`.
  /// - [limit] is the maximum number of logs to return (1-100, default 50).
  Future<DeploymentLogSearchResponse> getLogs({
    required String name,
    String? workerName,
    String? workflowName,
    String? after,
    String? before,
    String? order,
    String? cursor,
    int? limit,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (workerName != null) queryParams['worker_name'] = workerName;
    if (workflowName != null) queryParams['workflow_name'] = workflowName;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;
    if (order != null) queryParams['order'] = order;
    if (cursor != null) queryParams['cursor'] = cursor;
    if (limit != null) queryParams['limit'] = limit.toString();

    final url = requestBuilder.buildUrl(
      '/v1/workflows/deployments/$name/logs',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DeploymentLogSearchResponse.fromJson(responseBody);
  }

  /// Streams logs for a deployment (across all of its workers) via SSE.
  ///
  /// Each `log` event yields a [DeploymentLogRecord]. An `error` event (a
  /// `StreamError` payload) raises a [StreamException].
  ///
  /// If [lastEventId] is set it resumes from that cursor (sent as both the
  /// `last_event_id` query parameter and the `Last-Event-ID` header, which
  /// takes precedence server-side) and takes precedence over [after];
  /// otherwise [after] sets a fresh stream's start point (omit both to tail
  /// from the deployment start).
  ///
  /// - [workerName] filters logs by worker name.
  /// - [workflowName] filters logs by workflow name.
  Stream<DeploymentLogRecord> streamLogs({
    required String name,
    String? workerName,
    String? workflowName,
    String? after,
    String? lastEventId,
  }) {
    ensureNotClosed?.call();
    return _streamLogs(
      name: name,
      workerName: workerName,
      workflowName: workflowName,
      after: after,
      lastEventId: lastEventId,
    );
  }

  Stream<DeploymentLogRecord> _streamLogs({
    required String name,
    String? workerName,
    String? workflowName,
    String? after,
    String? lastEventId,
  }) async* {
    final queryParams = <String, String>{};
    if (workerName != null) queryParams['worker_name'] = workerName;
    if (workflowName != null) queryParams['workflow_name'] = workflowName;
    if (after != null) queryParams['after'] = after;
    if (lastEventId != null) queryParams['last_event_id'] = lastEventId;

    final url = requestBuilder.buildUrl(
      '/v1/workflows/deployments/$name/logs/stream',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: lastEventId != null
          ? {'Last-Event-ID': lastEventId}
          : null,
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
      yield DeploymentLogRecord.fromJson(json);
    }
  }
}
