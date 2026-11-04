/// Bounded raw/typed Agent results on one synthetic observation.
/// Flags: --raw (no local parser), --create (streamed creation), --bad-output.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

import 'agent_session_recovery_example.dart' show recoverySessionFixture;

Future<void> main(List<String> arguments) async {
  final raw = arguments.contains('--raw');
  final creation = arguments.contains('--create');
  final invalid = arguments.contains('--bad-output');
  final body = StreamController<List<int>>();
  var inputs = 0;
  void emit(Object event) =>
      body.add(utf8.encode('data: ${jsonEncode(event)}\n\n'));
  void complete() {
    emit(_turn('created'));
    emit({
      'type': 'agent.session.turn.item.done',
      'event_id': 'answer',
      'session_id': 'session',
      'turn_id': 'root',
      'output_index': 0,
      'item': {
        'type': 'message',
        'role': 'assistant',
        'id': 'message',
        'turn_id': 'root',
        'phase': 'final_answer',
        'status': 'completed',
        'content': [
          {
            'type': 'output_text',
            'text': invalid ? 'invalid-json' : '{"answer":4}',
          },
        ],
      },
    });
    emit(_turn('completed'));
    emit({
      'type': 'agent.session.idle',
      'event_id': 'idle',
      'session': recoverySessionFixture(requestId: 'unused', status: 'idle'),
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
    final wire =
        jsonDecode(utf8.decode(await input.expand((chunk) => chunk).toList()))
            as Map;
    if (!request.url.path.endsWith('/events')) {
      if (!raw && ((wire['agent'] as Map)['text'] as Map)['format'] == null) {
        throw StateError('Missing canonical format');
      }
      emit({
        'type': 'agent.session.created',
        'event_id': 'created',
        'session': recoverySessionFixture(requestId: 'unused', status: 'idle'),
      });
      complete();
      return http.StreamedResponse(
        body.stream,
        201,
        headers: {'content-type': 'text/event-stream'},
      );
    }
    inputs++;
    complete();
    return http.StreamedResponse(const Stream.empty(), 202);
  });
  final client = OpenAIClient(httpClient: transport);
  final run = creation
      ? client.agents.sessions.createRun(
          CreateAgentSessionRequest(
            agentId: 'agent',
            environment: AgentSessionEnvironment.none(),
            input: AgentSessionInitialInput.text('What is 2 + 2?'),
          ),
        )
      : client.agents.sessions.stream(
          'session',
          input: AgentSessionInitialInput.text('What is 2 + 2?'),
        );
  try {
    if (raw) {
      run.withResultCollection(maxMessages: 16, maxBytes: 1024 * 1024);
      await run.nextEvent(); // Partial progress, then continue the same cursor.
      final result = await run.finalResult();
      stdout.writeln(
        'Raw completed turn ${result.turnId}: ${result.outputText}',
      );
    } else {
      final typed = run.withOutput(
        AgentSessionOutputBinding<int>(
          format: AgentJsonSchemaFormat(
            schema: const {
              'type': 'object',
              'properties': {
                'answer': {'type': 'integer'},
              },
              'required': ['answer'],
              'additionalProperties': false,
            },
          ),
          parse: (text) {
            final value = jsonDecode(text);
            if (value is! Map<String, dynamic> || value['answer'] is! int) {
              throw const FormatException('Expected an integer answer');
            }
            return value['answer']! as int;
          },
        ),
      );
      await typed.nextEvent(); // Every later block is still validated.
      try {
        final result = await typed.finalResult();
        stdout.writeln(
          'Validated answer: ${result.parsed}; completed turn: ${result.turnId}.',
        );
      } on AgentSessionOutputParseException catch (error) {
        if (!invalid || error.result.turn.status.value != 'completed') rethrow;
        stdout.writeln(
          'Local validation failed; the successful completed raw result remains available.',
        );
      }
    }
    if (inputs != (creation ? 0 : 1)) {
      throw StateError('A second input was submitted');
    }
    stdout.writeln(
      'One observation; no external calls or backend cancellation.',
    );
  } finally {
    await run.close();
    client.close();
    transport.close();
    unawaited(body.close());
  }
}

Map<String, dynamic> _turn(String status) => {
  'type': 'agent.session.turn.$status',
  'event_id': 'turn-$status',
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
