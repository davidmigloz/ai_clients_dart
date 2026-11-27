import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

const _sttModel = 'voxtral-mini-transcribe-realtime-3-0';
const _ttsModel = 'voxtral-mini-tts-3-0';
const _token = 'rt_fixture-token';
const _isBrowser = bool.fromEnvironment('dart.library.js_interop');
const Map<String, Object> _format = {
  'encoding': 'pcm_s16le',
  'sample_rate': 16000,
};
const Map<String, Object> _sttSession = {
  'model': _sttModel,
  'audio_format': _format,
};
const Map<String, Object> _ttsSession = {'model': _ttsModel};

void main() {
  test('session request copies distinguish omitted fields from null', () {
    final request = CreateRealtimeClientSessionRequest.fromJson(const {
      'model': _sttModel,
      'purpose': 'realtime',
      'ttl_seconds': 180,
      'metadata': {'client': 'fixture'},
    });
    expect(request.copyWith().toJson(), request.toJson());
    expect(
      request
          .copyWith(ttlSeconds: null, metadata: const <String, dynamic>{})
          .toJson(),
      {
        'model': _sttModel,
        'purpose': 'realtime',
        'metadata': const <String, dynamic>{},
      },
    );
    expect(request.copyWith(metadata: null).toJson(), {
      'model': _sttModel,
      'purpose': 'realtime',
      'ttl_seconds': 180,
    });
  });

  test('mints an ephemeral token with the pinned HTTP contract', () async {
    final client = MistralClient.withApiKey(
      'workspace-fixture',
      httpClient: MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url, Uri.https('api.mistral.ai', '/v1/client/sessions'));
        expect(request.headers['authorization'], 'Bearer workspace-fixture');
        expect(jsonDecode(request.body), {
          'purpose': 'realtime',
          'model': _sttModel,
          'ttl_seconds': 180,
          'metadata': {'client': 'fixture'},
        });
        return http.Response(
          jsonEncode({
            'object': 'client.session',
            'purpose': 'realtime',
            'expires_at': '2026-11-27T13:05:00+01:00',
            'client_secret': {
              'value': _token,
              'expires_at': '2026-11-27T12:03:00Z',
            },
          }),
          201,
        );
      }),
    );
    addTearDown(client.close);

    final session = await client.realtime.sessions.create(
      request: const CreateRealtimeClientSessionRequest(
        model: _sttModel,
        ttlSeconds: 180,
        metadata: {'client': 'fixture'},
      ),
    );
    expect(session.clientSecret.value, _token);
    expect(session.clientSecret.expiresAt, DateTime.utc(2026, 11, 27, 12, 3));
    expect(session.expiresAt, DateTime.utc(2026, 11, 27, 12, 5));
    expect(session.toJson()['purpose'], 'realtime');
    expect(session.toString(), isNot(contains(_token)));
    expect(session.clientSecret.toString(), isNot(contains(_token)));
    await expectLater(
      client.realtime.sessions.create(
        request: const CreateRealtimeClientSessionRequest(
          model: _sttModel,
          ttlSeconds: 0,
        ),
      ),
      throwsArgumentError,
    );
  });

  test(
    'uses scoped subprotocol auth and waits for session acknowledgments',
    () async {
      final client = MistralClient(
        config: const MistralConfig(
          baseUrl: 'https://example.test/proxy',
          authProvider: ApiKeyProvider('long-lived-fixture'),
          defaultHeaders: {'X-Native-Only': 'fixture'},
          defaultQueryParams: {'model': 'stale', 'route': 'blue'},
        ),
      );
      addTearDown(client.close);
      final socket = _FakeSocket();
      final dialed = Completer<void>();
      var connected = false;
      final opening = client.audio.realtime
          .connect(
            model: _sttModel,
            clientToken: _token,
            options: const RealtimeTranscriptionOptions(
              audioFormat: RealtimeAudioFormat(
                encoding: RealtimeAudioEncoding.pcmS16le,
                sampleRate: 16000,
              ),
              language: 'en',
              diarize: false,
              contextBias: ['Voxtral'],
              targetStreamingDelayMs: 480,
              turnDetection: RealtimeTurnDetection(startThreshold: 0.6),
            ),
            connector: (url, {required headers, required protocols}) async {
              expect(url.scheme, 'wss');
              expect(url.path, '/proxy/v1/audio/transcriptions/realtime');
              expect(url.queryParameters, {
                'model': _sttModel,
                'route': 'blue',
              });
              expect(url.toString(), isNot(contains(_token)));
              expect(headers, isEmpty);
              expect(protocols, ['realtime', _token]);
              dialed.complete();
              return socket;
            },
          )
          .then((value) {
            connected = true;
            return value;
          });

      await dialed.future;
      expect(socket.sent, isEmpty);
      expect(connected, isFalse);
      socket.emit('session.created', {'session': _sttSession});
      expect(await socket.nextSent, {
        'type': 'session.update',
        'session': {
          'audio_format': _format,
          'language': 'en',
          'diarize': false,
          'context_bias': ['Voxtral'],
          'target_streaming_delay_ms': 480,
          'turn_detection': {'start_threshold': 0.6},
        },
      });
      expect(connected, isFalse);
      socket.emit('session.updated', {
        'session': {
          ..._sttSession,
          'target_streaming_delay_ms': 480,
          'turn_detection': {'start_threshold': 0.6},
        },
      });

      final connection = await opening;
      addTearDown(connection.close);
      expect(connection.session.audioFormat.sampleRate, 16000);
      expect(connection.session.targetStreamingDelayMs, 480);
      expect(connection.session.turnDetection?.startThreshold, 0.6);

      final updating = connection.updateSession(
        const RealtimeTranscriptionOptions(
          diarize: true,
          speakerReferences: {'Ava': 'AQID'},
        ),
      );
      expect(await socket.nextSent, {
        'type': 'session.update',
        'session': {
          'diarize': true,
          'speaker_references': {'Ava': 'AQID'},
        },
      });
      socket.emit('session.updated', {
        'session': {
          ..._sttSession,
          'diarize': true,
          'speaker_references': ['Ava'],
        },
      });
      await updating;
      expect(connection.session.speakerReferences, ['Ava']);

      final received = connection.events.toList();
      connection
        ..sendAudio([1, 2, 3])
        ..flushAudio()
        ..endAudio()
        ..endAudio();
      expect(() => connection.sendAudio([4]), throwsStateError);
      expect(socket.sent.skip(2), [
        {'type': 'input_audio.append', 'audio': 'AQID'},
        {'type': 'input_audio.flush'},
        {'type': 'input_audio.end'},
      ]);

      socket
        ..emit('transcription.language', {'audio_language': 'en'})
        ..emit('turn.start', {'time_s': 0})
        ..emit('transcription.text.delta', {'text': 'Hi'})
        ..emit('turn.eager_end', {'time_s': 1})
        ..emit('turn.resume', {'time_s': 1.1})
        ..emit('turn.end', {'time_s': 2.5, 'end_reason': 'threshold'})
        ..emit('transcription.segment', {
          'text': 'Hi',
          'start': 0,
          'end': 2.5,
          'speaker_id': 'Ava',
        })
        ..emit('future.event', {
          'opaque': [1, 2],
        })
        ..emit('transcription.done', {
          'model': _sttModel,
          'text': 'Hi',
          'language': 'en',
          'segments': <Object>[],
          'usage': {'total_tokens': 3},
        })
        ..peerClose(1000);
      final frames = await received;
      expect(frames.map((value) => value.type), [
        'session.created',
        'session.updated',
        'session.updated',
        'transcription.language',
        'turn.start',
        'transcription.text.delta',
        'turn.eager_end',
        'turn.resume',
        'turn.end',
        'transcription.segment',
        'future.event',
        'transcription.done',
      ]);
      expect(frames[3].data?.audioLanguage, 'en');
      expect(frames[8].data?.timeSeconds, 2.5);
      expect(frames[8].data?.endReason, 'threshold');
      expect(frames[9].data?.segment?.speakerId, 'Ava');
      expect(frames[10].data, isNull);
      expect(frames[10].rawJson['opaque'], [1, 2]);
      expect(frames.last.data?.isDone, isTrue);
      expect(frames.last.data?.usage?.totalTokens, 3);
      expect(connection.closeCode, 1000);
      await connection.done;
      await connection.close();
      expect(socket.closeCount, 1);
    },
  );

  test(
    'speech native credentials, repeated flush, and final audio',
    skip: _isBrowser,
    () async {
      final client = MistralClient(
        config: const MistralConfig(
          authProvider: ApiKeyProvider('workspace-fixture'),
          defaultHeaders: {'X-Source': 'default', 'X-Keep': 'keep'},
        ),
      );
      addTearDown(client.close);
      final socket = _FakeSocket();
      socket.onFrame = (frame) {
        if (frame['type'] == 'session.update') {
          socket.emit('session.updated', {
            'session': {..._ttsSession, ...frame['session'] as Map},
          });
        }
        if (const {
          'input_text.flush',
          'input_text.end',
        }.contains(frame['type'])) {
          socket
            ..emit('speech.audio.delta', {'audio_data': 'AQID'})
            ..emit('speech.audio.done', {
              'usage': {'total_tokens': 9},
            });
        }
      };
      final connection = await client.audio.realtimeSpeech.connect(
        model: _ttsModel,
        additionalHeaders: {'x-source': 'override'},
        options: const RealtimeSpeechOptions(
          voiceId: 'preset_fixture',
          responseFormat: SpeechOutputFormat.pcm,
          streamingMode: RealtimeSpeechMode.responsive,
          expressiveness: 2,
          phonemeHints: {
            'Voxtral': [IpaPhoneme.o, IpaPhoneme.k],
          },
        ),
        connector: (url, {required headers, required protocols}) async {
          expect(
            url,
            Uri(
              scheme: 'wss',
              host: 'api.mistral.ai',
              path: '/v1/audio/speech/realtime',
              queryParameters: {'model': _ttsModel},
            ),
          );
          expect(headers, {
            'authorization': 'Bearer workspace-fixture',
            'x-source': 'override',
            'x-keep': 'keep',
          });
          expect(protocols, isEmpty);
          socket.emit('session.created', {'session': _ttsSession});
          return socket;
        },
      );
      addTearDown(connection.close);
      expect(socket.sent.first, {
        'type': 'session.update',
        'session': {
          'voice': 'preset_fixture',
          'response_format': 'pcm',
          'streaming_mode': 'responsive',
          'expressiveness': 2,
          'phoneme_hints': {
            'Voxtral': ['o', 'k'],
          },
        },
      });
      expect(connection.session.voiceId, 'preset_fixture');
      expect(connection.session.expressiveness, 2);
      expect(connection.session.phonemeHints?['Voxtral'], [
        IpaPhoneme.o,
        IpaPhoneme.k,
      ]);
      final audio = connection.events
          .where((event) => event.data != null)
          .take(4)
          .toList();
      connection
        ..sendText('First')
        ..flush(text: ' generation.')
        ..sendText('Second generation.')
        ..end();
      final frames = await audio;
      expect(socket.sent.skip(1), [
        {'type': 'input_text.append', 'text': 'First'},
        {'type': 'input_text.flush', 'text': ' generation.'},
        {'type': 'input_text.append', 'text': 'Second generation.'},
        {'type': 'input_text.end'},
      ]);
      expect(
        base64Decode((frames[0].data! as SpeechStreamAudioDelta).audioData),
        [1, 2, 3],
      );
      expect((frames[1].data! as SpeechStreamDone).usage.totalTokens, 9);
      expect(frames[3].data, isA<SpeechStreamDone>());
      await connection.done;
      expect(socket.closeCount, 1);
    },
  );

  test('helper sends all input and closes after the terminal event', () async {
    final client = MistralClient();
    addTearDown(client.close);
    final socket = _FakeSocket();
    socket.onFrame = (frame) {
      if (frame['type'] == 'input_audio.append') {
        socket.emit('transcription.text.delta', {'text': 'Hi'});
      }
      if (frame['type'] == 'input_audio.end') {
        socket.emit('transcription.done', {'text': 'Hi', 'model': _sttModel});
      }
    };
    final frames = await client.audio.realtime
        .transcribeStream(
          model: _sttModel,
          clientToken: _token,
          audio: Stream.value([1, 2]),
          connector: socket.openStt,
        )
        .toList();
    expect(socket.sent, [
      {'type': 'input_audio.append', 'audio': 'AQI='},
      {'type': 'input_audio.end'},
    ]);
    expect(frames.map((event) => event.type), [
      'transcription.text.delta',
      'transcription.done',
    ]);
    expect(socket.closeCount, 1);
  });

  test(
    'helper cancellation stops pending input and releases the socket',
    () async {
      final client = MistralClient();
      addTearDown(client.close);
      final socket = _FakeSocket();
      final subscribed = Completer<void>();
      final cancelled = Completer<void>();
      final input = StreamController<List<int>>(
        onListen: subscribed.complete,
        onCancel: cancelled.complete,
      );
      final subscription = client.audio.realtime
          .transcribeStream(
            model: _sttModel,
            clientToken: _token,
            audio: input.stream,
            connector: socket.openStt,
          )
          .listen((_) => fail('Unexpected event'));
      await subscribed.future;
      await subscription.cancel();
      await cancelled.future;
      await input.close();
      expect(socket.sent, isEmpty);
      expect(socket.closeCount, 1);
    },
  );

  test('abort while opening closes a socket that arrives late', () async {
    final client = MistralClient();
    addTearDown(client.close);
    final abort = Completer<void>();
    final dialed = Completer<void>();
    final arriving = Completer<WebSocket>();
    final socket = _FakeSocket();

    final future = client.audio.realtime.connect(
      model: _sttModel,
      clientToken: _token,
      abortTrigger: abort.future,
      connector: (_, {required headers, required protocols}) {
        dialed.complete();
        return arriving.future;
      },
    );
    final expectation = expectLater(future, throwsA(isA<AbortedException>()));
    await dialed.future;
    abort.complete();
    await expectation;
    arriving.complete(socket);
    await socket.closed.future;
    expect(socket.closeCount, 1);
  });

  test('startup timeout closes an unacknowledged session', () async {
    final client = MistralClient();
    addTearDown(client.close);
    final socket = _FakeSocket();
    await expectLater(
      client.audio.realtime.connect(
        model: _sttModel,
        clientToken: _token,
        connectionTimeout: const Duration(milliseconds: 30),
        options: const RealtimeTranscriptionOptions(language: 'en'),
        connector: socket.openStt,
      ),
      throwsA(isA<MistralException>()),
    );
    await socket.closed.future;
    expect(socket.sent, [
      {
        'type': 'session.update',
        'session': {'language': 'en'},
      },
    ]);
    expect(socket.closeCount, 1);
  });

  test('raw errors are typed and abort ends the active connection', () async {
    final client = MistralClient();
    addTearDown(client.close);
    final socket = _FakeSocket();
    final abort = Completer<void>();
    final connection = await client.audio.realtime.connect(
      model: _sttModel,
      clientToken: _token,
      connector: socket.openStt,
      abortTrigger: abort.future,
    );
    final received = expectLater(
      connection.events,
      emitsInOrder([
        isA<
              RealtimeEvent<
                RealtimeTranscriptionSession,
                TranscriptionStreamEvent
              >
            >()
            .having((value) => value.type, 'frame type', 'session.created'),
        isA<
              RealtimeEvent<
                RealtimeTranscriptionSession,
                TranscriptionStreamEvent
              >
            >()
            .having((value) => value.error?.code, 'code', 422)
            .having((value) => value.error?.message, 'details', {
              'field': 'language',
            }),
        emitsError(isA<AbortedException>()),
        emitsDone,
      ]),
    );
    socket.emit('error', {
      'error': {
        'code': 422,
        'message': {'field': 'language'},
      },
    });
    await Future<void>.delayed(Duration.zero);
    abort.complete();
    await received;
    await connection.done;
    expect(socket.closeCount, 1);
  });

  test(
    'peer close before the terminal event reports incomplete output',
    () async {
      final client = MistralClient();
      addTearDown(client.close);
      final socket = _FakeSocket();
      socket.onFrame = (_) => socket.peerClose(1000);
      await expectLater(
        client.audio.realtime.transcribeStream(
          model: _sttModel,
          clientToken: _token,
          audio: const Stream.empty(),
          connector: socket.openStt,
        ),
        emitsInOrder([
          emitsError(isA<RealtimeConnectionException>()),
          emitsDone,
        ]),
      );
      expect(socket.closeCount, 1);
    },
  );

  test(
    'rejects unusable browser credentials without opening a socket',
    () async {
      final client = MistralClient.withApiKey('workspace-fixture');
      addTearDown(client.close);
      Future<WebSocket> reject(
        Uri _, {
        required Map<String, String> headers,
        required List<String> protocols,
      }) async => fail('Unexpected dial');
      await expectLater(
        client.audio.realtime.connect(
          model: _sttModel,
          clientToken: 'rt_invalid,split',
          connector: reject,
        ),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.toString(),
            'redacted',
            isNot(contains('rt_invalid')),
          ),
        ),
      );
      if (_isBrowser) {
        await expectLater(
          client.audio.realtime.connect(model: _sttModel, connector: reject),
          throwsUnsupportedError,
        );
        await expectLater(
          client.audio.realtimeSpeech.connect(
            model: _ttsModel,
            connector: reject,
          ),
          throwsUnsupportedError,
        );
      }
    },
  );
}

final class _FakeSocket implements WebSocket {
  final _events = StreamController<WebSocketEvent>();
  final _sentSignal = StreamController<Map<String, dynamic>>();
  final sent = <Map<String, dynamic>>[];
  final closed = Completer<void>();
  late final StreamIterator<Map<String, dynamic>> _sentIterator =
      StreamIterator(_sentSignal.stream);
  void Function(Map<String, dynamic>)? onFrame;
  int closeCount = 0;

  @override
  Stream<WebSocketEvent> get events => _events.stream;

  @override
  String get protocol => 'realtime';

  Future<Map<String, dynamic>> get nextSent async {
    if (!await _sentIterator.moveNext()) throw StateError('No outbound frame.');
    return _sentIterator.current;
  }

  Future<WebSocket> openStt(
    Uri url, {
    required Map<String, String> headers,
    required List<String> protocols,
  }) async {
    emit('session.created', {'session': _sttSession});
    return this;
  }

  void emit(String type, [Map<String, dynamic> payload = const {}]) {
    _events.add(TextDataReceived(jsonEncode({'type': type, ...payload})));
  }

  void peerClose(int code) => _events.add(CloseReceived(code, ''));

  @override
  void sendText(String text) {
    final frame = jsonDecode(text) as Map<String, dynamic>;
    sent.add(frame);
    _sentSignal.add(frame);
    onFrame?.call(frame);
  }

  @override
  void sendBytes(Uint8List bytes) => fail('Expected a JSON text frame.');

  @override
  Future<void> close([int? code, String? reason]) async {
    if (++closeCount == 1) {
      unawaited(_sentIterator.cancel());
      unawaited(_sentSignal.close());
      unawaited(_events.close());
      closed.complete();
    }
  }
}
