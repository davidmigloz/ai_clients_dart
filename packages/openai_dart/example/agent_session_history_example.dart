// ignore_for_file: avoid_print
// Run: dart run example/agent_session_history_example.dart
// Offline history inspection: known IDs, no session creation or live API/key ($0).
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var requests = 0;
  final transport = MockClient((request) async {
    requests++;
    final path = request.url.path;
    Object wire;
    if (path.endsWith('/traces')) {
      final next = request.url.queryParameters['after'] != null;
      final id = next ? 'turn_3' : 'turn_1';
      wire = {
        'object': 'list',
        'data': [
          {..._trace, 'id': id},
        ],
        'first_id': id,
        'last_id': id,
        'has_more': !next,
      };
    } else if (path.endsWith('/turns/turn_1')) {
      wire = _turn;
    } else if (path.endsWith('/turns')) {
      wire = {
        'object': 'list',
        'data': [_turn],
        'first_id': 'turn_1',
        'last_id': 'turn_1',
        'has_more': false,
      };
    } else {
      wire = {
        'object': 'list',
        'data': [_rootInteraction],
        'first_id': 'item_1',
        'last_id': 'item_1',
        'has_more': false,
      };
    }
    return http.Response(
      jsonEncode(wire),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient.withApiKey(
    'synthetic-offline',
    httpClient: transport,
  );
  try {
    final sessions = client.agents.sessions;
    final items = await sessions.items.list(
      'session_known',
      limit: 20,
      order: AgentListOrder.asc,
    );
    // Root history contains coordinator interactions with children; each child
    // has a separate history. A historical tool call is not a pending action.
    print('Root history items: ${items.data.length}. No actions are replayed.');
    final turns = await sessions.turns.list(
      'session_known',
      limit: 20,
      order: AgentListOrder.asc,
    );
    final turn = await sessions.turns.retrieve(
      'session_known',
      turns.data.first.id,
    );
    await sessions.turns.items.list(
      'session_known',
      turn.id,
      order: AgentListOrder.asc,
    );
    // A terminal turn is distinct from session idle or a live observer's EOF.
    print(
      'Recorded turn status: ${turn.status.value}; usage can remain unknown.',
    );
    String? after;
    var traces = 0;
    do {
      final page = await sessions.traces.list(
        'session_known',
        limit: 1,
        order: AgentListOrder.asc,
        after: after,
      );
      // Inspect/export each private OTLP payload deliberately; do not log it.
      traces += page.data.length;
      if (!page.hasMore) break;
      after = page.lastId;
      if (after == null) {
        throw StateError('Cannot advance a trace page without its cursor');
      }
    } while (true);
    // Trace export needs organization export enabled and a project key with
    // api.traces.read or api.agents.read. Pages
    // skip unpublished turns (turn_2 in this fixture), never await late updates,
    // and cannot prove a complete historical export. The service limits reads
    // and JSON to 16 MiB; request fewer traces when it reports that limit.
    print(
      'Currently published traces: $traces; $requests mock GETs; cost \$0.',
    );
  } finally {
    client.close();
    transport.close();
  }
}

final Map<String, dynamic> _turn = {
  'agent_id': 'root_agent',
  'completed_at': null,
  'created_at': 0,
  'error': null,
  'id': 'turn_1',
  'object': 'agent.session.turn',
  'session_id': 'session_known',
  'started_at': null,
  'status': 'completed',
  'subagent_id': null,
  'usage': null,
};
final Map<String, dynamic> _trace = {
  'id': 'turn_1',
  'object': 'agent.session.trace',
  'session_id': 'session_known',
  'created_at': 1,
  'otlp': {
    'resourceSpans': [
      {
        'resource': {
          'attributes': [
            {
              'key': 'agent.type',
              'value': {'stringValue': 'root'},
            },
          ],
        },
        'scopeSpans': [
          {
            'spans': [
              {
                'name': 'lookup',
                'attributes': [
                  {
                    'key': 'example',
                    'value': {'stringValue': 'synthetic'},
                  },
                ],
              },
            ],
          },
        ],
      },
    ],
  },
};
final Map<String, dynamic> _rootInteraction = {
  'agent_id': 'child_agent',
  'content': <Object?>[],
  'id': 'item_1',
  'model': null,
  'reasoning_effort': null,
  'status': 'in_progress',
  'turn_id': 'turn_1',
  'type': 'create_subagent_call',
};
