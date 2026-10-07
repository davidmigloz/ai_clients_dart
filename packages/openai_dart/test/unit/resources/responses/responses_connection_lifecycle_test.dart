import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart';

void main() {
  group('ResponsesConnection lifecycle', () {
    test('rejects nonpositive opening buffer before starting a reader', () {
      for (final capacity in [0, -1]) {
        final socket = _Socket();
        expect(
          () => ResponsesConnection(socket, maxBufferedEvents: capacity),
          throwsArgumentError,
        );
        expect(socket.listenCount, 0);
        unawaited(socket.dispose());
      }
    });

    test(
      'sends exact create frames without mutating the HTTP request',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        const request = CreateResponseRequest(
          model: 'synthetic-model',
          input: ResponseInput.text('synthetic input'),
          stream: true,
          background: false,
          previousResponseId: 'resp_parent',
          metadata: {'test': 'offline'},
        );
        final original = request.toJson();
        connection
          ..create(request, streamId: 'lane.one', generate: false)
          ..send(const ResponsesCreateEvent(request: request));
        expect(socket.sent.length, 2);
        final first = jsonDecode(socket.sent.first) as Map<String, dynamic>;
        final expected = Map<String, dynamic>.from(original)
          ..remove('stream')
          ..remove('background')
          ..addAll({
            'type': 'response.create',
            'stream_id': 'lane.one',
            'generate': false,
          });
        expect(first, expected);
        final second = jsonDecode(socket.sent.last) as Map<String, dynamic>;
        expect(second, isNot(contains('stream_id')));
        expect(second, isNot(contains('generate')));
        expect(request.toJson(), original);
        await connection.close();
      },
    );

    test('GA rejects beta multi-agent configuration without sending', () async {
      final socket = _Socket();
      final connection = ResponsesConnection(socket);
      const request = CreateResponseRequest(
        model: 'synthetic-model',
        input: ResponseInput.text('synthetic'),
        multiAgent: MultiAgentConfig(enabled: true),
      );
      expect(() => connection.create(request), throwsArgumentError);
      expect(socket.sent, isEmpty);
      await connection.close();
      final betaSocket = _Socket();
      final beta = ResponsesConnection(betaSocket, beta: true)..create(request);
      expect(jsonDecode(betaSocket.sent.single), contains('multi_agent'));
      await beta.close();
    });

    test(
      'interleaved lanes and terminal response leave the socket usable',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        final events = <ResponsesServerEvent>[];
        final subscription = connection.events.listen(events.add);
        socket
          ..text(_future('first', lane: 'alpha'))
          ..text(_future('second', lane: 'beta'))
          ..text({
            'type': 'response.completed',
            'stream_id': 'alpha',
            'sequence_number': 3,
            'response': {
              'id': 'resp_synthetic',
              'object': 'response',
              'created_at': 0,
              'status': 'completed',
              'output': <Object?>[],
            },
          })
          ..text(_future('fourth', lane: 'beta'))
          ..text(_future('default'));
        await _tick();
        expect(events.map((e) => e.streamId), [
          'alpha',
          'beta',
          'alpha',
          'beta',
          null,
        ]);
        expect(events[2], isA<ResponsesStreamEvent>());
        expect(connection.isClosed, isFalse);
        connection.create(
          const CreateResponseRequest(
            model: 'synthetic-model',
            input: ResponseInput.text('synthetic'),
          ),
        );
        expect(socket.sent.length, 1);
        await subscription.cancel();
        await connection.close();
      },
    );

    test('request-scoped server errors do not poison other lanes', () async {
      final socket = _Socket();
      final connection = ResponsesConnection(socket);
      final events = <ResponsesServerEvent>[];
      final errors = <Object>[];
      final subscription = connection.events.listen(
        events.add,
        onError: errors.add,
      );
      final wire = {
        'type': 'error',
        'stream_id': 'bad',
        'status': 400,
        'error': {
          'type': 'invalid_request_error',
          'code': 'future_error',
          'message': 'synthetic failure',
          'param': null,
          'headers': {'x-request-id': 'req_synthetic'},
        },
      };
      socket
        ..text(wire)
        ..text(_future('good', lane: 'good'));
      await _tick();
      expect(events.first, isA<ResponsesErrorEvent>());
      expect(events.first.toJson(), wire);
      expect(events.last.streamId, 'good');
      expect(errors, isEmpty);
      expect(connection.isClosed, isFalse);
      await subscription.cancel();
      await connection.close();
    });

    test(
      'future frames preserve all raw JSON and arbitrary returned lane',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        final received = connection.events.first;
        final frame = {
          'type': 'response.future',
          'stream_id': 'server lane / not a request lane',
          'nested': {
            'array': [1, null, true],
          },
        };
        socket.text(frame);
        final event = await received;
        expect(event, isA<UnknownResponsesServerEvent>());
        expect(event.toJson(), frame);
        await connection.close();
      },
    );

    test(
      'early event and peer close survive until a late first listener',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        socket
          ..text(_future('early'))
          ..peerClose(1006, 'synthetic abnormal close');
        await connection.done.timeout(const Duration(seconds: 1));
        expect(connection.isClosed, isTrue);
        expect(connection.closeCode, 1006);
        expect(connection.closeReason, 'synthetic abnormal close');
        final events = await connection.events.toList();
        expect(events.single.toJson(), _future('early'));
        expect(socket.cancelCount, 1);
        await connection.close();
        expect(socket.closeCount, 0);
      },
    );

    test(
      'early protocol errors survive early close and remain redacted',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        socket.controller.add(TextDataReceived('{ secret invalid json'));
        socket.peerClose();
        await connection.done;
        final errors = <Object>[];
        final events = <ResponsesServerEvent>[];
        final complete = Completer<void>();
        connection.events.listen(
          events.add,
          onError: errors.add,
          onDone: complete.complete,
        );
        await complete.future;
        expect(events, isEmpty);
        expect(errors.single, isA<ResponsesProtocolException>());
        expect(errors.single.toString(), isNot(contains('secret')));
      },
    );

    test(
      'early socket failure survives close and completes without listeners',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        socket.controller.addError(
          WebSocketException('secret credential failure'),
        );
        await connection.done.timeout(const Duration(seconds: 1));
        final errors = <Object>[];
        final complete = Completer<void>();
        connection.events.listen(
          (_) {},
          onError: errors.add,
          onDone: complete.complete,
        );
        await complete.future;
        expect(errors.single, isA<ResponsesTransportException>());
        expect(errors.single.toString(), isNot(contains('secret')));
        expect(socket.closeCount, 1);
        expect(socket.cancelCount, 1);
      },
    );

    test('overflow preserves prefix then reports failure and closes', () async {
      final socket = _Socket();
      final connection = ResponsesConnection(socket, maxBufferedEvents: 2);
      socket
        ..text(_future('one'))
        ..text(_future('two'))
        ..text(_future('three'));
      await connection.done.timeout(const Duration(seconds: 1));
      final events = <ResponsesServerEvent>[];
      final errors = <Object>[];
      final complete = Completer<void>();
      connection.events.listen(
        events.add,
        onError: errors.add,
        onDone: complete.complete,
      );
      await complete.future;
      expect(events.map((e) => e.toJson()['marker']), ['one', 'two']);
      expect(errors.single, isA<ResponsesEventBufferOverflowException>());
      expect(
        (errors.single as ResponsesEventBufferOverflowException)
            .maxBufferedEvents,
        2,
      );
      expect(socket.closeCount, 1);
    });

    test(
      'errors share the bounded opening buffer with ordinary events',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket, maxBufferedEvents: 1);
        socket.controller.add(TextDataReceived('[]'));
        socket.text(_future('overflow'));
        await connection.done;
        final errors = <Object>[];
        final complete = Completer<void>();
        connection.events.listen(
          (_) {},
          onError: errors.add,
          onDone: complete.complete,
        );
        await complete.future;
        expect(errors, [
          isA<ResponsesProtocolException>(),
          isA<ResponsesEventBufferOverflowException>(),
        ]);
      },
    );

    test(
      'protocol failures are identifiable and a valid later frame still arrives',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        final errors = <Object>[];
        final events = <ResponsesServerEvent>[];
        final subscription = connection.events.listen(
          events.add,
          onError: errors.add,
        );
        socket.controller.add(BinaryDataReceived(Uint8List.fromList([1, 2])));
        socket.controller.add(TextDataReceived('{ secret payload'));
        socket.controller.add(TextDataReceived('["secret"]'));
        socket
          ..text({
            'type': 'error',
            'error': {'message': 'secret'},
          })
          ..text(_future('valid'));
        await _tick();
        expect(
          errors.whereType<ResponsesProtocolException>().map((e) => e.kind),
          ['binary', 'invalid_json', 'non_object', 'invalid_event'],
        );
        expect(
          errors.map((e) => e.toString()).join(),
          isNot(contains('secret')),
        );
        expect(events.single.type, 'response.future');
        expect(connection.isClosed, isFalse);
        await subscription.cancel();
        await connection.close();
      },
    );

    test(
      'broadcast cancellation is local and later subscribers get no replay',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        final first = <ResponsesServerEvent>[];
        final second = <ResponsesServerEvent>[];
        final firstSub = connection.events.listen(first.add);
        final secondSub = connection.events.listen(second.add);
        socket.text(_future('both'));
        await _tick();
        await firstSub.cancel();
        socket.text(_future('second'));
        await _tick();
        expect(first.length, 1);
        expect(second.length, 2);
        expect(socket.cancelCount, 0);
        await secondSub.cancel();
        socket.text(_future('no listener'));
        await _tick();
        final third = <ResponsesServerEvent>[];
        final thirdSub = connection.events.listen(third.add);
        socket.text(_future('third'));
        await _tick();
        expect(third.single.toJson()['marker'], 'third');
        expect(connection.isClosed, isFalse);
        await thirdSub.cancel();
        await connection.close();
      },
    );

    test(
      'paused listener never delays transport done or close completion',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        final subscription = connection.events.listen((_) {})..pause();
        socket.text(_future('pending'));
        await connection.close().timeout(const Duration(seconds: 1));
        await connection.done.timeout(const Duration(seconds: 1));
        expect(connection.isClosed, isTrue);
        await subscription.cancel();
      },
    );

    test(
      'concurrent and repeated close call socket once and capture peer facts',
      () async {
        final socket = _Socket(holdClose: true);
        final connection = ResponsesConnection(socket);
        final first = connection.close(3001, 'synthetic caller reason');
        final second = connection.close(3002, 'ignored concurrent reason');
        expect(identical(first, second), isTrue);
        expect(connection.isClosed, isTrue);
        expect(
          () => connection.create(
            const CreateResponseRequest(
              model: 'x',
              input: ResponseInput.text('synthetic'),
            ),
          ),
          throwsStateError,
        );
        socket.peerClose(1011, 'observed peer reason');
        socket.closeGate.complete();
        await first;
        await connection.close();
        expect(socket.closeCount, 1);
        expect(connection.closeCode, 1011);
        expect(connection.closeReason, 'observed peer reason');
        expect(connection.toString(), isNot(contains('observed peer reason')));
      },
    );

    test(
      'socket close failure always tears down reader and completes done',
      () async {
        final socket = _Socket(failClose: true);
        final connection = ResponsesConnection(socket);
        final errors = <Object>[];
        final subscription = connection.events.listen(
          (_) {},
          onError: errors.add,
        );
        await expectLater(
          connection.close(),
          throwsA(isA<ResponsesTransportException>()),
        );
        await connection.done.timeout(const Duration(seconds: 1));
        await _tick();
        expect(socket.cancelCount, 1);
        expect(errors.single.toString(), isNot(contains('secret')));
        expect(connection.isClosed, isTrue);
        await subscription.cancel();
        await socket.dispose();
      },
    );

    test(
      'send failure is redacted, ends transport, and future sends fail',
      () async {
        final socket = _Socket(failSend: true);
        final connection = ResponsesConnection(socket);
        expect(
          () => connection.create(
            const CreateResponseRequest(
              model: 'x',
              input: ResponseInput.text('synthetic'),
            ),
          ),
          throwsA(isA<ResponsesTransportException>()),
        );
        await connection.done;
        final errors = <Object>[];
        final complete = Completer<void>();
        connection.events.listen(
          (_) {},
          onError: errors.add,
          onDone: complete.complete,
        );
        await complete.future;
        expect(errors.single.toString(), isNot(contains('secret')));
        expect(
          () => connection.create(
            const CreateResponseRequest(
              model: 'x',
              input: ResponseInput.text('synthetic'),
            ),
          ),
          throwsStateError,
        );
        expect(socket.closeCount, 1);
      },
    );

    test(
      'a reason without a code sends normal closure and retains reason',
      () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        await connection.close(null, 'synthetic reason');
        expect(socket.lastCode, 1000);
        expect(socket.lastReason, 'synthetic reason');
        expect(connection.closeCode, 1000);
        expect(connection.closeReason, 'synthetic reason');
      },
    );

    for (final code in [1000, 3000, 4999]) {
      test('accepts caller close code $code', () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        await connection.close(code);
        expect(socket.lastCode, code);
      });
    }
    for (final code in [999, 1001, 1006, 2999, 5000]) {
      test('rejects caller close code $code before closing', () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        expect(() => connection.close(code), throwsArgumentError);
        expect(connection.isClosed, isFalse);
        expect(socket.closeCount, 0);
        await connection.close();
      });
    }
    for (final reason in ['a' * 123, '${'😀' * 30}abc']) {
      test('accepts close reason at 123 UTF-8 bytes', () async {
        final socket = _Socket();
        final connection = ResponsesConnection(socket);
        await connection.close(1000, reason);
        expect(socket.lastReason, reason);
      });
    }
    for (final reason in ['a' * 124, '😀' * 31]) {
      test(
        'rejects close reason over 123 UTF-8 bytes without disclosure',
        () async {
          final socket = _Socket();
          final connection = ResponsesConnection(socket);
          expect(() => connection.close(1000, reason), throwsArgumentError);
          expect(socket.closeCount, 0);
          await connection.close();
        },
      );
    }
  });
}

Map<String, dynamic> _future(String marker, {String? lane}) => {
  'type': 'response.future',
  'marker': marker,
  'stream_id': ?lane,
};

Future<void> _tick() => Future<void>.delayed(Duration.zero);

class _Socket implements WebSocket {
  _Socket({
    this.holdClose = false,
    this.failClose = false,
    this.failSend = false,
  }) {
    controller = StreamController<WebSocketEvent>(
      sync: true,
      onListen: () => listenCount++,
      onCancel: () => cancelCount++,
    );
  }

  final bool holdClose;
  final bool failClose;
  final bool failSend;
  late final StreamController<WebSocketEvent> controller;
  final Completer<void> closeGate = Completer();
  final List<String> sent = [];
  int listenCount = 0;
  int cancelCount = 0;
  int closeCount = 0;
  int? lastCode;
  String? lastReason;

  void text(Map<String, dynamic> json) =>
      controller.add(TextDataReceived(jsonEncode(json)));

  void peerClose([int? code = 1000, String reason = '']) {
    controller.add(CloseReceived(code, reason));
  }

  Future<void> dispose() => controller.close();

  @override
  Stream<WebSocketEvent> get events => controller.stream;

  @override
  String get protocol => '';

  @override
  void sendText(String text) {
    if (failSend) throw WebSocketException('secret send failure');
    sent.add(text);
  }

  @override
  void sendBytes(Uint8List bytes) => throw UnimplementedError();

  @override
  Future<void> close([int? code, String? reason]) async {
    closeCount++;
    lastCode = code;
    lastReason = reason;
    if (failClose) throw WebSocketException('secret close failure');
    if (holdClose) {
      await closeGate.future;
    } else {
      peerClose(code ?? 1000, reason ?? '');
    }
    await controller.close();
  }
}
