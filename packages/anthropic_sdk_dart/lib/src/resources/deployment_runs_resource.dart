import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/deployments/deployment_run.dart';
import '../models/managed_agents/deployments/deployment_run_list_response.dart';
import '../models/managed_agents/deployments/trigger_type.dart';
import 'base_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for the Deployment Runs API (Beta).
///
/// A deployment run is a persistent, append-only record of a single deployment
/// execution. This is a beta feature and requires the `anthropic-beta` header.
class DeploymentRunsResource extends ResourceBase {
  /// Creates a [DeploymentRunsResource].
  DeploymentRunsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Retrieves a specific deployment run.
  ///
  /// Parameters:
  /// - [deploymentRunId]: The ID of the deployment run to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeploymentRun> retrieve(
    String deploymentRunId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/deployment_runs/$deploymentRunId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeploymentRun.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists deployment runs.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of runs to return.
  /// - [page]: Pagination cursor from a previous response.
  /// - [deploymentId]: Filter to runs produced by the given deployment.
  /// - [triggerType]: Filter by trigger type (`schedule` or `manual`).
  /// - [hasError]: Filter to runs that did (true) or did not (false) error.
  /// - [createdAtGte]: Filter to runs created at or after this time.
  /// - [createdAtLte]: Filter to runs created at or before this time.
  /// - [createdAtGt]: Filter to runs created strictly after this time.
  /// - [createdAtLt]: Filter to runs created strictly before this time.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeploymentRunListResponse> list({
    int? limit,
    String? page,
    String? deploymentId,
    TriggerType? triggerType,
    bool? hasError,
    String? createdAtGte,
    String? createdAtLte,
    String? createdAtGt,
    String? createdAtLt,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'deployment_id': ?deploymentId,
      'trigger_type': ?triggerType?.toJson(),
      'has_error': ?hasError?.toString(),
      'created_at[gte]': ?createdAtGte,
      'created_at[lte]': ?createdAtLte,
      'created_at[gt]': ?createdAtGt,
      'created_at[lt]': ?createdAtLt,
    };

    final url = requestBuilder.buildUrl(
      '/v1/deployment_runs',
      queryParams: queryParams.isEmpty ? null : queryParams,
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeploymentRunListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
