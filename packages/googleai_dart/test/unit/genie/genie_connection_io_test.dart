@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

const _socketTimeout = Duration(seconds: 4);
const _scopedToken = 'auth_tokens/scoped+loopback-fixture';

class _LoopbackGenie {
  final HttpServer server;
  final request = Completer<HttpRequest>();
  final socket = Completer<WebSocket>();
  late final frames = StreamIterator<dynamic>(
    Stream.fromFuture(socket.future).asyncExpand((socket) => socket),
  );

  _LoopbackGenie._(this.server) {
    server.listen((incoming) async {
      request.complete(incoming);
      socket.complete(await WebSocketTransformer.upgrade(incoming));
    });
  }

  static Future<_LoopbackGenie> start() async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final fixture = _LoopbackGenie._(server);
    addTearDown(() async {
      await fixture.frames.cancel();
      await server.close(force: true);
    });
    return fixture;
  }

  GenieResource resource({GoogleAIConfig? config}) {
    final client = GoogleAIClient(
      config:
          config ??
          GoogleAIConfig(
            baseUrl:
                'http://127.0.0.1:${server.port}/proxy/?key=stale&route=preview',
            authProvider: const ApiKeyProvider('backend-fixture'),
            apiVersion: ApiVersion.v1,
            defaultHeaders: const {
              'X-Goog-Api-Key': 'header-stale',
              'Authorization': 'bearer stale',
              'API-Revision': 'old',
              'x-test': 'retained',
            },
            defaultQueryParams: const {
              'auth_token': 'query-stale',
              'access_token': 'oauth-stale',
            },
          ),
    );
    addTearDown(client.close);
    return client.interactions.genie;
  }

  Future<dynamic> nextFrame() async {
    expect(await frames.moveNext().timeout(_socketTimeout), isTrue);
    return jsonDecode(frames.current as String);
  }

  Future<void> send(Map<String, dynamic> frame, {bool binary = false}) async {
    final text = jsonEncode(frame);
    final connection = await socket.future.timeout(_socketTimeout);
    connection.add(binary ? utf8.encode(text) : text);
  }
}

void main() {
  test(
    'uses pinned v1beta header authentication and drains typed media and terminal events',
    () async {
      final fixture = await _LoopbackGenie.start();
      final session = await fixture.resource().connect(
        'int_loopback',
        authToken: _scopedToken,
        timeout: _socketTimeout,
      );
      addTearDown(session.detach);
      final request = await fixture.request.future;
      expect(request.uri.path, '/proxy/v1beta/interactions/live');
      expect(request.uri.queryParameters, {'route': 'preview'});
      expect(request.headers.value('x-goog-api-key'), _scopedToken);
      expect(request.headers.value('api-revision'), '2026-05-20');
      expect(request.headers.value('authorization'), isNull);
      expect(request.headers.value('x-test'), 'retained');
      expect(await fixture.nextFrame(), {
        'event_type': 'interaction.connect',
        'id': 'int_loopback',
      });
      expect(
        () => session.sendBatch([
          const GenieWorldSetup(prompt: 'A riverside village'),
          const GenieTextInput(' '),
        ]),
        throwsArgumentError,
      );
      expect(() => session.sendText('before setup'), throwsStateError);
      session.sendBatch([
        GenieWorldSetup(
          prompt: 'A riverside village',
          referenceImage: GenieReferenceImage.bytes([
            1,
            2,
            3,
          ], mimeType: 'image/jpeg'),
        ),
        const GenieUserAction(action: GenieAction.keyDown, key: GenieKey.w),
        const GenieTextInput('A boat approaches'),
      ]);
      expect(await fixture.nextFrame(), {
        'events': [
          {
            'event_type': 'world_setup',
            'world_prompt': {'text': 'A riverside village'},
            'reference_image': {'data': 'AQID', 'mime_type': 'image/jpeg'},
          },
          {'event_type': 'user_action', 'action': 'key_down', 'input': 'key_w'},
          {
            'event_type': 'input',
            'content': [
              {'type': 'text', 'text': 'A boat approaches'},
            ],
          },
        ],
      });
      expect(
        () => session.send(const GenieWorldSetup(prompt: 'new setup')),
        throwsStateError,
      );
      session.send(
        const GenieUserAction(action: GenieAction.keyUp, key: GenieKey.w),
      );
      expect(await fixture.nextFrame(), {
        'event_type': 'user_action',
        'action': 'key_up',
        'input': 'key_w',
      });

      final received = StreamIterator(session.receive());
      addTearDown(received.cancel);
      final connected = received.moveNext();
      await fixture.send({
        'event_type': 'interaction.connected',
        'interaction_id': 'server-reported',
        'interaction': {
          'id': 'server-reported',
          'status': 'in_progress',
          'model': 'genie-4',
        },
      });
      expect(await connected, isTrue);
      expect(
        received.current,
        isA<GenieConnectedEvent>()
            .having((e) => e.interactionId, 'id', 'server-reported')
            .having((e) => e.interaction?.model, 'model', 'genie-4'),
      );
      expect(session.id, 'int_loopback');
      await expectLater(session.receive(), emitsError(isA<StateError>()));

      final nextVideo = received.moveNext();
      await fixture.send({
        'events': [
          {
            'event_type': 'step.delta',
            'index': 0,
            'delta': {
              'type': 'video',
              'mime_type': 'image/jpeg',
              'data': 'AQID',
            },
          },
          {
            'event_type': 'step.delta',
            'index': 0,
            'delta': {
              'type': 'audio',
              'mime_type': 'audio/l16',
              'data': 'BAUGBw==',
            },
          },
          {
            'event_type': 'error',
            'error': {
              'code': 'permission_denied',
              'message': 'credential $_scopedToken',
            },
          },
          {'event_type': 'test.future', 'payload': 7},
        ],
      }, binary: true);
      expect(await nextVideo, isTrue);
      final video = received.current as GenieStepEvent;
      expect(
        (video.step as StepDeltaEvent).delta,
        isA<VideoDelta>().having(
          (delta) => delta.mimeType,
          'MIME',
          'image/jpeg',
        ),
      );
      expect(video.mediaBytes, [1, 2, 3]);
      expect(await received.moveNext(), isTrue);
      final audio = received.current as GenieStepEvent;
      expect((audio.step as StepDeltaEvent).delta, isA<AudioDelta>());
      expect(audio.mediaBytes, [4, 5, 6, 7]);
      expect(await received.moveNext(), isTrue);
      expect(
        (received.current as GenieErrorEvent).error?.message,
        'credential [redacted]',
      );
      expect(await received.moveNext(), isTrue);
      expect((received.current as GenieUnknownEvent).rawJson['payload'], 7);

      var acknowledged = false;
      final completion = session.complete().then((_) => acknowledged = true);
      expect(await fixture.nextFrame(), {'event_type': 'interaction.complete'});
      expect(acknowledged, isFalse);
      expect(
        () => session.sendText('after complete started'),
        throwsStateError,
      );
      final nextTerminal = received.moveNext();
      await fixture.send({
        'events': [
          {
            'event_type': 'interaction.completed',
            'status': {'code': 0},
            'usage': {'total_output_tokens': 8},
          },
          {'event_type': 'test.trailing'},
        ],
      });
      expect(await nextTerminal, isTrue);
      final terminal = received.current as GenieTerminalEvent;
      expect(terminal.completed, isTrue);
      expect(terminal.status?.code, 0);
      expect(terminal.usage?.totalOutputTokens, 8);
      await completion;
      expect(await received.moveNext(), isFalse);
      await session.complete();
    },
  );

  test(
    'redacts URI-encoded diagnostics and rejects nonzero completion status',
    () async {
      final fixture = await _LoopbackGenie.start();
      final session = await fixture.resource().connect(
        'int_failed_completion',
        authToken: _scopedToken,
        timeout: _socketTimeout,
      );
      addTearDown(session.detach);
      expect(await fixture.nextFrame(), {
        'event_type': 'interaction.connect',
        'id': 'int_failed_completion',
      });

      final tokenInQuery = Uri.encodeQueryComponent(_scopedToken);
      final mixedCaseTokenInQuery = tokenInQuery.replaceFirst('%2F', '%2f');
      final completionError = throwsA(
        isA<GenieConnectionException>().having(
          (e) => e.message,
          'message',
          contains('RPC status 13'),
        ),
      );
      final completed = expectLater(session.complete(), completionError);
      expect(await fixture.nextFrame(), {'event_type': 'interaction.complete'});
      await fixture.send({
        'events': [
          {
            'event_type': 'error',
            'error': {
              'code': 'permission_denied',
              'message': 'Upstream URL ?auth_token:$tokenInQuery',
            },
          },
          {
            'event_type': 'interaction.completed',
            'status': {
              'code': 13,
              'message':
                  'Internal processing failure for $mixedCaseTokenInQuery',
              'details': [
                {'target-$tokenInQuery': 'raw $_scopedToken'},
              ],
            },
          },
        ],
      });
      await completed;
      await expectLater(session.complete(), completionError);

      final events = await session.receive().toList().timeout(_socketTimeout);
      expect(events, hasLength(2));
      final reportedError = (events.first as GenieErrorEvent).error;
      expect(reportedError?.message, 'Upstream URL ?auth_token:[redacted]');
      final terminal = events.last as GenieTerminalEvent;
      expect(terminal.completed, isTrue);
      expect(terminal.status?.code, 13);
      expect(
        terminal.status?.message,
        'Internal processing failure for [redacted]',
      );
      expect(terminal.status?.details, [
        {'target-[redacted]': 'raw [redacted]'},
      ]);
    },
  );

  test(
    'detach after a terminal event discards unread events and sends no disconnect',
    () async {
      final fixture = await _LoopbackGenie.start();
      final session = await fixture.resource().connect(
        'int_finished',
        timeout: _socketTimeout,
      );
      addTearDown(session.detach);
      expect(await fixture.nextFrame(), {
        'event_type': 'interaction.connect',
        'id': 'int_finished',
      });
      final completed = session.complete();
      expect(await fixture.nextFrame(), {'event_type': 'interaction.complete'});
      await fixture.send({
        'events': [
          {'event_type': 'interaction.connected'},
          {'event_type': 'interaction.completed'},
        ],
      });
      await completed;
      await session.detach();
      expect(await session.receive().toList(), isEmpty);
      expect(await fixture.frames.moveNext().timeout(_socketTimeout), isFalse);
    },
  );

  for (final paused in [false, true]) {
    test(
      'preserves terminal and control events when the receiver is ${paused ? 'paused' : 'absent'}',
      () async {
        final fixture = await _LoopbackGenie.start();
        final session = await fixture.resource().connect(
          'int_backpressure',
          timeout: _socketTimeout,
        );
        addTearDown(session.detach);
        expect(await fixture.nextFrame(), {
          'event_type': 'interaction.connect',
          'id': 'int_backpressure',
        });
        final events = <GenieServerEvent>[];
        final drained = Completer<void>();
        final StreamSubscription<GenieServerEvent>? receiver;
        if (paused) {
          receiver = session.receive().listen(
            events.add,
            onDone: drained.complete,
          )..pause();
          addTearDown(receiver.cancel);
        } else {
          receiver = null;
        }
        final completed = session.complete();
        expect(await fixture.nextFrame(), {
          'event_type': 'interaction.complete',
        });
        await fixture.send({
          'events': [
            {'event_type': 'interaction.connected'},
            for (var index = 0; index < 520; index++)
              {
                'event_type': 'step.delta',
                'index': index,
                'delta': {
                  'type': 'video',
                  'mime_type': 'image/jpeg',
                  'data': 'AQID',
                },
              },
            {'event_type': 'test.control'},
            {'event_type': 'interaction.completed'},
          ],
        }, binary: true);
        await completed.timeout(_socketTimeout);

        if (receiver == null) {
          events.addAll(
            await session.receive().toList().timeout(_socketTimeout),
          );
        } else {
          receiver.resume();
          await drained.future.timeout(_socketTimeout);
        }
        expect(events, hasLength(513));
        expect(events.first, isA<GenieConnectedEvent>());
        expect(events[events.length - 2].eventType, 'test.control');
        expect(events.last, isA<GenieTerminalEvent>());
        expect(
          events.whereType<GenieStepEvent>().map(
            (event) => (event.step as StepDeltaEvent).index,
          ),
          List.generate(510, (i) => i + 10),
        );
      },
    );
  }

  test(
    'changing receiver does not change the connection and cancel aborts generation',
    () async {
      final fixture = await _LoopbackGenie.start();
      final session = await fixture.resource().connect(
        'int_cancel',
        timeout: _socketTimeout,
      );
      addTearDown(session.detach);
      final request = await fixture.request.future;
      expect(request.headers.value('x-goog-api-key'), 'backend-fixture');
      expect(await fixture.nextFrame(), {
        'event_type': 'interaction.connect',
        'id': 'int_cancel',
      });

      final first = session.receive();
      final initial = first.first;
      await fixture.send({'event_type': 'interaction.connected'});
      expect(await initial, isA<GenieConnectedEvent>());
      final second = StreamIterator(session.receive());
      addTearDown(second.cancel);
      final created = second.moveNext();
      session.send(
        const GenieWorldSetup(
          referenceImage: GenieReferenceImage.uri(
            uri: 'gs://fixture/start.jpg',
          ),
        ),
      );
      expect(await fixture.nextFrame(), {
        'event_type': 'world_setup',
        'reference_image': {'uri': 'gs://fixture/start.jpg'},
      });
      await fixture.send({'event_type': 'interaction.created'});
      expect(await created, isTrue);
      expect(second.current, isA<GenieCreatedEvent>());
      await session.cancel();
      expect(await fixture.nextFrame(), {'event_type': 'interaction.cancel'});
      expect(await second.moveNext(), isFalse);
      await session.cancel();
    },
  );

  test(
    'detach sends disconnect and omits completion or cancellation',
    () async {
      final fixture = await _LoopbackGenie.start();
      final session = await fixture.resource().connect(
        'int_detach',
        timeout: _socketTimeout,
      );
      addTearDown(session.detach);
      expect(await fixture.nextFrame(), {
        'event_type': 'interaction.connect',
        'id': 'int_detach',
      });
      final first = Completer<void>();
      final done = Completer<void>();
      final events = <GenieServerEvent>[];
      late final StreamSubscription<GenieServerEvent> receiving;
      receiving = session.receive().listen((event) {
        events.add(event);
        if (!first.isCompleted) {
          receiving.pause();
          first.complete();
        }
      }, onDone: done.complete);
      addTearDown(receiving.cancel);
      await fixture.send({
        'events': [
          {'event_type': 'interaction.connected'},
          {'event_type': 'test.unread'},
        ],
      });
      await first.future.timeout(_socketTimeout);
      await session.detach();
      expect(await fixture.nextFrame(), {
        'event_type': 'interaction.disconnect',
      });
      expect(await fixture.frames.moveNext().timeout(_socketTimeout), isFalse);
      receiving.resume();
      await done.future.timeout(_socketTimeout);
      expect(events, [isA<GenieConnectedEvent>()]);
      expect(session.complete, throwsStateError);
    },
  );

  test(
    'completion timeout can be retried without a duplicate control frame',
    () async {
      final fixture = await _LoopbackGenie.start();
      final session = await fixture.resource().connect(
        'int_timeout',
        timeout: _socketTimeout,
      );
      addTearDown(session.detach);
      expect(await fixture.nextFrame(), {
        'event_type': 'interaction.connect',
        'id': 'int_timeout',
      });
      final timed = expectLater(
        session.complete(timeout: const Duration(milliseconds: 25)),
        throwsA(
          isA<GenieConnectionException>().having(
            (e) => e.message,
            'message',
            contains('completion'),
          ),
        ),
      );
      expect(await fixture.nextFrame(), {'event_type': 'interaction.complete'});
      await timed;
      final again = session.complete();
      await fixture.send({'event_type': 'interaction.completed'});
      await again;
      expect(await fixture.frames.moveNext().timeout(_socketTimeout), isFalse);
    },
  );

  test(
    'close diagnostics omit upstream close reason containing the credential',
    () async {
      final fixture = await _LoopbackGenie.start();
      final session = await fixture.resource().connect(
        'int_close',
        authToken: _scopedToken,
        timeout: _socketTimeout,
      );
      addTearDown(session.detach);
      expect(await fixture.nextFrame(), {
        'event_type': 'interaction.connect',
        'id': 'int_close',
      });
      final waiting = expectLater(
        session.receive(),
        emitsError(
          isA<GenieConnectionException>()
              .having((e) => e.closeCode, 'close code', 1008)
              .having(
                (e) => e.toString(),
                'message',
                isNot(contains(_scopedToken)),
              ),
        ),
      );
      final socket = await fixture.socket.future;
      await socket.close(1008, 'credential $_scopedToken');
      await waiting;
    },
  );
}
