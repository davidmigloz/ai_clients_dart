// ignore_for_file: avoid_print
// Run: dart run example/agent_subagents_example.dart
// Read-only mock HTTP ($0): no API key, child execution or tool replay.
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  var requests = 0;
  var childReads = 0;
  final transport = MockClient((request) async {
    requests++;
    if (request.method != 'GET' ||
        request.headers['openai-beta'] != 'agents=v1') {
      throw StateError('Expected beta inspection GET');
    }
    final parts = request.url.pathSegments;
    final child = <String, dynamic>{
      'id': 'child_demo',
      'object': 'agent.session.subagent',
      'session_id': 'session_demo',
      'name': null,
      'instructions': [
        {'type': 'output_text', 'text': 'Inspect the report [image preview]'},
      ],
      'parent_agent_id': 'coordinator_demo',
      'status': 'active',
      'opened_at': 1,
      'closed_at': null,
    };
    final turn = <String, dynamic>{
      'id': 'turn_demo',
      'object': 'agent.session.turn',
      'status': 'completed',
      'session_id': 'session_demo',
      'agent_id': 'child_demo',
      'subagent_id': 'child_demo',
      'created_at': 1,
      'started_at': 1,
      'completed_at': 2,
      'usage': null,
      'error': null,
    };
    // Root and child histories are distinct. Mock pages intentionally contain
    // no pending tool work; this program never dispatches a historical call.
    final empty = <String, dynamic>{
      'object': 'list',
      'data': <Object>[],
      'first_id': null,
      'last_id': null,
      'has_more': false,
    };
    Object wire;
    if (parts.last == 'subagents') {
      wire = {
        ...empty,
        'data': [child],
        'first_id': 'child_demo',
        'last_id': 'child_demo',
      };
    } else if (parts.last == 'child_demo') {
      childReads++;
      wire = {
        ...child,
        'status': childReads == 1 ? 'closed' : 'active',
        'closed_at': childReads == 1 ? 2 : null,
      };
    } else if (parts.last == 'turns') {
      wire = {
        ...empty,
        'data': [turn],
        'first_id': 'turn_demo',
        'last_id': 'turn_demo',
      };
    } else if (parts.last == 'turn_demo') {
      wire = turn;
    } else {
      final isChild = parts.contains('subagents');
      final isTurn = parts.contains('turns');
      final next = request.url.queryParameters.containsKey('after');
      final id = isTurn
          ? 'turn_item_demo'
          : isChild
          ? 'child_item_demo'
          : 'root_item_demo';
      final message = {
        'type': 'message',
        'id': id,
        'turn_id': isChild ? 'turn_demo' : 'root_turn_demo',
        'role': 'user',
        'content': [
          {
            'type': 'input_text',
            'text': isChild ? 'Child task' : 'Coordinator request',
          },
        ],
        'status': 'completed',
        'phase': null,
      };
      wire = {
        ...empty,
        'data': next ? <Object>[] : [message],
        'first_id': next ? null : id,
        'last_id': next ? null : id,
        'has_more': isChild && !isTurn && !next,
      };
    }
    return http.Response.bytes(
      utf8.encode(jsonEncode(wire)),
      200,
      headers: {'content-type': 'application/json'},
    );
  });
  final client = OpenAIClient.withApiKey('example-only', httpClient: transport);
  try {
    final subagents = client.agents.sessions.subagents;
    final children = await subagents.list('session_demo', limit: 20);
    final childId = children.data.single.id;
    final closed = await subagents.retrieve('session_demo', childId);
    final resumed = await subagents.retrieve('session_demo', childId);
    if (closed.closedAt == null ||
        resumed.closedAt != null ||
        closed.openedAt != resumed.openedAt) {
      throw StateError('Invalid received lifecycle fixture');
    }
    // These changes are returned by the service. Reading does not cause resume.
    final root = await client.agents.sessions.items.list('session_demo');
    final childItems = await subagents.items.list(
      'session_demo',
      childId,
      limit: 20,
      order: AgentListOrder.asc,
    );
    final turns = await subagents.turns.list(
      'session_demo',
      childId,
      limit: 20,
      order: AgentListOrder.asc,
    );
    final turnId = turns.data.single.id;
    final turn = await subagents.turns.retrieve(
      'session_demo',
      childId,
      turnId,
    );
    final turnItems = await subagents.turns.items.list(
      'session_demo',
      childId,
      turnId,
      limit: 20,
      order: AgentListOrder.asc,
    );
    if (childItems.lastId != null) {
      await subagents.items.list(
        'session_demo',
        childId,
        limit: 20,
        order: AgentListOrder.asc,
        after: childItems.lastId,
      );
    }
    if (requests != 9 || turn.id != turnId) {
      throw StateError('Incomplete inspection');
    }
    print(
      'Inspected child state and turn history separately: root ${root.data.length}, '
      'child ${childItems.data.length}, child turn ${turnItems.data.length} items. Cost: \$0.',
    );
  } finally {
    client.close();
    transport.close();
  }
}
