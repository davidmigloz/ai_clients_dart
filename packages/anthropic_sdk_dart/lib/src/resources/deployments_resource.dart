import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/deployments/create_deployment_params.dart';
import '../models/managed_agents/deployments/deployment.dart';
import '../models/managed_agents/deployments/deployment_list_response.dart';
import '../models/managed_agents/deployments/deployment_run.dart';
import '../models/managed_agents/deployments/deployment_status.dart';
import '../models/managed_agents/deployments/update_deployment_params.dart';
import 'base_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for the Deployments API (Beta).
///
/// A deployment binds an agent to everything needed to run it autonomously: an
/// environment, credentials, initial events, and an optional cron schedule.
/// This is a beta feature and requires the `anthropic-beta` header.
class DeploymentsResource extends ResourceBase {
  /// Creates a [DeploymentsResource].
  DeploymentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new deployment.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Deployment> create(
    CreateDeploymentParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/deployments');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Deployment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists deployments.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of deployments to return.
  /// - [page]: Pagination cursor from a previous response.
  /// - [agentId]: Filter to deployments running the given agent.
  /// - [status]: Filter by deployment status (`active` or `paused`).
  /// - [createdAtGte]: Filter to deployments created at or after this time.
  /// - [createdAtLte]: Filter to deployments created at or before this time.
  /// - [includeArchived]: Whether to include archived deployments.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeploymentListResponse> list({
    int? limit,
    String? page,
    String? agentId,
    DeploymentStatus? status,
    String? createdAtGte,
    String? createdAtLte,
    bool? includeArchived,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'agent_id': ?agentId,
      'status': ?status?.toJson(),
      'created_at[gte]': ?createdAtGte,
      'created_at[lte]': ?createdAtLte,
      'include_archived': ?includeArchived?.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/deployments',
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

    return DeploymentListResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific deployment.
  ///
  /// Parameters:
  /// - [deploymentId]: The ID of the deployment to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Deployment> retrieve(
    String deploymentId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/deployments/$deploymentId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Deployment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Updates a deployment.
  ///
  /// Parameters:
  /// - [deploymentId]: The ID of the deployment to update.
  /// - [request]: The update parameters.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Deployment> update(
    String deploymentId,
    UpdateDeploymentParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/deployments/$deploymentId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Deployment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Archives a deployment.
  ///
  /// Parameters:
  /// - [deploymentId]: The ID of the deployment to archive.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Deployment> archive(
    String deploymentId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/deployments/$deploymentId/archive',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Deployment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Pauses a deployment, halting its schedule from firing runs.
  ///
  /// Parameters:
  /// - [deploymentId]: The ID of the deployment to pause.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Deployment> pause(
    String deploymentId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/deployments/$deploymentId/pause');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Deployment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Unpauses a deployment, resuming its schedule.
  ///
  /// Parameters:
  /// - [deploymentId]: The ID of the deployment to unpause.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Deployment> unpause(
    String deploymentId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/deployments/$deploymentId/unpause',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return Deployment.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Triggers a manual run of the deployment.
  ///
  /// Parameters:
  /// - [deploymentId]: The ID of the deployment to run.
  /// - [abortTrigger]: Allows canceling the request.
  Future<DeploymentRun> run(
    String deploymentId, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/deployments/$deploymentId/run');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'anthropic-beta': _betaHeader},
    );
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(<String, dynamic>{});

    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );

    return DeploymentRun.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
