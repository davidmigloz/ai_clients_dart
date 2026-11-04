import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/openai_dart_realtime.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

RealtimeReconnectOptions _options({
  WebSocketReconnectPreparation? prepare,
  int maxAttempts = 5,
  int maxQueueBytes = 0,
}) => RealtimeReconnectOptions(
  onReconnecting:
      prepare ?? (_) => const WebSocketReconnectDecision.continueWith(),
  maxAttempts: maxAttempts,
  initialDelay: Duration.zero,
  maxDelay: Duration.zero,
  maxQueueBytes: maxQueueBytes,
);

void main() {
  for (final translation in [false, true]) {
    group(translation ? 'Translation recovery' : 'Realtime recovery', () {
      test('default never reconnects and preserves peer close facts', () async {
        final client = OpenAIClient();
        addTearDown(client.close);
        final first = _Socket();
        var dials = 0;
        final connection = await _open(
          client,
          translation,
          connector: (uri, {headers}) async {
            dials++;
            return first;
          },
        );
        expect(connection.recovery, isNull);
        first.peerClose(1006, 'private reason');
        await connection.done;
        expect(dials, 1);
        expect(connection.isClosed(), isTrue);
        expect(connection.closeCode(), 1006);
        expect(connection.closeReason(), 'private reason');
        expect(first.cancels, 1);
      });

      test(
        'reconnect refreshes auth, retains queries and sends no initial config twice',
        () async {
          final auth = _Auth();
          final client = OpenAIClient(
            config: OpenAIConfig(
              authProvider: auth,
              baseUrl:
                  'wss://offline.invalid/v1?tenant=base&api-version=frozen',
              defaultHeaders: const {
                'X-Default': 'default',
                'Authorization': 'old',
              },
            ),
          );
          addTearDown(client.close);
          final first = _Socket();
          final second = _Socket();
          final urls = <Uri>[];
          final capturedHeaders = <Map<String, String>?>[];
          final headers = {'X-Call': 'original'};
          final query = {'tenant': 'call', 'client': 'original'};
          final connection = await _open(
            client,
            translation,
            initialConfig: true,
            reconnect: _options(),
            additionalHeaders: headers,
            queryParameters: query,
            connector: (uri, {headers}) async {
              urls.add(uri);
              capturedHeaders.add(headers);
              return urls.length == 1 ? first : second;
            },
          );
          addTearDown(connection.close);
          headers['X-Call'] = 'mutated';
          query['client'] = 'mutated';
          expect(first.sent, hasLength(1));
          expect(
            (jsonDecode(first.sent.single) as Map<String, dynamic>)['type'],
            'session.update',
          );
          first.peerClose(1006);
          await _until(
            () =>
                connection.recovery!.lastEvent is WebSocketRecoveryReconnected,
          );
          expect(auth.calls, 2);
          expect(urls.map((u) => u.scheme), everyElement('wss'));
          expect(
            urls.map((u) => u.queryParameters),
            everyElement({
              'tenant': 'call',
              'api-version': 'frozen',
              'client': 'original',
              'model': 'fixture-model',
            }),
          );
          expect(capturedHeaders[0]!['authorization'], 'Bearer token-1');
          expect(capturedHeaders[1]!['authorization'], 'Bearer token-2');
          expect(capturedHeaders[1]!['x-call'], 'original');
          expect(second.sent, isEmpty);
        },
      );

      test(
        'retry overrides layer over per-call values and empty maps clear only retry overrides',
        () async {
          final client = OpenAIClient(
            config: const OpenAIConfig(
              baseUrl: 'https://offline.invalid/v1?base=kept',
            ),
          );
          addTearDown(client.close);
          final sockets = [_Socket(), _Socket(), _Socket()];
          final urls = <Uri>[];
          final seen = <Map<String, String>?>[];
          var hooks = 0;
          final connection = await _open(
            client,
            translation,
            additionalHeaders: {'X-Call': 'kept'},
            queryParameters: {'call': 'kept'},
            reconnect: _options(
              prepare: (_) {
                return ++hooks == 1
                    ? const WebSocketReconnectDecision.continueWith(
                        headers: {'X-Retry': 'temporary'},
                        queryParameters: {'retry': 'temporary'},
                      )
                    : const WebSocketReconnectDecision.continueWith(
                        headers: {},
                        queryParameters: {},
                      );
              },
            ),
            connector: (uri, {headers}) async {
              urls.add(uri);
              seen.add(headers);
              return sockets[urls.length - 1];
            },
          );
          addTearDown(connection.close);
          sockets[0].peerClose(1006);
          await _until(
            () => urls.length == 2 && !connection.recovery!.isRecovering,
          );
          sockets[1].peerClose(1006);
          await _until(
            () => urls.length == 3 && !connection.recovery!.isRecovering,
          );
          expect(urls[1].queryParameters, {
            'base': 'kept',
            'call': 'kept',
            'retry': 'temporary',
            'model': 'fixture-model',
          });
          expect(urls[2].queryParameters, {
            'base': 'kept',
            'call': 'kept',
            'model': 'fixture-model',
          });
          expect(seen[1]!['x-call'], 'kept');
          expect(seen[1]!['x-retry'], 'temporary');
          expect(seen[2]!['x-call'], 'kept');
          expect(seen[2]!.containsKey('x-retry'), isFalse);
        },
      );

      test(
        'pending work stays detached until explicit flush after restoration',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final first = _Socket();
          final second = _Socket();
          final preparation = Completer<WebSocketReconnectDecision>();
          var dials = 0;
          final connection = await _open(
            client,
            translation,
            reconnect: _options(
              maxQueueBytes: 2048,
              prepare: (_) => preparation.future,
            ),
            connector: (uri, {headers}) async => ++dials == 1 ? first : second,
          );
          addTearDown(connection.close);
          first.peerClose(1006);
          await _until(() => connection.recovery!.isRecovering);
          final audio = {'type': 'audio.work', 'audio': 'before'};
          connection.send(audio);
          audio['audio'] = 'after';
          preparation.complete(const WebSocketReconnectDecision.continueWith());
          await _until(
            () =>
                connection.recovery!.lastEvent is WebSocketRecoveryReconnected,
          );
          expect(second.sent, isEmpty);
          expect(connection.recovery!.queuedMessages, 1);
          connection.send({
            'type': 'session.update',
            'session': {'instructions': 'restored'},
          });
          expect(second.sent, hasLength(1));
          connection.flushPending();
          expect(second.sent, hasLength(2));
          expect(jsonDecode(second.sent.last), {
            'type': 'audio.work',
            'audio': 'before',
          });
          expect(connection.recovery!.queuedBytes, 0);
        },
      );

      test(
        'zero default queue rejects disconnected sends and preserves recovery',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final first = _Socket();
          final preparation = Completer<WebSocketReconnectDecision>();
          final options = RealtimeReconnectOptions(
            onReconnecting: (_) => preparation.future,
          );
          expect(options.maxQueueBytes, 0);
          final connection = await _open(
            client,
            translation,
            reconnect: options,
            connector: (uri, {headers}) async => first,
          );
          first.peerClose(1006);
          await _until(() => connection.recovery!.isRecovering);
          expect(
            () => connection.send({'type': 'audio.work'}),
            throwsA(isA<WebSocketSendQueueOverflowException>()),
          );
          expect(connection.isClosed(), isFalse);
          expect(connection.recovery!.queuedMessages, 0);
          await connection.close();
          preparation.complete(const WebSocketReconnectDecision.abort());
        },
      );

      test(
        'takePending detaches immutable never-attempted snapshots',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final first = _Socket();
          final preparation = Completer<WebSocketReconnectDecision>();
          final connection = await _open(
            client,
            translation,
            reconnect: _options(
              maxQueueBytes: 2048,
              prepare: (_) => preparation.future,
            ),
            connector: (uri, {headers}) async => first,
          );
          first.peerClose(1006);
          await _until(() => connection.recovery!.isRecovering);
          connection.send({
            'type': 'unsent',
            'payload': {'secret': 'before'},
          });
          final detached = connection.takePending();
          expect(detached.single.message, {
            'type': 'unsent',
            'payload': {'secret': 'before'},
          });
          expect(detached.clear, throwsUnsupportedError);
          expect(connection.recovery!.queuedMessages, 0);
          await connection.close();
          expect(connection.recovery!.unsentMessages, isEmpty);
          expect(detached.single.message['type'], 'unsent');
          preparation.complete(const WebSocketReconnectDecision.abort());
        },
      );

      test(
        'retry budget is lifetime-wide across successful reconnects',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final sockets = [_Socket(), _Socket(), _Socket()];
          var dials = 0;
          final connection = await _open(
            client,
            translation,
            reconnect: _options(maxAttempts: 1),
            connector: (uri, {headers}) async => sockets[dials++],
          );
          sockets[0].peerClose(1006);
          await _until(
            () =>
                connection.recovery!.lastEvent is WebSocketRecoveryReconnected,
          );
          sockets[1].peerClose(1006);
          final report = await connection.recovery!.done;
          await connection.done;
          expect(report.cause, 'exhausted');
          expect(dials, 2);
        },
      );

      test('TLS policy close is never reconnected', () async {
        final client = OpenAIClient();
        addTearDown(client.close);
        final first = _Socket();
        var hooks = 0;
        final connection = await _open(
          client,
          translation,
          reconnect: _options(
            prepare: (_) {
              hooks++;
              return const WebSocketReconnectDecision.continueWith();
            },
          ),
          connector: (uri, {headers}) async => first,
        );
        first.peerClose(1015, 'private TLS detail');
        final report = await connection.recovery!.done;
        await connection.done;
        expect(report.code, 1015);
        expect(report.reason, 'private TLS detail');
        expect(hooks, 0);
      });

      test(
        'initial config send failure disposes reader/socket without replay',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final first = _Socket()..sendFailure = StateError('private payload');
          await expectLater(
            _open(
              client,
              translation,
              initialConfig: true,
              connector: (uri, {headers}) async => first,
            ),
            throwsA(
              isA<RealtimeTransportException>().having(
                (e) => e.toString(),
                'redacted',
                isNot(contains('private')),
              ),
            ),
          );
          expect(first.closeCalls, 1);
          expect(first.cancels, 1);
          expect(first.sent, isEmpty);
        },
      );

      test(
        'setup events getter failure still disposes returned socket',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final failure = StateError('fixture setup failure');
          final first = _Socket()..eventsFailure = failure;
          await expectLater(
            _open(
              client,
              translation,
              connector: (uri, {headers}) async => first,
            ),
            throwsA(same(failure)),
          );
          expect(first.closeCalls, 1);
        },
      );

      test('pre-abort rejects before auth and dial', () async {
        final auth = _Auth();
        final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
        addTearDown(client.close);
        var dials = 0;
        await expectLater(
          _open(
            client,
            translation,
            abortTrigger: Future.value(),
            connector: (uri, {headers}) async {
              dials++;
              return _Socket();
            },
          ),
          throwsA(isA<AbortedException>()),
        );
        expect(auth.calls, 0);
        expect(dials, 0);
      });

      test('abort pending dial disposes late success', () async {
        final client = OpenAIClient();
        addTearDown(client.close);
        final pending = Completer<ws.WebSocket>();
        final abort = Completer<void>();
        final first = _Socket();
        var dials = 0;
        final opening = _open(
          client,
          translation,
          abortTrigger: abort.future,
          connector: (uri, {headers}) {
            dials++;
            return pending.future;
          },
        );
        final failed = expectLater(opening, throwsA(isA<AbortedException>()));
        await _until(() => dials == 1);
        abort.complete();
        await failed;
        pending.complete(first);
        await _until(() => first.closeCalls == 1);
      });

      test('timeout disposes late dial and redacts native error', () async {
        final client = OpenAIClient();
        addTearDown(client.close);
        final pending = Completer<ws.WebSocket>();
        final first = _Socket();
        await expectLater(
          _open(
            client,
            translation,
            connectionTimeout: const Duration(milliseconds: 15),
            connector: (uri, {headers}) => pending.future,
          ),
          throwsA(isA<ConnectionException>()),
        );
        pending.complete(first);
        await _until(() => first.closeCalls == 1);
      });

      test('abort closes recovery during pending replacement dial', () async {
        final client = OpenAIClient();
        addTearDown(client.close);
        final abort = Completer<void>();
        final pending = Completer<ws.WebSocket>();
        final first = _Socket();
        final late = _Socket();
        var dials = 0;
        final connection = await _open(
          client,
          translation,
          abortTrigger: abort.future,
          reconnect: _options(maxQueueBytes: 2048),
          connector: (uri, {headers}) async =>
              ++dials == 1 ? first : pending.future,
        );
        first.peerClose(1006);
        await _until(() => dials == 2);
        connection.send({'type': 'never-attempted'});
        abort.complete();
        await connection.done;
        expect(connection.isClosed(), isTrue);
        expect(
          connection.recovery!.unsentMessages.single.message['type'],
          'never-attempted',
        );
        pending.complete(late);
        await _until(() => late.closeCalls == 1);
        expect(late.sent, isEmpty);
      });

      test(
        'close failure still cancels reader and finishes with a paused tap',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final first = _Socket()
            ..closeFailure = StateError('private close detail');
          final connection = await _open(
            client,
            translation,
            connector: (uri, {headers}) async => first,
          );
          final tap = connection.events.listen((_) {})..pause();
          final closing = connection.close();
          await expectLater(
            closing,
            throwsA(isA<RealtimeTransportException>()),
          );
          await connection.done.timeout(const Duration(seconds: 1));
          expect(first.cancels, 1);
          expect(connection.isClosed(), isTrue);
          tap.resume();
          await tap.cancel();
        },
      );

      test(
        'invalid UTF8 close reason rejects before mutating connection',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final first = _Socket();
          final connection = await _open(
            client,
            translation,
            connector: (uri, {headers}) async => first,
          );
          expect(
            () => connection.close(reason: List.filled(62, '界').join()),
            throwsArgumentError,
          );
          expect(connection.isClosed(), isFalse);
          expect(first.closeCalls, 0);
          await connection.close();
        },
      );

      test(
        'receive error cleans up without exposing payload in diagnostics',
        () async {
          final client = OpenAIClient();
          addTearDown(client.close);
          final first = _Socket();
          final connection = await _open(
            client,
            translation,
            connector: (uri, {headers}) async => first,
          );
          final errors = <Object>[];
          final tap = connection.events.listen((_) {}, onError: errors.add);
          first.emitError(StateError('private receive detail'));
          await connection.done;
          await _turn();
          expect(errors.single, isA<RealtimeTransportException>());
          expect(errors.single.toString(), isNot(contains('private')));
          expect(first.closeCalls, 1);
          expect(first.cancels, 1);
          await tap.cancel();
        },
      );
    });
  }

  test(
    'recovery rejects call_id model-session mismatch before credentials',
    () async {
      final auth = _Auth();
      final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
      addTearDown(client.close);
      await expectLater(
        client.realtime.connect(
          model: 'fixture',
          queryParameters: {'call_id': 'private-id'},
          reconnect: _options(),
          connector: (uri, {headers}) async => _Socket(),
        ),
        throwsArgumentError,
      );
      expect(auth.calls, 0);
    },
  );

  test('session model mismatch rejects before dialing', () async {
    final client = OpenAIClient();
    addTearDown(client.close);
    await expectLater(
      client.realtime.connect(
        model: 'fixture',
        config: const RealtimeSessionCreateRequest(model: 'other'),
        connector: (uri, {headers}) async => throw StateError('must not dial'),
      ),
      throwsArgumentError,
    );
  });
}

Future<_Connection> _open(
  OpenAIClient client,
  bool translation, {
  RealtimeWebSocketConnector? connector,
  RealtimeReconnectOptions? reconnect,
  Map<String, String>? additionalHeaders,
  Map<String, String>? queryParameters,
  Duration? connectionTimeout,
  Future<void>? abortTrigger,
  bool initialConfig = false,
}) async {
  if (translation) {
    final connection = await client.realtime.connectTranslation(
      model: 'fixture-model',
      config: initialConfig
          ? const RealtimeTranslationSessionUpdateRequest()
          : null,
      connector: connector,
      reconnect: reconnect,
      additionalHeaders: additionalHeaders,
      queryParameters: queryParameters,
      connectionTimeout: connectionTimeout,
      abortTrigger: abortTrigger,
    );
    return _Connection(
      events: connection.events,
      close: connection.close,
      done: connection.done,
      send: connection.send,
      recovery: connection.recovery,
      isClosed: () => connection.isClosed,
      closeCode: () => connection.closeCode,
      closeReason: () => connection.closeReason,
      takePending: connection.takePending,
      flushPending: connection.flushPending,
    );
  }
  final connection = await client.realtime.connect(
    model: 'fixture-model',
    config: initialConfig
        ? const RealtimeSessionCreateRequest(model: 'fixture-model')
        : null,
    connector: connector,
    reconnect: reconnect,
    additionalHeaders: additionalHeaders,
    queryParameters: queryParameters,
    connectionTimeout: connectionTimeout,
    abortTrigger: abortTrigger,
  );
  return _Connection(
    events: connection.events,
    close: connection.close,
    done: connection.done,
    send: connection.send,
    recovery: connection.recovery,
    isClosed: () => connection.isClosed,
    closeCode: () => connection.closeCode,
    closeReason: () => connection.closeReason,
    takePending: connection.takePending,
    flushPending: connection.flushPending,
  );
}

class _Connection {
  _Connection({
    required this.events,
    required this.close,
    required this.done,
    required this.send,
    required this.recovery,
    required this.isClosed,
    required this.closeCode,
    required this.closeReason,
    required this.takePending,
    required this.flushPending,
  });
  final Stream<Object?> events;
  final Future<void> Function({int? code, String? reason}) close;
  final Future<void> done;
  final void Function(Map<String, dynamic>) send;
  final WebSocketRecovery? recovery;
  final bool Function() isClosed;
  final int? Function() closeCode;
  final String? Function() closeReason;
  final List<WebSocketUnsentMessage> Function() takePending;
  final void Function() flushPending;
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer token-${++calls}',
  };
}

class _Socket implements ws.WebSocket {
  _Socket() {
    _events = StreamController(
      onCancel: () {
        cancels++;
      },
    );
  }
  late final StreamController<ws.WebSocketEvent> _events;
  final List<String> sent = [];
  int closeCalls = 0;
  int cancels = 0;
  Error? sendFailure;
  Error? closeFailure;
  Error? eventsFailure;

  void peerClose(int? code, [String reason = '']) =>
      _events.add(ws.CloseReceived(code, reason));
  void emitError(Object error) => _events.addError(error);
  @override
  Stream<ws.WebSocketEvent> get events {
    if (eventsFailure case final error?) throw error;
    return _events.stream;
  }

  @override
  String get protocol => '';
  @override
  void sendText(String text) {
    if (sendFailure case final error?) throw error;
    sent.add(text);
  }

  @override
  void sendBytes(Uint8List bytes) => throw UnsupportedError('text fixture');
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    if (closeFailure case final error?) throw error;
    if (!_events.isClosed) {
      _events.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
      unawaited(_events.close());
    }
  }
}

Future<void> _turn() => Future<void>.delayed(Duration.zero);
Future<void> _until(bool Function() condition) async {
  for (var i = 0; i < 2000; i++) {
    if (condition()) return;
    await _turn();
  }
  fail('Offline Realtime condition did not arrive');
}
