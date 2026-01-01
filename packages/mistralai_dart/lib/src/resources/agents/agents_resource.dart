import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/agents/agent.dart';
import '../../models/agents/agent_completion_request.dart';
import '../../models/agents/agent_completion_response.dart';
import '../../models/agents/agent_list.dart';
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
      yield ChatCompletionStreamResponse.fromJson(json);
    }
  }
}
