import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/interactions/agents/agent.dart';
import '../models/interactions/agents/list_agents_response.dart';
import 'base_resource.dart';

/// Resource for the Agents API.
///
/// Provides CRUD operations on reusable [Agent] definitions that can be
/// referenced when creating interactions.
///
/// **Note:** the Agents API is part of the experimental Interactions API.
class AgentsResource extends ResourceBase {
  /// Creates an [AgentsResource].
  AgentsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// The Interactions API schema revision this client targets.
  ///
  /// Sent via the `Api-Revision` header on every request, mirroring the
  /// official google-genai SDK, which sends it unconditionally for the
  /// Interactions API family (interactions, agents, webhooks).
  ///
  /// See https://ai.google.dev/gemini-api/docs/interactions-breaking-changes-may-2026
  static const _apiRevision = '2026-05-20';

  /// Builds headers for an Agents API request, always opting into the
  /// [_apiRevision] schema via the `Api-Revision` header.
  Map<String, String> _buildHeaders([Map<String, String>? additionalHeaders]) {
    return requestBuilder.buildHeaders(
      // Spread additionalHeaders first so the Api-Revision opt-in always wins.
      additionalHeaders: {...?additionalHeaders, 'Api-Revision': _apiRevision},
    );
  }

  /// Creates a new [Agent].
  ///
  /// Returns the created agent with its server-assigned [Agent.id] populated.
  Future<Agent> create({required Agent agent}) async {
    final url = requestBuilder.buildUrl('/{version}/agents');

    final headers = _buildHeaders(const {'Content-Type': 'application/json'});

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(agent.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Agent.fromJson(responseBody);
  }

  /// Lists agents.
  ///
  /// [parent] optionally scopes the listing. [pageSize] caps the maximum number
  /// of agents per page and [pageToken] is used for pagination.
  Future<ListAgentsResponse> list({
    String? parent,
    int? pageSize,
    String? pageToken,
  }) async {
    final queryParams = <String, String>{
      'parent': ?parent,
      if (pageSize != null) 'pageSize': pageSize.toString(),
      'pageToken': ?pageToken,
    };

    final url = requestBuilder.buildUrl(
      '/{version}/agents',
      queryParams: queryParams,
    );

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ListAgentsResponse.fromJson(responseBody);
  }

  /// Gets a specific agent by [id].
  Future<Agent> get(String id) async {
    final url = requestBuilder.buildUrl('/{version}/agents/$id');

    final headers = _buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return Agent.fromJson(responseBody);
  }

  /// Deletes an agent by [id].
  Future<void> delete(String id) async {
    final url = requestBuilder.buildUrl('/{version}/agents/$id');

    final headers = _buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }
}
