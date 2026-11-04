import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

Map<String, dynamic> _question() => {
  'type': 'predicate',
  'name': 'ready',
  'instructions': 'Is the user ready?',
};
Map<String, dynamic> _delegation() => {
  'type': 'decisions',
  'acknowledgement_delay_ms': 300,
  'decisions': {
    'model': 'gpt-6-luna',
    'questions': [_question()],
  },
};
Map<String, dynamic> _trigger() => {
  'type': 'decisions',
  'event_type': 'session.input_transcript.delta',
  'decisions': {
    'questions': [_question()],
  },
};
Map<String, dynamic> _session() => {
  'id': 'live_fixture',
  'model': 'gpt-live-1',
  'expires_at': -1,
  'status': 'active',
  'delegation': _delegation(),
  'triggers': [_trigger()],
};
Map<String, dynamic> _decisionEvent({bool trigger = false}) => {
  'type': 'decision.event',
  'event_id': 'decision_event',
  'delegation_id': trigger ? null : 'delegation_1',
  'trigger_id': trigger ? 'trigger_1' : null,
  'source_event_type': trigger ? 'session.input_transcript.delta' : null,
  'source_event_id': trigger ? 'transcript_2' : null,
  'event': {
    'type': 'decision.completed',
    'decision': {
      'model': 'gpt-6-luna',
      'answers': [
        {'type': 'predicate', 'name': 'ready', 'probability': 0.9},
      ],
      'usage': {
        'input_tokens': 8,
        'output_tokens': 0,
        'total_tokens': 8,
        'input_tokens_details': {'cached_tokens': 0, 'cache_write_tokens': 0},
        'output_tokens_details': {'reasoning_tokens': 0},
      },
      'future': {'keep': true},
    },
  },
};
Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  test(
    'HTTP WebRTC create and SIP accept retain native delegation/triggers',
    () async {
      final requests = <http.Request>[];
      final transport = MockClient((request) async {
        requests.add(request);
        expect(request.headers['authorization'], 'Bearer synthetic');
        expect(request.headers['openai-beta'], isNull);
        if (request.url.path.endsWith('/accept')) return http.Response('', 200);
        return http.Response(
          jsonEncode({
            'session': {'id': 'live_fixture'},
            'transport': {'type': 'webrtc', 'sdp': 'synthetic answer'},
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = OpenAIClient(
        config: const OpenAIConfig(
          baseUrl: 'https://fixture.invalid/proxy/v1?tenant=one',
          authProvider: ApiKeyProvider('synthetic'),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      final input = {
        'model': 'gpt-live-1',
        'delegation': _delegation(),
        'triggers': [_trigger()],
      };
      final created = await client.live.sessions.create(
        LiveSessionCreateRequest.fromJson({
          'session': input,
          'transport': const {'type': 'webrtc', 'sdp': 'synthetic offer'},
        }),
      );
      expect(created.session.id, 'live_fixture');
      await client.live.sessions.accept(
        'live/opaque',
        LiveCallAcceptRequest.fromJson({
          'session': {...input, 'type': 'live'},
        }),
      );
      expect(requests.map((r) => r.method), ['POST', 'POST']);
      expect(requests[0].url.path, '/proxy/v1/live/sessions');
      expect(requests[1].url.pathSegments.last, 'accept');
      for (final request in requests) {
        expect(request.url.queryParameters['tenant'], 'one');
        final sent = jsonDecode(request.body) as Map<String, dynamic>;
        expect(
          (sent['session'] as Map<String, dynamic>)['delegation'],
          _delegation(),
        );
        expect((sent['session'] as Map<String, dynamic>)['triggers'], [
          _trigger(),
        ]);
      }
    },
  );

  for (final channel in ['primary', 'sideband', 'fork']) {
    test(
      '$channel configures, updates, sends shared items and receives native decisions',
      () async {
        final client = OpenAIClient(
          httpClient: MockClient(
            (_) async => throw StateError('No HTTP expected'),
          ),
        );
        final socket = _Socket();
        final connection = switch (channel) {
          'primary' => await client.live.connect(
            connector: (uri, {headers}) async => socket,
          ),
          'sideband' => await client.live.attach(
            'live_fixture',
            connector: (uri, {headers}) async => socket,
          ),
          _ => await client.live.forkConnection(
            'stored_fixture',
            connector: (uri, {headers}) async => socket,
          ),
        };
        addTearDown(() async {
          await connection.close();
          client.close();
        });
        final received = <LiveServerEvent>[];
        final errors = <Object>[];
        final tap = connection.events.listen(received.add, onError: errors.add);
        addTearDown(tap.cancel);
        if (connection is LivePrimaryConnection) {
          final started = connection.start(
            LiveSessionStartEvent(
              session: LiveSessionCreateParams.fromJson({
                'model': 'gpt-live-1',
                'delegation': _delegation(),
                'triggers': [_trigger()],
              }),
            ),
          );
          await _tick();
          socket.emit({
            'type': 'session.started',
            'event_id': 'started',
            'session': _session(),
          });
          await started;
        } else if (connection is LiveForkConnection) {
          final started = connection.start(
            LiveForkSessionStartEvent(session: LiveForkSessionConfigParam()),
          );
          await _tick();
          socket.emit({
            'type': 'session.started',
            'event_id': 'started',
            'session': _session(),
          });
          await started;
        } else {
          socket.emit({
            'type': 'session.updated',
            'event_id': 'updated',
            'session': _session(),
          });
          await _tick();
        }
        void send(Map<String, dynamic> wire) {
          if (connection is LivePrimaryConnection) {
            connection.send(LiveClientEvent.fromJson(wire));
          } else if (connection is LiveForkConnection) {
            connection.send(LiveClientEvent.fromForkJson(wire));
          } else {
            (connection as LiveSidebandConnection).send(
              LiveSidebandClientEvent.fromJson(wire),
            );
          }
        }

        send({
          'type': 'session.update',
          'session': {
            'delegation': {
              'type': 'decisions',
              'decisions': {
                'questions': [_question()],
              },
            },
            'triggers': <Object?>[],
          },
        });
        final item = {
          'type': 'message',
          'role': 'developer',
          'content': 'Current state is ready.',
        };
        send({'type': 'decision.item.create', 'event_id': null, 'item': item});
        send({'type': 'decision.create', 'event_id': 'manual_evaluation'});
        send({'type': 'decision.item.delete', 'item_id': 'item_1'});
        expect(
          socket.writes.map((e) => e['type']),
          containsAllInOrder([
            'session.update',
            'decision.item.create',
            'decision.create',
            'decision.item.delete',
          ]),
        );
        expect(
          socket.writes.firstWhere(
            (e) => e['type'] == 'decision.item.create',
          )['event_id'],
          isNull,
        );
        expect(
          () => send({'type': 'response.create'}),
          throwsA(isA<LiveProtocolException>()),
        );
        send({
          'type': 'session.commentary.append',
          'delegation_id': 'delegation_1',
          'content': 'Confirmed application result',
        });
        expect(socket.writes.last['delegation_id'], 'delegation_1');

        socket
          ..emit({
            'type': 'decision.item.created',
            'event_id': 'created',
            'item': {...item, 'id': 'item_1'},
          })
          ..emit({
            'type': 'session.input_transcript.delta',
            'event_id': 'transcript_1',
            'delta': 'I am ',
            'start_ms': 0,
            'end_ms': 100,
          })
          ..emit({
            'type': 'session.input_transcript.delta',
            'event_id': 'transcript_2',
            'delta': 'ready',
            'start_ms': 100,
            'end_ms': 200,
          })
          ..emit({
            'type': 'session.output_transcript.delta',
            'event_id': 'spoken_1',
            'delta': 'Understood',
            'start_ms': 200,
            'end_ms': 300,
          })
          ..emit(_decisionEvent(trigger: true))
          ..emit(
            _decisionEvent(trigger: true)..['source_event_id'] = 'transcript_1',
          )
          ..emit(_decisionEvent())
          ..emit({'type': 'future.decision.event', 'order': 3})
          ..emit({
            'type': 'decision.item.deleted',
            'event_id': 'deleted',
            'item_id': 'item_1',
          });
        await _tick();
        expect(errors, isEmpty);
        final decisions = received.whereType<LiveDecisionEvent>().toList();
        expect(decisions, hasLength(3));
        expect(decisions.map((e) => e.sourceEventId), [
          'transcript_2',
          'transcript_1',
          null,
        ]);
        expect(
          received.whereType<LiveInputTranscriptDelta>().map((e) => e.delta),
          ['I am ', 'ready'],
        );
        expect(
          received.whereType<LiveOutputTranscriptDelta>().single.type,
          'session.output_transcript.delta',
        );
        expect(decisions.first.sourceEventId, 'transcript_2');
        expect(decisions.first.delegationId, isNull);
        expect(decisions.last.delegationId, 'delegation_1');
        expect(decisions.last.triggerId, isNull);
        expect(decisions.first.typedDecision.model, 'gpt-6-luna');
        expect(
          decisions.first.typedDecision.answers.single,
          isA<PredicateDecisionAnswer>(),
        );
        expect(decisions.first.toJson(), _decisionEvent(trigger: true));
        expect(
          received.whereType<LiveDecisionItemCreated>().single.item.id,
          'item_1',
        );
        expect(
          received.whereType<UnknownLiveServerEvent>().single.type,
          'future.decision.event',
        );
        expect(
          received.whereType<LiveDecisionItemDeleted>().single.itemId,
          'item_1',
        );
      },
    );
  }
}

class _Socket implements WebSocket {
  final _events = StreamController<WebSocketEvent>(sync: true);
  final List<Map<String, dynamic>> writes = [];
  void emit(Map<String, dynamic> json) =>
      _events.add(TextDataReceived(jsonEncode(json)));
  @override
  Stream<WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) =>
      writes.add(jsonDecode(text) as Map<String, dynamic>);
  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('JSON fixture');
  @override
  Future<void> close([int? code, String? reason]) async {
    unawaited(_events.close());
  }
}
