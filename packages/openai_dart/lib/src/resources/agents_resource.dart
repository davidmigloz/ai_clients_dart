import 'dart:convert';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../models/agents/agent_json_helpers.dart';
import '../models/agents/agents.dart';
import '../utils/private_audio_http.dart';
import 'agent_environments_resource.dart';
import 'agent_sessions_resource.dart';
import 'base_resource.dart';

/// Saved Agents API configuration, scoped to the authenticated project.
///
/// Access through `client.agents`. Every request forces `OpenAI-Beta: agents=v1`
/// after caller headers. This resource manages reusable configuration only;
/// creation does not start a session, run a model or execute a configured tool.
class AgentsResource extends ResourceBase {
  AgentEnvironmentsResource? _environments;

  /// Owned hosted prewarming and reusable environment templates.
  AgentEnvironmentsResource get environments {
    ensureNotClosed?.call();
    return _environments ??= AgentEnvironmentsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
      streamClientFactory: streamClientFactory,
    );
  }

  AgentSessionsResource? _sessions;

  /// Raw durable session CRUD, persistent events and manual input submission.
  AgentSessionsResource get sessions {
    ensureNotClosed?.call();
    return _sessions ??= AgentSessionsResource(
      config: config,
      httpClient: httpClient,
      interceptorChain: interceptorChain,
      requestBuilder: requestBuilder,
      ensureNotClosed: ensureNotClosed,
      streamClientFactory: streamClientFactory,
    );
  }

  /// Creates the cached resource using the ordinary client HTTP policy.
  AgentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  /// Creates reusable configuration without storing MCP session credentials.
  ///
  /// The model name is preserved exactly. Omitted fields retain service defaults;
  /// `clearX: true` emits explicit null on fields permitting it. Tools are limited
  /// to 2,000 entries and 3 MiB of compact UTF-8 JSON before authentication.
  Future<Agent> create(
    CreateAgentRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    request.validate();
    return _send(
      'POST',
      '/agents',
      Agent.fromJson,
      expectedStatus: 201,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Lists one page, with limit 1–100 and service defaults when omitted.
  ///
  /// Use the returned `lastId` as `after` with the same order and limit. Empty
  /// pages retain required nullable `firstId` and `lastId`. The API has no
  /// `before` cursor on this operation.
  Future<AgentList> list({
    int? limit,
    AgentListOrder? order,
    String? after,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    if (limit != null) {
      validateAgentInt(limit, 'Agents list.limit', min: 1, max: 100);
    }
    if (order != null) {
      validateAgentEnum(order.value, const [
        'asc',
        'desc',
      ], 'Agents list.order');
    }
    if (after != null) {
      validateAgentLength(after, 'Agents list.after', max: 1048576);
    }
    return _send(
      'GET',
      '/agents',
      AgentList.fromJson,
      query: {
        if (limit != null) 'limit': limit.toString(),
        if (order != null) 'order': order.value,
        'after': ?after,
      },
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Retrieves one saved agent using an opaque encoded path segment.
  ///
  /// IDs have a canonical maximum of 1,048,576 Unicode characters. Empty, `.`
  /// and `..` segments are rejected as local Dart URI transport safeguards.
  /// Slashes, percent signs, query punctuation and Unicode retain their value.
  Future<Agent> retrieve(
    String agentId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _send(
      'GET',
      _path(agentId),
      Agent.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Replaces supplied fields on an existing agent.
  ///
  /// Omission leaves a field unchanged. Objects, lists and maps replace the
  /// complete field, rather than merging it. For example, `clearReasoning: true`
  /// sends `reasoning: null`, restoring the model's default effort. Use
  /// `clearName`, `clearTools` or `clearMetadata` to clear those fields explicitly.
  Future<Agent> update(
    String agentId,
    UpdateAgentRequest request, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final path = _path(agentId);
    request.validate();
    return _send(
      'POST',
      path,
      Agent.fromJson,
      body: request.toJson(),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Deletes one saved agent and returns the service's typed deletion result.
  Future<DeletedAgent> delete(
    String agentId, {
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return _send(
      'DELETE',
      _path(agentId),
      DeletedAgent.fromJson,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  String _path(String id) {
    validateAgentLength(id, 'Agents agentId', max: 1048576);
    if (id.isEmpty || id == '.' || id == '..') {
      throw const FormatException('Agents agentId: expected an opaque segment');
    }
    try {
      return '/agents/${Uri.encodeComponent(id)}';
    } on ArgumentError {
      throw const FormatException(
        'Agents agentId: expected an encodable segment',
      );
    }
  }

  Future<T> _send<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) parse, {
    int expectedStatus = 200,
    Map<String, dynamic>? body,
    Map<String, String>? query,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    // Detach caller options before cancellation detection suspends dispatch.
    final callerHeaders = additionalHeaders == null
        ? null
        : Map<String, String>.unmodifiable(additionalHeaders);
    await checkPrivateAudioAbort(abortTrigger, 'Agents');
    final request =
        http.Request(method, requestBuilder.buildUrl(path, queryParams: query))
          ..headers.addAll(
            requestBuilder.buildBetaHeaders(
              betaFeature: 'agents=v1',
              additionalHeaders: callerHeaders,
            ),
          );
    // Apply required values to http's case-insensitive map after caller merges.
    request.headers['openai-beta'] = 'agents=v1';
    request.headers['accept'] = 'application/json';
    if (body == null) {
      request.headers.remove('content-type');
    } else {
      request
        ..headers['content-type'] = 'application/json; charset=utf-8'
        ..encoding = utf8
        ..bodyBytes = utf8.encode(jsonEncode(body));
    }
    final response = await sendPrivateAudioRequest(
      request,
      interceptorChain: interceptorChain,
      context: 'Agents',
      abortTrigger: abortTrigger,
    );
    if (response.statusCode != expectedStatus) {
      throw ParseException(
        message: 'Unexpected Agents success status; expected $expectedStatus.',
        responseBody: utf8.decode(response.bodyBytes, allowMalformed: true),
      );
    }
    return parsePrivateAudioResponse(response, parse, 'Agents');
  }
}
