@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

class _CountingProvider implements AuthProvider {
  final AuthCredentials credentials;
  int calls = 0;

  _CountingProvider(this.credentials);

  @override
  Future<AuthCredentials> getCredentials() async {
    calls++;
    return credentials;
  }
}

class _PendingProvider implements AuthProvider {
  final requested = Completer<void>();
  final initialCredentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() {
    if (requested.isCompleted) {
      return Future.value(const ApiKeyCredentials('next-fixture'));
    }
    requested.complete();
    return initialCredentials.future;
  }
}

class _Handshake {
  final Uri uri;
  final String? authorization;
  final String? apiKeyHeader;
  final Map<String, dynamic> firstMessage;

  _Handshake({
    required this.uri,
    required this.authorization,
    required this.apiKeyHeader,
    required this.firstMessage,
  });
}

class _Server {
  final HttpServer http;
  final handshake = Completer<_Handshake>();
  final peerSocket = Completer<WebSocket>();
  final peerClosed = Completer<void>();
  int upgrades = 0;

  _Server(
    this.http, {
    required bool reject,
    required Object? setupReply,
    this.onRealtimeInput,
    this.onClientMessage,
  }) {
    http.listen((request) async {
      if (reject) {
        request.response.statusCode = HttpStatus.unauthorized;
        await request.response.close();
        return;
      }
      upgrades++;
      final uri = request.uri;
      final authorization = request.headers.value('authorization');
      final apiKeyHeader = request.headers.value('x-goog-api-key');
      final socket = await WebSocketTransformer.upgrade(request);
      peerSocket.complete(socket);
      socket.listen((data) {
        final frame = jsonDecode(data as String) as Map<String, dynamic>;
        if (handshake.isCompleted) {
          onClientMessage?.call(frame);
          final input = frame['realtimeInput'] as Map<String, dynamic>?;
          if (input != null) onRealtimeInput?.call(socket, input);
          return;
        }
        handshake.complete(
          _Handshake(
            uri: uri,
            authorization: authorization,
            apiKeyHeader: apiKeyHeader,
            firstMessage: frame,
          ),
        );
        if (setupReply != null) {
          socket.add(
            setupReply is String ? utf8.encode(setupReply) : setupReply,
          );
        }
      }, onDone: peerClosed.complete);
    });
  }

  final void Function(WebSocket, Map<String, dynamic>)? onRealtimeInput;
  final void Function(Map<String, dynamic>)? onClientMessage;

  String get baseUrl => 'http://127.0.0.1:${http.port}';

  static Future<_Server> start({
    bool reject = false,
    Object? setupReply = '{"setupComplete":{"sessionId":"loopback"}}',
    void Function(WebSocket, Map<String, dynamic>)? onRealtimeInput,
    void Function(Map<String, dynamic>)? onClientMessage,
  }) async {
    final server = _Server(
      await HttpServer.bind(InternetAddress.loopbackIPv4, 0),
      reject: reject,
      setupReply: setupReply,
      onRealtimeInput: onRealtimeInput,
      onClientMessage: onClientMessage,
    );
    addTearDown(() => server.http.close(force: true));
    return server;
  }
}

LiveClient _createLive(GoogleAIConfig config) {
  final client = GoogleAIClient(config: config);
  final live = client.createLiveClient();
  addTearDown(client.close);
  addTearDown(live.close);
  return live;
}

const _developerPath =
    '/ws/google.ai.generativelanguage.v1beta.'
    'GenerativeService.BidiGenerateContentConstrained';
const _model = 'gemini-3.8-live';
const _deadline = Duration(seconds: 4);

void main() {
  test('Vertex 3.8 Live sends context updates in order', () async {
    final frames = <Map<String, dynamic>>[];
    final received = Completer<void>();
    final server = await _Server.start(
      onClientMessage: (frame) {
        frames.add(frame);
        if (frames.length == 2) received.complete();
      },
    );
    final config = GoogleAIConfig.vertexAI(
      projectId: 'P',
      location: 'eu',
      authProvider: const BearerTokenProvider('local-fixture'),
    ).copyWith(baseUrl: server.baseUrl);
    final session = await _createLive(
      config,
    ).connect(model: _model).timeout(_deadline);
    session
      ..sendContextUpdate(
        systemInstruction: Content.text('Use concise answers.'),
      )
      ..sendContextUpdate(tools: const []);
    await received.future.timeout(_deadline);
    expect(frames, [
      {
        'contextUpdate': {
          'systemInstruction': Content.text('Use concise answers.').toJson(),
        },
      },
      {
        'contextUpdate': {
          'tools': {'tools': <Object>[]},
        },
      },
    ]);
  });

  test('Developer Live rejects typed Vertex context updates', () async {
    final next = Completer<Map<String, dynamic>>();
    final server = await _Server.start(onClientMessage: next.complete);
    final session = await _createLive(
      GoogleAIConfig(baseUrl: server.baseUrl),
    ).connect(model: _model).timeout(_deadline);
    expect(
      () => session.sendContextUpdate(tools: const []),
      throwsUnsupportedError,
    );
    session.sendText('still connected');
    expect(await next.future.timeout(_deadline), {
      'realtimeInput': {'text': 'still connected'},
    });
  });

  test(
    'Vertex 2.5 completes a turn without turns or per-input media override',
    () async {
      final next = Completer<Map<String, dynamic>>();
      final server = await _Server.start(onClientMessage: next.complete);
      final config = GoogleAIConfig.vertexAI(
        projectId: 'P',
        location: 'us-central1',
        authProvider: const BearerTokenProvider('local-fixture'),
      ).copyWith(baseUrl: server.baseUrl);
      final session = await _createLive(
        config,
      ).connect(model: 'gemini-live-2.5-flash-native-audio').timeout(_deadline);
      expect(
        () => session.send(
          const BidiGenerateContentRealtimeInput(
            video: Blob(mimeType: 'image/jpeg', data: 'AQID'),
            mediaResolution: MediaResolution(level: MediaResolutionLevel.high),
          ),
        ),
        throwsUnsupportedError,
      );
      session.sendContent(turnComplete: true);
      expect(await next.future.timeout(_deadline), {
        'clientContent': {'turnComplete': true},
      });
    },
  );

  test(
    'Vertex v1 requests a prebuilt Live avatar and receives MP4 data',
    () async {
      final server = await _Server.start(
        onRealtimeInput: (socket, input) {
          expect(input, {'text': 'Hello'});
          socket.add(
            jsonEncode({
              'serverContent': {
                'modelTurn': {
                  'role': 'model',
                  'parts': [
                    {
                      'inlineData': {'mimeType': 'video/mp4', 'data': 'AQID'},
                    },
                  ],
                },
              },
            }),
          );
        },
      );
      final config = GoogleAIConfig.vertexAI(
        projectId: 'P',
        location: 'us-central1',
        authProvider: const BearerTokenProvider('local-fixture'),
      ).copyWith(baseUrl: server.baseUrl, apiVersion: ApiVersion.v1);
      final session = await _createLive(config)
          .connect(
            model: _model,
            liveConfig: LiveConfig(
              avatarConfig: const LiveAvatarConfig(avatarName: 'Ben'),
              generationConfig: LiveGenerationConfig(
                responseModalities: const [ResponseModality.video],
                speechConfig: SpeechConfig.withVoice(LiveVoices.puck),
              ),
            ),
          )
          .timeout(_deadline);

      final handshake = await server.handshake.future.timeout(_deadline);
      expect(
        handshake.uri.path,
        '/ws/google.cloud.aiplatform.v1.LlmBidiService/BidiGenerateContent',
      );
      expect(handshake.authorization, 'Bearer local-fixture');
      expect(handshake.firstMessage, {
        'setup': {
          'model':
              'projects/P/locations/us-central1/publishers/google/models/$_model',
          'generationConfig': {
            'responseModalities': ['VIDEO'],
            'speechConfig': {
              'voiceConfig': {
                'prebuiltVoiceConfig': {'voiceName': 'Puck'},
              },
            },
          },
          'avatarConfig': {'avatarName': 'Ben'},
        },
      });
      final response = session.messages.firstWhere(
        (message) => message is BidiGenerateContentServerContent,
      );
      session.send(const BidiGenerateContentRealtimeInput(text: 'Hello'));
      final content =
          await response.timeout(_deadline) as BidiGenerateContentServerContent;
      final part = content.modelTurn!.parts.single;
      final blob = (part as InlineDataPart).inlineData;
      expect(blob.mimeType, 'video/mp4');
      expect(blob.toBytes(), [1, 2, 3]);
    },
  );

  test(
    'Developer Live rejects a prebuilt avatar before auth or upgrade',
    () async {
      final auth = _CountingProvider(const ApiKeyCredentials('local-fixture'));
      final server = await _Server.start();
      final live = _createLive(
        GoogleAIConfig(baseUrl: server.baseUrl, authProvider: auth),
      );
      await expectLater(
        live.connect(
          model: _model,
          liveConfig: const LiveConfig(
            avatarConfig: LiveAvatarConfig(avatarName: 'Ben'),
          ),
        ),
        throwsUnsupportedError,
      );
      expect(auth.calls, 0);
      expect(server.upgrades, 0);
    },
  );

  test('Developer Live sends a per-input video resolution', () async {
    final next = Completer<Map<String, dynamic>>();
    final server = await _Server.start(onClientMessage: next.complete);
    final session = await _createLive(
      GoogleAIConfig(baseUrl: server.baseUrl),
    ).connect(model: _model).timeout(_deadline);
    session.send(
      const BidiGenerateContentRealtimeInput(
        video: Blob(mimeType: 'image/jpeg', data: 'AQID'),
        mediaResolution: MediaResolution(level: MediaResolutionLevel.high),
      ),
    );
    expect(await next.future.timeout(_deadline), {
      'realtimeInput': {
        'video': {'data': 'AQID', 'mimeType': 'image/jpeg'},
        'mediaResolution': {'level': 'MEDIA_RESOLUTION_HIGH'},
      },
    });
  });

  test('Developer Live setup sends translation and request metadata', () async {
    const model = 'gemini-3.5-live-translate-preview';
    final server = await _Server.start();
    final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
    await live
        .connect(
          model: model,
          liveConfig: const LiveConfig(
            labels: {'safety_identifier': 'local_fixture'},
            safetySettings: [
              SafetySetting(
                category: HarmCategory.hateSpeech,
                threshold: HarmBlockThreshold.blockOnlyHigh,
              ),
            ],
            generationConfig: LiveGenerationConfig(
              responseModalities: [ResponseModality.audio],
              translationConfig: TranslationConfig(
                targetLanguageCode: 'es',
                echoTargetLanguage: false,
              ),
            ),
            contextWindowCompression: ContextWindowCompressionConfig(
              triggerTokens: 10000,
              slidingWindow: SlidingWindow(targetTokens: 5000),
            ),
          ),
        )
        .timeout(_deadline);
    expect((await server.handshake.future).firstMessage, {
      'setup': {
        'model': 'models/$model',
        'labels': {'safety_identifier': 'local_fixture'},
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_ONLY_HIGH',
          },
        ],
        'generationConfig': {
          'responseModalities': ['AUDIO'],
          'translationConfig': {
            'targetLanguageCode': 'es',
            'echoTargetLanguage': false,
          },
        },
        'contextWindowCompression': {
          'triggerTokens': '10000',
          'slidingWindow': {'targetTokens': '5000'},
        },
      },
    });
  });

  test('Vertex Live setup carries VAD and generation settings', () async {
    final server = await _Server.start();
    final config = GoogleAIConfig.vertexAI(
      projectId: 'P',
      location: 'eu',
      authProvider: const BearerTokenProvider('local-fixture'),
    ).copyWith(baseUrl: server.baseUrl);
    await _createLive(config)
        .connect(
          model: _model,
          liveConfig: const LiveConfig(
            labels: {'deployment': 'fixture'},
            explicitVadSignal: true,
            safetySettings: [
              SafetySetting(
                category: HarmCategory.hateSpeech,
                threshold: HarmBlockThreshold.blockOnlyHigh,
                method: HarmBlockMethod.severity,
              ),
            ],
            generationConfig: LiveGenerationConfig(
              mediaResolution: MediaResolutionLevel.low,
              seed: 0,
            ),
          ),
        )
        .timeout(_deadline);
    expect((await server.handshake.future).firstMessage, {
      'setup': {
        'model': 'projects/P/locations/eu/publishers/google/models/$_model',
        'labels': {'deployment': 'fixture'},
        'explicitVadSignal': true,
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_ONLY_HIGH',
            'method': 'SEVERITY',
          },
        ],
        'generationConfig': {
          'mediaResolution': 'MEDIA_RESOLUTION_LOW',
          'seed': 0,
        },
      },
    });
  });

  test('Developer extended-thinking Live sends its thinking level', () async {
    const model = 'gemini-3.8-live-extended-thinking';
    final server = await _Server.start();
    final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
    await live
        .connect(
          model: model,
          liveConfig: const LiveConfig(
            generationConfig: LiveGenerationConfig(
              thinkingConfig: ThinkingConfig(thinkingLevel: ThinkingLevel.low),
            ),
          ),
        )
        .timeout(_deadline);
    expect((await server.handshake.future).firstMessage, {
      'setup': {
        'model': 'models/$model',
        'generationConfig': {
          'thinkingConfig': {'thinkingLevel': 'LOW'},
        },
      },
    });
  });

  test('Vertex 2.5 Live setup preserves legacy audio flags', () async {
    const model = 'gemini-live-2.5-flash-native-audio';
    final server = await _Server.start();
    final config = GoogleAIConfig.vertexAI(
      projectId: 'P',
      location: 'eu',
      authProvider: const BearerTokenProvider('local-fixture'),
    ).copyWith(baseUrl: server.baseUrl);
    await _createLive(config)
        .connect(
          model: model,
          liveConfig: const LiveConfig(
            generationConfig: LiveGenerationConfig(enableAffectiveDialog: true),
            proactivity: ProactivityConfig(proactiveAudio: true),
          ),
        )
        .timeout(_deadline);
    expect((await server.handshake.future).firstMessage, {
      'setup': {
        'model': 'projects/P/locations/eu/publishers/google/models/$model',
        'generationConfig': {'enableAffectiveDialog': true},
        'proactivity': {'proactiveAudio': true},
      },
    });
  });

  test('Developer Live rejects a Vertex safety method before auth', () async {
    final server = await _Server.start();
    final provider = _CountingProvider(const ApiKeyCredentials('fixture'));
    final live = _createLive(
      GoogleAIConfig(baseUrl: server.baseUrl, authProvider: provider),
    );
    await expectLater(
      live.connect(
        model: _model,
        liveConfig: const LiveConfig(
          safetySettings: [
            SafetySetting(
              category: HarmCategory.hateSpeech,
              threshold: HarmBlockThreshold.blockOnlyHigh,
              method: HarmBlockMethod.probability,
            ),
          ],
        ),
      ),
      throwsUnsupportedError,
    );
    expect(provider.calls, 0);
    expect(server.upgrades, 0);
  });

  test(
    'Developer Live rejects explicit Vertex VAD before connecting',
    () async {
      final server = await _Server.start();
      final provider = _CountingProvider(const ApiKeyCredentials('fixture'));
      final live = _createLive(
        GoogleAIConfig(baseUrl: server.baseUrl, authProvider: provider),
      );
      await expectLater(
        live.connect(
          model: _model,
          liveConfig: const LiveConfig(explicitVadSignal: false),
        ),
        throwsUnsupportedError,
      );
      expect(provider.calls, 0);
      expect(server.upgrades, 0);
    },
  );

  test(
    'closing Live cancels a pending credential lookup and allows reuse',
    () async {
      final provider = _PendingProvider();
      final server = await _Server.start();
      final live = _createLive(
        GoogleAIConfig(baseUrl: server.baseUrl, authProvider: provider),
      );

      final connection = expectLater(
        live.connect(model: _model),
        throwsA(isA<LiveConnectionException>()),
      );
      await provider.requested.future.timeout(_deadline);
      await live.close().timeout(_deadline);
      await connection.timeout(_deadline);

      provider.initialCredentials.complete(
        const ApiKeyCredentials('late-fixture'),
      );
      final next = await live.connect(model: _model).timeout(_deadline);
      expect(next.isConnected, isTrue);
      expect(
        (await server.handshake.future).uri.queryParameters['key'],
        'next-fixture',
      );
      expect(server.upgrades, 1);
    },
  );

  test('closing Live disconnects a stalled native WebSocket upgrade', () async {
    final server = await ServerSocket.bind(InternetAddress.loopbackIPv4, 0);
    addTearDown(server.close);
    final requested = Completer<void>();
    final peerClosed = Completer<void>();
    server.listen((socket) {
      addTearDown(socket.destroy);
      socket.listen(
        (_) {
          if (!requested.isCompleted) requested.complete();
        },
        onDone: () {
          if (!peerClosed.isCompleted) peerClosed.complete();
        },
        onError: (Object _) {
          if (!peerClosed.isCompleted) peerClosed.complete();
        },
      );
    });
    final live = _createLive(
      GoogleAIConfig(
        baseUrl: 'http://127.0.0.1:${server.port}',
        authProvider: const ApiKeyProvider('upgrade-secret'),
      ),
    );

    final connection = expectLater(
      live.connect(model: _model),
      throwsA(
        isA<LiveConnectionException>().having(
          (error) => error.toString(),
          'diagnostics',
          isNot(contains('upgrade-secret')),
        ),
      ),
    );
    await requested.future.timeout(_deadline);
    await live.close().timeout(_deadline);
    await connection.timeout(_deadline);
    await peerClosed.future.timeout(_deadline);
  });

  test(
    'closing Live cancels a session waiting for setup acknowledgement',
    () async {
      final server = await _Server.start(setupReply: null);
      final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));

      final connection = expectLater(
        live.connect(model: _model),
        throwsA(isA<LiveConnectionException>()),
      );
      await server.handshake.future.timeout(_deadline);
      await live.close().timeout(_deadline);
      await connection.timeout(_deadline);
      await server.peerClosed.future.timeout(_deadline);
    },
  );

  test('parses resumption and voice activity after malformed UTF-8', () async {
    const checkpoint = '9007199254740993';
    final server = await _Server.start(
      onRealtimeInput: (socket, _) {
        socket
          ..add([0xff, 0xfe])
          ..add(
            jsonEncode({
              'voiceActivity': {
                'type': 'ACTIVITY_START',
                'audioOffset': '1.250s',
              },
              'serverContent': {'waitingForInput': false},
            }),
          )
          ..add(
            jsonEncode({
              'voiceActivity': {
                'type': 'ACTIVITY_END',
                'audioOffset': '1.820s',
              },
            }),
          )
          ..add(
            jsonEncode({
              'sessionResumptionUpdate': {
                'newHandle': 'checkpoint-handle',
                'resumable': true,
                'lastConsumedClientMessageIndex': checkpoint,
              },
            }),
          )
          ..add(
            '{"sessionResumptionUpdate":{"newHandle":"","resumable":false}}',
          );
      },
    );
    final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
    final session = await live.connect(model: _model).timeout(_deadline);
    final messages = <BidiGenerateContentServerMessage>[];
    final errors = <Object>[];
    final received = Completer<void>();
    final subscription = session.messages.listen((message) {
      messages.add(message);
      if (messages.length == 4) received.complete();
    }, onError: errors.add);
    addTearDown(subscription.cancel);
    session.sendText('Start a fixture.');
    await received.future.timeout(_deadline);
    expect(errors, [isA<LiveSessionException>()]);
    expect(messages[0], isA<BidiGenerateContentServerContent>());
    expect(
      messages[0].voiceActivity?.type,
      LiveVoiceActivityType.activityStart,
    );
    expect(messages[0].voiceActivity?.audioOffset, '1.250s');
    expect(messages[1], isA<UnknownServerMessage>());
    expect(messages[1].voiceActivity?.type, LiveVoiceActivityType.activityEnd);
    expect(
      (messages[2] as SessionResumptionUpdate).lastConsumedClientMessageIndex,
      checkpoint,
    );
    expect(session.resumptionToken, isEmpty);
    expect(session.resumable, isFalse);
    expect(session.lastResumableUpdate?.newHandle, 'checkpoint-handle');
    expect(
      session.lastResumableUpdate?.lastConsumedClientMessageIndex,
      checkpoint,
    );

    subscription.pause();
    await live.close().timeout(_deadline);
    await server.peerClosed.future.timeout(_deadline);
    expect(session.isConnected, isFalse);
    subscription.resume();
  });

  test('Vertex resume preserves transparent resumption setup', () async {
    final server = await _Server.start();
    final config = GoogleAIConfig.vertexAI(
      projectId: 'P',
      location: 'eu',
      authProvider: const BearerTokenProvider('local-fixture'),
    ).copyWith(baseUrl: server.baseUrl);
    await _createLive(config)
        .resume(
          model: _model,
          resumptionToken: 'previous-checkpoint',
          liveConfig: const LiveConfig(
            sessionResumption: SessionResumptionConfig.enabled(
              transparent: true,
            ),
          ),
        )
        .timeout(_deadline);
    expect((await server.handshake.future).firstMessage, {
      'setup': {
        'model': 'projects/P/locations/eu/publishers/google/models/$_model',
        'sessionResumption': {
          'handle': 'previous-checkpoint',
          'transparent': true,
        },
      },
    });
  });

  test(
    'Developer connect and resume leave transparent mode out of setup',
    () async {
      for (final resume in [false, true]) {
        final server = await _Server.start();
        final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
        const config = LiveConfig(
          sessionResumption: SessionResumptionConfig(
            handle: 'original-handle',
            transparent: false,
          ),
        );
        if (resume) {
          await live
              .resume(
                model: _model,
                resumptionToken: 'updated-handle',
                liveConfig: config,
              )
              .timeout(_deadline);
        } else {
          await live
              .connect(model: _model, liveConfig: config)
              .timeout(_deadline);
        }
        expect((await server.handshake.future).firstMessage, {
          'setup': {
            'model': 'models/$_model',
            'sessionResumption': {
              'handle': resume ? 'updated-handle' : 'original-handle',
            },
          },
        });
        expect(config.sessionResumption?.toJson(), {
          'handle': 'original-handle',
          'transparent': false,
        });
      }
    },
  );

  test(
    'resume surfaces a typed setup rejection without exposing its handle',
    () async {
      const handle = 'resume+opaque/fixture';
      const encodedHandle = 'resume%2bopaque%2ffixture';
      final server = await _Server.start(setupReply: null);
      final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
      final failed = expectLater(
        live.resume(model: _model, resumptionToken: handle).timeout(_deadline),
        throwsA(
          isA<LiveSessionResumptionException>()
              .having((error) => error.handle, 'handle', isNull)
              .having(
                (error) => error.cause,
                'underlying rejection',
                isA<LiveSessionClosedException>()
                    .having((error) => error.code, 'close code', 1008)
                    .having(
                      (error) => error.reason,
                      'close reason',
                      'Invalid handle [redacted] ([redacted])',
                    ),
              ),
        ),
      );
      expect((await server.handshake.future.timeout(_deadline)).firstMessage, {
        'setup': {
          'model': 'models/$_model',
          'sessionResumption': {'handle': handle},
        },
      });
      final socket = await server.peerSocket.future;
      unawaited(socket.close(1008, 'Invalid handle $handle ($encodedHandle)'));
      await failed;
      await server.peerClosed.future.timeout(_deadline);
    },
  );

  test(
    'close diagnostics redact current and retained Live checkpoints',
    () async {
      const retained = 'retain+old/x';
      const current = 'current+new/y';
      final server = await _Server.start();
      final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
      final session = await live.connect(model: _model).timeout(_deadline);
      final checkpointSeen = Completer<void>();
      final closed = Completer<LiveSessionClosedException>();
      final subscription = session.messages.listen(
        (message) {
          if (message case SessionResumptionUpdate(newHandle: current)) {
            checkpointSeen.complete();
          }
        },
        onError: (Object error) =>
            closed.complete(error as LiveSessionClosedException),
      );
      addTearDown(subscription.cancel);
      final socket = await server.peerSocket.future;
      socket
        ..add(
          jsonEncode({
            'sessionResumptionUpdate': {
              'newHandle': retained,
              'resumable': true,
            },
          }),
        )
        ..add(
          jsonEncode({
            'sessionResumptionUpdate': {
              'newHandle': current,
              'resumable': false,
            },
          }),
        );
      await checkpointSeen.future.timeout(_deadline);
      expect(session.resumptionToken, current);
      expect(session.lastResumableUpdate?.newHandle, retained);
      unawaited(
        socket.close(
          1008,
          'Rejected $retained (retain%2bold%2fx) and $current (current%2bnew%2fy)',
        ),
      );
      final error = await closed.future.timeout(_deadline);
      expect(error.code, 1008);
      expect(
        error.reason,
        'Rejected [redacted] ([redacted]) and [redacted] ([redacted])',
      );
    },
  );

  test('closes the socket after a malformed binary setup reply', () async {
    final server = await _Server.start(setupReply: [0xff, 0xfe]);
    final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
    await expectLater(
      live.connect(model: _model).timeout(_deadline),
      throwsA(
        isA<LiveSessionSetupException>().having(
          (error) => error.cause,
          'parse failure',
          isA<LiveSessionException>(),
        ),
      ),
    );
    await server.peerClosed.future.timeout(_deadline);
  });

  test('closes the socket if encoding a setup message throws', () async {
    final server = await _Server.start();
    final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
    const liveConfig = LiveConfig(
      systemInstruction: Content(
        parts: [
          FunctionCallPart(
            FunctionCall(name: 'fixture', args: {'badValue': Object()}),
          ),
        ],
      ),
    );
    await expectLater(
      live.connect(model: _model, liveConfig: liveConfig).timeout(_deadline),
      throwsA(isA<LiveSessionSetupException>()),
    );
    await server.peerClosed.future.timeout(_deadline);
    expect(server.handshake.isCompleted, isFalse);
  });

  test(
    'uses a shorter configured setup deadline and closes the socket',
    () async {
      final server = await _Server.start(setupReply: null);
      final live = _createLive(
        GoogleAIConfig(
          baseUrl: server.baseUrl,
          timeout: const Duration(milliseconds: 100),
        ),
      );
      final failed = expectLater(
        live.connect(model: _model).timeout(_deadline),
        throwsA(
          isA<LiveSessionSetupException>().having(
            (error) => error.message,
            'message',
            contains('timed out'),
          ),
        ),
      );
      await server.handshake.future.timeout(_deadline);
      await failed;
      await server.peerClosed.future.timeout(_deadline);
    },
  );

  test('redacts encoded credentials in remote close reasons', () async {
    const opaqueKey = 'loopback+close/fixture';
    const encodedKey = 'loopback%2bclose%2ffixture';
    final server = await _Server.start(
      onRealtimeInput: (socket, _) {
        unawaited(socket.close(1008, 'Forbidden ?key=$encodedKey'));
      },
    );
    final live = _createLive(
      GoogleAIConfig(
        baseUrl: server.baseUrl,
        authProvider: const ApiKeyProvider(opaqueKey),
        defaultQueryParams: const {'tenant': 'loopback'},
      ),
    );
    final session = await live.connect(model: _model).timeout(_deadline);
    final failed = expectLater(
      session.messages.first.timeout(_deadline),
      throwsA(
        isA<LiveSessionClosedException>()
            .having((error) => error.code, 'close code', 1008)
            .having(
              (error) => error.reason,
              'close reason',
              'Forbidden ?key=[redacted]',
            ),
      ),
    );
    session.sendText('Trigger a local close.');
    await failed;
    expect(session.isConnected, isFalse);
  });

  test(
    'Live session delivers top-level usage with and without content',
    () async {
      final server = await _Server.start(
        onRealtimeInput: (socket, _) {
          socket
            ..add('{"usageMetadata":{"promptTokenCount":"invalid"}}')
            ..add(
              utf8.encode(
                '{"serverContent":{"waitingForInput":true},'
                '"usageMetadata":{"responseTokenCount":2}}',
              ),
            )
            ..add(
              '{"usageMetadata":{"responseTokenCount":3,"totalTokenCount":10}}',
            );
        },
      );
      final session = await _createLive(
        GoogleAIConfig(baseUrl: server.baseUrl),
      ).connect(model: _model).timeout(_deadline);

      final messages = <BidiGenerateContentServerMessage>[];
      final errors = <Object>[];
      final received = Completer<void>();
      final subscription = session.messages.listen((message) {
        messages.add(message);
        if (messages.length == 2) received.complete();
      }, onError: errors.add);
      addTearDown(subscription.cancel);

      session.sendText('Check top-level usage.');
      await received.future.timeout(_deadline);
      expect(errors, [isA<LiveSessionException>()]);
      expect(
        messages.first,
        isA<BidiGenerateContentServerContent>()
            .having((m) => m.waitingForInput, 'waitingForInput', true)
            .having(
              (m) => m.responseUsageMetadata?.responseTokenCount,
              'response tokens',
              2,
            ),
      );
      expect(messages.last.responseUsageMetadata?.counts.totalTokenCount, 10);
      expect(messages.last.responseUsageMetadata?.responseTokenCount, 3);
    },
  );

  for (final vertex in [false, true]) {
    test(
      '${vertex ? 'Vertex' : 'Developer'} Live setup sends canonical VAD enums',
      () async {
        final server = await _Server.start();
        final config = vertex
            ? GoogleAIConfig.vertexAI(
                projectId: 'P',
                location: 'eu',
                authProvider: const BearerTokenProvider('local-fixture'),
              ).copyWith(baseUrl: server.baseUrl)
            : GoogleAIConfig(baseUrl: server.baseUrl);
        final liveConfig = LiveConfig.fromJson({
          'realtimeInputConfig': {
            'automaticActivityDetection': {
              'startOfSpeechSensitivity': 'HIGH',
              'endOfSpeechSensitivity': 'LOW',
            },
            'activityHandling': 'ACTIVITY_HANDLING_UNSPECIFIED',
            'turnCoverage': 'TURN_INCLUDES_AUDIO_ACTIVITY_AND_ALL_VIDEO',
          },
        });
        await _createLive(
          config,
        ).connect(model: _model, liveConfig: liveConfig).timeout(_deadline);
        final model = vertex
            ? 'projects/P/locations/eu/publishers/google/models/$_model'
            : 'models/$_model';
        expect((await server.handshake.future).firstMessage, {
          'setup': {
            'model': model,
            'realtimeInputConfig': {
              'automaticActivityDetection': {
                'startOfSpeechSensitivity': 'START_SENSITIVITY_HIGH',
                'endOfSpeechSensitivity': 'END_SENSITIVITY_LOW',
              },
              'activityHandling': 'ACTIVITY_HANDLING_UNSPECIFIED',
              'turnCoverage': 'TURN_INCLUDES_AUDIO_ACTIVITY_AND_ALL_VIDEO',
            },
          },
        });
      },
    );
  }

  test(
    'Live Transcribe sends settings and delivers interim and final frames',
    () async {
      const model = 'gemini-3.5-transcribe-live';
      const interimFrame = {
        'serverContent': {
          'interimInputTranscription': {
            'text': 'hello',
            'finished': false,
            'languageCode': 'en-US',
            'startOffset': '0s',
            'endOffset': '0.410s',
          },
        },
      };
      const finalFrame = {
        'serverContent': {
          'inputTranscription': {
            'text': 'Hello world.',
            'finished': true,
            'languageCode': 'en-US',
            'startOffset': '0s',
            'endOffset': '0.790s',
          },
        },
      };
      final inputs = <Map<String, dynamic>>[];
      final server = await _Server.start(
        onRealtimeInput: (socket, input) {
          inputs.add(input);
          if (input.containsKey('audio')) socket.add(jsonEncode(interimFrame));
          if (input['audioStreamEnd'] == true) {
            socket.add(utf8.encode(jsonEncode(finalFrame)));
          }
        },
      );
      final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
      final session = await live
          .connect(
            model: model,
            liveConfig: LiveConfig(
              generationConfig: LiveGenerationConfig.textOnly(),
              inputAudioTranscription: const AudioTranscriptionConfig(
                enabled: true,
                languageCodes: ['en-US'],
                customVocabulary: ['Gemini'],
                mode: AudioTranscriptionConfigMode.smart,
                sourceText: 'Hello.',
              ),
              outputAudioTranscription: AudioTranscriptionConfig.disabled(),
              realtimeInputConfig: const RealtimeInputConfig(
                interimTranscriptTimestampEnabled: true,
              ),
            ),
          )
          .timeout(_deadline);
      expect((await server.handshake.future).firstMessage, {
        'setup': {
          'model': 'models/$model',
          'generationConfig': {
            'responseModalities': ['TEXT'],
          },
          'realtimeInputConfig': {'interimTranscriptTimestampEnabled': true},
          'inputAudioTranscription': {
            'languageCodes': ['en-US'],
            'customVocabulary': ['Gemini'],
            'mode': 'SMART',
            'sourceText': 'Hello.',
          },
        },
      });

      final messages = session.messages.take(2).toList().timeout(_deadline);
      session
        ..sendAudio([0, 1, 2, 3])
        ..signalAudioStreamEnd();
      final [interim, finalMessage] = await messages;
      expect(inputs, [
        {
          'audio': {'data': 'AAECAw==', 'mimeType': 'audio/pcm;rate=16000'},
        },
        {'audioStreamEnd': true},
      ]);
      expect(interim, isA<BidiGenerateContentServerContent>());
      expect(interim.toJson(), interimFrame);
      expect(
        (interim as BidiGenerateContentServerContent).inputTranscription,
        isNull,
      );
      expect(interim.interimInputTranscription?.finished, isFalse);
      expect(interim.interimInputTranscription?.endOffset, '0.410s');
      expect(finalMessage.toJson(), finalFrame);
      expect(
        (finalMessage as BidiGenerateContentServerContent)
            .interimInputTranscription,
        isNull,
      );
      expect(finalMessage.inputTranscription?.languageCode, 'en-US');
      expect(finalMessage.inputTranscription?.finished, isTrue);
    },
  );

  test(
    'manual Live activity signals keep legacy transcription enabled',
    () async {
      final inputs = <Map<String, dynamic>>[];
      final server = await _Server.start(
        onRealtimeInput: (socket, input) {
          inputs.add(input);
          if (input.containsKey('activityEnd')) {
            socket.add(
              jsonEncode({
                'serverContent': {
                  'outputTranscription': {'text': 'Hello!', 'finished': true},
                },
              }),
            );
          }
        },
      );
      final live = _createLive(GoogleAIConfig(baseUrl: server.baseUrl));
      final session = await live
          .connect(
            model: _model,
            liveConfig: LiveConfig(
              inputAudioTranscription: const AudioTranscriptionConfig(),
              outputAudioTranscription: AudioTranscriptionConfig.enabled(),
              realtimeInputConfig: RealtimeInputConfig.manual(),
            ),
          )
          .timeout(_deadline);
      expect((await server.handshake.future).firstMessage, {
        'setup': {
          'model': 'models/$_model',
          'inputAudioTranscription': <String, dynamic>{},
          'outputAudioTranscription': <String, dynamic>{},
          'realtimeInputConfig': {
            'automaticActivityDetection': {'disabled': true},
            'activityHandling': 'NO_INTERRUPTION',
          },
        },
      });
      final message = session.messages.first.timeout(_deadline);
      session
        ..signalActivityStart()
        ..sendAudio([0, 1])
        ..signalActivityEnd();
      expect(
        await message,
        isA<BidiGenerateContentServerContent>().having(
          (content) => content.outputTranscription?.text,
          'output audio text',
          'Hello!',
        ),
      );
      expect(inputs, [
        {'activityStart': <String, dynamic>{}},
        {
          'audio': {'data': 'AAE=', 'mimeType': 'audio/pcm;rate=16000'},
        },
        {'activityEnd': <String, dynamic>{}},
      ]);
    },
  );

  test(
    'an explicit token uses the constrained endpoint and suppresses old keys',
    () async {
      final server = await _Server.start();
      final provider = _CountingProvider(
        const ApiKeyCredentials('provider-key'),
      );
      final live = _createLive(
        GoogleAIConfig(
          apiVersion: ApiVersion.v1,
          authProvider: provider,
          baseUrl:
              '${server.baseUrl}/tenant/?key=base-key&access_token=old-token',
          defaultQueryParams: {
            'key': 'default-key',
            'access_token': 'default-token',
            'tenant': 'demo',
          },
        ),
      );

      final session = await live
          .connect(model: _model, accessToken: 'auth_tokens/explicit+token')
          .timeout(_deadline);
      final handshake = await server.handshake.future;
      expect(provider.calls, 0);
      expect(server.upgrades, 1);
      expect(handshake.uri.path, '/tenant$_developerPath');
      expect(handshake.uri.queryParameters, {
        'access_token': 'auth_tokens/explicit+token',
        'tenant': 'demo',
      });
      expect(handshake.authorization, isNull);
      expect(handshake.apiKeyHeader, isNull);
      expect(handshake.firstMessage, {
        'setup': {'model': 'models/$_model'},
      });
      expect(session.sessionId, 'loopback');
    },
  );

  test('ordinary Developer API keys keep the legacy query merge', () async {
    final server = await _Server.start();
    final provider = _CountingProvider(const ApiKeyCredentials('provider-key'));
    final live = _createLive(
      GoogleAIConfig(
        authProvider: provider,
        baseUrl: '${server.baseUrl}?key=base-key',
        defaultQueryParams: {'key': 'default-key', 'tenant': 'demo'},
      ),
    );

    await live.connect(model: _model).timeout(_deadline);
    final handshake = await server.handshake.future;
    expect(provider.calls, 1);
    expect(
      handshake.uri.path,
      '/ws/google.ai.generativelanguage.v1beta.GenerativeService.BidiGenerateContent',
    );
    expect(handshake.uri.queryParameters, {
      'key': 'default-key',
      'tenant': 'demo',
    });
    expect(handshake.authorization, isNull);
    expect(handshake.firstMessage, {
      'setup': {'model': 'models/$_model'},
    });
  });

  for (final placement in EphemeralTokenPlacement.values) {
    test(
      'a provider token uses the constrained endpoint with ${placement.name}',
      () async {
        final server = await _Server.start();
        final provider = _CountingProvider(
          EphemeralTokenCredentials(
            'auth_tokens/provider-token',
            placement: placement,
          ),
        );
        final live = _createLive(
          GoogleAIConfig(
            apiVersion: ApiVersion.v1,
            authProvider: provider,
            baseUrl: '${server.baseUrl}?key=old-key&access_token=old-token',
            defaultQueryParams: {
              'key': 'default-key',
              'access_token': 'default-token',
            },
          ),
        );

        await live.connect(model: 'models/$_model').timeout(_deadline);
        final handshake = await server.handshake.future;
        expect(provider.calls, 1);
        expect(handshake.uri.path, _developerPath);
        expect(
          handshake.uri.queryParameters,
          placement == EphemeralTokenPlacement.header
              ? isEmpty
              : {'access_token': 'auth_tokens/provider-token'},
        );
        expect(
          handshake.authorization,
          placement == EphemeralTokenPlacement.header
              ? 'Token auth_tokens/provider-token'
              : isNull,
        );
        expect(handshake.apiKeyHeader, isNull);
        expect(handshake.firstMessage, {
          'setup': {'model': 'models/$_model'},
        });
      },
    );
  }

  for (final (configuredModel, expectedModel, apiVersion, wireVersion) in [
    (
      _model,
      'projects/P/locations/eu/publishers/google/models/$_model',
      ApiVersion.v1,
      'v1',
    ),
    (
      'publishers/google/models/$_model',
      'projects/P/locations/eu/publishers/google/models/$_model',
      ApiVersion.v1beta,
      'v1beta1',
    ),
    (
      'projects/Q/locations/us/publishers/google/models/$_model',
      'projects/Q/locations/us/publishers/google/models/$_model',
      ApiVersion.v1,
      'v1',
    ),
  ]) {
    test(
      'Vertex $wireVersion sends native OAuth with model $configuredModel',
      () async {
        final server = await _Server.start();
        final provider = _CountingProvider(
          const BearerTokenCredentials('adc-fixture-token'),
        );
        final live = _createLive(
          GoogleAIConfig.vertexAI(
            projectId: 'P',
            location: 'eu',
            apiVersion: apiVersion,
            authProvider: provider,
            defaultQueryParams: {
              'access_token': 'old-access-token',
              'api-key': 'old-config-key',
              'regionHint': 'eu',
            },
          ).copyWith(
            baseUrl:
                '${server.baseUrl}/proxy?key=old-url-key&X-Goog-Api-Key=old',
          ),
        );

        await live.connect(model: configuredModel).timeout(_deadline);
        final handshake = await server.handshake.future;
        expect(provider.calls, 1);
        expect(
          handshake.uri.path,
          '/proxy/ws/google.cloud.aiplatform.$wireVersion.LlmBidiService/BidiGenerateContent',
        );
        expect(handshake.uri.queryParameters, {'regionHint': 'eu'});
        expect(handshake.authorization, 'Bearer adc-fixture-token');
        expect(handshake.apiKeyHeader, isNull);
        expect(handshake.firstMessage, {
          'setup': {'model': expectedModel},
        });
      },
    );
  }

  test('Vertex rejects API-key credentials before opening a socket', () async {
    final server = await _Server.start();
    final provider = _CountingProvider(
      const ApiKeyCredentials('developer-key'),
    );
    final live = _createLive(
      GoogleAIConfig.vertexAI(
        projectId: 'P',
        authProvider: provider,
      ).copyWith(baseUrl: server.baseUrl),
    );

    await expectLater(
      live.connect(model: _model).timeout(_deadline),
      throwsA(
        isA<LiveConnectionException>().having(
          (error) => error.message,
          'message',
          contains('requires OAuth credentials'),
        ),
      ),
    );
    expect(provider.calls, 1);
    expect(server.upgrades, 0);
  });

  test(
    'Vertex does not use an explicit Developer API ephemeral token',
    () async {
      final server = await _Server.start();
      final provider = _CountingProvider(const BearerTokenCredentials('adc'));
      final live = _createLive(
        GoogleAIConfig.vertexAI(
          projectId: 'P',
          authProvider: provider,
        ).copyWith(baseUrl: server.baseUrl),
      );

      await expectLater(
        live
            .connect(model: _model, accessToken: 'developer-only')
            .timeout(_deadline),
        throwsA(
          isA<LiveConnectionException>().having(
            (error) => error.message,
            'message',
            contains('Gemini Developer API'),
          ),
        ),
      );
      expect(provider.calls, 0);
      expect(server.upgrades, 0);
    },
  );

  test(
    'a failed upgrade redacts query credentials from diagnostic fields',
    () async {
      final server = await _Server.start(reject: true);
      final live = _createLive(
        GoogleAIConfig(baseUrl: '${server.baseUrl}?proxy_auth=extrasecret'),
      );

      await expectLater(
        live
            .connect(model: _model, accessToken: 'auth_tokens/secret+value')
            .timeout(_deadline),
        throwsA(
          isA<LiveConnectionException>()
              .having((error) => error.uri?.path, 'uri path', _developerPath)
              .having((error) => error.uri?.query, 'uri query', isEmpty)
              .having(
                (error) => '${error.message} ${error.cause}',
                'message and cause',
                allOf(
                  isNot(contains('secret+value')),
                  isNot(contains('secret%2Bvalue')),
                  isNot(contains('extrasecret')),
                ),
              ),
        ),
      );
    },
  );
}
