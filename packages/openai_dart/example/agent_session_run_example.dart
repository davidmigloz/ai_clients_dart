/// One lazy idle-session follow-up, using only synthetic HTTP and SSE.
/// Pass --cancel-active to exercise an explicit raw cancellation decision instead.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';

import 'agent_session_recovery_example.dart' show recoverySessionFixture;

Future<void> main(List<String> arguments) async {
  final cancelRequested = arguments.contains('--cancel-active');
  final body = StreamController<List<int>>();
  final requests = <String>[];
  final idle = {
    'type': 'agent.session.idle',
    'event_id': 'final-idle',
    'session': recoverySessionFixture(requestId: 'unused', status: 'idle'),
  };
  void emit(Object event) =>
      body.add(utf8.encode('data: ${jsonEncode(event)}\n\n'));
  final transport = MockClient.streaming((request, input) async {
    requests.add('${request.method} ${request.url.path}');
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
    final submitted =
        jsonDecode(utf8.decode(await input.expand((bytes) => bytes).toList()))
            as Map<String, dynamic>;
    final type = ((submitted['events'] as List).single as Map)['type'];
    if (type == 'agent.session.input.message') {
      emit({...idle, 'event_id': 'initial-idle'});
      emit(_turn('created', 'created'));
      if (!cancelRequested) {
        emit({
          'type': 'agent.session.turn.output_text.delta',
          'event_id': 'text',
          'session_id': 'session',
          'turn_id': 'root',
          'item_id': 'message',
          'content_index': 0,
          'output_index': 0,
          'delta': '4',
        });
        emit(_turn('completed', 'completed'));
        emit(idle);
      }
    } else if (type == 'agent.session.input.cancel' && cancelRequested) {
      emit(_turn('cancelled', 'cancelled'));
      emit(idle);
    } else {
      throw StateError('Unexpected application input');
    }
    return http.StreamedResponse(const Stream.empty(), 202);
  });
  final client = OpenAIClient(httpClient: transport);
  final run = client.agents.sessions.stream(
    'session',
    input: AgentSessionInitialInput.text('What is 2 + 2?'),
  );
  try {
    if (requests.isNotEmpty) {
      throw StateError('The helper started before consumption');
    }
    // This controlled pull path can pause and continue on the same cursor. Use
    // `await for (final event in run.events)` as the ordinary Stream alternative;
    // breaking that adapter closes observation, so never combine both drivers.
    final first = await run.nextEvent();
    if (first is! AgentSessionIdleEvent) {
      throw StateError('Expected initial idle');
    }
    var events = 1;
    while (true) {
      final event = await run.nextEvent();
      if (event == null) break;
      events++;
      if (cancelRequested && event is AgentSessionTurnCreatedEvent) {
        // This explicit CLI/application choice sends a raw backend action. It
        // is separate from run.close(), which only closes local observation.
        await cancelActiveDurableWork(client.agents.sessions, run.sessionId);
      }
    }
    if (events != (cancelRequested ? 4 : 5) ||
        run.selectedTurnId != 'root' ||
        requests.length != (cancelRequested ? 4 : 3)) {
      throw StateError('The idle/root boundary or request sequence changed');
    }
    stdout
      ..writeln(
        'Started lazily: retrieved idle, subscribed before input, observed $events events.',
      )
      ..writeln(
        'Initial idle did not finish the run; root termination followed by idle did.',
      )
      ..writeln(
        'Zero external calls. Closing observation never cancels durable work.',
      );
  } finally {
    await run.close();
    await body.close();
    client.close();
    transport.close();
  }
}

/// A separate application decision to cancel active work, never an observer exit.
Future<void> cancelActiveDurableWork(
  AgentSessionsResource sessions,
  String sessionId,
) => sessions.events.create(
  sessionId,
  CreateAgentSessionEventsRequest(events: [AgentSessionInput.cancel()]),
);

Map<String, dynamic> _turn(String eventId, String kind) => {
  'type': 'agent.session.turn.$kind',
  'event_id': eventId,
  'session_id': 'session',
  'turn_id': 'root',
  if (kind != 'created') 'usage': null,
  'turn': {
    'object': 'agent.session.turn',
    'id': 'root',
    'session_id': 'session',
    'agent_id': 'agent',
    'subagent_id': null,
    'created_at': 0,
    'started_at': 0,
    'completed_at': kind == 'created' ? null : 1,
    'status': kind == 'created' ? 'queued' : kind,
    'error': null,
    'usage': null,
  },
};
