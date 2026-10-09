// ignore_for_file: avoid_print
// Offline saved-agent CRUD/configuration: MockClient only, no API key or charges.
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final service = _OfflineAgents();
  final transport = MockClient(service.handle);
  final client = OpenAIClient.withApiKey(
    'synthetic-offline-agent',
    httpClient: transport,
  );
  try {
    final agent = await client.agents.create(
      CreateAgentRequest(
        model: 'requested-model',
        name: 'Offline researcher',
        instructions: 'Look up a reference before answering.',
        serviceTier: AgentServiceTierParam.fast,
        reasoning: AgentReasoningConfig(effort: AgentReasoningEffortParam.low),
        text: AgentTextConfig(
          format: AgentTextFormat.jsonSchema(
            schema: const {
              'type': 'object',
              'properties': {
                'answer': {'type': 'string'},
              },
              'required': ['answer'],
              'additionalProperties': false,
            },
          ),
        ),
        multiAgent: AgentMultiAgentConfig(enabled: false),
        tools: [
          AgentTool.function(
            name: 'lookup',
            description: 'Look up a reference supplied by the application.',
            parameters: const {
              'type': 'object',
              'properties': {
                'query': {'type': 'string'},
              },
            },
          ),
          const AgentTool.toolSearch(),
          AgentTool.programmaticToolCalling(enabled: false),
          AgentTool.mcp(
            serverLabel: 'reference-service',
            transport: AgentMcpTransport.http(
              serverUrl: 'https://mcp.fixture.invalid',
              headers: const {'X-Application': 'offline-example'},
            ),
          ),
          AgentTool.webSearch(mode: AgentWebSearchModeParam.cached),
          AgentTool.computerUse(includeScreenshots: false),
        ],
      ),
    );
    print(
      'Created ${agent.id}; stored ${agent.tools.length} tool definitions.',
    );

    final first = await client.agents.list(limit: 1, order: AgentListOrder.asc);
    final second = await client.agents.list(
      limit: 1,
      order: AgentListOrder.asc,
      after: first.lastId,
    );
    print('Pagination: ${first.data.length} then ${second.data.length} items.');
    final retrieved = await client.agents.retrieve(agent.id);
    print('Requested model retained: ${retrieved.model}.');

    // Supplying an object replaces the whole saved field, rather than merging.
    await client.agents.update(
      agent.id,
      UpdateAgentRequest(
        reasoning: AgentReasoningConfig(
          summary: AgentReasoningSummaryParam.auto,
        ),
      ),
    );
    // Omitted fields remain unchanged; explicit null clears/resets a field.
    final reset = await client.agents.update(
      agent.id,
      UpdateAgentRequest(
        clearName: true,
        clearReasoning: true,
        metadata: const {'example': 'offline'},
      ),
    );
    assert(reset.name == null);
    assert(reset.reasoning.effort == null);
    print('Name cleared and reasoning reset; tool definitions retained.');

    final deletion = await client.agents.delete(agent.id);
    print(
      'Deleted: ${deletion.deleted}; ${service.requests} mock requests, cost \$0.',
    );
  } finally {
    // The injected transport belongs to the caller, even after client closure.
    client.close();
    transport.close();
  }
}

class _OfflineAgents {
  Map<String, dynamic>? saved;
  int requests = 0;

  Future<http.Response> handle(http.Request request) async {
    requests++;
    if (request.headers['openai-beta'] != 'agents=v1') {
      throw StateError('Expected the Agents opt-in header.');
    }
    final path = request.url.path;
    if (path == '/v1/agents' && request.method == 'POST') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      saved = {
        'id': 'agent_offline',
        'object': 'agent',
        'created_at': 100,
        'updated_at': 100,
        'model': body['model'],
        'name': body['name'],
        'instructions': body['instructions'],
        'metadata': body['metadata'] ?? <String, String>{},
        'reasoning': _reasoning(body['reasoning']),
        'text': _text(body['text']),
        'service_tier': body['service_tier'] ?? 'auto',
        'multi_agent': _multiAgent(body['multi_agent']),
        'tools': [
          for (final tool in body['tools'] as List<dynamic>? ?? [])
            _resolvedTool(tool as Map<String, dynamic>),
        ],
      };
      return _json(saved!, 201);
    }
    if (path == '/v1/agents' && request.method == 'GET') {
      final data = request.url.queryParameters.containsKey('after')
          ? <Object>[]
          : <Object>[saved!];
      return _json({
        'object': 'list',
        'data': data,
        'first_id': data.isEmpty ? null : saved!['id'],
        'last_id': data.isEmpty ? null : saved!['id'],
        'has_more': data.isNotEmpty,
      });
    }
    if (path == '/v1/agents/agent_offline') {
      if (request.method == 'GET') return _json(saved!);
      if (request.method == 'POST') {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        for (final entry in body.entries) {
          saved![entry.key] = switch (entry.key) {
            'reasoning' => _reasoning(entry.value),
            'text' => _text(entry.value),
            'multi_agent' => _multiAgent(entry.value),
            'metadata' => entry.value ?? <String, String>{},
            'tools' => [
              for (final tool in entry.value as List<dynamic>? ?? [])
                _resolvedTool(tool as Map<String, dynamic>),
            ],
            _ => entry.value,
          };
        }
        saved!['updated_at'] = 101;
        return _json(saved!);
      }
      if (request.method == 'DELETE') {
        saved = null;
        return _json({
          'id': 'agent_offline',
          'object': 'agent.deleted',
          'deleted': true,
        });
      }
    }
    throw StateError('Unexpected offline operation.');
  }
}

Map<String, dynamic> _reasoning(Object? value) {
  final config = value as Map<String, dynamic>? ?? {};
  return {'effort': config['effort'], 'summary': config['summary']};
}

Map<String, dynamic> _text(Object? value) {
  final config = value as Map<String, dynamic>? ?? {};
  return {
    'format': config['format'] ?? {'type': 'text'},
    'verbosity': config['verbosity'] ?? 'medium',
  };
}

Map<String, dynamic> _multiAgent(Object? value) {
  final config = value as Map<String, dynamic>? ?? {};
  return {
    'enabled': config['enabled'] ?? false,
    'max_concurrent_subagents': config['enabled'] == true
        ? config['max_concurrent_subagents'] ?? 6
        : null,
  };
}

Map<String, dynamic> _resolvedTool(Map<String, dynamic> tool) =>
    switch (tool['type']) {
      'function' => {...tool, 'defer_loading': tool['defer_loading'] ?? false},
      'programmatic_tool_calling' => {
        ...tool,
        'enabled': tool['enabled'] ?? true,
      },
      'computer_use' => {
        ...tool,
        'include_screenshots': tool['include_screenshots'] ?? false,
      },
      'tool_search' => tool,
      'web_search' => {
        ...tool,
        'mode': tool['mode'] ?? 'live',
        'context_size': tool['context_size'] ?? 'medium',
        'allowed_domains': tool['allowed_domains'],
        'location': tool['location'],
      },
      'mcp' => {
        ...tool,
        'credential_id': tool['credential_id'],
        'request_metadata': tool['request_metadata'] ?? <String, dynamic>{},
        'allowed_tools': tool['allowed_tools'],
        'required': tool['required'] ?? false,
        'connection_origin': tool['connection_origin'] ?? 'service',
        'transport': {
          ...tool['transport'] as Map<String, dynamic>,
          'headers':
              (tool['transport'] as Map<String, dynamic>)['headers'] ??
              <String, String>{},
        },
      },
      _ => throw StateError('Unsupported offline tool.'),
    };

http.Response _json(Map<String, dynamic> json, [int status = 200]) =>
    http.Response(
      jsonEncode(json),
      status,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
