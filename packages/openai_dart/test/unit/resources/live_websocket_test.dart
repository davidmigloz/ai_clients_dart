import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/resources/live/websocket_connector_common.dart'
    show validateLiveBrowserHandshake;
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

const _secret = 'PRIVATE_LIVE_SOCKET_SECRET';
const _browser = bool.fromEnvironment('dart.library.js_interop');
Map<String, dynamic> _snapshot() => {
  'model': 'synthetic-live',
  'id': _secret,
  'expires_at': -1,
  'status': 'active',
};
Map<String, dynamic> _started() => {
  'type': 'session.started',
  'event_id': 'started-private',
  'session': _snapshot(),
};
Map<String, dynamic> _final([double seconds = 7.5]) => {
  'type': 'session.closed',
  'event_id': 'closed-private',
  'reason': 'close_requested',
  'session': _snapshot(),
  'usage': {'seconds': seconds},
};
Map<String, dynamic> _future(int sequence) => {
  'type': 'future.live',
  'sequence': sequence,
  'private': {
    'nested': [_secret, null],
  },
};
LiveSessionStartEvent _startup() => LiveSessionStartEvent(
  session: LiveSessionCreateParams(model: 'synthetic-live'),
  eventId: _secret,
);
Future<void> _tick() => Future<void>.delayed(Duration.zero);
OpenAIClient _client({OpenAIConfig? config}) => OpenAIClient(
  config: config ?? const OpenAIConfig(),
  httpClient: MockClient((_) async => throw StateError('Unexpected HTTP call')),
);

void main() {
  group('public Live handshake', () {
    test(
      'actual browser handshake validation redacts private header names and values',
      () {
        const privateName = 'PRIVATE_CUSTOM_HEADER_NAME';
        expect(
          () => validateLiveBrowserHandshake(
            Uri.parse('wss://example.invalid/private?token=$_secret'),
            {privateName: _secret},
          ),
          throwsA(
            isA<LiveBrowserHeadersException>()
                .having(
                  (e) => e.message,
                  'explicit actionable header',
                  contains(privateName),
                )
                .having(
                  (e) => e.message,
                  'supported alternative',
                  contains('backend'),
                )
                .having(
                  (e) => e.message,
                  'header value omitted',
                  isNot(contains(_secret)),
                )
                .having(
                  (e) => e.toString(),
                  'header name redacted',
                  isNot(contains(privateName)),
                )
                .having(
                  (e) => e.toString(),
                  'header value redacted',
                  isNot(contains(_secret)),
                ),
          ),
        );
      },
    );

    for (final scheme in ['https', 'http', 'wss', 'ws']) {
      for (final sideband in [false, true]) {
        test(
          '$scheme exact ${sideband ? 'attach' : 'primary'} URI and headers',
          () async {
            final auth = _Auth();
            final client = _client(
              config: OpenAIConfig(
                baseUrl:
                    '$scheme://example.invalid/custom/v1/?k=a&k=b&flag=old',
                authProvider: auth,
                organization: 'org-private',
                project: 'project-private',
                apiVersion: 'v-private',
                defaultHeaders: const {
                  'Authorization': 'default',
                  'X-Request-ID': 'default-trace',
                  'X-Custom': 'old',
                },
              ),
            );
            final socket = _Socket();
            Uri? actual;
            Map<String, String>? sentHeaders;
            Future<WebSocket> connector(
              Uri uri, {
              Map<String, String>? headers,
            }) async {
              actual = uri;
              expect(headers, isNotNull);
              // Copy at the seam to prove the supplied map cannot be mutated.
              expect(() => headers!['new'] = 'bad', throwsUnsupportedError);
              return socket;
            }

            Future<WebSocket> capturing(
              Uri uri, {
              Map<String, String>? headers,
            }) {
              sentHeaders = headers;
              return connector(uri, headers: headers);
            }

            final connection = sideband
                ? await client.live.attach(
                    'opaque/百分%2F?',
                    gracefulClose: false,
                    connector: capturing,
                    additionalHeaders: {
                      'X-Custom': 'new',
                      'OpenAI-Project': 'request-project',
                    },
                  )
                : await client.live.connect(
                    connector: capturing,
                    additionalHeaders: {
                      'X-Custom': 'new',
                      'OpenAI-Project': 'request-project',
                    },
                  );
            expect(
              actual!.scheme,
              scheme == 'http' || scheme == 'ws' ? 'ws' : 'wss',
            );
            expect(actual!.host, 'example.invalid');
            expect(
              actual!.pathSegments,
              sideband
                  ? [
                      'custom',
                      'v1',
                      'live',
                      'sessions',
                      'opaque/百分%2F?',
                      'attach',
                    ]
                  : ['custom', 'v1', 'live', 'sessions'],
            );
            expect(actual!.queryParametersAll['k'], ['a', 'b']);
            expect(actual!.queryParameters['flag'], 'old');
            expect(actual!.queryParameters.containsKey('model'), isFalse);
            expect(
              actual!.queryParameters['graceful_close'],
              sideband ? 'false' : null,
            );
            expect(sentHeaders, {
              'authorization': 'Bearer $_secret',
              'x-request-id': _secret,
              'x-custom': 'new',
              'openai-organization': 'org-private',
              'openai-project': 'request-project',
              'openai-version': 'v-private',
            });
            expect(auth.calls, 1);
            expect(socket.sent, isEmpty);
            client.close();
            expect(connection.isClosed, isFalse);
            await connection.close();
            expect(socket.closeCount, 1);
          },
        );
      }
    }
    for (final id in ['é/录音', '%2F', '../literal', ' x ', '?secret#', '😀']) {
      test('attach opaque ID is encoded once: ${id.length}', () async {
        final client = _client();
        final socket = _Socket();
        final connection = await client.live.attach(
          id,
          gracefulClose: true,
          connector: (uri, {headers}) async {
            expect(uri.pathSegments, ['v1', 'live', 'sessions', id, 'attach']);
            expect(
              uri.toString(),
              contains('/${Uri.encodeComponent(id)}/attach'),
            );
            expect(uri.queryParameters['graceful_close'], 'true');
            return socket;
          },
        );
        await connection.close();
        client.close();
      });
    }
    for (final id in ['', '.', '..']) {
      test('invalid attach ID ${id.length} fails before auth/dial', () async {
        final auth = _Auth();
        final client = _client(config: OpenAIConfig(authProvider: auth));
        var dials = 0;
        await expectLater(
          Future.sync(
            () => client.live.attach(
              id,
              connector: (uri, {headers}) async {
                dials++;
                return _Socket();
              },
            ),
          ),
          throwsFormatException,
        );
        expect(auth.calls, 0);
        expect(dials, 0);
        client.close();
      });
    }
    for (final base in [
      'ftp://example.invalid',
      'https:///missing',
      'https://example.invalid/#$_secret',
      'not a url',
    ]) {
      test('invalid base safely fails: ${base.length}', () async {
        final auth = _Auth();
        final client = _client(
          config: OpenAIConfig(baseUrl: base, authProvider: auth),
        );
        await expectLater(
          client.live.connect(connector: (uri, {headers}) async => _Socket()),
          throwsA(
            isA<ArgumentError>().having(
              (e) => e.toString(),
              'safe',
              isNot(contains(_secret)),
            ),
          ),
        );
        expect(auth.calls, 0);
        client.close();
      });
    }
    for (final attach in [false, true]) {
      test(
        '${attach ? 'attach' : 'connect'} precompleted abort/error before auth',
        () async {
          for (final error in [false, true]) {
            final auth = _Auth();
            final client = _client(config: OpenAIConfig(authProvider: auth));
            final abort = Completer<void>();
            if (error) {
              abort.completeError(StateError(_secret));
            } else {
              abort.complete();
            }
            var dials = 0;
            Future<WebSocket> connector(
              Uri uri, {
              Map<String, String>? headers,
            }) async {
              dials++;
              return _Socket();
            }

            await expectLater(
              attach
                  ? client.live.attach(
                      'id',
                      connector: connector,
                      abortTrigger: abort.future,
                    )
                  : client.live.connect(
                      connector: connector,
                      abortTrigger: abort.future,
                    ),
              throwsA(
                isA<AbortedException>().having(
                  (e) => e.toString(),
                  'safe',
                  isNot(contains(_secret)),
                ),
              ),
            );
            expect(auth.calls, 0);
            expect(dials, 0);
            client.close();
          }
        },
      );
      test(
        '${attach ? 'attach' : 'connect'} cancellation disposes a late socket once',
        () async {
          final auth = _Auth();
          final client = _client(config: OpenAIConfig(authProvider: auth));
          final opening = Completer<WebSocket>();
          final abort = Completer<void>();
          var dials = 0;
          Future<WebSocket> connector(Uri uri, {Map<String, String>? headers}) {
            dials++;
            return opening.future;
          }

          final future = attach
              ? client.live.attach(
                  'id',
                  connector: connector,
                  abortTrigger: abort.future,
                )
              : client.live.connect(
                  connector: connector,
                  abortTrigger: abort.future,
                );
          await _tick();
          abort.complete();
          await expectLater(
            future,
            throwsA(
              isA<AbortedException>()
                  .having((e) => e.correlationId, 'caller trace', _secret)
                  .having(
                    (e) => e.toString(),
                    'safe',
                    isNot(contains(_secret)),
                  ),
            ),
          );
          final socket = _Socket();
          opening.complete(socket);
          await _tick();
          expect(dials, 1);
          expect(socket.closeCount, 1);
          client.close();
        },
      );
      test(
        '${attach ? 'attach' : 'connect'} timeout consumes late failure',
        () async {
          final client = _client();
          final opening = Completer<WebSocket>();
          var dials = 0;
          Future<WebSocket> connector(Uri uri, {Map<String, String>? headers}) {
            dials++;
            return opening.future;
          }

          final future = attach
              ? client.live.attach(
                  'id',
                  connector: connector,
                  connectionTimeout: const Duration(milliseconds: 5),
                )
              : client.live.connect(
                  connector: connector,
                  connectionTimeout: const Duration(milliseconds: 5),
                );
          await expectLater(
            future,
            throwsA(
              isA<ConnectionException>().having(
                (e) => e.cause,
                'cause',
                isA<TimeoutException>(),
              ),
            ),
          );
          opening.completeError(StateError(_secret));
          await _tick();
          expect(dials, 1);
          client.close();
        },
      );
      test(
        '${attach ? 'attach' : 'connect'} timeout disposes late success',
        () async {
          final client = _client();
          final opening = Completer<WebSocket>();
          Future<WebSocket> connector(
            Uri uri, {
            Map<String, String>? headers,
          }) => opening.future;
          await expectLater(
            attach
                ? client.live.attach(
                    'id',
                    connector: connector,
                    connectionTimeout: const Duration(milliseconds: 5),
                  )
                : client.live.connect(
                    connector: connector,
                    connectionTimeout: const Duration(milliseconds: 5),
                  ),
            throwsA(isA<ConnectionException>()),
          );
          final socket = _Socket();
          opening.complete(socket);
          await _tick();
          expect(socket.closeCount, 1);
          client.close();
        },
      );
      test(
        '${attach ? 'attach' : 'connect'} client close during handshake releases late socket',
        () async {
          final client = _client();
          final opening = Completer<WebSocket>();
          Future<WebSocket> connector(
            Uri uri, {
            Map<String, String>? headers,
          }) => opening.future;
          final future = attach
              ? client.live.attach('id', connector: connector)
              : client.live.connect(connector: connector);
          await _tick();
          client.close();
          final socket = _Socket();
          opening.complete(socket);
          await expectLater(future, throwsStateError);
          expect(socket.closeCount, 1);
        },
      );
    }
    test(
      'handshake failure preserves raw cause privately and never retries',
      () async {
        final cause = StateError(_secret);
        final client = _client(
          config: const OpenAIConfig(retryPolicy: RetryPolicy(maxRetries: 9)),
        );
        var dials = 0;
        await expectLater(
          client.live.connect(
            connector: (uri, {headers}) {
              dials++;
              throw cause;
            },
          ),
          throwsA(
            isA<ConnectionException>()
                .having((e) => e.cause, 'identical cause', same(cause))
                .having((e) => e.url, 'caller URL', contains('/live/sessions'))
                .having((e) => e.toString(), 'safe', isNot(contains(_secret))),
          ),
        );
        expect(dials, 1);
        client.close();
      },
    );
    test(
      'closed client admission and invalid options precede authentication',
      () async {
        final auth = _Auth();
        final client = _client(config: OpenAIConfig(authProvider: auth));
        for (final max in [0, -1]) {
          await expectLater(
            client.live.connect(
              maxBufferedEvents: max,
              connector: (uri, {headers}) async => _Socket(),
            ),
            throwsArgumentError,
          );
        }
        for (final timeout in [Duration.zero, const Duration(seconds: -1)]) {
          await expectLater(
            client.live.connect(
              connectionTimeout: timeout,
              connector: (uri, {headers}) async => _Socket(),
            ),
            throwsArgumentError,
          );
        }
        client.close();
        expect(() => client.live.connect(), throwsStateError);
        expect(() => client.live.attach('x'), throwsStateError);
        expect(auth.calls, 0);
      },
    );
    if (_browser) {
      for (final headers in [
        {'authorization': _secret},
        {'OPENAI-PROJECT': _secret},
        {'X-Future': _secret},
        {'PRIVATE_CUSTOM_HEADER_NAME': _secret},
      ]) {
        test(
          'default browser rejects every header before provider invocation ${headers.keys.single}',
          () async {
            final auth = _Auth();
            final client = _client(
              config: OpenAIConfig(authProvider: auth, defaultHeaders: headers),
            );
            await expectLater(
              client.live.connect(),
              throwsA(
                isA<LiveBrowserHeadersException>()
                    .having(
                      (e) => e.toString(),
                      'safe',
                      isNot(contains(_secret)),
                    )
                    .having((e) => e.message, 'guidance', contains('backend'))
                    .having(
                      (e) => e.message,
                      'explicit caller key',
                      contains(headers.keys.single),
                    )
                    .having(
                      (e) => e.toString(),
                      'caller key redacted',
                      isNot(contains(headers.keys.single)),
                    ),
              ),
            );
            expect(auth.calls, 0);
            client.close();
          },
        );
      }
    }
  });

  group('public Live roles, readiness and lifetime', () {
    test('primary requires explicit startup then acknowledgment', () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(socket);
      expect(
        () => connection.send(LiveResponseCreateParam()),
        throwsStateError,
      );
      expect(socket.sent, isEmpty);
      connection.send(_startup());
      expect(jsonDecode(socket.sent.single), _startup().toJson());
      expect(() => connection.send(_startup()), throwsStateError);
      expect(
        () => connection.send(LiveResponseCreateParam()),
        throwsStateError,
      );
      socket.text(_started());
      connection.send(
        LiveInputAudioAppendEvent(audio: 'AQID', eventId: _secret),
      );
      expect(jsonDecode(socket.sent.last), {
        'type': 'session.input_audio.append',
        'audio': 'AQID',
        'event_id': _secret,
      });
      expect(connection.startedEvent!.session.id, _secret);
      await connection.close();
    });
    test(
      'start catches immediate acknowledgment before send returns',
      () async {
        final socket = _Socket(
          onSend: (socket, wire) {
            if (wire['type'] == 'session.start') socket.text(_started());
          },
        );
        final connection = LivePrimaryConnection(socket);
        final started = await connection.start(_startup());
        expect(started.session.id, _secret);
        connection.send(LiveInputAudioMuteParam());
        expect(socket.sent.length, 2);
        await connection.close();
      },
    );
    test('primary rejects fork startup without a socket write', () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(socket);
      final fork = LiveClientEvent.fromForkJson(const {
        'type': 'session.start',
        'session': <String, dynamic>{},
      });
      expect(
        () => connection.send(fork),
        throwsA(isA<LiveProtocolException>()),
      );
      expect(socket.sent, isEmpty);
      await connection.close();
    });
    test('startup timeout releases owned socket without replay', () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(socket);
      await expectLater(
        connection.start(_startup(), timeout: const Duration(milliseconds: 5)),
        throwsA(isA<LiveTransportException>()),
      );
      expect(socket.sent.length, 1);
      expect(socket.closeCount, 1);
      expect(connection.isFinalized, isFalse);
    });
    test('startup abort releases socket and sends no work', () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(socket);
      final abort = Completer<void>();
      final future = connection.start(_startup(), abortTrigger: abort.future);
      await _tick();
      abort.complete();
      await expectLater(future, throwsA(isA<AbortedException>()));
      expect(socket.sent.length, 1);
      expect(socket.closeCount, 1);
    });
    test(
      'sideband statically excludes startup/audio and sends common command',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final dynamic start = _startup();
        final dynamic audio = LiveInputAudioAppendEvent(audio: 'AQID');
        expect(() => connection.send(start), throwsA(isA<TypeError>()));
        expect(() => connection.send(audio), throwsA(isA<TypeError>()));
        connection.send(LiveInputAudioMuteParam(eventId: _secret));
        expect(socket.sent.length, 1);
        expect(jsonDecode(socket.sent.single), {
          'type': 'session.input_audio.mute',
          'event_id': _secret,
        });
        await connection.close();
      },
    );
    for (final borrowed in [false, true]) {
      test(
        'graceful close immediate final event ${borrowed ? 'borrowed' : 'owned'}',
        () async {
          final socket = _Socket(
            onSend: (socket, wire) {
              if (wire['type'] == 'session.close') socket.text(_final());
            },
          );
          final connection = LiveSidebandConnection(
            socket,
            ownsSocket: !borrowed,
          );
          final paused = connection.events.listen((_) {})..pause();
          final future = connection.closeSession(
            event: LiveSessionCloseParam(eventId: _secret),
          );
          final sameFuture = connection.closeSession();
          expect(identical(future, sameFuture), isTrue);
          final closed = await future;
          expect(closed.session.status, 'active');
          expect(closed.reason, 'close_requested');
          expect(connection.isFinalized, isTrue);
          expect(connection.latestUsageSeconds, 7.5);
          expect(connection.finalEvent, same(closed));
          expect(socket.closeCount, borrowed ? 0 : 1);
          expect(socket.cancelCount, 1);
          expect(socket.sent.length, 1);
          expect(jsonDecode(socket.sent.single), {
            'type': 'session.close',
            'event_id': _secret,
          });
          await connection.done;
          await connection.close();
          expect(socket.closeCount, borrowed ? 0 : 1);
          paused.resume();
          await paused.cancel();
          await socket.dispose();
        },
      );
    }
    test(
      'close listener precedes send and rejects work while awaiting final',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final future = connection.closeSession();
        expect(connection.isClosing, isTrue);
        expect(
          () => connection.send(LiveResponseCreateParam()),
          throwsStateError,
        );
        expect(socket.sent, isEmpty);
        await _tick();
        expect(
          () => connection.send(LiveResponseCreateParam()),
          throwsStateError,
        );
        socket.text(_final(1.25));
        expect((await future).usage.seconds, 1.25);
        expect(socket.closeCount, 1);
      },
    );
    test('socket close before final remains explicitly unconfirmed', () async {
      final socket = _Socket();
      final connection = LiveSidebandConnection(socket);
      final future = connection.closeSession();
      await _tick();
      socket.peerClose(4004, _secret);
      await expectLater(future, throwsA(isA<LiveUnconfirmedCloseException>()));
      expect(connection.isFinalized, isFalse);
      expect(connection.closeCode, 4004);
      expect(connection.closeReason, _secret);
      expect(connection.toString(), isNot(contains(_secret)));
      await socket.dispose();
    });
    test('finalization timeout releases owned socket once', () async {
      final socket = _Socket();
      final connection = LiveSidebandConnection(socket);
      await expectLater(
        connection.closeSession(timeout: const Duration(milliseconds: 5)),
        throwsA(isA<LiveTransportException>()),
      );
      expect(socket.closeCount, 1);
      expect(socket.sent.length, 1);
      expect(connection.isFinalized, isFalse);
    });
    test(
      'finalization cancellation releases once without confirmed usage',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final abort = Completer<void>();
        final future = connection.closeSession(abortTrigger: abort.future);
        await _tick();
        abort.completeError(StateError(_secret));
        await expectLater(future, throwsA(isA<AbortedException>()));
        expect(socket.closeCount, 1);
        expect(connection.isFinalized, isFalse);
      },
    );
    test('precompleted finalization abort sends no close command', () async {
      final socket = _Socket();
      final connection = LiveSidebandConnection(socket);
      await expectLater(
        connection.closeSession(abortTrigger: Future.value()),
        throwsA(isA<AbortedException>()),
      );
      expect(socket.sent, isEmpty);
      expect(socket.closeCount, 1);
    });
    test(
      'usage is latest cumulative fractional snapshot, not summed',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        for (final seconds in [3.5, 3.5, 2.0]) {
          socket.text({
            'type': 'session.usage.updated',
            'event_id': 'usage',
            'usage': {'seconds': seconds},
          });
          expect(connection.latestUsageSeconds, seconds);
        }
        socket.text(_final(8.25));
        expect(connection.latestUsageSeconds, 8.25);
        expect(connection.isFinalized, isTrue);
        await connection.closeSession();
        expect(socket.sent, isEmpty);
        expect(socket.closeCount, 1);
      },
    );
    test(
      'moderated final event confirms closure but ordinary errors do not',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final received = <LiveServerEvent>[];
        final tap = connection.events.listen(received.add);
        socket.text({
          'type': 'error',
          'event_id': 'error',
          'error': {
            'type': 'invalid_request_error',
            'code': null,
            'message': _secret,
          },
        });
        connection.send(LiveResponseCreateParam());
        expect(connection.isClosed, isFalse);
        expect(connection.isFinalized, isFalse);
        socket.text({..._final(), 'reason': 'content'});
        await _tick();
        expect(received.first, isA<LiveErrorEvent>());
        expect(connection.isFinalized, isTrue);
        await connection.closeSession();
        await tap.cancel();
        expect(socket.sent.length, 1);
      },
    );
    for (final borrowed in [false, true]) {
      test(
        'local close cleanup ${borrowed ? 'borrowed' : 'owned'} does not request finalization',
        () async {
          final socket = _Socket();
          final connection = LivePrimaryConnection(
            socket,
            ownsSocket: !borrowed,
          );
          await connection.close(reason: _secret);
          await connection.close();
          await connection.done;
          expect(socket.sent, isEmpty);
          expect(socket.closeCount, borrowed ? 0 : 1);
          expect(socket.cancelCount, 1);
          expect(connection.isFinalized, isFalse);
          expect(connection.toString(), isNot(contains(_secret)));
          await socket.dispose();
        },
      );
    }
    test(
      'owned local close timeout still cancels reader exactly once',
      () async {
        final socket = _Socket(holdClose: true);
        final connection = LiveSidebandConnection(socket);
        await expectLater(
          connection.close(timeout: const Duration(milliseconds: 5)),
          throwsA(isA<LiveTransportException>()),
        );
        await connection.done;
        expect(socket.closeCount, 1);
        expect(socket.cancelCount, 1);
        socket.closeGate.complete();
        await _tick();
      },
    );
    test(
      'close failure still tears down and exposes only explicit cause',
      () async {
        final cause = StateError(_secret);
        final socket = _Socket(closeError: cause);
        final connection = LiveSidebandConnection(socket);
        await expectLater(
          connection.close(),
          throwsA(
            isA<LiveTransportException>()
                .having((e) => e.cause, 'raw cause', same(cause))
                .having((e) => e.toString(), 'safe', isNot(contains(_secret))),
          ),
        );
        await connection.done;
        expect(socket.cancelCount, 1);
        expect(socket.closeCount, 1);
        await socket.dispose();
      },
    );
    test('send failure is never replayed and cleanup is once', () async {
      final cause = StateError(_secret);
      final socket = _Socket(sendError: cause);
      final connection = LiveSidebandConnection(socket);
      expect(
        () => connection.send(LiveResponseCreateParam()),
        throwsA(
          isA<LiveTransportException>().having(
            (e) => e.cause,
            'cause',
            same(cause),
          ),
        ),
      );
      await connection.done;
      expect(socket.sendCount, 1);
      expect(socket.closeCount, 1);
      expect(socket.cancelCount, 1);
    });
    test(
      'lifetime abort keeps raw trace, safe diagnostics and closes socket',
      () async {
        final socket = _Socket();
        final abort = Completer<void>();
        final connection = LiveSidebandConnection(
          socket,
          abortTrigger: abort.future,
          correlationId: _secret,
        );
        final errors = <Object>[];
        final tap = connection.events.listen((_) {}, onError: errors.add);
        abort.completeError(StateError(_secret));
        await connection.done;
        await _tick();
        expect(errors.single, isA<AbortedException>());
        final e = errors.single as AbortedException;
        expect(e.correlationId, _secret);
        expect(e.toString(), isNot(contains(_secret)));
        expect(socket.closeCount, 1);
        await tap.cancel();
      },
    );
    for (final code in [1001, 2999, 5000]) {
      test('invalid outbound close $code does not begin cleanup', () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        expect(() => connection.close(code: code), throwsArgumentError);
        expect(connection.isClosed, isFalse);
        expect(socket.closeCount, 0);
        await connection.close();
      });
    }
    test('UTF8 close reason boundary is exact and private', () async {
      final socket = _Socket();
      final connection = LiveSidebandConnection(socket);
      expect(() => connection.close(reason: 'é' * 62), throwsArgumentError);
      expect(socket.closeCount, 0);
      await connection.close(code: 3000, reason: 'é' * 61 + 'a');
      expect(socket.lastCode, 3000);
    });
  });

  group('complete role writer inventories', () {
    final commands = <Map<String, dynamic>>[
      {
        'type': 'session.start',
        'session': {
          'model': 'synthetic-live',
          'delegation': {
            'type': 'responses',
            'responses': {'model': 'synthetic-backend'},
          },
        },
        'event_id': _secret,
      },
      {
        'type': 'session.update',
        'session': <String, dynamic>{},
        'event_id': null,
      },
      {'type': 'session.input_audio.append', 'audio': 'AQID', 'event_id': null},
      {'type': 'session.input_audio.mute', 'event_id': _secret},
      {'type': 'session.input_audio.unmute'},
      {
        'type': 'session.instructions.append',
        'content': _secret,
        'delegation_id': null,
      },
      {
        'type': 'session.thinking.append',
        'content': _secret,
        'delegation_id': null,
      },
      {
        'type': 'session.commentary.append',
        'content': _secret,
        'delegation_id': null,
      },
      {
        'type': 'response.item.create',
        'item': {
          'type': 'function_call_output',
          'call_id': 'pending-private',
          'output': _secret,
        },
      },
      {'type': 'response.create'},
      {'type': 'session.close', 'event_id': _secret},
    ];
    for (final sideband in [false, true]) {
      for (final wire in commands.where(
        (wire) =>
            !sideband ||
            (wire['type'] != 'session.start' &&
                wire['type'] != 'session.input_audio.append'),
      )) {
        test(
          '${sideband ? 'sideband' : 'primary'} writer sends exact ${wire['type']}',
          () async {
            final snapshot = {
              ..._snapshot(),
              'delegation': {
                'type': 'responses',
                'responses': {'model': 'synthetic-backend'},
              },
            };
            final socket = _Socket(
              onSend: (socket, sent) {
                if (sent['type'] == 'session.start') {
                  socket.text({
                    'type': 'session.started',
                    'event_id': 'start',
                    'session': snapshot,
                  });
                }
                if (sent['type'] == 'session.close') socket.text(_final());
              },
            );
            final LiveConnection connection;
            if (sideband) {
              final writer = LiveSidebandConnection(
                socket,
                initialSession: LiveSessionResourceParam.fromJson(snapshot),
              )..send(LiveSidebandClientEvent.fromJson(wire));
              connection = writer;
            } else {
              final writer = LivePrimaryConnection(socket);
              if (wire['type'] == 'session.start') {
                await writer.start(LiveSessionStartEvent.fromJson(wire));
              } else {
                await writer.start(
                  LiveSessionStartEvent.fromJson(commands.first),
                );
                writer.send(LiveClientEvent.fromJson(wire));
              }
              connection = writer;
            }
            expect(jsonDecode(socket.sent.last), wire);
            expect(
              socket.sent.length,
              sideband || wire['type'] == 'session.start' ? 1 : 2,
            );
            if (wire['type'] == 'session.close') {
              await connection.closeSession();
            } else {
              await connection.close();
            }
            expect(socket.closeCount, 1);
            expect(socket.cancelCount, 1);
          },
        );
      }
    }
  });

  group('known session modes and explicit media adapters', () {
    for (final variant in ['omitted', 'null', 'client']) {
      test(
        'resolved $variant delegation overrides requested Responses mode',
        () async {
          final snapshot = {
            ..._snapshot(),
            if (variant != 'omitted')
              'delegation': variant == 'null' ? null : {'type': 'client'},
          };
          final socket = _Socket(
            onSend: (socket, wire) {
              if (wire['type'] == 'session.start') {
                socket.text({
                  'type': 'session.started',
                  'event_id': 'resolved',
                  'session': snapshot,
                });
              }
            },
          );
          final connection = LivePrimaryConnection(socket);
          await connection.start(
            LiveSessionStartEvent.fromJson(const {
              'type': 'session.start',
              'session': {
                'model': 'synthetic-live',
                'delegation': {
                  'type': 'responses',
                  'responses': {'model': 'synthetic-backend'},
                },
              },
            }),
          );
          expect(
            () => connection.send(LiveResponseCreateParam()),
            throwsA(isA<LiveProtocolException>()),
          );
          connection.send(
            LiveThinkingAppendParam(
              content: _secret,
              delegationId: 'client-delegation',
            ),
          );
          expect(socket.sent.length, 2);
          expect(
            connection.currentSession!.delegation?.type,
            variant == 'client' ? 'client' : null,
          );
          await connection.close();
        },
      );
    }

    for (final mode in ['client', 'responses']) {
      for (final acknowledged in ['session.started', 'session.updated']) {
        test('$mode mode learned from $acknowledged constrains writes', () async {
          final socket = _Socket();
          final connection = LiveSidebandConnection(socket)
            ..send(LiveResponseCreateParam());
          // An attached mode is unknown until a snapshot arrives; service admission applies.
          final snapshot = {
            ..._snapshot(),
            'delegation': mode == 'responses'
                ? {
                    'type': 'responses',
                    'responses': {'model': 'synthetic-backend'},
                  }
                : {'type': 'client'},
          };
          socket.text({
            'type': acknowledged,
            'event_id': 'mode',
            'session': snapshot,
          });
          expect(connection.currentSession!.delegation!.type, mode);
          final before = socket.sent.length;
          final response = LiveResponseCreateParam();
          if (mode == 'client') {
            expect(
              () => connection.send(response),
              throwsA(isA<LiveProtocolException>()),
            );
            expect(socket.sent.length, before);
          } else {
            connection.send(response);
            expect(socket.sent.length, before + 1);
          }
          for (final type in [
            'session.instructions.append',
            'session.thinking.append',
            'session.commentary.append',
          ]) {
            final general = LiveSidebandClientEvent.fromJson({
              'type': type,
              'content': _secret,
              'delegation_id': null,
            });
            connection.send(general);
            final owned = LiveSidebandClientEvent.fromJson({
              'type': type,
              'content': _secret,
              'delegation_id': 'client-private',
            });
            final sent = socket.sent.length;
            if (mode == 'responses') {
              expect(
                () => connection.send(owned),
                throwsA(
                  isA<LiveProtocolException>().having(
                    (e) => e.toString(),
                    'private',
                    isNot(contains(_secret)),
                  ),
                ),
              );
              expect(socket.sent.length, sent);
            } else {
              connection.send(owned);
              expect(socket.sent.length, sent + 1);
            }
          }
          final original = connection.currentSession;
          final disallowed = LiveSessionUpdateParam(
            session: LiveSessionUpdateParams.fromJson({
              'delegation': mode == 'responses'
                  ? null
                  : {'type': 'responses', 'responses': <String, dynamic>{}},
            }),
          );
          final writes = socket.sent.length;
          expect(
            () => connection.send(disallowed),
            throwsA(isA<LiveProtocolException>()),
          );
          expect(socket.sent.length, writes);
          expect(connection.currentSession, same(original));
          await connection.close();
        });
      }
    }
    test(
      'known Responses initial snapshot admits backend outputs and forbids mode reset',
      () async {
        final snapshot = LiveSessionResourceParam.fromJson({
          ..._snapshot(),
          'delegation': const {
            'type': 'responses',
            'responses': {'model': 'synthetic-backend'},
          },
        });
        final socket = _Socket();
        final connection =
            LiveSidebandConnection(socket, initialSession: snapshot)
              ..send(
                LiveResponseItemCreateParam.fromJson(const {
                  'type': 'response.item.create',
                  'item': {
                    'type': 'function_call_output',
                    'call_id': 'call-private',
                    'output': _secret,
                  },
                }),
              )
              ..send(LiveResponseCreateParam());
        expect(socket.sent.length, 2);
        final reset = LiveSessionUpdateParam(
          session: LiveSessionUpdateParams(
            delegation: null,
            hasDelegation: true,
          ),
        );
        expect(
          () => connection.send(reset),
          throwsA(isA<LiveProtocolException>()),
        );
        expect(connection.currentSession, same(snapshot));
        expect(socket.sent.length, 2);
        await connection.close();
      },
    );
    test(
      'known client initial snapshot forbids backend output command',
      () async {
        final socket = _Socket();
        final snapshot = LiveSessionResourceParam.fromJson(_snapshot());
        final connection = LiveSidebandConnection(
          socket,
          initialSession: snapshot,
        );
        final item = LiveResponseItemCreateParam.fromJson(const {
          'type': 'response.item.create',
          'item': {
            'type': 'function_call_output',
            'call_id': 'call-private',
            'output': _secret,
          },
        });
        expect(
          () => connection.send(item),
          throwsA(isA<LiveProtocolException>()),
        );
        expect(socket.sent, isEmpty);
        await connection.close();
      },
    );
    test(
      'HTTP-started borrowed media adapter sends work and never startup',
      () async {
        final socket = _Socket();
        final connection = LivePrimaryConnection(
          socket,
          ownsSocket: false,
          sessionAlreadyStarted: true,
          initialSession: LiveSessionResourceParam.fromJson(_snapshot()),
        );
        expect(
          () => connection.send(LiveInputAudioAppendEvent(audio: 'AQID')),
          throwsA(isA<LiveProtocolException>()),
        );
        expect(connection.startedEvent, isNull);
        expect(connection.sessionAlreadyStarted, isTrue);
        connection.send(LiveInputAudioMuteParam());
        expect(() => connection.send(_startup()), throwsStateError);
        await expectLater(connection.start(_startup()), throwsStateError);
        expect(socket.sent.length, 1);
        await connection.close();
        expect(socket.closeCount, 0);
        expect(socket.cancelCount, 1);
        await socket.dispose();
      },
    );
    test('unstarted primary finalization requires local close', () async {
      final socket = _Socket();
      final connection = LivePrimaryConnection(socket);
      expect(connection.closeSession, throwsStateError);
      expect(socket.sent, isEmpty);
      expect(connection.isClosing, isFalse);
      await connection.close();
      expect(socket.closeCount, 1);
      expect(connection.isFinalized, isFalse);
    });
    test(
      'bounded borrowed reader cancellation does not close caller media',
      () async {
        final socket = _Socket(holdCancel: true);
        final connection = LiveSidebandConnection(socket, ownsSocket: false);
        await expectLater(
          connection.close(timeout: const Duration(milliseconds: 5)),
          throwsA(isA<LiveTransportException>()),
        );
        await connection.done;
        expect(socket.cancelCount, 1);
        expect(socket.closeCount, 0);
        socket.cancelGate.complete();
        await socket.dispose();
      },
    );
    for (final literal in ['Infinity', '-Infinity', 'NaN']) {
      test(
        'runtime $literal opening capacity fails before auth/reader on all backends',
        () async {
          final dynamic value = num.parse(literal);
          final auth = _Auth();
          final client = _client(config: OpenAIConfig(authProvider: auth));
          var dials = 0;
          await expectLater(
            Future.sync(
              () => client.live.connect(
                maxBufferedEvents: value,
                connector: (uri, {headers}) async {
                  dials++;
                  return _Socket();
                },
              ),
            ),
            throwsA(value is int ? isA<ArgumentError>() : isA<TypeError>()),
          );
          final socket = _Socket();
          expect(
            () => LiveSidebandConnection(socket, maxBufferedEvents: value),
            throwsA(value is int ? isA<ArgumentError>() : isA<TypeError>()),
          );
          expect(auth.calls, 0);
          expect(dials, 0);
          expect(socket.listenCount, 0);
          unawaited(socket.dispose());
          client.close();
        },
      );
    }
  });

  group('runtime nonfinite connection controls', () {
    for (final literal in ['Infinity', '-Infinity', 'NaN']) {
      test('runtime $literal close code is rejected without cleanup', () async {
        final dynamic value = num.parse(literal);
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        expect(
          () => connection.close(code: value),
          throwsA(value is int ? isA<ArgumentError>() : isA<TypeError>()),
        );
        expect(socket.closeCount, 0);
        expect(connection.isClosed, isFalse);
        await connection.close();
      });
      test(
        'runtime $literal connection duration is rejected before auth',
        () async {
          final dynamic value = num.parse(literal);
          final auth = _Auth();
          final client = _client(config: OpenAIConfig(authProvider: auth));
          await expectLater(
            Future.sync(
              () => client.live.connect(
                connectionTimeout: Duration(microseconds: value),
                connector: (uri, {headers}) async => _Socket(),
              ),
            ),
            throwsA(value is int ? isA<ArgumentError>() : isA<TypeError>()),
          );
          expect(auth.calls, 0);
          client.close();
        },
      );
    }
  });

  group('delivery gaps and application-owned deduplication', () {
    test(
      'sideband reflected frames retain bytes, gaps and delivery order',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final events = <LiveServerEvent>[];
        final tap = connection.events.listen(events.add);
        final wires = <Map<String, dynamic>>[
          {
            'type': 'session.output_audio.delta',
            'delta': 'AAEC',
            'start_ms': 100,
            'end_ms': 110,
          },
          {'type': 'session.input_audio.append', 'audio': 'AwQF'},
          {
            'type': 'session.output_audio.delta',
            'delta': 'BgcI',
            'start_ms': 200,
            'end_ms': 210,
          },
          {
            'type': 'session.output_audio.delta',
            'delta': 'CQoL',
            'start_ms': 150,
            'end_ms': 160,
          },
        ]..forEach(socket.text);
        await _tick();
        expect(events.map((e) => e.toJson()), wires);
        expect(socket.sent, isEmpty);
        await connection.close();
        await tap.cancel();
      },
    );
    test(
      'SIP replay original IDs remain visible; application explicitly deduplicates',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final events = <LiveServerEvent>[];
        final unique = <String>{};
        var actions = 0;
        final tap = connection.events.listen((event) {
          events.add(event);
          if (event.eventId case final id?) {
            if (unique.add(id)) actions++;
          }
        });
        final ringing = {
          'type': 'transport.ringing',
          'event_id': 'original-id',
          'session_id': _secret,
        };
        socket
          ..text(ringing)
          ..text(ringing)
          ..text({
            'type': 'transport.answered',
            'event_id': 'answer-id',
            'session_id': _secret,
          });
        await _tick();
        expect(events.map((e) => e.eventId), [
          'original-id',
          'original-id',
          'answer-id',
        ]);
        expect(actions, 2);
        expect(socket.sent, isEmpty);
        await connection.close();
        await tap.cancel();
      },
    );
    test(
      'response envelope compact snapshots remain raw and no automatic work is run',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final events = <LiveServerEvent>[];
        final tap = connection.events.listen(events.add);
        final wire = {
          'type': 'response.event',
          'event_id': 'outer',
          'client_event_id': 'command',
          'delegation_id': null,
          'event': {
            'response': {
              'id': _secret,
              'instructions': null,
              'tools': null,
              'output': null,
            },
          },
        };
        socket.text(wire);
        await _tick();
        expect(events.single.toJson(), wire);
        expect(socket.sent, isEmpty);
        expect(connection.isClosed, isFalse);
        await connection.close();
        await tap.cancel();
      },
    );
  });

  group('public received delivery and protocol isolation', () {
    test(
      'early events survive peer close and reach first listener in order',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        socket
          ..text(_future(1))
          ..text(_future(2))
          ..peerClose(1000, _secret);
        await connection.done;
        final received = await connection.events.toList();
        expect(received.map((e) => e.toJson()['sequence']), [1, 2]);
        expect(received.first.rawJson['private'], {
          'nested': [_secret, null],
        });
        expect(socket.cancelCount, 1);
        await socket.dispose();
      },
    );
    test(
      'bounded opening overflow is explicit after retained frames',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket, maxBufferedEvents: 2);
        socket
          ..text(_future(1))
          ..text(_future(2))
          ..text(_future(3));
        await connection.done;
        final values = <int>[];
        final errors = <Object>[];
        final streamDone = Completer<void>();
        final tap = connection.events.listen(
          (e) => values.add(e.toJson()['sequence'] as int),
          onError: errors.add,
          onDone: streamDone.complete,
        );
        await streamDone.future;
        await tap.cancel();
        expect(values, [1, 2]);
        expect(errors.single, isA<LiveEventBufferOverflowException>());
        expect(socket.closeCount, 1);
        expect(socket.cancelCount, 1);
      },
    );
    test(
      'concurrent taps receive all future frames and cancel independently',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        socket.text(_future(0));
        final app = <int>[];
        final helper = <int>[];
        final a = connection.events.listen(
          (e) => app.add(e.toJson()['sequence'] as int),
        );
        final b = connection.events.listen(
          (e) => helper.add(e.toJson()['sequence'] as int),
        );
        await _tick();
        socket.text(_future(1));
        await _tick();
        await b.cancel();
        socket.text(_future(2));
        await _tick();
        expect(app, [0, 1, 2]);
        expect(helper, [1]);
        expect(socket.cancelCount, 0);
        await a.cancel();
        expect(connection.isClosed, isFalse);
        await connection.close();
      },
    );
    test(
      'protocol errors do not terminate and remain ordered with events',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final received = <Object>[];
        final tap = connection.events.listen(
          received.add,
          onError: received.add,
        );
        socket.controller.add(TextDataReceived('$_secret{'));
        socket.controller.add(TextDataReceived('[]'));
        socket.controller.add(BinaryDataReceived(Uint8List.fromList([1, 2])));
        socket
          ..text({'type': 'session.started', 'event_id': 'missing-session'})
          ..text(_future(1));
        await _tick();
        expect(received.take(4).map((e) => (e as LiveProtocolException).kind), [
          'invalid_json',
          'non_object',
          'binary',
          'invalid_event',
        ]);
        for (final e in received.take(4)) {
          expect(e.toString(), isNot(contains(_secret)));
        }
        expect(received.last, isA<UnknownLiveServerEvent>());
        expect(connection.isClosed, isFalse);
        connection.send(LiveResponseCreateParam());
        await connection.close();
        await tap.cancel();
      },
    );
    test(
      'transport errors preserve explicit cause and terminate once',
      () async {
        final socket = _Socket();
        final connection = LiveSidebandConnection(socket);
        final errors = <Object>[];
        final tap = connection.events.listen((_) {}, onError: errors.add);
        final cause = StateError(_secret);
        socket.controller.addError(cause);
        await connection.done;
        await _tick();
        final error = errors.single as LiveTransportException;
        expect(error.cause, same(cause));
        expect(error.operation, 'receive');
        expect(error.toString(), isNot(contains(_secret)));
        expect(socket.closeCount, 1);
        expect(socket.cancelCount, 1);
        await tap.cancel();
      },
    );
    for (final sideband in [false, true]) {
      test(
        '${sideband ? 'sideband' : 'primary'} output audio directional timing',
        () async {
          final socket = _Socket();
          final connection = sideband
              ? LiveSidebandConnection(socket)
              : LivePrimaryConnection(socket);
          final events = <LiveServerEvent>[];
          final errors = <Object>[];
          final tap = connection.events.listen(events.add, onError: errors.add);
          socket
            ..text({
              'type': 'session.output_audio.delta',
              'delta': 'AAEC',
              if (sideband) ...{'start_ms': 10, 'end_ms': 20},
            })
            ..text({
              'type': 'session.output_audio.delta',
              'delta': 'AwQF',
              if (!sideband) ...{'start_ms': 30, 'end_ms': 40},
            })
            ..text({'type': 'session.input_audio.append', 'audio': 'BgcI'});
          await _tick();
          expect(events.length, 2);
          expect(errors.single, isA<LiveProtocolException>());
          expect(events.first.toJson()['delta'], 'AAEC');
          expect(events.last.toJson()['audio'], 'BgcI');
          expect(events.first.eventId, isNull);
          expect(events.last.eventId, isNull);
          await connection.close();
          await tap.cancel();
        },
      );
    }
    for (final capacity in [0, -1]) {
      test('invalid capacity $capacity never opens a reader', () {
        final socket = _Socket();
        expect(
          () => LivePrimaryConnection(socket, maxBufferedEvents: capacity),
          throwsArgumentError,
        );
        expect(socket.listenCount, 0);
        unawaited(socket.dispose());
      });
    }
  });
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() {
    calls++;
    return {'Authorization': 'Bearer $_secret', 'X-Request-ID': _secret};
  }
}

class _Socket implements WebSocket {
  _Socket({
    this.onSend,
    this.sendError,
    this.closeError,
    this.holdClose = false,
    this.holdCancel = false,
  }) {
    controller = StreamController<WebSocketEvent>(
      sync: true,
      onListen: () => listenCount++,
      onCancel: () {
        cancelCount++;
        if (holdCancel) return cancelGate.future;
      },
    );
  }
  final void Function(_Socket, Map<String, dynamic>)? onSend;
  final Error? sendError;
  final Error? closeError;
  final bool holdClose;
  final bool holdCancel;
  late final StreamController<WebSocketEvent> controller;
  final closeGate = Completer<void>();
  final cancelGate = Completer<void>();
  final sent = <String>[];
  int listenCount = 0;
  int cancelCount = 0;
  int closeCount = 0;
  int sendCount = 0;
  int? lastCode;
  void text(Map<String, dynamic> wire) =>
      controller.add(TextDataReceived(jsonEncode(wire)));
  void peerClose(int code, String reason) =>
      controller.add(CloseReceived(code, reason));
  Future<void> dispose() => controller.close();
  @override
  Stream<WebSocketEvent> get events => controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    sendCount++;
    if (sendError case final error?) {
      throw error;
    }
    sent.add(text);
    onSend?.call(this, jsonDecode(text) as Map<String, dynamic>);
  }

  @override
  void sendBytes(Uint8List bytes) =>
      throw StateError('No binary client frames');
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCount++;
    lastCode = code;
    if (closeError case final error?) {
      throw error;
    }
    if (holdClose) {
      await closeGate.future;
    }
    if (!controller.isClosed) {
      peerClose(code ?? 1000, reason ?? '');
      await controller.close();
    }
  }
}
