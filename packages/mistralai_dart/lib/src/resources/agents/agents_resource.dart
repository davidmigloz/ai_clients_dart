import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/agents/agent.dart';
import '../../models/agents/agent_alias_response.dart';
import '../../models/agents/agent_completion_request.dart';
import '../../models/agents/agent_completion_response.dart';
import '../../models/agents/agent_list.dart';
import '../../models/agents/agent_list_page.dart';
import '../../models/agents/create_agent_request.dart';
import '../../models/agents/update_agent_request.dart';
import '../../models/chat/chat_completion_stream_response.dart';
import '../../utils/streaming_parser.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for Agents API operations (Beta).
///
/// Agents are pre-configured AI assistants with specific instructions,
/// tools, and behaviors. This resource provides CRUD operations for agents
/// and the ability to run completions using an agent.
///
/// Example usage:
/// ```dart
/// // Create an agent
/// final agent = await client.agents.create(
///   request: CreateAgentRequest(
///     name: 'Code Assistant',
///     model: 'mistral-large-latest',
///     instructions: 'You are a helpful coding assistant.',
///     tools: [Tool.codeInterpreter()],
///   ),
/// );
///
/// // Use the agent for completion
/// final response = await client.agents.complete(
///   request: AgentCompletionRequest(
///     agentId: agent.id,
///     messages: [ChatMessage.user('Write a Python function to sort a list')],
///   ),
/// );
/// print(response.text);
/// ```
class AgentsResource extends ResourceBase with StreamingResource {
  /// Creates an [AgentsResource].
  AgentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Lists all agents.
  ///
  /// Optional [page] and [pageSize] for pagination.
  ///
  /// Returns an [AgentList] containing the agents.
  Future<AgentList> list({int? page, int? pageSize}) async {
    final queryParams = <String, String>{
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };

    final url = requestBuilder.buildUrl('/v1/agents', queryParams: queryParams);
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return AgentList.fromJson(responseBody);
  }

  /// Lists agent entities, cursor-paginated.
  ///
  /// Unlike the deprecated [list], this paginates by opaque cursor and
  /// honors per-agent sharing, returning only agents the caller is
  /// authorized to see.
  ///
  /// - [pageSize] is the number of agents per page (default 20, max 1000).
  /// - [deploymentChat] filters by deployment-chat availability.
  /// - [sources] filters by request source (e.g. `api`, `playground`,
  ///   `agent_builder_v1`).
  /// - [name] filters by exact agent name.
  /// - [search] searches agents by name or ID.
  /// - [id] filters by agent ID.
  /// - [metadata] filters by metadata key/value pairs; sent as a JSON-encoded
  ///   query parameter since the API declares it as a `content: application/`
  ///   `json` query param rather than a plain string.
  /// - [pageToken] is the opaque cursor from a previous response's
  ///   `next_page_token`.
  Future<AgentListPage> listPages({
    int? pageSize,
    bool? deploymentChat,
    List<String>? sources,
    String? name,
    String? search,
    String? id,
    Map<String, dynamic>? metadata,
    String? pageToken,
  }) async {
    final queryParams = <String, dynamic>{};
    if (pageSize != null) queryParams['page_size'] = pageSize.toString();
    if (deploymentChat != null) {
      queryParams['deployment_chat'] = deploymentChat.toString();
    }
    if (sources != null) queryParams['sources'] = sources;
    if (name != null) queryParams['name'] = name;
    if (search != null) queryParams['search'] = search;
    if (id != null) queryParams['id'] = id;
    if (metadata != null) queryParams['metadata'] = jsonEncode(metadata);
    if (pageToken != null) queryParams['page_token'] = pageToken;

    final url = requestBuilder.buildUrl(
      '/v1/agents/pages',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return AgentListPage.fromJson(responseBody);
  }

  /// Creates a new agent.
  ///
  /// The [request] contains the agent configuration.
  ///
  /// Returns the created [Agent].
  Future<Agent> create({required CreateAgentRequest request}) async {
    final url = requestBuilder.buildUrl('/v1/agents');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Agent.fromJson(responseBody);
  }

  /// Retrieves an agent by ID.
  ///
  /// The [agentId] identifies the agent to retrieve.
  /// Optional [version] to retrieve a specific version.
  ///
  /// Returns the [Agent].
  Future<Agent> retrieve({required String agentId, int? version}) async {
    final queryParams = <String, String>{
      if (version != null) 'version': version.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/agents/$agentId',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Agent.fromJson(responseBody);
  }

  /// Updates an existing agent.
  ///
  /// The [agentId] identifies the agent to update.
  /// The [request] contains the fields to update.
  ///
  /// Returns the updated [Agent].
  Future<Agent> update({
    required String agentId,
    required UpdateAgentRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/agents/$agentId');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PATCH', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Agent.fromJson(responseBody);
  }

  /// Deletes an agent.
  ///
  /// The [agentId] identifies the agent to delete.
  Future<void> delete({required String agentId}) async {
    final url = requestBuilder.buildUrl('/v1/agents/$agentId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Updates the active version of an agent.
  ///
  /// The [agentId] identifies the agent.
  /// The [version] is the version number to activate.
  ///
  /// Returns the [Agent] with the new active version.
  Future<Agent> updateVersion({
    required String agentId,
    required int version,
  }) async {
    final url = requestBuilder.buildUrl('/v1/agents/$agentId/version');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode({'version': version});

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Agent.fromJson(responseBody);
  }

  /// Lists all versions of an agent.
  ///
  /// The [agentId] identifies the agent.
  /// Optional [page] and [pageSize] for pagination.
  ///
  /// Returns a list of [Agent] versions.
  Future<List<Agent>> listVersions({
    required String agentId,
    int? page,
    int? pageSize,
  }) async {
    final queryParams = <String, String>{
      if (page != null) 'page': page.toString(),
      if (pageSize != null) 'page_size': pageSize.toString(),
    };

    final url = requestBuilder.buildUrl(
      '/v1/agents/$agentId/versions',
      queryParams: queryParams,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as List<dynamic>;
    return responseBody
        .map((e) => Agent.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Retrieves a specific version of an agent.
  ///
  /// The [agentId] identifies the agent.
  /// The [version] identifies the version to retrieve. Can be a version
  /// number or an alias name (e.g., "latest").
  ///
  /// Returns the [Agent] at the specified version.
  Future<Agent> retrieveVersion({
    required String agentId,
    required String version,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/agents/$agentId/versions/$version',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Agent.fromJson(responseBody);
  }

  /// Lists all aliases for an agent.
  ///
  /// The [agentId] identifies the agent.
  ///
  /// Returns a list of [AgentAliasResponse].
  Future<List<AgentAliasResponse>> listAliases({
    required String agentId,
  }) async {
    final url = requestBuilder.buildUrl('/v1/agents/$agentId/aliases');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as List<dynamic>;
    return responseBody
        .map((e) => AgentAliasResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Creates or updates an agent version alias.
  ///
  /// The [agentId] identifies the agent.
  /// The [alias] is the alias name.
  /// The [version] is the version number to point the alias to.
  ///
  /// Returns the created/updated [AgentAliasResponse].
  Future<AgentAliasResponse> createOrUpdateAlias({
    required String agentId,
    required String alias,
    required int version,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/agents/$agentId/aliases',
      queryParams: {'alias': alias, 'version': version.toString()},
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('PUT', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return AgentAliasResponse.fromJson(responseBody);
  }

  /// Deletes an agent version alias.
  ///
  /// The [agentId] identifies the agent.
  /// The [alias] is the alias name to delete.
  Future<void> deleteAlias({
    required String agentId,
    required String alias,
  }) async {
    final url = requestBuilder.buildUrl(
      '/v1/agents/$agentId/aliases',
      queryParams: {'alias': alias},
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Generates a completion using an agent.
  ///
  /// The [request] contains the agent ID and messages.
  ///
  /// Returns an [AgentCompletionResponse].
  ///
  /// Example:
  /// ```dart
  /// final response = await client.agents.complete(
  ///   request: AgentCompletionRequest(
  ///     agentId: 'agent-123',
  ///     messages: [ChatMessage.user('Hello!')],
  ///   ),
  /// );
  /// print(response.text);
  /// ```
  Future<AgentCompletionResponse> complete({
    required AgentCompletionRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/agents/completions');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return AgentCompletionResponse.fromJson(responseBody);
  }

  /// Generates a completion using an agent with streaming.
  ///
  /// The [request] contains the agent ID and messages.
  ///
  /// Returns a stream of [ChatCompletionStreamResponse] chunks.
  ///
  /// Example:
  /// ```dart
  /// final stream = client.agents.completeStream(
  ///   request: AgentCompletionRequest(
  ///     agentId: 'agent-123',
  ///     messages: [ChatMessage.user('Tell me a story')],
  ///   ),
  /// );
  ///
  /// await for (final chunk in stream) {
  ///   final content = chunk.choices.first.delta.content;
  ///   if (content != null) {
  ///     stdout.write(content);
  ///   }
  /// }
  /// ```
  Stream<ChatCompletionStreamResponse> completeStream({
    required AgentCompletionRequest request,
  }) async* {
    final url = requestBuilder.buildUrl('/v1/agents/completions');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is true for streaming
    final requestData = request.copyWith(stream: true);

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    // Parse SSE stream - uses same response format as chat
    await for (final json in parseSSE(streamedResponse.stream)) {
      final sseEvent = json['_event'] as String?;
      final error = json['error'];
      if (sseEvent == 'error' || error != null) {
        throwInlineStreamError(json, sseEvent, error);
      }
      yield ChatCompletionStreamResponse.fromJson(json);
    }
  }
}
