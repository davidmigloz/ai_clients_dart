import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';
import 'package:web_socket/web_socket.dart' as ws;

const _request = CreateResponseRequest(
  model: 'gpt-6-sol',
  input: ResponseInput.text('Offline recovery fixture'),
);

ResponsesReconnectOptions _options({
  ResponsesReconnectPreparation? prepare,
  int maxAttempts = 5,
  int maxQueueBytes = 1048576,
}) => ResponsesReconnectOptions(
  onReconnecting:
      prepare ?? (_) => const ResponsesReconnectDecision.continueWith(),
  maxAttempts: maxAttempts,
  initialDelay: Duration.zero,
  maxDelay: Duration.zero,
  maxQueueBytes: maxQueueBytes,
);

void main() {
  test('default public connection never reconnects', () async {
    final client = OpenAIClient();
    final socket = _Socket();
    var dials = 0;
    final connection = await client.responses.connect(
      connector: (uri, {headers}) async {
        dials++;
        return socket;
      },
    );
    addTearDown(client.close);
    addTearDown(connection.close);
    expect(connection.recovery, isNull);
    socket.peerClose(1006);
    await connection.done;
    expect(dials, 1);
    expect(connection.closeCode, 1006);
  });

  test('old public connect tear-off remains assignable', () async {
    final client = OpenAIClient();
    addTearDown(client.close);
    final Future<ResponsesConnection> Function({
      bool beta,
      ResponsesWebSocketConnector? connector,
      Map<String, String>? additionalHeaders,
      Duration? connectionTimeout,
      int maxBufferedEvents,
    })
    open = client.responses.connect;
    final connection = await open(
      connector: (uri, {headers}) async => _Socket(),
    );
    expect(connection.recovery, isNull);
    await connection.close();
  });

  for (final options in [
    _options(maxAttempts: -1),
    _options(maxQueueBytes: -1),
    _options().copyWith(initialDelay: const Duration(microseconds: -1)),
    _options().copyWith(maxDelay: const Duration(microseconds: -1)),
  ]) {
    test('invalid recovery option rejects synchronously before auth', () {
      final auth = _Auth();
      final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
      addTearDown(client.close);
      var dials = 0;
      expect(
        () => client.responses.connect(
          reconnect: options,
          connector: (uri, {headers}) async {
            dials++;
            return _Socket();
          },
        ),
        throwsArgumentError,
      );
      expect(auth.calls, 0);
      expect(dials, 0);
    });
  }

  test('zero attempts opts out of recovery dialing', () async {
    final client = OpenAIClient();
    final socket = _Socket();
    var dials = 0;
    var hooks = 0;
    final connection = await client.responses.connect(
      reconnect: _options(
        maxAttempts: 0,
        prepare: (_) {
          hooks++;
          return const ResponsesReconnectDecision.continueWith();
        },
      ),
      connector: (uri, {headers}) async {
        dials++;
        return socket;
      },
    );
    addTearDown(client.close);
    addTearDown(connection.close);
    socket.peerClose(1006);
    final report = await connection.recovery!.done;
    await connection.done;
    expect(report.code, 1006);
    expect(dials, 1);
    expect(hooks, 0);
  });

  test(
    'fresh auth and replace/retain/clear decisions apply per dial',
    () async {
      final auth = _Auth();
      final client = OpenAIClient(
        config: OpenAIConfig(
          baseUrl: 'https://example.invalid/proxy/v1?k=a&k=b&same=base',
          authProvider: auth,
          defaultHeaders: const {
            'X-Default': 'default',
            'Authorization': 'old',
          },
          organization: 'organization',
          project: 'project',
          apiVersion: 'version',
        ),
      );
      final initial = _Socket();
      final successor = _Socket();
      final urls = <Uri>[];
      final requests = <Map<String, String>>[];
      final contexts = <ResponsesReconnectContext>[];
      final connection = await client.responses.connect(
        beta: true,
        additionalHeaders: const {
          'Authorization': 'initial',
          'X-User': 'first',
        },
        reconnect: _options(
          prepare: (context) {
            contexts.add(context);
            return switch (context.attempt) {
              1 => const ResponsesReconnectDecision.continueWith(
                headers: {
                  'aUtHoRiZaTiOn': 'refreshed',
                  'x-user': 'replacement',
                  'OpenAI-Beta': 'cannot override',
                },
                queryParameters: {'same': 'attempt', 'new': 'value'},
              ),
              2 => const ResponsesReconnectDecision.continueWith(),
              _ => const ResponsesReconnectDecision.continueWith(
                headers: {},
                queryParameters: {},
              ),
            };
          },
        ),
        connector: (uri, {headers}) async {
          urls.add(uri);
          requests.add(headers!);
          if (urls.length == 1) return initial;
          if (urls.length < 4) {
            throw StateError('secret credential in failed handshake');
          }
          return successor;
        },
      );
      addTearDown(client.close);
      addTearDown(connection.close);
      initial.peerClose(1006, 'private disconnect');
      await _until(
        () => connection.recovery!.lastEvent is ResponsesRecoveryReconnected,
      );
      expect(contexts.map((c) => c.attempt), [1, 2, 3]);
      expect(auth.calls, 4);
      expect(
        urls.every((u) => u.scheme == 'wss' && u.path == '/proxy/v1/responses'),
        isTrue,
      );
      expect(urls[0].queryParametersAll, {
        'k': ['a', 'b'],
        'same': ['base'],
      });
      for (final index in [1, 2]) {
        expect(urls[index].queryParametersAll, {
          'k': ['a', 'b'],
          'same': ['attempt'],
          'new': ['value'],
        });
        expect(requests[index]['authorization'], 'refreshed');
        expect(requests[index]['x-user'], 'replacement');
      }
      expect(urls[3].queryParametersAll, {
        'k': ['a', 'b'],
        'same': ['base'],
      });
      expect(requests[0]['authorization'], 'initial');
      expect(requests[3]['authorization'], 'Bearer token-4');
      expect(requests[3].containsKey('x-user'), isFalse);
      for (final headers in requests) {
        expect(headers['openai-beta'], 'responses_multi_agent=v1');
        expect(headers['openai-organization'], 'organization');
        expect(headers['openai-project'], 'project');
        expect(headers['openai-version'], 'version');
        expect(headers['x-default'], 'default');
        expect(headers.containsKey('content-type'), isFalse);
        expect(headers.containsKey('x-client-request-id'), isFalse);
        expect(() => headers['mutable'] = 'no', throwsUnsupportedError);
      }
    },
  );

  test(
    'sync preparation map snapshots precede caller microtask mutation',
    () async {
      final client = OpenAIClient();
      final initial = _Socket();
      final successor = _Socket();
      final query = {'stable': 'before'};
      final headers = {'X-State': 'before'};
      Uri? reopenedUrl;
      Map<String, String>? reopenedHeaders;
      var dials = 0;
      final connection = await client.responses.connect(
        reconnect: _options(
          prepare: (_) {
            scheduleMicrotask(() {
              query['stable'] = 'after';
              headers['X-State'] = 'after';
            });
            return ResponsesReconnectDecision.continueWith(
              headers: headers,
              queryParameters: query,
            );
          },
        ),
        connector: (uri, {headers}) async {
          if (++dials == 1) return initial;
          reopenedUrl = uri;
          reopenedHeaders = headers;
          return successor;
        },
      );
      addTearDown(client.close);
      addTearDown(connection.close);
      initial.peerClose(1006);
      await _until(
        () => connection.recovery!.lastEvent is ResponsesRecoveryReconnected,
      );
      expect(query['stable'], 'after');
      expect(reopenedUrl!.queryParameters['stable'], 'before');
      expect(reopenedHeaders!['x-state'], 'before');
    },
  );

  test(
    'public create and steer queue snapshots then flush FIFO without replay',
    () async {
      final client = OpenAIClient();
      final initial = _Socket();
      final successor = _Socket();
      final preparation = Completer<ResponsesReconnectDecision>();
      var dials = 0;
      final connection = await client.responses.connect(
        beta: true,
        reconnect: _options(prepare: (_) => preparation.future),
        connector: (uri, {headers}) async => ++dials == 1 ? initial : successor,
      );
      addTearDown(client.close);
      addTearDown(connection.close);
      connection
        ..create(_request)
        ..steer(
          previousResponseId: 'sent',
          input: const ResponsesSteerInput.text('already sent'),
        );
      initial.peerClose(1006);
      await _until(() => connection.recovery!.isRecovering);
      final metadata = <String, String>{'unicode': '界😀'};
      connection
        ..create(_request.copyWith(metadata: metadata))
        ..steer(
          previousResponseId: 'caller-reconciled',
          input: const ResponsesSteerInput.text('new unsent'),
        );
      metadata['unicode'] = 'mutated';
      expect(connection.recovery!.queuedMessages, 2);
      preparation.complete(const ResponsesReconnectDecision.continueWith());
      await _until(
        () => connection.recovery!.lastEvent is ResponsesRecoveryReconnected,
      );
      expect(initial.sent, hasLength(2));
      expect(successor.sent, hasLength(2));
      expect((jsonDecode(successor.sent[0]) as Map)['metadata'], {
        'unicode': '界😀',
      });
      expect(
        (jsonDecode(successor.sent[1]) as Map)['previous_response_id'],
        'caller-reconciled',
      );
      expect(successor.sent.join(), isNot(contains('already sent')));
      expect(connection.recovery!.queuedBytes, 0);
      expect(connection.recovery!.queuedMessages, 0);
    },
  );

  test('public overflow rejects new frame and preserves recovery', () async {
    final client = OpenAIClient();
    final initial = _Socket();
    final pending = Completer<ResponsesReconnectDecision>();
    final connection = await client.responses.connect(
      reconnect: _options(maxQueueBytes: 0, prepare: (_) => pending.future),
      connector: (uri, {headers}) async => initial,
    );
    addTearDown(client.close);
    addTearDown(connection.close);
    initial.peerClose(1006);
    await _until(() => connection.recovery!.isRecovering);
    expect(
      () => connection.create(_request),
      throwsA(isA<ResponsesSendQueueOverflowException>()),
    );
    expect(connection.isClosed, isFalse);
    expect(
      connection.recovery!.lastEvent,
      isA<ResponsesRecoveryQueueOverflow>(),
    );
    expect(connection.recovery!.queuedMessages, 0);
    await connection.close();
    pending.completeError(StateError('late private preparation failure'));
    await _turn();
    expect((await connection.recovery!.done).unsentMessages, isEmpty);
  });

  test(
    'close while async preparation waits never refreshes or dials',
    () async {
      final auth = _Auth();
      final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
      final initial = _Socket();
      final pending = Completer<ResponsesReconnectDecision>();
      var dials = 0;
      final connection = await client.responses.connect(
        reconnect: _options(prepare: (_) => pending.future),
        connector: (uri, {headers}) async {
          dials++;
          return initial;
        },
      );
      addTearDown(client.close);
      addTearDown(connection.close);
      initial.peerClose(1006);
      await _until(() => connection.recovery!.isRecovering);
      await connection.close().timeout(const Duration(seconds: 1));
      await connection.done;
      expect((await connection.recovery!.done).cause, 'explicit_close');
      pending.complete(const ResponsesReconnectDecision.continueWith());
      await _turn();
      expect(auth.calls, 1);
      expect(dials, 1);
    },
  );

  for (final succeeds in [true, false]) {
    test(
      'close during handshake consumes late outcome success=$succeeds',
      () async {
        final client = OpenAIClient();
        final initial = _Socket();
        final late = _Socket();
        final pending = Completer<ws.WebSocket>();
        var dials = 0;
        final connection = await client.responses.connect(
          reconnect: _options(),
          connector: (uri, {headers}) async =>
              ++dials == 1 ? initial : pending.future,
        );
        addTearDown(client.close);
        addTearDown(connection.close);
        initial.peerClose(1006);
        await _until(() => dials == 2);
        final metadata = <String, String>{'message': '界😀'};
        connection.create(_request.copyWith(metadata: metadata));
        metadata['message'] = 'after';
        await connection.close().timeout(const Duration(seconds: 1));
        final report = await connection.recovery!.done;
        await connection.done;
        expect(report.cause, 'explicit_close');
        expect(connection.closeCode, report.code);
        expect(report.unsentMessages, hasLength(1));
        final unsent = report.unsentMessages.single;
        expect(unsent.message['type'], 'response.create');
        expect(unsent.message['metadata'], {'message': '界😀'});
        expect(unsent.byteLength, utf8.encode(unsent.text).length);
        expect(report.unsentMessages.clear, throwsUnsupportedError);
        if (succeeds) {
          pending.complete(late);
        } else {
          pending.completeError(StateError('late secret handshake failure'));
        }
        await _until(() => !succeeds || late.closeCalls == 1);
        await _turn();
        expect(late.sent, isEmpty);
        expect(dials, 2);
        expect(connection.recovery!.closed, same(report));
      },
    );
  }

  test(
    'closed client prevents hook and future auth but leaves socket caller-owned',
    () async {
      final auth = _Auth();
      final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
      final initial = _Socket();
      var hooks = 0;
      var dials = 0;
      final connection = await client.responses.connect(
        reconnect: _options(
          prepare: (_) {
            hooks++;
            return const ResponsesReconnectDecision.continueWith();
          },
        ),
        connector: (uri, {headers}) async {
          dials++;
          return initial;
        },
      );
      addTearDown(connection.close);
      client.close();
      expect(initial.closeCalls, 0);
      connection.create(_request);
      initial.peerClose(1006);
      expect((await connection.recovery!.done).cause, 'preparation_failed');
      await connection.done;
      expect(initial.sent, hasLength(1));
      expect(hooks, 0);
      expect(auth.calls, 1);
      expect(dials, 1);
    },
  );

  test(
    'recovery handshake timeout inherits public connection timeout and disposes late socket',
    () async {
      final auth = _Auth();
      final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
      final initial = _Socket();
      final late = _Socket();
      final pending = Completer<ws.WebSocket>();
      var dials = 0;
      final connection = await client.responses.connect(
        connectionTimeout: const Duration(milliseconds: 20),
        reconnect: _options(maxAttempts: 1),
        connector: (uri, {headers}) async =>
            ++dials == 1 ? initial : pending.future,
      );
      addTearDown(client.close);
      addTearDown(connection.close);
      initial.peerClose(1006);
      final report = await connection.recovery!.done;
      await connection.done;
      expect(report.cause, 'exhausted');
      expect(auth.calls, 2);
      expect(dials, 2);
      pending.complete(late);
      await _until(() => late.closeCalls == 1);
      expect(late.sent, isEmpty);
    },
  );
}

Future<void> _turn() => Future<void>.delayed(Duration.zero);

Future<void> _until(bool Function() condition) async {
  for (var attempt = 0; attempt < 2000; attempt++) {
    if (condition()) return;
    await _turn();
  }
  fail('Offline recovery condition did not arrive');
}

class _Auth implements AuthProvider {
  int calls = 0;
  @override
  Map<String, String> getHeaders() => {
    'Authorization': 'Bearer token-${++calls}',
  };
}

class _Socket implements ws.WebSocket {
  final StreamController<ws.WebSocketEvent> _events = StreamController();
  final List<String> sent = [];
  int closeCalls = 0;

  void peerClose(int? code, [String reason = '']) =>
      _events.add(ws.CloseReceived(code, reason));
  @override
  Stream<ws.WebSocketEvent> get events => _events.stream;
  @override
  String get protocol => '';
  @override
  void sendText(String text) => sent.add(text);
  @override
  void sendBytes(Uint8List bytes) =>
      throw UnsupportedError('text fixtures only');
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    if (!_events.isClosed) {
      _events.add(ws.CloseReceived(code ?? 1000, reason ?? ''));
      unawaited(_events.close());
    }
  }
}
