import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/create_deployment_request.dart';
import '../../models/workflows/deployment_archive.dart';
import '../../models/workflows/deployment_detail_response.dart';
import '../../models/workflows/deployment_list_response.dart';
import '../../models/workflows/deployment_log_record.dart';
import '../../models/workflows/deployment_log_search_response.dart';
import '../../models/workflows/deployment_log_type.dart';
import '../../models/workflows/deployment_worker_list_response.dart';
import '../../models/workflows/location_type.dart';
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
  /// - [createdBy] and [owner] filter by principal.
  /// - [locationTypes] filters by local, Kubernetes, or managed deployments.
  /// - [search] filters by name or ID prefix.
  /// - [orderBy] and [order] control sorting by creation or update time.
  /// - [repositoryUrl] and [dockerfilePath] filter managed builds.
  /// - [limit] is the maximum number of deployments to return.
  /// - [cursor] is the pagination cursor from a previous response.
  /// - [workspaceId] scopes the request to a workspace.
  Future<DeploymentListResponse> list({
    bool? activeOnly,
    String? workflowName,
    bool? isHardened,
    String? createdBy,
    String? owner,
    List<LocationType>? locationTypes,
    String? search,
    String? orderBy,
    String? order,
    String? repositoryUrl,
    String? dockerfilePath,
    int? limit,
    String? cursor,
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, Object>{};
    if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();
    if (workflowName != null) queryParams['workflow_name'] = workflowName;
    if (isHardened != null) queryParams['is_hardened'] = isHardened.toString();
    if (createdBy != null) queryParams['created_by'] = createdBy;
    if (owner != null) queryParams['owner'] = owner;
    if (locationTypes != null) {
      queryParams['location_types'] = locationTypes.map((type) => type.value);
    }
    if (search != null) queryParams['search'] = search;
    if (orderBy != null) queryParams['order_by'] = orderBy;
    if (order != null) queryParams['order'] = order;
    if (repositoryUrl != null) queryParams['repository_url'] = repositoryUrl;
    if (dockerfilePath != null) queryParams['dockerfile_path'] = dockerfilePath;
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
  Future<DeploymentDetailResponse> get({
    required String name,
    String? workflowName,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/deployments/${Uri.encodeComponent(name)}',
      queryParams: {'workflow_name': ?workflowName},
    );
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return DeploymentDetailResponse.fromJson(responseBody);
  }

  /// Requests signed upload details for a gzipped tar archive.
  ///
  /// PUT the raw archive bytes to the returned URL with its signed headers,
  /// using a separate HTTP client without Mistral credentials. After upload,
  /// pass the archive ID to the deployment's worker spec.
  Future<DeploymentArchiveUploadResponse> createArchive({
    required CreateDeploymentArchiveRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/workflows/deployments/archives');
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(
        requestBuilder.buildHeaders(
          additionalHeaders: {'Content-Type': 'application/json'},
        ),
      )
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return DeploymentArchiveUploadResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves signed download details for an archive-backed deployment.
  ///
  /// The URL expires within 24 hours and is null after the archive is deleted.
  /// Repository-backed deployments return a 404.
  Future<DeploymentArchiveResponse> getArchive({required String name}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/deployments/${Uri.encodeComponent(name)}/archive',
    );
    final httpRequest = http.Request('GET', url)
      ..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(httpRequest);
    return DeploymentArchiveResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists workers for a deployment, optionally filtering by activity.
  ///
  /// Pass the previous page's cursor to continue through the worker list.
  Future<DeploymentWorkerListResponse> listWorkers({
    required String name,
    String? workerStatus,
    int? limit,
    String? cursor,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/deployments/${Uri.encodeComponent(name)}/workers',
      queryParams: {
        'worker_status': ?workerStatus,
        if (limit != null) 'limit': limit.toString(),
        'cursor': ?cursor,
      },
    );
    final httpRequest = http.Request('GET', url)
      ..headers.addAll(requestBuilder.buildHeaders());
    final response = await interceptorChain.execute(httpRequest);
    return DeploymentWorkerListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Unhardens a deployment by ID.
  ///
  /// Requires deployment ownership or workspace administrator access.
  Future<void> unharden({
    required String deploymentId,
    String? workspaceId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/workflows/deployments/${Uri.encodeComponent(deploymentId)}/unharden',
      queryParams: {'workspace_id': ?workspaceId},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(requestBuilder.buildHeaders());
    await interceptorChain.execute(httpRequest);
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
  /// - [logType] selects worker runtime logs or managed image build output.
  /// - [workerName] filters logs by worker name.
  /// - [workflowName] filters logs by workflow name.
  /// - [after] only returns logs at or after this timestamp.
  /// - [before] only returns logs before this timestamp.
  /// - [order] is the first-page sort order (`asc` or `desc`, default `asc`).
  /// - [cursor] is the pagination cursor from a previous `next_cursor`.
  /// - [limit] is the maximum number of logs to return (1-100, default 50).
  Future<DeploymentLogSearchResponse> getLogs({
    required String name,
    DeploymentLogType? logType,
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
    if (logType != null) queryParams['log_type'] = logType.value;
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
  ///
  /// The optional [abortTrigger] cancels the streaming request.
  Stream<DeploymentLogRecord> streamLogs({
    required String name,
    String? workerName,
    String? workflowName,
    String? after,
    String? lastEventId,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _streamLogs(
      name: name,
      workerName: workerName,
      workflowName: workflowName,
      after: after,
      lastEventId: lastEventId,
      abortTrigger: abortTrigger,
    );
  }

  Stream<DeploymentLogRecord> _streamLogs({
    required String name,
    String? workerName,
    String? workflowName,
    String? after,
    String? lastEventId,
    Future<void>? abortTrigger,
  }) => streamRequest(
    () {
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
        additionalHeaders: {
          'Accept': 'text/event-stream',
          'Last-Event-ID': ?lastEventId,
        },
      );

      final httpRequest = http.Request('GET', url)..headers.addAll(headers);
      return httpRequest;
    },
    DeploymentLogRecord.fromJson,
    abortTrigger: abortTrigger,
    parseEvents: (bytes) => parseSSE(bytes, includeEventId: true),
  );
}
