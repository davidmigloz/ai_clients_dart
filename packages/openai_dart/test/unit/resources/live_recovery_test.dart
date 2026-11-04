import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

Map<String, dynamic> _session(String id) => {
  'model': 'synthetic-live',
  'id': id,
  'expires_at': 0,
  'status': 'active',
};
LiveSessionStartEvent _start() => LiveSessionStartEvent(
  session: LiveSessionCreateParams(model: 'synthetic-live'),
);
LiveReconnectOptions _options({
  int maxQueueBytes = 4096,
  WebSocketReconnectPreparation? prepare,
}) => LiveReconnectOptions(
  maxAttempts: 2,
  initialDelay: Duration.zero,
  maxDelay: Duration.zero,
  maxQueueBytes: maxQueueBytes,
  onReconnecting:
      prepare ?? (_) => const WebSocketReconnectDecision.continueWith(),
);
OpenAIClient _client({OpenAIConfig? config}) => OpenAIClient(
  config: config ?? const OpenAIConfig(),
  httpClient: MockClient((_) async => throw StateError('Unexpected HTTP call')),
);
Future<void> _until(bool Function() check) async {
  for (var i = 0; i < 100; i++) {
    if (check()) return;
    await Future<void>.delayed(Duration.zero);
  }
  fail('Expected lifecycle transition did not occur.');
}

void main() {
  for (final recover in [false, true]) {
    for (final sideband in [false, true]) {
      test(
        'synchronous $sideband/$recover close inside listen releases installed reader',
        () async {
          final socket = _CloseDuringListenSocket();
          final client = _client();
          try {
            final options = recover ? _options() : null;
            final connection = sideband
                ? await client.live.attach(
                    'existing',
                    connector: (_, {headers}) async => socket,
                    reconnect: options,
                  )
                : await client.live.connect(
                    connector: (_, {headers}) async => socket,
                    reconnect: options,
                  );
            await connection.done;
            expect(connection.isClosed, isTrue);
            expect(socket.cancelCount, 1);
            expect(socket.controller.hasListener, isFalse);
            await connection.close();
            expect(socket.cancelCount, 1);
          } finally {
            await socket.controller.close();
            client.close();
          }
        },
      );
    }
  }
  test(
    'Live recovery options default to no pending queue and preserve copies',
    () {
      WebSocketReconnectDecision prepare(WebSocketReconnectContext _) =>
          const WebSocketReconnectDecision.continueWith();
      final options = LiveReconnectOptions(onReconnecting: prepare);
      expect(options.maxQueueBytes, 0);
      expect(options.maxAttempts, 5);
      expect(options.initialDelay, const Duration(milliseconds: 500));
      expect(options.maxDelay, const Duration(seconds: 8));
      expect(options.copyWith(), options);
      expect(options.copyWith().hashCode, options.hashCode);
      expect(options.copyWith(maxQueueBytes: 4).maxQueueBytes, 4);
    },
  );

  test(
    'invalid recovery rejects before credentials or connector use',
    () async {
      final auth = _Auth();
      final client = _client(config: OpenAIConfig(authProvider: auth));
      try {
        await expectLater(
          client.live.connect(
            reconnect: LiveReconnectOptions(
              maxQueueBytes: -1,
              onReconnecting: (_) => const WebSocketReconnectDecision.abort(),
            ),
            connector: (_, {headers}) async =>
                throw StateError('Unexpected dial'),
          ),
          throwsArgumentError,
        );
        expect(auth.calls, 0);
      } finally {
        client.close();
      }
    },
  );

  test(
    'primary retains only newly unsent commands behind fresh startup barrier',
    () async {
      final original = _Socket('old');
      final replacement = _Socket('new');
      final prepared = Completer<WebSocketReconnectDecision>();
      final client = _client();
      var dials = 0;
      final connection = await client.live.connect(
        connector: (_, {headers}) async =>
            dials++ == 0 ? original : replacement,
        reconnect: _options(prepare: (_) => prepared.future),
      );
      try {
        await connection.start(_start());
        connection.send(LiveInputAudioMuteParam(eventId: 'already-attempted'));
        original.peerClose(1006, 'interrupted');
        await _until(() => connection.recovery!.isRecovering);
        expect(connection.startedEvent, isNull);
        expect(connection.currentSession, isNull);
        expect(connection.latestUsageSeconds, isNull);
        connection.send(LiveInputAudioMuteParam(eventId: 'newly-unsent'));
        expect(connection.recovery!.queuedMessages, 1);
        expect(() => connection.send(_start()), throwsStateError);
        prepared.complete(const WebSocketReconnectDecision.continueWith());
        await _until(() => dials == 2 && !connection.recovery!.isRecovering);
        expect(replacement.sent, isEmpty);
        expect(connection.flushPending, throwsStateError);
        expect(connection.recovery!.flushPending, throwsStateError);
        expect(
          () => connection.send(LiveInputAudioMuteParam()),
          throwsStateError,
        );
        await connection.start(_start());
        expect(connection.startedEvent!.session.id, 'new');
        expect(replacement.sent.single['type'], 'session.start');
        connection.flushPending();
        expect(replacement.sent.map((e) => e['event_id']), [
          null,
          'newly-unsent',
        ]);
        expect(connection.recovery!.queuedBytes, 0);
        expect(original.sent.map((e) => e['event_id']), [
          null,
          'already-attempted',
        ]);
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'reconnect rebuilds credentials and preserves immutable initial request options',
    () async {
      final auth = _Auth();
      final client = _client(
        config: OpenAIConfig(
          baseUrl: 'https://example.invalid/custom/v1/?base=a&base=b&flag=base',
          authProvider: auth,
          defaultHeaders: const {'X-Default': 'default'},
        ),
      );
      final sockets = [_Socket('one'), _Socket('two'), _Socket('three')];
      final urls = <Uri>[];
      final headersSeen = <Map<String, String>>[];
      final initialQuery = {'tenant': 'initial', 'flag': 'initial'};
      final initialHeaders = {'X-Static': 'initial', 'X-Overlay': 'initial'};
      var prepares = 0;
      final connection = await client.live.attach(
        'opaque/session',
        gracefulClose: false,
        queryParameters: initialQuery,
        additionalHeaders: initialHeaders,
        connector: (url, {headers}) async {
          urls.add(url);
          headersSeen.add(headers!);
          return sockets[urls.length - 1];
        },
        reconnect: _options(
          prepare: (_) => ++prepares == 1
              ? const WebSocketReconnectDecision.continueWith(
                  queryParameters: {'flag': 'reconnected', 'session': 'resume'},
                  headers: {'x-overlay': 'reconnected'},
                )
              : const WebSocketReconnectDecision.continueWith(
                  queryParameters: {},
                  headers: {},
                ),
        ),
      );
      try {
        initialQuery['tenant'] = 'mutated';
        initialHeaders['X-Static'] = 'mutated';
        sockets[0].peerClose(1006, 'first');
        await _until(
          () => urls.length == 2 && !connection.recovery!.isRecovering,
        );
        expect(urls[1].queryParametersAll['base'], ['a', 'b']);
        expect(urls[1].queryParameters['tenant'], 'initial');
        expect(urls[1].queryParameters['flag'], 'reconnected');
        expect(urls[1].queryParameters['session'], 'resume');
        expect(urls[1].queryParameters['graceful_close'], 'false');
        expect(headersSeen[1]['authorization'], 'Bearer synthetic-2');
        expect(headersSeen[1]['x-static'], 'initial');
        expect(headersSeen[1]['x-overlay'], 'reconnected');
        sockets[1].peerClose(1012, 'second');
        await _until(
          () => urls.length == 3 && !connection.recovery!.isRecovering,
        );
        expect(urls[2].queryParameters['flag'], 'initial');
        expect(urls[2].queryParameters.containsKey('session'), isFalse);
        expect(headersSeen[2]['x-overlay'], 'initial');
        expect(headersSeen[2]['authorization'], 'Bearer synthetic-3');
        expect(auth.calls, 3);
        expect(
          () => headersSeen[2]['new'] = 'mutation',
          throwsUnsupportedError,
        );
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test('fork also needs a fresh explicit stored-session startup', () async {
    final first = _Socket('first');
    final next = _Socket('second');
    final gate = Completer<WebSocketReconnectDecision>();
    final client = _client();
    var attempts = 0;
    final connection = await client.live.forkConnection(
      'stored',
      connector: (_, {headers}) async => attempts++ == 0 ? first : next,
      reconnect: _options(prepare: (_) => gate.future),
    );
    LiveForkSessionStartEvent startup() =>
        LiveForkSessionStartEvent(session: LiveForkSessionConfigParam());
    try {
      await connection.start(startup());
      first.peerClose(1006, 'fork interrupted');
      await _until(() => connection.recovery!.isRecovering);
      connection.send(LiveInputAudioMuteParam(eventId: 'retained'));
      gate.complete(const WebSocketReconnectDecision.continueWith());
      await _until(() => attempts == 2 && !connection.recovery!.isRecovering);
      expect(next.sent, isEmpty);
      expect(connection.recovery!.flushPending, throwsStateError);
      await connection.start(startup());
      connection.flushPending();
      expect(next.sent.map((e) => e['type']), [
        'session.start',
        'session.input_audio.mute',
      ]);
    } finally {
      await connection.close();
      client.close();
    }
  });

  test(
    'interrupted old startup waiter cannot accept replacement acknowledgment or close it',
    () async {
      final original = _Socket('old', acknowledge: false);
      final replacement = _Socket('new');
      final client = _client();
      var dials = 0;
      final connection = await client.live.connect(
        connector: (_, {headers}) async =>
            dials++ == 0 ? original : replacement,
        reconnect: _options(),
      );
      try {
        final oldStart = connection.start(_start());
        final oldResult = expectLater(
          oldStart,
          throwsA(
            isA<LiveTransportException>().having(
              (e) => e.operation,
              'interruption',
              'startup_interrupted',
            ),
          ),
        );
        await _until(() => original.sent.isNotEmpty);
        original.peerClose(1006, 'interrupted before ack');
        await oldResult;
        await _until(() => dials == 2 && !connection.recovery!.isRecovering);
        expect(connection.isClosed, isFalse);
        expect(replacement.closeCount, 0);
        expect((await connection.start(_start())).session.id, 'new');
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  for (final fork in [false, true]) {
    test(
      'old ${fork ? 'fork' : 'primary'} startup abort cannot close replacement',
      () async {
        final original = _Socket('old', acknowledge: false);
        final replacement = _Socket('new');
        final abort = Completer<void>();
        final client = _client();
        var dials = 0;
        Future<WebSocket> connector(
          Uri _, {
          Map<String, String>? headers,
        }) async => dials++ == 0 ? original : replacement;
        final LiveConnection connection = fork
            ? await client.live.forkConnection(
                'stored',
                connector: connector,
                reconnect: _options(),
              )
            : await client.live.connect(
                connector: connector,
                reconnect: _options(),
              );
        Future<LiveSessionStarted> start({Future<void>? abortTrigger}) =>
            switch (connection) {
              final LivePrimaryConnection connection => connection.start(
                _start(),
                abortTrigger: abortTrigger,
              ),
              final LiveForkConnection connection => connection.start(
                LiveForkSessionStartEvent(
                  session: LiveForkSessionConfigParam(),
                ),
                abortTrigger: abortTrigger,
              ),
              _ => throw StateError('Unexpected sideband'),
            };
        try {
          final oldResult = expectLater(
            start(abortTrigger: abort.future),
            throwsA(isA<AbortedException>()),
          );
          await _until(() => original.sent.isNotEmpty);
          // Install the operation wait before racing its own abort with physical
          // retirement. Abort resolves first, while cleanup observes a new socket.
          await Future<void>.delayed(Duration.zero);
          abort.complete();
          scheduleMicrotask(
            () => original.peerClose(1006, 'operation abort race'),
          );
          await oldResult;
          await _until(() => dials == 2 && !connection.recovery!.isRecovering);
          expect(connection.isClosed, isFalse);
          expect(replacement.closeCount, 0);
          expect((await start()).session.id, 'new');
        } finally {
          await connection.close();
          client.close();
        }
      },
    );
  }

  test(
    'connection-wide abort still closes a replacement Live socket',
    () async {
      final original = _Socket('old');
      final replacement = _Socket('new');
      final abort = Completer<void>();
      final client = _client();
      var dials = 0;
      final connection = await client.live.connect(
        connector: (_, {headers}) async =>
            dials++ == 0 ? original : replacement,
        reconnect: _options(),
        abortTrigger: abort.future,
      );
      try {
        await connection.start(_start());
        original.peerClose(1006, 'before global abort');
        await _until(() => dials == 2 && !connection.recovery!.isRecovering);
        abort.complete();
        await connection.done;
        expect(connection.isClosed, isTrue);
        expect(connection.recovery!.isClosed, isTrue);
        expect(replacement.closeCount, 1);
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'retired queued acknowledgment cannot satisfy fresh startup barrier',
    () async {
      final original = _Socket('old', acknowledge: false);
      final replacement = _Socket('new', acknowledge: false);
      final client = _client();
      var dials = 0;
      final connection = await client.live.connect(
        connector: (_, {headers}) async =>
            dials++ == 0 ? original : replacement,
        reconnect: _options(),
      );
      try {
        connection.send(_start());
        original
          ..text({
            'type': 'session.started',
            'event_id': 'queued-old',
            'session': _session('old'),
          })
          ..peerClose(1006, 'same turn');
        await _until(() => dials == 2 && !connection.recovery!.isRecovering);
        expect(connection.startedEvent, isNull);
        var completed = false;
        final freshStart = connection.start(_start()).then((value) {
          completed = true;
          return value;
        });
        await _until(() => replacement.sent.isNotEmpty);
        expect(completed, isFalse);
        replacement.text({
          'type': 'session.started',
          'event_id': 'fresh',
          'session': _session('new'),
        });
        expect((await freshStart).session.id, 'new');
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'zero queue overflow leaves recovery active and caller can close it',
    () async {
      final original = _Socket('old');
      final gate = Completer<WebSocketReconnectDecision>();
      final client = _client();
      final connection = await client.live.connect(
        connector: (_, {headers}) async => original,
        reconnect: _options(maxQueueBytes: 0, prepare: (_) => gate.future),
      );
      try {
        await connection.start(_start());
        original.peerClose(1006, 'interrupted');
        await _until(() => connection.recovery!.isRecovering);
        expect(
          () => connection.send(LiveInputAudioMuteParam()),
          throwsA(isA<WebSocketSendQueueOverflowException>()),
        );
        expect(
          () => connection.send(LiveSessionCloseParam()),
          throwsStateError,
        );
        expect(connection.isClosing, isFalse);
        expect(connection.isClosed, isFalse);
        expect(connection.recovery!.isRecovering, isTrue);
        await connection.close();
        expect((await connection.recovery!.done).unsentMessages, isEmpty);
        gate.complete(const WebSocketReconnectDecision.abort());
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'finalizing during recovery cannot queue stale close or poison future recovery',
    () async {
      final first = _Socket('old');
      final next = _Socket('new');
      final gate = Completer<WebSocketReconnectDecision>();
      final client = _client();
      var attempts = 0;
      final connection = await client.live.attach(
        'existing',
        connector: (_, {headers}) async => attempts++ == 0 ? first : next,
        reconnect: _options(prepare: (_) => gate.future),
      );
      try {
        first.peerClose(1006, 'interrupted');
        await _until(() => connection.recovery!.isRecovering);
        expect(
          () => connection.send(LiveSessionCloseParam()),
          throwsStateError,
        );
        expect(connection.closeSession, throwsStateError);
        expect(connection.isClosing, isFalse);
        expect(connection.recovery!.queuedMessages, 0);
        connection.send(LiveInputAudioMuteParam(eventId: 'safe-pending'));
        gate.complete(const WebSocketReconnectDecision.continueWith());
        await _until(() => attempts == 2 && !connection.recovery!.isRecovering);
        connection.flushPending();
        expect(next.sent.single['event_id'], 'safe-pending');
        expect(connection.isClosed, isFalse);
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'terminal report and takePending contain only never-attempted commands',
    () async {
      final first = _Socket('old');
      final next = _Socket('new');
      final gate = Completer<WebSocketReconnectDecision>();
      final client = _client();
      var attempts = 0;
      final connection = await client.live.attach(
        'existing',
        connector: (_, {headers}) async => attempts++ == 0 ? first : next,
        reconnect: _options(prepare: (_) => gate.future),
      );
      try {
        connection.send(LiveInputAudioMuteParam(eventId: 'attempted'));
        first.peerClose(1006, 'interrupted');
        await _until(() => connection.recovery!.isRecovering);
        connection.send(LiveInputAudioMuteParam(eventId: 'detached'));
        final detached = connection.takePending();
        expect(detached.single.message['event_id'], 'detached');
        expect(connection.recovery!.queuedMessages, 0);
        expect(detached.clear, throwsUnsupportedError);
        connection
          ..send(LiveInputAudioMuteParam(eventId: 'unsent-one'))
          ..send(LiveInputAudioMuteParam(eventId: 'unsent-two'));
        gate.complete(const WebSocketReconnectDecision.continueWith());
        await _until(() => attempts == 2 && !connection.recovery!.isRecovering);
        expect(next.sent, isEmpty);
        next.peerClose(1008, 'private terminal reason');
        final report = await connection.recovery!.done;
        expect(report.code, 1008);
        expect(report.reason, 'private terminal reason');
        expect(report.unsentMessages.map((e) => e.message['event_id']), [
          'unsent-one',
          'unsent-two',
        ]);
        expect(report.toString(), isNot(contains('private terminal reason')));
        await connection.done;
        expect(
          connection.recovery!.unsentMessages,
          same(report.unsentMessages),
        );
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'closing-session interruption ends old final wait without reconnecting',
    () async {
      final first = _Socket('old');
      final client = _client();
      var attempts = 0;
      final connection = await client.live.connect(
        connector: (_, {headers}) async {
          attempts++;
          return first;
        },
        reconnect: _options(),
      );
      try {
        await connection.start(_start());
        final finalWait = expectLater(
          connection.closeSession(),
          throwsA(isA<LiveUnconfirmedCloseException>()),
        );
        await _until(() => first.sent.any((e) => e['type'] == 'session.close'));
        first.peerClose(1006, 'while finalizing');
        await finalWait;
        expect(attempts, 1);
        expect(connection.currentSession!.id, 'old');
        expect((await connection.recovery!.done).code, 1006);
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'finalized session retains final snapshot and usage without reconnecting',
    () async {
      final first = _Socket('old');
      final client = _client();
      var attempts = 0;
      final connection = await client.live.connect(
        connector: (_, {headers}) async {
          attempts++;
          return first;
        },
        reconnect: _options(),
      );
      try {
        await connection.start(_start());
        first.text({
          'type': 'session.closed',
          'event_id': 'final',
          'reason': 'close_requested',
          'session': _session('final-snapshot'),
          'usage': {'seconds': 12.5},
        });
        await _until(() => connection.isFinalized);
        first.peerClose(1006, 'after finalization');
        await connection.recovery!.done;
        expect(connection.finalEvent!.session.id, 'final-snapshot');
        expect(connection.currentSession!.id, 'final-snapshot');
        expect(connection.latestUsageSeconds, 12.5);
        expect(attempts, 1);
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test(
    'queued terminal event stays authoritative when physical close begins recovery',
    () async {
      final first = _Socket('old');
      final gate = Completer<WebSocketReconnectDecision>();
      final client = _client();
      var attempts = 0;
      final connection = await client.live.connect(
        connector: (_, {headers}) async {
          attempts++;
          return first;
        },
        reconnect: _options(prepare: (_) => gate.future),
      );
      try {
        await connection.start(_start());
        first
          ..text({
            'type': 'session.closed',
            'event_id': 'final-queued',
            'reason': 'close_requested',
            'session': _session('terminal-snapshot'),
            'usage': {'seconds': 4.25},
          })
          ..peerClose(1006, 'after queued terminal');
        await _until(() => connection.isFinalized);
        final confirmed = await connection.closeSession();
        expect(confirmed.session.id, 'terminal-snapshot');
        gate.complete(const WebSocketReconnectDecision.continueWith());
        await connection.recovery!.done;
        expect(attempts, 1);
        expect(connection.finalEvent!.session.id, 'terminal-snapshot');
        expect(connection.latestUsageSeconds, 4.25);
      } finally {
        await connection.close();
        client.close();
      }
    },
  );

  test('close during replacement dial disposes a late socket', () async {
    final first = _Socket('old');
    final next = _Socket('late');
    final dial = Completer<WebSocket>();
    final client = _client();
    var attempts = 0;
    final connection = await client.live.attach(
      'existing',
      connector: (_, {headers}) =>
          attempts++ == 0 ? Future.value(first) : dial.future,
      reconnect: _options(),
    );
    try {
      first.peerClose(1006, 'interrupted');
      await _until(() => attempts == 2);
      await connection.close(code: 3001, reason: 'caller');
      dial.complete(next);
      await _until(() => next.closeCount == 1);
      final report = await connection.recovery!.done;
      expect(report.code, 3001);
      expect(report.reason, 'caller');
      expect(next.listenCount, 0);
    } finally {
      await connection.close();
      client.close();
    }
  });
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer synthetic-${++calls}',
  };
}

class _Socket implements WebSocket {
  _Socket(this.id, {this.acknowledge = true}) {
    controller = StreamController<WebSocketEvent>(
      sync: true,
      onListen: () => listenCount++,
      onCancel: () => cancelCount++,
    );
  }
  final String id;
  final bool acknowledge;
  late final StreamController<WebSocketEvent> controller;
  final sent = <Map<String, dynamic>>[];
  int closeCount = 0;
  int listenCount = 0;
  int cancelCount = 0;
  void text(Map<String, dynamic> value) =>
      controller.add(TextDataReceived(jsonEncode(value)));
  void peerClose(int code, String reason) =>
      controller.add(CloseReceived(code, reason));
  @override
  Stream<WebSocketEvent> get events => controller.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String data) {
    final event = jsonDecode(data) as Map<String, dynamic>;
    sent.add(event);
    if (acknowledge && event['type'] == 'session.start') {
      text({
        'type': 'session.started',
        'event_id': 'started-$id',
        'session': _session(id),
      });
    }
  }

  @override
  void sendBytes(Uint8List bytes) => throw StateError('Unexpected binary send');
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCount++;
    if (!controller.isClosed) await controller.close();
  }
}

class _CloseDuringListenSocket extends _Socket {
  _CloseDuringListenSocket() : super('early');

  @override
  Stream<WebSocketEvent> get events =>
      _CloseDuringListenStream(controller.stream);
}

class _CloseDuringListenStream extends Stream<WebSocketEvent> {
  _CloseDuringListenStream(this.source);
  final Stream<WebSocketEvent> source;

  @override
  StreamSubscription<WebSocketEvent> listen(
    void Function(WebSocketEvent)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    final subscription = source.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
    onData?.call(CloseReceived(1000, 'closed inside listen'));
    return subscription;
  }
}
