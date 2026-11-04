/// Exercises native Live Decisions using a synthetic in-memory WebSocket.
/// No API key, Live session, media capture or external action is used.
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:web_socket/web_socket.dart';

Future<void> main() async {
  final peer = _Peer();
  final client = OpenAIClient(
    httpClient: MockClient((_) async => throw StateError('No HTTP expected.')),
  );
  final connection = await client.live.connect(
    connector: (uri, {headers}) async => peer,
  );
  final decisions = <LiveDecisionEvent>[];
  final errors = <Object>[];
  final tap = connection.events.listen((event) {
    if (event is LiveDecisionEvent) decisions.add(event);
  }, onError: errors.add);
  final question = LiveDecisionQuestion.predicate(
    name: 'ready',
    instructions: const LiveDecisionInstructions.text(
      'Is the user ready to continue?',
    ),
  );
  try {
    await connection.start(
      LiveSessionStartEvent(
        session: LiveSessionCreateParams(
          model: 'gpt-live-1',
          delegation: LiveDecisionsDelegationParam(
            decisions: LiveDecisionsSettingsInputParam(
              model: 'gpt-6-luna',
              questions: [question],
            ),
          ),
          triggers: [
            LiveDecisionTriggerInputParam(
              eventType: 'session.input_transcript.delta',
              decisions: LiveDecisionQuestionsInputParam(questions: [question]),
            ),
          ],
        ),
      ),
    );

    // Changes apply after the server's acknowledgment, before shared items are
    // appended. Updates preserve the delegation owner selected at startup.
    final updated = connection.events.firstWhere(
      (event) => event is LiveSessionUpdated,
    );
    connection.send(
      LiveSessionUpdateParam(
        session: LiveSessionUpdateParams(
          delegation: LiveDecisionsDelegationUpdateParam(
            decisions: LiveDecisionsSettingsUpdateParam(questions: [question]),
          ),
        ),
      ),
    );
    await updated;

    final itemAdded = connection.events.firstWhere(
      (event) => event is LiveDecisionItemCreated,
    );
    connection.send(
      LiveDecisionItemCreateParam(
        item: LiveDecisionMessageParam.developer(
          content: const LiveDecisionContent.text(
            'Application state: setup is complete.',
          ),
        ),
      ),
    );
    final stored = (await itemAdded) as LiveDecisionItemCreated;

    final evaluated = connection.events.firstWhere(
      (event) => event is LiveDecisionEvent,
    );
    connection.send(LiveDecisionCreateParam(eventId: 'evaluate_once'));
    final delegated = (await evaluated) as LiveDecisionEvent;
    final answer =
        delegated.typedDecision.answers.single as PredicateDecisionAnswer;
    if (answer.probability < 0.8) {
      throw StateError('Unexpected fixture result.');
    }

    // Production applications choose and confirm any external action themselves,
    // append current state to shared Decision items, await item.created, and only
    // then report the confirmed result to Live using the delegation ID.
    connection.send(
      LiveCommentaryAppendParam(
        delegationId: delegated.delegationId,
        content: 'The application confirms setup is complete.',
      ),
    );

    final triggered = connection.events.firstWhere(
      (event) => event is LiveDecisionEvent && event.triggerId != null,
    );
    peer.transcript();
    final reaction = (await triggered) as LiveDecisionEvent;
    if (reaction.delegationId != null ||
        reaction.sourceEventId != 'input_delta_1') {
      throw StateError('Trigger/source correlation changed.');
    }
    // Results can arrive out of order. Match sourceEventId to the corresponding
    // transcript delta; decide which result is still relevant in your app.
    await (connection
          ..send(LiveDecisionItemDeleteParam(itemId: stored.item.id)))
        .closeSession();
    if (errors.isNotEmpty) {
      throw StateError('Unexpected fixture protocol error.');
    }
    if (decisions.length != 2) {
      throw StateError('Expected delegation and trigger results.');
    }
    stdout
      ..writeln('Received native delegation and transcript-trigger decisions.')
      ..writeln('Zero API requests, media sessions or external actions.');
  } finally {
    await tap.cancel();
    await connection.close();
    client.close();
  }
}

class _Peer implements WebSocket {
  final _events = StreamController<WebSocketEvent>(sync: true);
  Map<String, dynamic> _session = {};

  void _emit(Map<String, dynamic> value) =>
      _events.add(TextDataReceived(jsonEncode(value)));

  void _decision({bool trigger = false}) => _emit({
    'type': 'decision.event',
    'event_id': trigger ? 'trigger_result' : 'delegated_result',
    'delegation_id': trigger ? null : 'delegation_1',
    'trigger_id': trigger ? 'trigger_1' : null,
    'source_event_type': trigger ? 'session.input_transcript.delta' : null,
    'source_event_id': trigger ? 'input_delta_1' : null,
    'event': {
      'type': 'decision.completed',
      'decision': {
        'model': 'gpt-6-luna',
        'answers': [
          {'type': 'predicate', 'name': 'ready', 'probability': 0.95},
        ],
        'usage': {
          'input_tokens': 10,
          'output_tokens': 0,
          'total_tokens': 10,
          'input_tokens_details': {'cached_tokens': 0, 'cache_write_tokens': 0},
          'output_tokens_details': {'reasoning_tokens': 0},
        },
      },
    },
  });

  void transcript() {
    _emit({
      'type': 'session.input_transcript.delta',
      'event_id': 'input_delta_1',
      'delta': 'I am ready.',
      'start_ms': 0,
      'end_ms': 500,
    });
    _decision(trigger: true);
  }

  @override
  void sendText(String text) {
    final command = jsonDecode(text) as Map<String, dynamic>;
    switch (command['type']) {
      case 'session.start':
        _session = {
          ...command['session'] as Map<String, dynamic>,
          'id': 'live_synthetic',
          'expires_at': -1,
          'status': 'active',
        };
        _emit({
          'type': 'session.started',
          'event_id': 'started',
          'session': _session,
        });
      case 'session.update':
        // This fixture only changes questions inside the existing settings.
        final changes = command['session'] as Map<String, dynamic>;
        final update =
            (changes['delegation'] as Map<String, dynamic>)['decisions']
                as Map<String, dynamic>;
        final delegation = _session['delegation'] as Map<String, dynamic>;
        _session = {
          ..._session,
          'delegation': {
            ...delegation,
            'decisions': {
              ...delegation['decisions'] as Map<String, dynamic>,
              ...update,
            },
          },
        };
        _emit({
          'type': 'session.updated',
          'event_id': 'updated',
          'session': _session,
        });
      case 'decision.item.create':
        _emit({
          'type': 'decision.item.created',
          'event_id': 'item_added',
          'item': {
            ...command['item'] as Map<String, dynamic>,
            'id': 'shared_state',
          },
        });
      case 'decision.create':
        _decision();
      case 'session.commentary.append':
        break;
      case 'decision.item.delete':
        _emit({
          'type': 'decision.item.deleted',
          'event_id': 'item_removed',
          'item_id': command['item_id'],
        });
      case 'session.close':
        _emit({
          'type': 'session.closed',
          'event_id': 'closed',
          'reason': 'close_requested',
          'session': _session,
          'usage': {'seconds': 1.0},
        });
      default:
        throw StateError('Unexpected fixture command.');
    }
  }

  @override
  Stream<WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('JSON fixture');
  @override
  Future<void> close([int? code, String? reason]) async {
    unawaited(_events.close());
  }
}
