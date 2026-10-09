import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

const _browser = bool.fromEnvironment('dart.library.js_interop');
const _secret = 'PRIVATE_FORK_VALUE';
Map<String, dynamic> _session({String id = 'live_new', String? mode}) => {
  'id': id,
  'model': 'inherited-model',
  'expires_at': -1,
  'status': 'active',
  'store': true,
  'instructions': _secret,
  if (mode != null)
    'delegation': {
      'type': mode,
      if (mode == 'responses') 'responses': {'model': 'backend-model'},
    },
};
Map<String, dynamic> _started({String? mode}) => {
  'type': 'session.started',
  'event_id': 'fork-started',
  'session': _session(mode: mode),
};
Map<String, dynamic> _final() => {
  'type': 'session.closed',
  'event_id': 'fork-closed',
  'session': _session(),
  'reason': 'close_requested',
  'usage': {'seconds': 1.5},
};
LiveForkSessionStartEvent _start() =>
    LiveForkSessionStartEvent(session: LiveForkSessionConfigParam());
OpenAIClient _client({OpenAIConfig config = const OpenAIConfig()}) =>
    OpenAIClient(
      config: config,
      httpClient: MockClient((_) async => throw StateError('No HTTP expected')),
    );
Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  group('public stored-session fork transport', () {
    for (final scheme in ['http', 'https', 'ws', 'wss']) {
      test(
        '$scheme exact escaped route, inherited query, headers and no automatic startup',
        () async {
          final client = _client(
            config: OpenAIConfig(
              baseUrl:
                  '$scheme://example.invalid/custom/v1/?flag=retained&k=a&k=b',
              authProvider: const ApiKeyProvider(_secret),
              organization: 'org',
              project: 'project',
              defaultHeaders: const {
                'X-Custom': 'old',
                'X-Client-Request-ID': 'trace',
              },
            ),
          );
          final socket = _Socket();
          Uri? actual;
          Map<String, String>? actualHeaders;
          final connection = await client.live.forkConnection(
            'live_stored/a?%2F',
            connector: (url, {headers}) async {
              actual = url;
              actualHeaders = headers;
              return socket;
            },
            additionalHeaders: {'X-Custom': 'new'},
          );
          expect(connection, isA<LiveForkConnection>());
          expect(
            actual!.scheme,
            scheme == 'http' || scheme == 'ws' ? 'ws' : 'wss',
          );
          expect(actual!.pathSegments, [
            'custom',
            'v1',
            'live',
            'sessions',
            'live_stored/a?%2F',
            'fork',
          ]);
          expect(actual!.queryParametersAll['k'], ['a', 'b']);
          expect(actual!.queryParameters['flag'], 'retained');
          expect(actual!.queryParameters.containsKey('model'), isFalse);
          expect(
            actual!.queryParameters.containsKey('graceful_close'),
            isFalse,
          );
          expect(actualHeaders!['authorization'], 'Bearer $_secret');
          expect(actualHeaders!['openai-organization'], 'org');
          expect(actualHeaders!['openai-project'], 'project');
          expect(actualHeaders!['x-custom'], 'new');
          expect(() => actualHeaders!['bad'] = 'bad', throwsUnsupportedError);
          expect(socket.sent, isEmpty);
          expect(connection.toString(), isNot(contains(_secret)));
          await connection.close();
          expect(socket.closeCalls, 1);
          client.close();
        },
      );
    }
    for (final id in ['', '.', '..', '\uD800']) {
      test(
        'invalid opaque ID fails before authentication or connector $id',
        () {
          final auth = _Auth();
          final client = _client(config: OpenAIConfig(authProvider: auth));
          var calls = 0;
          expect(
            () => client.live.forkConnection(
              id,
              connector: (url, {headers}) async {
                calls++;
                return _Socket();
              },
            ),
            throwsFormatException,
          );
          expect(calls, 0);
          expect(auth.calls, 0);
          client.close();
        },
      );
    }
    for (final rejection in [
      'recording_unavailable',
      'zdr_storage_unavailable',
      'source_not_finalized',
    ]) {
      test(
        'service rejects $rejection without retries, playback or storage mutation',
        () async {
          final client = _client();
          var attempts = 0;
          await expectLater(
            client.live.forkConnection(
              'live_stored',
              connector: (url, {headers}) {
                attempts++;
                expect(url.queryParameters.containsKey('store'), isFalse);
                throw _ForkRejected(rejection);
              },
            ),
            throwsA(
              isA<ConnectionException>()
                  .having(
                    (e) => e.cause,
                    'explicit rejection',
                    isA<_ForkRejected>(),
                  )
                  .having(
                    (e) => e.toString(),
                    'private automatic diagnostic',
                    isNot(contains(rejection)),
                  ),
            ),
          );
          expect(attempts, 1);
          client.close();
        },
      );
    }
    test('closed client fails before opening fork', () {
      final client = _client()..close();
      expect(() => client.live.forkConnection('live_stored'), throwsStateError);
    });
    test('precompleted cancellation never authenticates or opens', () async {
      final auth = _Auth();
      final client = _client(config: OpenAIConfig(authProvider: auth));
      var calls = 0;
      await expectLater(
        client.live.forkConnection(
          'live_stored',
          abortTrigger: Future<void>.value(),
          connector: (url, {headers}) async {
            calls++;
            return _Socket();
          },
        ),
        throwsA(isA<AbortedException>()),
      );
      expect(calls, 0);
      expect(auth.calls, 0);
      client.close();
    });
    for (final timeout in [Duration.zero, const Duration(microseconds: -1)]) {
      test('invalid handshake timeout rejected $timeout', () async {
        final client = _client();
        await expectLater(
          client.live.forkConnection('live_stored', connectionTimeout: timeout),
          throwsArgumentError,
        );
        client.close();
      });
    }
    for (final capacity in [0, -1]) {
      test('invalid opening capacity rejected $capacity', () async {
        final client = _client();
        await expectLater(
          client.live.forkConnection(
            'live_stored',
            maxBufferedEvents: capacity,
          ),
          throwsArgumentError,
        );
        client.close();
      });
    }
    test('abandoned handshake closes late owned fork without replay', () async {
      final client = _client();
      final opening = Completer<WebSocket>();
      final socket = _Socket();
      await expectLater(
        client.live.forkConnection(
          'live_stored',
          connectionTimeout: const Duration(milliseconds: 1),
          connector: (url, {headers}) => opening.future,
        ),
        throwsA(isA<ConnectionException>()),
      );
      opening.complete(socket);
      await _tick();
      expect(socket.closeCalls, 1);
      expect(socket.sent, isEmpty);
      client.close();
    });
    test(
      'handshake cause/URL/header values remain explicit and redacted',
      () async {
        final client = _client(
          config: const OpenAIConfig(
            baseUrl: 'https://example.invalid/$_secret/',
          ),
        );
        await expectLater(
          client.live.forkConnection(
            _secret,
            connector: (url, {headers}) {
              throw StateError(_secret);
            },
          ),
          throwsA(
            isA<ConnectionException>().having(
              (e) => e.toString(),
              'private automatic diagnostics',
              isNot(contains(_secret)),
            ),
          ),
        );
        client.close();
      },
    );
    if (_browser) {
      test('browser fork policy rejects headers before auth', () async {
        final auth = _Auth();
        final client = _client(config: OpenAIConfig(authProvider: auth));
        await expectLater(
          client.live.forkConnection('live_stored'),
          throwsA(isA<LiveBrowserHeadersException>()),
        );
        expect(auth.calls, 0);
        client.close();
      });
      test(
        'browser custom header key is explicitly actionable and automatically redacted',
        () async {
          final client = _client();
          await expectLater(
            client.live.forkConnection(
              'live_stored',
              additionalHeaders: const {_secret: 'PRIVATE_VALUE'},
            ),
            throwsA(
              isA<LiveBrowserHeadersException>()
                  .having((e) => e.message, 'explicit key', contains(_secret))
                  .having(
                    (e) => e.toString(),
                    'redacted key',
                    isNot(contains(_secret)),
                  ),
            ),
          );
          client.close();
        },
      );
    }
  });
  group('distinct fork startup and lifecycle', () {
    for (final overrides in [
      <String, dynamic>{'initial_items': <dynamic>[]},
      {'unknown_override': 'PRIVATE_OVERRIDE'},
      {
        'audio': {'gain': 'PRIVATE_OVERRIDE'},
      },
      {
        'audio': {'channels': 2},
      },
    ]) {
      test(
        'new fork writer admits only documented root/audio overrides ${overrides.keys}',
        () async {
          final socket = _Socket();
          final connection = LiveForkConnection(socket);
          final event = LiveForkSessionStartEvent.fromJson({
            'type': 'session.start',
            'session': overrides,
          });
          expect(
            () => connection.send(event),
            throwsA(
              isA<LiveProtocolException>().having(
                (e) => e.toString(),
                'safe diagnostic',
                isNot(contains('PRIVATE_OVERRIDE')),
              ),
            ),
          );
          expect(socket.sent, isEmpty);
          connection.send(_start());
          expect(socket.sent.single, {
            'type': 'session.start',
            'session': <String, dynamic>{},
          });
          await connection.close();
        },
      );
    }

    test(
      'empty overrides start once and acknowledgment gates work/new ID',
      () async {
        final socket = _Socket();
        final connection = LiveConnection.fork(socket) as LiveForkConnection;
        expect(
          () => connection.send(LiveInputAudioMuteParam()),
          throwsStateError,
        );
        expect(
          () => connection.send(
            LiveSessionStartEvent(
              session: LiveSessionCreateParams(model: 'new-model'),
            ),
          ),
          throwsA(isA<LiveProtocolException>()),
        );
        expect(socket.sent, isEmpty);
        final startup = connection.start(_start());
        await _tick();
        expect(socket.sent.single, {
          'type': 'session.start',
          'session': <String, dynamic>{},
        });
        expect(
          () => connection.send(LiveInputAudioMuteParam()),
          throwsStateError,
        );
        socket.text(_started());
        final started = await startup;
        expect(started.session.id, 'live_new');
        expect(started.session.model, 'inherited-model');
        expect(started.session.store, isTrue);
        expect(started.session.instructions, _secret);
        connection.send(LiveInputAudioMuteParam());
        expect(socket.sent.last['type'], 'session.input_audio.mute');
        expect(() => connection.send(_start()), throwsStateError);
        await connection.close();
      },
    );
    test('synchronous start acknowledgment is never missed', () async {
      final socket = _Socket();
      socket.onSend = (event) {
        if (event['type'] == 'session.start') socket.text(_started());
      };
      final connection = LiveForkConnection(socket);
      final started = await connection.start(_start());
      expect(started.session.id, 'live_new');
      await connection.close();
    });
    test(
      'all ordinary fork commands preserve IDs and manual ownership after Responses ack',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(socket);
        final startup = connection.start(_start());
        await _tick();
        socket.text(_started(mode: 'responses'));
        await startup;
        final commands = <LiveClientEvent>[
          LiveInputAudioAppendEvent(audio: 'AA==', eventId: 'audio'),
          LiveInputAudioMuteParam(),
          LiveInputAudioUnmuteParam(),
          LiveSessionUpdateParam(session: LiveSessionUpdateParams()),
          LiveInstructionsAppendParam(content: 'manual', delegationId: null),
          LiveThinkingAppendParam(content: 'thinking', delegationId: null),
          LiveCommentaryAppendParam(content: 'commentary', delegationId: null),
          LiveResponseItemCreateParam(
            item: LiveInputItem.fromJson(const {
              'type': 'function_call_output',
              'call_id': 'call',
              'output': 'result',
            }),
          ),
          LiveResponseCreateParam(),
        ];
        for (final command in commands) {
          connection.send(command);
          expect(socket.sent.last, command.toJson());
        }
        connection.send(LiveSessionCloseParam());
        expect(socket.sent.last['type'], 'session.close');
        expect(socket.sent.length, 11);
        await connection.close();
      },
    );
    test(
      'known inherited client owner rejects backend override before consuming startup',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(
          socket,
          initialSession: LiveSessionResourceParam.fromJson(_session()),
        );
        final override = LiveForkSessionStartEvent(
          session: LiveForkSessionConfigParam(
            delegation: LiveResponsesDelegationUpdateParam.fromJson(const {
              'type': 'responses',
              'responses': {'model': 'backend'},
            }),
          ),
        );
        expect(
          () => connection.send(override),
          throwsA(isA<FormatException>()),
        );
        expect(socket.sent, isEmpty);
        connection.send(_start());
        expect(socket.sent.single['type'], 'session.start');
        await connection.close();
      },
    );
    for (final override in [
      <String, dynamic>{'model': 'new'},
      {'voice': 'new'},
      {'instructions': 'new'},
      {'input': <dynamic>[]},
      {'client': <String, dynamic>{}},
      {
        'audio': {'format': 'mp3'},
      },
      {'store': null},
    ]) {
      test(
        'forbidden inherited/media override rejected ${override.keys.join(',')}',
        () {
          expect(
            () => LiveForkSessionStartEvent.fromJson({
              'type': 'session.start',
              'session': override,
            }),
            throwsFormatException,
          );
        },
      );
    }
    test(
      'explicit allowed audio/store/backend overrides retain wire omission and false',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(socket);
        final command = LiveForkSessionStartEvent.fromJson(const {
          'type': 'session.start',
          'event_id': null,
          'session': {
            'store': false,
            'audio': {
              'format': {'type': 'audio/pcm', 'rate': 24000},
            },
            'delegation': {
              'type': 'responses',
              'responses': {'instructions': null},
            },
          },
        });
        connection.send(command);
        expect(socket.sent.single, command.toJson());
        await connection.close();
      },
    );
    test(
      'confirmed close drains final snapshot, shares one request and forbids new work',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(socket);
        final start = connection.start(_start());
        await _tick();
        socket.text(_started());
        await start;
        final first = connection.closeSession();
        final second = connection.closeSession();
        expect(identical(first, second), isTrue);
        expect(
          () => connection.send(LiveInputAudioMuteParam()),
          throwsStateError,
        );
        await _tick();
        socket.text(_final());
        final event = await first;
        expect(event.session.id, 'live_new');
        expect(event.usage.seconds, 1.5);
        expect(connection.isFinalized, isTrue);
        expect(connection.latestUsageSeconds, 1.5);
        expect(
          socket.sent.where((e) => e['type'] == 'session.close').length,
          1,
        );
        expect(socket.closeCalls, 1);
      },
    );
    test('peer close never fabricates stored finalization', () async {
      final socket = _Socket();
      final connection = LiveForkConnection(socket);
      final start = connection.start(_start());
      await _tick();
      socket.text(_started());
      await start;
      final closing = connection.closeSession();
      socket.peerClose();
      await expectLater(closing, throwsA(isA<LiveUnconfirmedCloseException>()));
      expect(connection.isFinalized, isFalse);
      expect(connection.finalEvent, isNull);
      expect(connection.closeCode, 1001);
      expect(connection.closeReason, _secret);
      expect(connection.toString(), isNot(contains(_secret)));
    });
    test(
      'start canceled releases owned transport and never restores or replays',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(socket);
        final abort = Completer<void>();
        final start = connection.start(_start(), abortTrigger: abort.future);
        await _tick();
        abort.complete();
        await expectLater(start, throwsA(isA<AbortedException>()));
        expect(socket.sent.length, 1);
        expect(socket.closeCalls, 1);
        expect(connection.isFinalized, isFalse);
      },
    );
    test('start timeout releases owned transport without replay', () async {
      final socket = _Socket();
      final connection = LiveForkConnection(socket);
      await expectLater(
        connection.start(_start(), timeout: const Duration(milliseconds: 1)),
        throwsA(isA<LiveTransportException>()),
      );
      expect(socket.sent.length, 1);
      expect(socket.closeCalls, 1);
      expect(connection.isFinalized, isFalse);
    });
    test(
      'transport completion during startup is not an acknowledgment',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(socket);
        final start = connection.start(_start());
        await _tick();
        socket.peerClose();
        await expectLater(start, throwsA(isA<LiveTransportException>()));
        expect(connection.startedEvent, isNull);
      },
    );
    test('borrowed fork closes only its reader', () async {
      final socket = _Socket();
      final connection =
          LiveConnection.fork(socket, ownsSocket: false) as LiveForkConnection;
      await connection.close();
      expect(socket.closeCalls, 0);
      expect(connection.isClosed, isTrue);
      await socket.close();
    });
    test(
      'two taps preserve interleaved IDs and ordinary Live server errors',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(socket);
        final first = <LiveServerEvent>[];
        final second = <LiveServerEvent>[];
        final a = connection.events.listen(first.add);
        final b = connection.events.listen(second.add);
        socket
          ..text({
            'type': 'response.event',
            'event_id': 'one',
            'delegation_id': 'del_one',
            'event': {'response_id': 'resp_one'},
          })
          ..text({
            'type': 'response.event',
            'event_id': 'two',
            'delegation_id': 'del_two',
            'event': {'response_id': 'resp_two'},
          })
          ..text({
            'type': 'error',
            'event_id': 'err',
            'error': {
              'type': 'invalid_request_error',
              'code': null,
              'message': _secret,
            },
          });
        await _tick();
        expect(first.map((e) => e.eventId), ['one', 'two', 'err']);
        expect(second, first);
        expect((first[0] as LiveResponseEvent).delegationId, 'del_one');
        await a.cancel();
        await b.cancel();
        await connection.close();
      },
    );
    test(
      'primary reflected audio policy and future raw event remain reused on fork',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(socket);
        final events = <LiveServerEvent>[];
        final errors = <Object>[];
        final sub = connection.events.listen(events.add, onError: errors.add);
        socket
          ..text({'type': 'future.fork', 'secret': _secret})
          ..text({'type': 'session.output_audio.delta', 'delta': 'AA=='})
          ..text({'type': 'session.started', 'event_id': 'bad'});
        await _tick();
        expect(events.first, isA<UnknownLiveServerEvent>());
        expect(errors, isNotEmpty);
        expect(errors.every((e) => !e.toString().contains(_secret)), isTrue);
        await sub.cancel();
        await connection.close();
      },
    );
    test(
      'overflow capacity is visible and bounded with no reconnect',
      () async {
        final socket = _Socket();
        final connection = LiveForkConnection(socket, maxBufferedEvents: 1);
        socket
          ..text({'type': 'future.one'})
          ..text({'type': 'future.two'});
        await connection.done;
        final errors = <Object>[];
        final events = <LiveServerEvent>[];
        final completed = Completer<void>();
        final tap = connection.events.listen(
          events.add,
          onError: errors.add,
          onDone: completed.complete,
        );
        await completed.future;
        await tap.cancel();
        expect(events.length, 1);
        expect(errors.single, isA<LiveEventBufferOverflowException>());
        expect(socket.closeCalls, 1);
      },
    );
  });
}

class _Socket implements WebSocket {
  final StreamController<WebSocketEvent> controller =
      StreamController<WebSocketEvent>.broadcast(sync: true);
  final List<Map<String, dynamic>> sent = [];
  void Function(Map<String, dynamic>)? onSend;
  int closeCalls = 0;
  void text(Map<String, dynamic> json) =>
      controller.add(TextDataReceived(jsonEncode(json)));
  void peerClose() {
    controller.add(CloseReceived(1001, _secret));
    unawaited(controller.close());
  }

  @override
  Stream<WebSocketEvent> get events => controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    final json = jsonDecode(text) as Map<String, dynamic>;
    sent.add(json);
    onSend?.call(json);
  }

  @override
  void sendBytes(Uint8List bytes) =>
      throw UnsupportedError('No binary commands');
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    await controller.close();
  }
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return {'Authorization': 'Bearer $_secret'};
  }
}

class _ForkRejected implements Exception {
  _ForkRejected(this.reason);
  final String reason;
}
