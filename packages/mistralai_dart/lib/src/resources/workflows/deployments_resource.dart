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
  /// Use [activeOnly] to filter for active deployments, and [workflowName]
  /// to filter by workflow name.
  Future<DeploymentListResponse> list({
    bool? activeOnly,
    String? workflowName,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (activeOnly != null) queryParams['active_only'] = activeOnly.toString();
    if (workflowName != null) queryParams['workflow_name'] = workflowName;

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
