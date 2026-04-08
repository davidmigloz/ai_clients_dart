import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/managed_agents/agents/agent.dart';
import '../models/managed_agents/agents/agent_list_response.dart';
import '../models/managed_agents/agents/create_agent_params.dart';
import '../models/managed_agents/agents/update_agent_params.dart';
import 'base_resource.dart';

/// Beta header for the Managed Agents API.
const _betaHeader = 'managed-agents-2026-04-01';

/// Resource for the Agents API (Beta).
///
/// Agents are reusable configurations that define how Claude behaves
/// in managed sessions. This is a beta feature and requires the
/// `anthropic-beta` header.
class AgentsResource extends ResourceBase {
  /// Creates an [AgentsResource].
  AgentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Creates a new agent.
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<Agent> create(
    CreateAgentParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/agents');
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

    return Agent.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists agents.
  ///
  /// Parameters:
  /// - [limit]: Maximum number of agents to return.
  /// - [page]: Pagination token from a previous response.
  /// - [createdAtGte]: Filter agents created at or after this ISO 8601 timestamp.
  /// - [createdAtLte]: Filter agents created at or before this ISO 8601 timestamp.
  /// - [includeArchived]: Whether to include archived agents.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListAgentsResponse> list({
    int? limit,
    String? page,
    String? createdAtGte,
    String? createdAtLte,
    bool? includeArchived,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
      'created_at[gte]': ?createdAtGte,
      'created_at[lte]': ?createdAtLte,
      'include_archived': ?includeArchived?.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/agents',
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

    return ListAgentsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a specific agent.
  ///
  /// Parameters:
  /// - [agentId]: The ID of the agent to retrieve.
  /// - [version]: Optional specific version to retrieve.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Agent> retrieve(
    String agentId, {
    int? version,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{'version': ?version?.toString()};

    final url = requestBuilder.buildUrl(
      '/v1/agents/$agentId',
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

    return Agent.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Updates an agent.
  ///
  /// Parameters:
  /// - [agentId]: The ID of the agent to update.
  /// - [request]: The update parameters.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Agent> update(
    String agentId,
    UpdateAgentParams request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/agents/$agentId');
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

    return Agent.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Archives an agent.
  ///
  /// Parameters:
  /// - [agentId]: The ID of the agent to archive.
  /// - [abortTrigger]: Allows canceling the request.
  Future<Agent> archive(String agentId, {Future<void>? abortTrigger}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/agents/$agentId/archive');
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

    return Agent.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  /// Lists versions of an agent.
  ///
  /// Parameters:
  /// - [agentId]: The ID of the agent.
  /// - [limit]: Maximum number of versions to return.
  /// - [page]: Pagination token from a previous response.
  /// - [abortTrigger]: Allows canceling the request.
  Future<ListAgentVersionsResponse> listVersions(
    String agentId, {
    int? limit,
    String? page,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, dynamic>{
      'limit': ?limit?.toString(),
      'page': ?page,
    };

    final url = requestBuilder.buildUrl(
      '/v1/agents/$agentId/versions',
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

    return ListAgentVersionsResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
