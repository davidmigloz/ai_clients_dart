/// Exercises Agent context settings and independent session action review.
/// Synthetic HTTP only: no API key, model execution or hosted compute.
library;

import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final peer = _Peer();
  final transport = MockClient(peer.handle);
  final client = OpenAIClient(httpClient: transport);
  try {
    final saved = await client.agents.create(
      CreateAgentRequest(
        model: 'gpt-6.1-sol',
        compaction: const AgentCompactionConfig(async: false),
        experimental: const AgentExperimentalConfig(timeAwareness: true),
        serviceTier: AgentServiceTierParam.ultrafast,
        tools: [
          AgentTool.function(
            name: 'lookup',
            description: 'Application-owned lookup.',
            parameters: const {'type': 'object'},
          ),
        ],
      ),
    );
    if (saved.compaction?.async != false ||
        saved.experimental?.timeAwareness != true) {
      throw StateError('Synthetic create settings were lost.');
    }
    // Compaction null resets background mode; empty experimental overrides
    // preserve keys instead of replacing them with default values.
    final reset = await client.agents.update(
      saved.id,
      UpdateAgentRequest(
        clearCompaction: true,
        experimental: const AgentExperimentalOverridesConfig(),
      ),
    );
    if (reset.compaction?.async != true ||
        reset.experimental?.timeAwareness != true) {
      throw StateError('Synthetic update semantics changed.');
    }

    final session = await client.agents.sessions.create(
      CreateAgentSessionRequest(
        agentId: saved.id,
        agent: AgentSessionAgentConfig(
          experimental: const AgentExperimentalOverridesConfig(
            timeAwareness: false,
          ),
        ),
        environment: AgentSessionEnvironment.none(),
        input: AgentSessionInitialInput.text(
          'Inspect the synthetic configuration.',
        ),
        metadata: const {'project': 'demo', 'owner': 'example'},
        review: SessionReviewParam.autoReview,
      ),
    );
    if (session.review != SessionReviewResource.autoReview ||
        session.agent.experimental?.timeAwareness != false) {
      throw StateError('Synthetic session overrides were lost.');
    }
    // Action review is independent of spending limits. Updates affect new root
    // turns; already-running turns and their subagents retain their review mode.
    final updated = await client.agents.sessions.update(
      session.id,
      UpdateAgentSessionRequest(
        review: SessionReviewParam.none,
        agent: AgentSessionAgentUpdate(clearTools: true),
      ),
    );
    if (updated.agent.tools.isNotEmpty || updated.review != null) {
      throw StateError('Synthetic tool clear/review update changed.');
    }

    // Every pair must match; keep the same filters when advancing a cursor.
    final page = await client.agents.sessions.list(
      metadata: const {'project': 'demo', 'owner': 'example'},
      order: AgentListOrder.asc,
      limit: 10,
    );
    if (page.data.single.id != session.id ||
        !peer.sawExactFilter ||
        peer.sawRemovedSpendField) {
      throw StateError('Synthetic metadata query or request shape changed.');
    }
    stdout
      ..writeln('Configured compaction, time awareness and ultrafast requests.')
      ..writeln(
        'Updated action review/tools and matched both metadata filters.',
      )
      ..writeln(
        'Zero external API requests, model execution or hosted compute.',
      );
  } finally {
    client.close();
    transport.close();
  }
}

class _Peer {
  Map<String, dynamic> saved = {};
  Map<String, dynamic> session = {};
  bool sawExactFilter = false;
  bool sawRemovedSpendField = false;

  Future<http.Response> handle(http.Request request) async {
    if (request.headers['openai-beta'] != 'agents=v1') {
      throw StateError('Missing Agents opt-in header.');
    }
    final body = request.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(request.body) as Map<String, dynamic>;
    sawRemovedSpendField |= body.containsKey('spend_control');
    switch ((request.method, request.url.path)) {
      case ('POST', '/v1/agents'):
        saved = {
          'id': 'agent_fixture',
          'object': 'agent',
          'created_at': 1,
          'updated_at': 1,
          ..._resolvedAgent(body),
          'metadata': <String, String>{},
        };
        return _json(saved, 201);
      case ('POST', '/v1/agents/agent_fixture'):
        if (body.containsKey('compaction')) {
          saved['compaction'] = _compaction(body['compaction']);
        }
        if (body.containsKey('experimental')) {
          saved['experimental'] = {
            ...saved['experimental'] as Map<String, dynamic>,
            ...body['experimental'] as Map<String, dynamic>,
          };
        }
        return _json(saved);
      case ('POST', '/v1/agents/sessions'):
        final overrides = body['agent'] as Map<String, dynamic>? ?? {};
        final resolved = _resolvedAgent(saved);
        resolved['experimental'] = {
          ...resolved['experimental'] as Map<String, dynamic>,
          ...?overrides['experimental'] as Map<String, dynamic>?,
        };
        session = {
          'id': 'session_fixture',
          'object': 'agent.session',
          'created_at': 1,
          'last_active_at': 1,
          'agent': {'id': saved['id'], ...resolved},
          'environment': {'type': 'none'},
          'error': null,
          'metadata': body['metadata'],
          'required_actions': <Object?>[],
          'status': 'idle',
          'usage': null,
          'vault_ids': <String>[],
          if (body['review'] != null && body['review'] != 'none')
            'review': body['review'],
        };
        return _json(session, 201);
      case ('POST', '/v1/agents/sessions/session_fixture'):
        if (body['review'] == 'none') {
          session.remove('review');
        } else if (body.containsKey('review')) {
          session['review'] = body['review'];
        }
        final agent = body['agent'] as Map<String, dynamic>?;
        if (agent?.containsKey('tools') ?? false) {
          (session['agent'] as Map<String, dynamic>)['tools'] =
              agent!['tools'] ?? <Object?>[];
        }
        return _json(session);
      case ('GET', '/v1/agents/sessions'):
        final query = request.url.queryParameters;
        sawExactFilter =
            query['metadata[project]'] == 'demo' &&
            query['metadata[owner]'] == 'example' &&
            !query.containsKey('metadata');
        return _json({
          'object': 'list',
          'data': [session],
          'has_more': false,
          'first_id': session['id'],
          'last_id': session['id'],
        });
      default:
        throw StateError('Unexpected synthetic request.');
    }
  }
}

Map<String, dynamic> _resolvedAgent(Map<String, dynamic> input) => {
  'instructions': input['instructions'],
  'model': input['model'],
  'multi_agent':
      input['multi_agent'] ??
      {'enabled': false, 'max_concurrent_subagents': null},
  'name': input['name'],
  'reasoning': input['reasoning'] ?? {'effort': null, 'summary': null},
  'service_tier': input['service_tier'] ?? 'auto',
  'text':
      input['text'] ??
      {
        'format': {'type': 'text'},
        'verbosity': 'medium',
      },
  'tools': [
    for (final tool in input['tools'] as List<dynamic>? ?? <Object?>[])
      _resolvedFunction(tool),
  ],
  'compaction': _compaction(input['compaction']),
  'experimental': {
    'time_awareness':
        (input['experimental'] as Map<String, dynamic>?)?['time_awareness'] ??
        false,
  },
};
Map<String, dynamic> _compaction(Object? value) => {
  'async': (value as Map<String, dynamic>?)?['async'] ?? true,
};
http.Response _json(Map<String, dynamic> value, [int status = 200]) =>
    http.Response(
      jsonEncode(value),
      status,
      headers: {'content-type': 'application/json'},
    );

Map<String, dynamic> _resolvedFunction(Object? value) {
  if (value is! Map<String, dynamic>) {
    throw StateError('Unexpected synthetic tool.');
  }
  return {...value, 'defer_loading': value['defer_loading'] ?? false};
}
