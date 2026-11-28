@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

const _model = 'lyria-realtime-exp';
const _deadline = Duration(seconds: 4);

class _MusicServer {
  final HttpServer _server;
  final arrived = Completer<Uri>();
  final socket = Completer<WebSocket>();
  final frames = <Map<String, dynamic>>[];
  final setup = Completer<Map<String, dynamic>>();
  final allCommands = Completer<void>();
  final closed = Completer<void>();

  _MusicServer(this._server, Future<void>? upgradeGate) {
    _server.listen((request) async {
      arrived.complete(request.uri);
      if (upgradeGate != null) await upgradeGate;
      final connection = await WebSocketTransformer.upgrade(request);
      socket.complete(connection);
      connection.listen((data) {
        final frame = jsonDecode(data as String) as Map<String, dynamic>;
        frames.add(frame);
        if (frames.length == 1) setup.complete(frame);
        if (frames.length == 7) allCommands.complete();
      }, onDone: closed.complete);
    });
  }

  String get baseUrl => 'http://127.0.0.1:${_server.port}';

  static Future<_MusicServer> start({Future<void>? upgradeGate}) async {
    final server = _MusicServer(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
      upgradeGate,
    );
    addTearDown(() => server._server.close(force: true));
    return server;
  }
}

LiveMusicClient _client(GoogleAIConfig config) {
  final client = GoogleAIClient(config: config);
  final music = client.createLiveMusicClient();
  addTearDown(client.close);
  addTearDown(music.close);
  return music;
}

void main() {
  test('waits for setup and exchanges typed Live Music frames', () async {
    final server = await _MusicServer.start();
    final music = _client(
      GoogleAIConfig(
        baseUrl: '${server.baseUrl}/proxy/?x=a&x=b&key=base',
        defaultQueryParams: const {'key': 'default', 'route': 'music'},
        authProvider: const ApiKeyProvider('test-key+/='),
      ),
    );

    final connecting = music.connect(model: _model);
    var connected = false;
    connecting.then((_) => connected = true).ignore();
    expect(await server.setup.future.timeout(_deadline), {
      'setup': {'model': 'models/$_model'},
    });
    expect(connected, isFalse);
    expect(server.frames, hasLength(1));

    final uri = await server.arrived.future;
    expect(
      uri.path,
      '/proxy/ws/google.ai.generativelanguage.v1beta.'
      'GenerativeService.BidiGenerateMusic',
    );
    expect(uri.queryParametersAll, {
      'x': ['a', 'b'],
      'key': ['test-key+/='],
      'route': ['music'],
    });
    final socket = await server.socket.future;
    socket
      ..add('{"setupComplete":{}}')
      ..add(
        utf8.encode(
          jsonEncode({
            'serverContent': {
              'audioChunks': [
                {
                  'data': 'AAH+/w==',
                  'mimeType': 'audio/pcm;rate=44100',
                  'sourceMetadata': {
                    'clientContent': {
                      'weightedPrompts': [
                        {'text': 'Piano', 'weight': 1},
                      ],
                    },
                    'musicGenerationConfig': {'bpm': 96, 'density': 0.5},
                  },
                },
                {'data': 'AgM=', 'mimeType': 'audio/pcm;rate=44100'},
              ],
            },
          }),
        ),
      )
      ..add('{"filteredPrompt":{"text":"Blocked","filteredReason":"reason"}}')
      ..add('{"warning":"Continue","futureField":{"count":2}}');
    final session = await connecting.timeout(_deadline);
    expect(session.isConnected, isTrue);
    session
      ..setWeightedPrompts(const [
        LiveMusicWeightedPrompt(text: 'Piano', weight: 1),
        LiveMusicWeightedPrompt(text: 'Drums', weight: -0.5),
      ])
      ..setMusicGenerationConfig(
        const LiveMusicGenerationConfig(
          bpm: 96,
          topK: 40,
          temperature: 1.25,
          muteBass: false,
          scale: LiveMusicScale.dMajorBMinor,
          musicGenerationMode: LiveMusicGenerationMode.quality,
        ),
      )
      ..play()
      ..pause()
      ..stop()
      ..resetContext();
    await server.allCommands.future.timeout(_deadline);
    expect(server.frames.skip(1), [
      {
        'clientContent': {
          'weightedPrompts': [
            {'text': 'Piano', 'weight': 1.0},
            {'text': 'Drums', 'weight': -0.5},
          ],
        },
      },
      {
        'musicGenerationConfig': {
          'bpm': 96,
          'topK': 40,
          'temperature': 1.25,
          'muteBass': false,
          'scale': 'D_MAJOR_B_MINOR',
          'musicGenerationMode': 'QUALITY',
        },
      },
      {'playbackControl': 'PLAY'},
      {'playbackControl': 'PAUSE'},
      {'playbackControl': 'STOP'},
      {'playbackControl': 'RESET_CONTEXT'},
    ]);

    final messages = await session.messages.take(3).toList().timeout(_deadline);
    final chunks = messages.first.serverContent!.audioChunks!;
    expect(chunks.first.data, [0, 1, 254, 255]);
    expect(chunks.last.data, [2, 3]);
    expect(chunks.first.mimeType, 'audio/pcm;rate=44100');
    expect(chunks.first.sourceMetadata?.weightedPrompts?.single.text, 'Piano');
    expect(chunks.first.sourceMetadata?.musicGenerationConfig?.density, 0.5);
    expect(messages[1].filteredPrompt?.text, 'Blocked');
    expect(messages[1].filteredPrompt?.filteredReason, 'reason');
    expect(messages.last.warning, 'Continue');
    expect(messages.last.additionalProperties['futureField'], {'count': 2});
    await server.closed.future.timeout(_deadline);
    expect(session.isConnected, isFalse);
    expect(session.play, throwsA(isA<LiveSessionClosedException>()));
    await session.close();
  });

  test('closes a socket that arrives after connect was canceled', () async {
    final permitUpgrade = Completer<void>();
    final server = await _MusicServer.start(upgradeGate: permitUpgrade.future);
    final music = _client(GoogleAIConfig(baseUrl: server.baseUrl));
    final cancel = Completer<void>();
    final connecting = music.connect(
      model: _model,
      abortTrigger: cancel.future,
    );
    await server.arrived.future.timeout(_deadline);
    cancel.complete();
    await expectLater(
      connecting,
      throwsA(
        isA<LiveConnectionException>().having(
          (error) => error.message,
          'message',
          contains('canceled'),
        ),
      ),
    );
    permitUpgrade.complete();
    await server.closed.future.timeout(_deadline);
    expect(server.frames, isEmpty);
  });

  test('times out while waiting for setup and closes the socket', () async {
    final server = await _MusicServer.start();
    final music = _client(
      GoogleAIConfig(
        baseUrl: server.baseUrl,
        timeout: const Duration(milliseconds: 700),
      ),
    );
    final connecting = music.connect(model: 'models/$_model');
    final failure = expectLater(
      connecting,
      throwsA(isA<LiveSessionSetupException>()),
    );
    expect(await server.setup.future.timeout(_deadline), {
      'setup': {'model': 'models/$_model'},
    });
    await failure;
    await server.closed.future.timeout(_deadline);
  });

  test('rejects content sent before the setup acknowledgment', () async {
    final server = await _MusicServer.start();
    final music = _client(GoogleAIConfig(baseUrl: server.baseUrl));
    final connecting = music.connect(model: _model);
    final failure = expectLater(
      connecting,
      throwsA(
        isA<LiveSessionSetupException>().having(
          (error) => error.message,
          'message',
          contains('acknowledgment'),
        ),
      ),
    );
    await server.setup.future.timeout(_deadline);
    (await server.socket.future).add('{"serverContent":{"audioChunks":[]}}');
    await failure;
    await server.closed.future.timeout(_deadline);
  });

  for (final malformed in [false, true]) {
    test(
      'reports a ${malformed ? 'malformed' : 'server error'} frame and closes',
      () async {
        final server = await _MusicServer.start();
        final music = _client(
          GoogleAIConfig(
            baseUrl: server.baseUrl,
            authProvider: const ApiKeyProvider('secret-key'),
          ),
        );
        final connecting = music.connect(model: _model);
        await server.setup.future.timeout(_deadline);
        final socket = await server.socket.future;
        socket.add('{"setupComplete":{}}');
        final session = await connecting;
        final received = expectLater(
          session.messages,
          emitsInOrder([
            emitsError(
              isA<LiveSessionException>().having(
                (error) => error.message,
                'message',
                malformed
                    ? contains('Invalid')
                    : allOf(
                        contains('rejected'),
                        isNot(contains('secret-key')),
                      ),
              ),
            ),
            emitsDone,
          ]),
        );
        if (malformed) {
          socket.add([0xff, 0xfe]);
        } else {
          socket.add('{"error":{"code":400,"message":"rejected secret-key"}}');
        }
        await received.timeout(_deadline);
        expect(session.isConnected, isFalse);
        await server.closed.future.timeout(_deadline);
      },
    );
  }

  test(
    'surfaces an abnormal close code and terminates the message stream',
    () async {
      final server = await _MusicServer.start();
      final music = _client(GoogleAIConfig(baseUrl: server.baseUrl));
      final connecting = music.connect(model: _model);
      await server.setup.future.timeout(_deadline);
      final socket = await server.socket.future;
      socket.add('{"setupComplete":{}}');
      final session = await connecting;
      final received = expectLater(
        session.messages,
        emitsInOrder([
          emitsError(
            isA<LiveSessionClosedException>().having(
              (error) => error.code,
              'code',
              1008,
            ),
          ),
          emitsDone,
        ]),
      );
      await socket.close(1008, 'denied');
      await received.timeout(_deadline);
      expect(session.isConnected, isFalse);
      await session.close();
    },
  );

  test(
    'client close finishes an unread session and prevents further connects',
    () async {
      final server = await _MusicServer.start();
      final music = _client(GoogleAIConfig(baseUrl: server.baseUrl));
      final connecting = music.connect(model: _model);
      await server.setup.future.timeout(_deadline);
      (await server.socket.future).add('{"setupComplete":{}}');
      final session = await connecting;
      await music.close().timeout(_deadline);
      await server.closed.future.timeout(_deadline);
      expect(session.isConnected, isFalse);
      await music.close();
      await expectLater(music.connect(model: _model), throwsStateError);
    },
  );
}
