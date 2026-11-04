import 'dart:async';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

void main() {
  test('binary report owns immutable bytes, kind, equality and copies', () {
    final source = Uint8List.fromList([1, 2, 3]);
    final frame = WebSocketUnsentMessage.fromBytes(source);
    source[0] = 9;
    expect(frame.bytes, [1, 2, 3]);
    expect(frame.byteLength, 3);
    expect(frame.isBinary, isTrue);
    expect(() => frame.bytes[0] = 7, throwsUnsupportedError);
    expect(() => frame.text, throwsStateError);
    expect(() => frame.message, throwsFormatException);
    expect(frame.copyWith(), frame);
    expect(frame.copyWith().hashCode, frame.hashCode);
    expect(frame.copyWith(text: 'hello').isBinary, isFalse);
    expect(
      WebSocketUnsentMessage.fromText('x').copyWith(bytes: source).isBinary,
      isTrue,
    );
    expect(() => frame.copyWith(text: 'x', bytes: source), throwsArgumentError);
    expect(frame.toString(), isNot(contains('[1, 2, 3]')));
  });

  test(
    'binary first frame obeys byte budget and mixed queue preserves kinds',
    () async {
      final dial = Completer<ws.WebSocket>();
      final h = _Harness(reconnect: (_) => dial.future, maxQueueBytes: 4);
      addTearDown(h.close);
      h.initial.peerClose();
      await _tick();
      final binary = Uint8List.fromList([1, 2, 3, 4, 5]);
      expect(
        () => h.socket.sendBytes(binary),
        throwsA(isA<WebSocketSendQueueOverflowException>()),
      );
      expect(h.socket.recovery.queuedBytes, 0);
      final accepted = Uint8List.fromList([3, 4]);
      h.socket.sendBytes(accepted);
      accepted[0] = 8;
      h.socket.sendText('é');
      expect(h.socket.recovery.queuedBytes, 4);
      final next = _Socket();
      dial.complete(next);
      await _tick();
      expect(next.writes, [
        [3, 4],
        'é',
      ]);
      expect(h.socket.recovery.queuedBytes, 0);
    },
  );

  test(
    'manual pending waits for reconciliation and permits fresh config',
    () async {
      final dial = Completer<ws.WebSocket>();
      final h = _Harness(reconnect: (_) => dial.future, manualQueue: true);
      addTearDown(h.close);
      h.initial.peerClose();
      await _tick();
      h.socket.sendText('pending');
      h.socket.sendBytes(Uint8List.fromList([4, 5]));
      expect(h.socket.recovery.flushPending, throwsStateError);
      final next = _Socket();
      dial.complete(next);
      await _tick();
      expect(next.writes, isEmpty);
      h.socket.sendText('fresh config');
      expect(next.writes, ['fresh config']);
      h.socket.recovery.flushPending();
      expect(next.writes, [
        'fresh config',
        'pending',
        [4, 5],
      ]);
      expect(h.socket.recovery.takePending(), isEmpty);
    },
  );

  test(
    'manual flush keeps reentrant new frames behind its pending tail',
    () async {
      final dial = Completer<ws.WebSocket>();
      final h = _Harness(reconnect: (_) => dial.future, manualQueue: true);
      addTearDown(h.close);
      h.initial.peerClose();
      await _tick();
      h.socket.sendText('first');
      h.socket.sendText('second');
      final next = _Socket();
      dial.complete(next);
      await _tick();
      next.onText = (text) {
        if (text == 'first') {
          expect(h.socket.recovery.flushPending, throwsStateError);
          h.socket.sendText('reentrant');
        }
      };
      h.socket.recovery.flushPending();
      expect(next.writes, ['first', 'second', 'reentrant']);
    },
  );

  test('frame-count budget bounds empty text and binary records', () async {
    final dial = Completer<ws.WebSocket>();
    final h = _Harness(reconnect: (_) => dial.future, maxQueueMessages: 2);
    addTearDown(h.close);
    h.initial.peerClose();
    await _tick();
    h.socket.sendText('');
    h.socket.sendBytes(Uint8List(0));
    expect(h.socket.recovery.queuedBytes, 0);
    expect(h.socket.recovery.queuedMessages, 2);
    expect(
      () => h.socket.sendText(''),
      throwsA(
        isA<WebSocketSendQueueOverflowException>().having(
          (e) => e.queuedMessages,
          'frame count',
          2,
        ),
      ),
    );
    await h.socket.close();
    final report = await h.socket.recovery.done;
    expect(report.unsentMessages.map((e) => e.isBinary), [false, true]);
    dial.complete(_Socket());
  });

  test('queue-count options and overflow facts preserve value contracts', () {
    final options = WebSocketReconnectOptions(
      onReconnecting: (_) => const WebSocketReconnectDecision.abort(),
    );
    expect(options.copyWith(), options);
    expect(options.copyWith().hashCode, options.hashCode);
    expect(options.copyWith(maxQueueMessages: 3), isNot(options));
    expect(
      options.copyWith(maxQueueMessages: -1).validate,
      throwsArgumentError,
    );
    const event = WebSocketRecoveryQueueOverflow(
      frameBytes: 0,
      maxQueueBytes: 5,
      queuedBytes: 0,
      maxQueueMessages: 2,
      queuedMessages: 2,
    );
    expect(event.copyWith(), event);
    expect(event.copyWith().hashCode, event.hashCode);
    expect(event.copyWith(queuedMessages: null).queuedMessages, isNull);
    const error = WebSocketSendQueueOverflowException(
      frameBytes: 0,
      maxQueueBytes: 5,
      queuedBytes: 0,
      maxQueueMessages: 2,
      queuedMessages: 2,
    );
    expect(error.copyWith(), error);
    expect(error.copyWith().hashCode, error.hashCode);
    expect(error.copyWith(maxQueueMessages: null).maxQueueMessages, isNull);
  });

  test(
    'interrupted manual flush throws and retains only unattempted tail',
    () async {
      final dial = Completer<ws.WebSocket>();
      final nextDial = Completer<ws.WebSocket>();
      var dials = 0;
      final h = _Harness(
        reconnect: (_) => ++dials == 1 ? dial.future : nextDial.future,
        manualQueue: true,
      );
      addTearDown(h.close);
      h.initial.peerClose();
      await _tick();
      h.socket.sendText('attempted');
      h.socket.sendText('pending');
      final next = _Socket();
      dial.complete(next);
      await _tick();
      next.onText = (_) => next.peerClose(1012);
      expect(h.socket.recovery.flushPending, throwsStateError);
      expect(next.writes, ['attempted']);
      expect(h.socket.recovery.queuedMessages, 1);
      await h.socket.close();
      expect(
        (await h.socket.recovery.done).unsentMessages.single.text,
        'pending',
      );
      nextDial.complete(_Socket());
    },
  );

  test('retry delay validation prevents browser timer overflow', () {
    final options = WebSocketReconnectOptions(
      onReconnecting: (_) => const WebSocketReconnectDecision.abort(),
    );
    const limit = Duration(milliseconds: 2147483647);
    options.copyWith(initialDelay: limit, maxDelay: limit).validate();
    const overflow = Duration(microseconds: 2147483647001);
    expect(
      options.copyWith(initialDelay: overflow).validate,
      throwsArgumentError,
    );
    expect(options.copyWith(maxDelay: overflow).validate, throwsArgumentError);
  });

  test('manual flush cannot bypass a protocol startup guard', () {
    var ready = false;
    final h = _Harness(
      beforeFlush: () {
        if (!ready) throw StateError('Start the session first.');
      },
    );
    addTearDown(h.close);
    expect(h.socket.recovery.flushPending, throwsStateError);
    ready = true;
    h.socket.recovery.flushPending();
  });

  test(
    'failed attempted binary is excluded from detached unsent remainder',
    () async {
      final dial = Completer<ws.WebSocket>();
      final h = _Harness(reconnect: (_) => dial.future, manualQueue: true);
      addTearDown(h.close);
      h.initial.peerClose();
      await _tick();
      h.socket.sendBytes(Uint8List.fromList([1, 2]));
      h.socket.sendText('never attempted');
      final next = _Socket()..failWrites = true;
      dial.complete(next);
      await _tick();
      expect(
        h.socket.recovery.flushPending,
        throwsA(
          isA<WebSocketDeliveryUnknownException>().having(
            (e) => e.frameBytes,
            'attempted bytes',
            2,
          ),
        ),
      );
      final report = await h.socket.recovery.done;
      expect(report.cause, 'delivery_unknown');
      expect(report.unsentMessages.map((e) => e.text), ['never attempted']);
      expect(h.socket.recovery.queuedBytes, 0);
      expect(h.socket.recovery.takePending(), isEmpty);
      expect(report.unsentMessages.single.text, 'never attempted');
    },
  );

  test(
    'takePending detaches FIFO without sending and final report stays exact',
    () async {
      final dial = Completer<ws.WebSocket>();
      final h = _Harness(reconnect: (_) => dial.future, manualQueue: true);
      addTearDown(h.close);
      h.initial.peerClose();
      await _tick();
      h.socket.sendText('take me');
      final taken = h.socket.recovery.takePending();
      expect(taken.clear, throwsUnsupportedError);
      h.socket.sendBytes(Uint8List.fromList([7]));
      await h.socket.close();
      final report = await h.socket.recovery.done;
      expect(taken.single.text, 'take me');
      expect(report.unsentMessages.single.bytes, [7]);
      final late = _Socket();
      dial.complete(late);
      await _tick();
      expect(late.closeCalls, 1);
      expect(late.writes, isEmpty);
    },
  );

  test('lifetime retry budget survives successful replacements', () async {
    final next = _Socket();
    var dials = 0;
    final h = _Harness(
      reconnect: (_) async {
        dials++;
        return next;
      },
      lifetimeRetries: true,
      maxAttempts: 1,
    );
    addTearDown(h.close);
    h.initial.peerClose();
    await _tick();
    expect(h.socket.recovery.isRecovering, isFalse);
    next.peerClose(1012, 'last physical reason');
    final report = await h.socket.recovery.done;
    expect(dials, 1);
    expect(report.cause, 'exhausted');
    expect(report.code, 1012);
    expect(report.reason, 'last physical reason');
  });

  for (final failure in ['delay', 'random', 'preparation']) {
    test('$failure failure preserves original physical close facts', () async {
      final h = _Harness(
        delay: failure == 'delay'
            ? (_) => Future.error(StateError('delay'))
            : null,
        random: failure == 'random' ? () => double.nan : null,
        prepare: failure == 'preparation'
            ? (_) => throw StateError('observer')
            : null,
      );
      addTearDown(h.close);
      h.initial.peerClose(1013, 'private close reason');
      final report = await h.socket.recovery.done;
      expect(report.code, 1013);
      expect(report.reason, 'private close reason');
      expect(report.toString(), isNot(contains('private close reason')));
    });
  }

  test(
    'initial reader setup failure settles state and disposes socket',
    () async {
      final initial = _Socket()..failEvents = true;
      final h = _Harness(initial: initial);
      addTearDown(h.close);
      final report = await h.socket.recovery.done;
      await _tick();
      expect(report.cause, 'setup_failed');
      expect(initial.closeCalls, 1);
    },
  );

  test(
    'direct attempted binary failure is uncertain and never queued',
    () async {
      final h = _Harness();
      addTearDown(h.close);
      h.initial.failWrites = true;
      expect(
        () => h.socket.sendBytes(Uint8List.fromList([5])),
        throwsA(isA<WebSocketDeliveryUnknownException>()),
      );
      expect((await h.socket.recovery.done).unsentMessages, isEmpty);
    },
  );
}

Future<void> _tick() async {
  for (var i = 0; i < 8; i++) {
    await Future<void>.delayed(Duration.zero);
  }
}

class _Harness {
  _Harness({
    _Socket? initial,
    Future<ws.WebSocket> Function(WebSocketReconnectDecision)? reconnect,
    WebSocketReconnectPreparation? prepare,
    Future<void> Function(Duration)? delay,
    double Function()? random,
    void Function()? beforeFlush,
    int maxQueueBytes = 1024,
    int maxQueueMessages = 1024,
    int maxAttempts = 2,
    bool manualQueue = false,
    bool lifetimeRetries = false,
  }) : initial = initial ?? _Socket() {
    socket = ResponsesRecoveringWebSocket(
      this.initial,
      options: WebSocketReconnectOptions(
        onReconnecting:
            prepare ?? (_) => const WebSocketReconnectDecision.continueWith(),
        maxQueueBytes: maxQueueBytes,
        maxQueueMessages: maxQueueMessages,
        maxAttempts: maxAttempts,
        initialDelay: Duration.zero,
        maxDelay: Duration.zero,
      ),
      reconnect: reconnect ?? (_) async => _Socket(),
      delay: delay ?? (_) async {},
      random: random ?? () => 1,
      manualQueue: manualQueue,
      lifetimeRetries: lifetimeRetries,
      beforeFlush: beforeFlush,
    );
    subscription = socket.events.listen((_) {});
  }

  final _Socket initial;
  late final ResponsesRecoveringWebSocket socket;
  late final StreamSubscription<ws.WebSocketEvent> subscription;

  Future<void> close() async {
    await socket.close();
    await subscription.cancel();
  }
}

class _Socket implements ws.WebSocket {
  final _events = StreamController<ws.WebSocketEvent>(sync: true);
  final List<Object> writes = [];
  bool failWrites = false;
  bool failEvents = false;
  int closeCalls = 0;
  void Function(String)? onText;

  void peerClose([int code = 1006, String reason = 'interrupted']) {
    _events.add(ws.CloseReceived(code, reason));
  }

  @override
  Stream<ws.WebSocketEvent> get events {
    if (failEvents) throw StateError('Reader setup failed.');
    return _events.stream;
  }

  @override
  String get protocol => '';

  @override
  void sendText(String text) {
    if (failWrites) throw StateError('Uncertain send.');
    writes.add(text);
    onText?.call(text);
  }

  @override
  void sendBytes(Uint8List bytes) {
    if (failWrites) throw StateError('Uncertain send.');
    writes.add(Uint8List.fromList(bytes));
  }

  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    unawaited(_events.close());
  }
}
