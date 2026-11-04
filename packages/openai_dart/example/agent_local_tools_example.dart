/// Opt-in local function dispatch using only synthetic HTTP and SSE.
/// Pass --create for streamed creation; otherwise follow an existing idle session.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

import 'agent_session_recovery_example.dart' show recoverySessionFixture;

Future<void> main(List<String> arguments) async {
  final creation = arguments.contains('--create');
  final body = StreamController<List<int>>();
  final requestKeys = <String?>[];
  var invoked = 0;
  var observedBeforeExecution = false;
  void emit(Object event) =>
      body.add(utf8.encode('data: ${jsonEncode(event)}\n\n'));
  void initial() {
    emit(_turn('created', 'created'));
    emit({
      'type': 'agent.session.turn.item.added',
      'event_id': 'call-event',
      'session_id': 'session',
      'turn_id': 'root',
      'output_index': 0,
      'item': {
        'type': 'function_call',
        'id': 'function',
        'call_id': 'call',
        'turn_id': 'root',
        'name': 'double_number',
        'arguments': {'number': 2},
        'status': 'completed',
      },
    });
  }

  final transport = MockClient.streaming((request, input) async {
    if (request.method == 'GET' && request.url.path.endsWith('/events')) {
      return http.StreamedResponse(
        body.stream,
        200,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    if (request.method == 'GET') {
      return http.StreamedResponse(
        Stream.value(
          utf8.encode(
            jsonEncode(
              recoverySessionFixture(requestId: 'unused', status: 'idle'),
            ),
          ),
        ),
        200,
        headers: {'content-type': 'application/json'},
      );
    }
    final json =
        jsonDecode(utf8.decode(await input.expand((chunk) => chunk).toList()))
            as Map<String, dynamic>;
    requestKeys.add(request.headers['idempotency-key']);
    if (!request.url.path.endsWith('/events')) {
      if (json['stream'] != true || json.containsKey('toolHandlers')) {
        throw StateError('Invalid local metadata boundary');
      }
      emit({
        'type': 'agent.session.created',
        'event_id': 'session-created',
        'session': recoverySessionFixture(requestId: 'unused', status: 'idle'),
      });
      initial();
      return http.StreamedResponse(
        body.stream,
        201,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    final event = (json['events'] as List).single as Map;
    if (event['type'] == 'agent.session.input.message') {
      initial();
    } else if (event['type'] == 'agent.session.input.tool_result') {
      if (event['turn_id'] != 'root' ||
          event['call_id'] != 'call' ||
          event['output'] != '{"answer":4}' ||
          !observedBeforeExecution) {
        throw StateError('Invalid function result sequence');
      }
      emit(_turn('completed', 'completed'));
      emit({
        'type': 'agent.session.idle',
        'event_id': 'idle',
        'session': recoverySessionFixture(requestId: 'unused', status: 'idle'),
      });
    } else {
      throw StateError('Unexpected input');
    }
    return http.StreamedResponse(const Stream.empty(), 202);
  });
  final client = OpenAIClient(httpClient: transport);
  final handlers = <String, AgentToolHandler>{
    'double_number': (args) {
      invoked++;
      return {'answer': (args['number']! as int) * 2};
    },
  };
  // The canonical definition is wire data; its implementation is separate local
  // metadata. For follow-ups the saved session must already have its tool schema.
  final request = CreateAgentSessionRequest(
    agent: AgentSessionAgentConfig(
      model: 'gpt-4.1',
      tools: [
        AgentSessionFunctionTool(
          name: 'double_number',
          description: 'Double a supplied number.',
          parameters: const {
            'type': 'object',
            'properties': {
              'number': {'type': 'integer'},
            },
            'required': ['number'],
            'additionalProperties': false,
          },
        ),
      ],
    ),
    environment: AgentSessionEnvironment.none(),
    input: AgentSessionInitialInput.text('Double 2.'),
  );
  final run = creation
      ? client.agents.sessions.createRun(request, toolHandlers: handlers)
      : client.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('Double 2.'),
          toolHandlers: handlers,
        );
  try {
    await for (final event in run.events) {
      if (event is AgentSessionTurnItemAddedEvent) {
        if (invoked != 0) {
          throw StateError(
            'The handler ran before its original call was delivered',
          );
        }
        observedBeforeExecution = true;
      }
    }
    if (invoked != 1 ||
        requestKeys.length != 2 ||
        requestKeys[0] == requestKeys[1]) {
      throw StateError(
        'Expected one handler and distinct logical request keys',
      );
    }
    stdout
      ..writeln(
        'Observed the original call, executed one local handler, submitted one result.',
      )
      ..writeln(
        'Zero external calls; unknown functions remain available for manual handling.',
      );
  } finally {
    await run.close();
    client.close();
    transport.close();
    unawaited(body.close());
  }
}

Map<String, dynamic> _turn(String event, String status) => {
  'type': 'agent.session.turn.$status',
  'event_id': event,
  'session_id': 'session',
  'turn_id': 'root',
  if (status != 'created') 'usage': null,
  'turn': {
    'object': 'agent.session.turn',
    'id': 'root',
    'session_id': 'session',
    'agent_id': 'agent',
    'subagent_id': null,
    'created_at': 0,
    'started_at': null,
    'completed_at': status == 'created' ? null : 1,
    'status': status == 'created' ? 'queued' : status,
    'error': null,
    'usage': null,
  },
};
