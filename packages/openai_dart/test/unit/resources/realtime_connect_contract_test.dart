import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

void main() {
  group('Realtime connection selectors', () {
    for (final target in [
      <String, String>{'call_id': 'call /?雪'},
      <String, String>{'intent': 'transcription'},
      <String, String>{'intent': 'realtime'},
      <String, String>{},
    ]) {
      test('encodes the optional target $target without a model', () async {
        final client = OpenAIClient(
          config: const OpenAIConfig(
            baseUrl: 'https://offline.invalid/v1?tenant=kept',
          ),
        );
        addTearDown(client.close);
        Uri? seen;
        final connection = await client.realtime.connect(
          callId: target['call_id'],
          intent: target['intent'],
          queryParameters: {'client': 'kept'},
          connector: (uri, {headers}) async {
            seen = uri;
            return _Socket();
          },
        );
        addTearDown(connection.close);
        expect(seen!.path, '/v1/realtime');
        expect(seen!.scheme, 'wss');
        expect(seen!.queryParameters, {
          'tenant': 'kept',
          'client': 'kept',
          ...target,
        });
      });
    }

    test(
      'typed keys override the same query key and retain other selectors',
      () async {
        final client = OpenAIClient();
        addTearDown(client.close);
        Uri? seen;
        final connection = await client.realtime.connect(
          model: 'typed-model',
          callId: 'typed-call',
          intent: 'realtime',
          queryParameters: {
            'model': 'query-model',
            'call_id': 'query-call',
            'intent': 'transcription',
            'extra': 'kept',
          },
          connector: (uri, {headers}) async {
            seen = uri;
            return _Socket();
          },
        );
        addTearDown(connection.close);
        // Canonical/Python parameters do not impose Node's stricter XOR. The
        // server validates these combinations, including existing query escapes.
        expect(seen!.queryParameters, {
          'model': 'typed-model',
          'call_id': 'typed-call',
          'intent': 'realtime',
          'extra': 'kept',
        });
      },
    );

    test('query model remains available without a typed model', () async {
      final client = OpenAIClient();
      addTearDown(client.close);
      Uri? seen;
      final connection = await client.realtime.connect(
        queryParameters: {'model': 'query-model'},
        config: const RealtimeSessionCreateRequest(model: 'query-model'),
        connector: (uri, {headers}) async {
          seen = uri;
          return _Socket();
        },
      );
      addTearDown(connection.close);
      expect(seen!.queryParameters, {'model': 'query-model'});
    });

    test('invalid typed intent rejects before auth or dialing', () async {
      final auth = _Auth();
      final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
      addTearDown(client.close);
      await expectLater(
        client.realtime.connect(
          intent: 'private-invalid-intent',
          connector: (uri, {headers}) async => throw StateError('no dial'),
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.toString(),
            'redacted value',
            isNot(contains('private')),
          ),
        ),
      );
      expect(auth.calls, 0);
    });

    for (final target in [
      <String, String>{'call_id': 'existing-call'},
      <String, String>{'intent': 'transcription'},
      <String, String>{},
    ]) {
      test('recovery requires a model session: $target', () async {
        final auth = _Auth();
        final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
        addTearDown(client.close);
        await expectLater(
          client.realtime.connect(
            callId: target['call_id'],
            intent: target['intent'],
            reconnect: const RealtimeReconnectOptions(
              onReconnecting: _continueRecovery,
            ),
            connector: (uri, {headers}) async => throw StateError('no dial'),
          ),
          throwsArgumentError,
        );
        expect(auth.calls, 0);
      });
    }

    for (final fromBase in [false, true]) {
      test('model query admits opt-in recovery (base=$fromBase)', () async {
        final client = OpenAIClient(
          config: OpenAIConfig(
            baseUrl:
                'https://offline.invalid/v1${fromBase ? '?model=query-model' : ''}',
          ),
        );
        addTearDown(client.close);
        final connection = await client.realtime.connect(
          queryParameters: fromBase ? null : {'model': 'query-model'},
          reconnect: const RealtimeReconnectOptions(
            onReconnecting: _continueRecovery,
          ),
          connector: (uri, {headers}) async => _Socket(),
        );
        addTearDown(connection.close);
        expect(connection.recovery, isNotNull);
      });
    }

    test(
      'retry query must retain a model session before refreshing auth',
      () async {
        final auth = _Auth();
        final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
        addTearDown(client.close);
        final socket = _Socket();
        var dials = 0;
        final connection = await client.realtime.connect(
          queryParameters: {'model': 'query-model'},
          reconnect: RealtimeReconnectOptions(
            onReconnecting: (_) =>
                const WebSocketReconnectDecision.continueWith(
                  queryParameters: {'model': ''},
                ),
            maxAttempts: 1,
            initialDelay: Duration.zero,
            maxDelay: Duration.zero,
          ),
          connector: (uri, {headers}) async {
            dials++;
            return socket;
          },
        );
        addTearDown(connection.close);
        socket.peerClose(1006);
        await connection.done.timeout(const Duration(seconds: 5));
        expect(auth.calls, 1);
        expect(dials, 1);
        expect(connection.isClosed, isTrue);
      },
    );
  });

  test(
    'public response.create encodes all typed inputs and preserves empty input',
    () async {
      final client = OpenAIClient();
      addTearDown(client.close);
      final socket = _Socket();
      final connection = await client.realtime.connect(
        model: 'fixture-model',
        connector: (uri, {headers}) async => socket,
      );
      addTearDown(connection.close);
      final wire = <Map<String, dynamic>>[
        {'type': 'item_reference', 'id': 'existing_1'},
        {
          'type': 'message',
          'role': 'user',
          'content': [
            {'type': 'input_text', 'text': 'Explicit context'},
          ],
        },
        {
          'type': 'function_call',
          'call_id': 'call_1',
          'name': 'lookup',
          'arguments': '{}',
        },
        {
          'type': 'function_call_output',
          'call_id': 'call_1',
          'output': 'result',
        },
      ];
      connection
        ..createResponse(
          input: wire.map(RealtimeResponseInputItem.fromJson).toList(),
          conversation: 'none',
          eventId: 'request_1',
        )
        ..createResponse(input: [])
        ..createResponse();
      expect(jsonDecode(socket.sent[0]), {
        'type': 'response.create',
        'event_id': 'request_1',
        'response': {'input': wire, 'conversation': 'none'},
      });
      expect(jsonDecode(socket.sent[1]), {
        'type': 'response.create',
        'response': {'input': <dynamic>[]},
      });
      expect(jsonDecode(socket.sent[2]), {'type': 'response.create'});
    },
  );

  test(
    'public Translation flow delivers typed trailing events until peer closes',
    () async {
      final client = OpenAIClient();
      addTearDown(client.close);
      final socket = _Socket();
      Uri? seen;
      final connection = await client.realtime.connectTranslation(
        model: 'translation-model',
        config: const RealtimeTranslationSessionUpdateRequest(
          audio: RealtimeTranslationSessionAudio(
            output: RealtimeTranslationSessionAudioOutput(language: 'es'),
          ),
        ),
        connector: (uri, {headers}) async {
          seen = uri;
          return socket;
        },
      );
      addTearDown(connection.close);
      final events = <RealtimeTranslationServerEvent>[];
      final tap = connection.events.listen(events.add);
      addTearDown(tap.cancel);
      expect(seen!.path, '/v1/realtime/translations');
      expect(seen!.queryParameters, {'model': 'translation-model'});
      connection
        ..appendAudioBytes([0, 0], eventId: 'audio_1')
        ..closeSession(eventId: 'close_1');
      expect(socket.sent.map(jsonDecode).toList(), [
        {
          'type': 'session.update',
          'session': {
            'audio': {
              'output': {'language': 'es'},
            },
          },
        },
        {
          'type': 'session.input_audio_buffer.append',
          'event_id': 'audio_1',
          'audio': 'AAA=',
        },
        {'type': 'session.close', 'event_id': 'close_1'},
      ]);
      final session = {
        'id': 'sess_fixture',
        'type': 'translation',
        'expires_at': 1234,
        'model': 'translation-model',
        'audio': {
          'output': {'language': 'es'},
        },
      };
      socket
        ..emit({
          'type': 'session.created',
          'event_id': 'created',
          'session': session,
        })
        ..emit({
          'type': 'session.updated',
          'event_id': 'updated',
          'session': session,
        })
        ..emit({
          'type': 'session.input_transcript.delta',
          'event_id': 'input',
          'delta': 'hello',
          'elapsed_ms': 200,
        })
        ..emit({
          'type': 'session.output_transcript.delta',
          'event_id': 'output',
          'delta': 'hola',
          'elapsed_ms': null,
        })
        ..emit({
          'type': 'session.output_audio.delta',
          'event_id': 'audio',
          'delta': 'AAA=',
          'format': 'pcm16',
          'sample_rate': 24000,
          'channels': 1,
          'elapsed_ms': 200,
        })
        ..emit({'type': 'session.closed', 'event_id': 'closed'});
      await _until(() => events.length == 6);
      expect(events[0], isA<RealtimeTranslationSessionCreatedEvent>());
      expect(events[1], isA<RealtimeTranslationSessionUpdatedEvent>());
      expect(events[2], isA<RealtimeTranslationInputTranscriptDeltaEvent>());
      expect(events[3], isA<RealtimeTranslationOutputTranscriptDeltaEvent>());
      expect(events[4], isA<RealtimeTranslationOutputAudioDeltaEvent>());
      expect(events[5], isA<RealtimeTranslationSessionClosedEvent>());
      expect(connection.isClosed, isFalse);
      socket.peerClose();
      await connection.done;
      expect(connection.closeCode, 1000);
      expect(socket.closeCalls, 0);
    },
  );
}

WebSocketReconnectDecision _continueRecovery(WebSocketReconnectContext _) =>
    const WebSocketReconnectDecision.continueWith();

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return {'Authorization': 'Bearer fixture'};
  }
}

class _Socket implements ws.WebSocket {
  final _events = StreamController<ws.WebSocketEvent>();
  final sent = <String>[];
  int closeCalls = 0;
  void emit(Map<String, dynamic> json) =>
      _events.add(ws.TextDataReceived(jsonEncode(json)));
  void peerClose([int code = 1000]) {
    _events.add(ws.CloseReceived(code, 'complete'));
    unawaited(_events.close());
  }

  @override
  Stream<ws.WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) => sent.add(text);
  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('text fixture');
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    if (!_events.isClosed) {
      _events.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
      unawaited(_events.close());
    }
  }
}

Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 2000; i++) {
    if (condition()) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('Offline Realtime event did not arrive.');
}
