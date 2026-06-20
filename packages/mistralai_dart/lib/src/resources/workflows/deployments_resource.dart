import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/workflows/deployment_detail_response.dart';
import '../../models/workflows/deployment_list_response.dart';
import '../base_resource.dart';

/// Resource for workflow deployment operations.
///
/// Provides methods to list and get deployment details.
class DeploymentsResource extends ResourceBase {
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
}
