import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:mistralai_dart/src/utils/streaming_parser.dart';
import 'package:test/test.dart';

const _deadline = Duration(seconds: 1);
final _chatRequest = ChatCompletionRequest(
  model: 'test',
  messages: [ChatMessage.user('Hi')],
);
final _routes = <String, Stream<Object> Function(MistralClient, Future<void>?)>{
  'chat': (c, a) => c.chat.createStream(request: _chatRequest, abortTrigger: a),
  'FIM': (c, a) => c.fim.createStream(
    request: const FimCompletionRequest(model: 'test', prompt: 'Hi'),
    abortTrigger: a,
  ),
  'agents': (c, a) => c.agents.completeStream(
    request: AgentCompletionRequest(
      agentId: 'a',
      messages: [ChatMessage.user('Hi')],
    ),
    abortTrigger: a,
  ),
  'speech': (c, a) => c.audio.speech.createStream(
    request: const SpeechRequest(input: 'Hi'),
    abortTrigger: a,
  ),
  'transcription': (c, a) => c.audio.transcriptions.createStream(
    request: const TranscriptionRequest(
      fileBytes: [1, 2, 3],
      fileName: 'clip.wav',
    ),
    abortTrigger: a,
  ),
  'index summary': (c, a) => c.rag.searchIndexes.generateSummary(
    indexId: 'i',
    language: SummaryLanguage.en,
    abortTrigger: a,
  ),
  'schema summary': (c, a) => c.rag.searchIndexes.generateSchemaSummary(
    indexId: 'i',
    schemaId: 's',
    language: SummaryLanguage.en,
    abortTrigger: a,
  ),
  'workflow events': (c, a) => c.workflows.events.stream(abortTrigger: a),
  'workflow executions': (c, a) =>
      c.workflows.executions.stream(executionId: 'e', abortTrigger: a),
  'execution logs': (c, a) =>
      c.workflows.executions.streamLogs(executionId: 'e', abortTrigger: a),
  'deployment logs': (c, a) =>
      c.workflows.deployments.streamLogs(name: 'd', abortTrigger: a),
};

class _Transport extends http.BaseClient {
  final requests = <http.BaseRequest>[];
  final responses = <Completer<http.StreamedResponse>>[];
  final _sent = StreamController<void>.broadcast(sync: true);
  bool closed = false;

  Future<void> waitForRequests(int count) async {
    if (requests.length >= count) return;
    await _sent.stream.firstWhere((_) => requests.length >= count);
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    requests.add(request);
    final response = Completer<http.StreamedResponse>();
    responses.add(response);
    _sent.add(null);
    return response.future;
  }

  @override
  void close() => closed = true;

  Future<void> dispose() => _sent.close();
}

class _DelayedAuth implements AuthProvider {
  final called = Completer<void>();
  final credentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() {
    called.complete();
    return credentials.future;
  }
}

Future<void> _tick() => Future<void>.delayed(Duration.zero);

void main() {
  late _Transport transport;
  late MistralClient client;

  setUp(() {
    transport = _Transport();
    client = MistralClient(
      config: const MistralConfig(
        authProvider: ApiKeyProvider('test-key'),
        sendRequestIdHeader: true,
      ),
      httpClient: transport,
    );
  });

  tearDown(() async {
    client.close();
    await transport.dispose();
  });

  for (final route in _routes.entries) {
    test(
      '${route.key} aborts before headers with native request cancellation',
      () async {
        final abort = Completer<void>();
        final result = route.value(client, abort.future).toList();
        await transport.waitForRequests(1);
        final request = transport.requests.single;
        expect(request.headers['authorization'], 'Bearer test-key');
        expect(request.headers['x-request-id'], isNotEmpty);
        final nativeAbort = (request as http.Abortable).abortTrigger!;
        abort.complete();
        await expectLater(
          result.timeout(_deadline),
          throwsA(isA<AbortedException>()),
        );
        await nativeAbort.timeout(_deadline);
        final lateCanceled = Completer<void>();
        final lateBody = StreamController<List<int>>(
          onCancel: lateCanceled.complete,
        );
        transport.responses.single.complete(
          http.StreamedResponse(lateBody.stream, 200),
        );
        await lateCanceled.future.timeout(_deadline);
        await lateBody.close();
        expect(transport.closed, isFalse);
      },
    );

    test(
      '${route.key} listener cancellation cancels an idle response body',
      () async {
        final listened = Completer<void>();
        final canceled = Completer<void>();
        final body = StreamController<List<int>>(
          onListen: listened.complete,
          onCancel: canceled.complete,
        );
        final subscription = route.value(client, null).listen((_) {});
        await transport.waitForRequests(1);
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, 200),
        );
        await listened.future;
        await subscription.cancel().timeout(_deadline);
        await canceled.future.timeout(_deadline);
        await body.close();
        expect(transport.closed, isFalse);
      },
    );
  }

  for (final name in ['chat', 'transcription']) {
    final create = _routes[name]!;
    test('$name pre-cancel prevents sending', () async {
      await expectLater(
        create(client, Future<void>.value()).toList(),
        throwsA(isA<AbortedException>()),
      );
      expect(transport.requests, isEmpty);
    });

    test(
      '$name abort during authentication does not wait for credentials',
      () async {
        final auth = _DelayedAuth();
        client.close();
        client = MistralClient(
          config: MistralConfig(authProvider: auth),
          httpClient: transport,
        );
        final abort = Completer<void>();
        final result = create(client, abort.future).toList();
        await auth.called.future;
        abort.complete();
        await expectLater(
          result.timeout(_deadline),
          throwsA(isA<AbortedException>()),
        );
        auth.credentials.completeError(StateError('late auth failure'));
        await _tick();
        expect(transport.requests, isEmpty);
      },
    );
  }

  test(
    'aborting one stream preserves concurrent stream and borrowed client',
    () async {
      final abort = Completer<void>();
      final first = _routes['chat']!(client, abort.future).toList();
      final sibling = _routes['chat']!(client, null).toList();
      await transport.waitForRequests(2);
      var siblingAborted = false;
      unawaited(
        (transport.requests.last as http.Abortable).abortTrigger!.then((_) {
          siblingAborted = true;
        }),
      );
      abort.complete();
      await expectLater(first, throwsA(isA<AbortedException>()));
      expect(siblingAborted, isFalse);
      transport.responses.last.complete(
        http.StreamedResponse(const Stream.empty(), 200),
      );
      expect(await sibling, isEmpty);
      transport.responses.first.complete(
        http.StreamedResponse(const Stream.empty(), 200),
      );
      client.close();
      expect(transport.closed, isFalse);
    },
  );

  for (final status in [200, 500]) {
    test('$status stalled body aborts promptly', () async {
      final listened = Completer<void>();
      final canceled = Completer<void>();
      final body = StreamController<List<int>>(
        onListen: listened.complete,
        onCancel: canceled.complete,
      );
      final abort = Completer<void>();
      final result = _routes['chat']!(client, abort.future).toList();
      await transport.waitForRequests(1);
      transport.responses.single.complete(
        http.StreamedResponse(body.stream, status),
      );
      await listened.future;
      abort.complete();
      await expectLater(
        result.timeout(_deadline),
        throwsA(isA<AbortedException>()),
      );
      await canceled.future.timeout(_deadline);
      await body.close();
    });

    test(
      '$status body network error terminates without a second API error',
      () async {
        final listened = Completer<void>();
        final canceled = Completer<void>();
        final body = StreamController<List<int>>(
          onListen: listened.complete,
          onCancel: canceled.complete,
        );
        final errors = <Object>[];
        final done = Completer<void>();
        _routes['chat']!(
          client,
          null,
        ).listen((_) {}, onError: errors.add, onDone: done.complete);
        await transport.waitForRequests(1);
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, status),
        );
        await listened.future;
        final failure = StateError('connection failed');
        body.addError(failure);
        await done.future.timeout(_deadline);
        await canceled.future.timeout(_deadline);
        await body.close();
        expect(errors, [same(failure)]);
      },
    );
  }

  for (final protocolDone in [false, true]) {
    test(
      'normal ${protocolDone ? '[DONE]' : 'EOF'} completion does not abort the native request',
      () async {
        final canceled = Completer<void>();
        final body = StreamController<List<int>>(onCancel: canceled.complete);
        final result = _routes['chat']!(client, null).toList();
        await transport.waitForRequests(1);
        var nativeAborted = false;
        unawaited(
          (transport.requests.single as http.Abortable).abortTrigger!.then((_) {
            nativeAborted = true;
          }),
        );
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, 200),
        );
        if (protocolDone) {
          body.add(utf8.encode('data: [DONE]\n\n'));
        } else {
          unawaited(body.close());
        }
        expect(await result.timeout(_deadline), isEmpty);
        await canceled.future.timeout(_deadline);
        await _tick();
        expect(nativeAborted, isFalse);
        await body.close();
      },
    );
  }

  for (final cancelListener in [false, true]) {
    test(
      '${cancelListener ? 'listener cancellation' : 'abort'} does not wait for transport cleanup',
      () async {
        final listened = Completer<void>();
        final cleanupStarted = Completer<void>();
        final releaseCleanup = Completer<void>();
        final body = StreamController<List<int>>(
          onListen: listened.complete,
          onCancel: () {
            cleanupStarted.complete();
            return releaseCleanup.future;
          },
        );
        final abort = Completer<void>();
        final stream = _routes['chat']!(client, abort.future);
        final subscription = cancelListener ? stream.listen((_) {}) : null;
        final result = cancelListener ? null : stream.toList();
        await transport.waitForRequests(1);
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, 200),
        );
        await listened.future;
        try {
          if (cancelListener) {
            await subscription!.cancel().timeout(_deadline);
          } else {
            abort.complete();
            await expectLater(
              result!.timeout(_deadline),
              throwsA(isA<AbortedException>()),
            );
          }
          await cleanupStarted.future.timeout(_deadline);
          expect(releaseCleanup.isCompleted, isFalse);
        } finally {
          releaseCleanup.complete();
          await body.close();
        }
      },
    );
  }

  for (final status in [200, 500]) {
    test('$status body read error survives failed transport cleanup', () async {
      final listened = Completer<void>();
      final body = StreamController<List<int>>(
        onListen: listened.complete,
        onCancel: () => Future<void>.error(StateError('cleanup failed')),
      );
      final errors = <Object>[];
      final done = Completer<void>();
      _routes['chat']!(
        client,
        null,
      ).listen((_) {}, onError: errors.add, onDone: done.complete);
      await transport.waitForRequests(1);
      transport.responses.single.complete(
        http.StreamedResponse(body.stream, status),
      );
      await listened.future;
      final failure = StateError('primary read error');
      body.addError(failure);
      await done.future.timeout(_deadline);
      await body.close();
      await _tick();
      expect(errors, [same(failure)]);
    });
  }

  test('malformed UTF-8 HTTP error body terminates with one error', () async {
    final done = Completer<void>();
    final errors = <Object>[];
    _routes['chat']!(
      client,
      null,
    ).listen((_) {}, onError: errors.add, onDone: done.complete);
    await transport.waitForRequests(1);
    transport.responses.single.complete(
      http.StreamedResponse(
        Stream.value([0xff]),
        500,
        headers: {'content-type': 'application/json'},
      ),
    );
    await done.future.timeout(_deadline);
    expect(errors, [isA<FormatException>()]);
  });

  test('abort after normal completion is ignored', () async {
    final abort = Completer<void>();
    final result = _routes['chat']!(client, abort.future).toList();
    await transport.waitForRequests(1);
    transport.responses.single.complete(
      http.StreamedResponse(const Stream.empty(), 200),
    );
    expect(await result, isEmpty);
    abort.complete();
    await _tick();
  });

  test(
    'inline error terminates and cancels the body while it is still open',
    () async {
      final canceled = Completer<void>();
      final body = StreamController<List<int>>(onCancel: canceled.complete);
      final result = _routes['chat']!(client, null).toList();
      await transport.waitForRequests(1);
      transport.responses.single.complete(
        http.StreamedResponse(body.stream, 200),
      );
      body.add(utf8.encode('event: error\ndata: Service unavailable\n\n'));
      await expectLater(
        result.timeout(_deadline),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'Service unavailable',
          ),
        ),
      );
      await canceled.future.timeout(_deadline);
      await body.close();
    },
  );

  test('pause and resume propagate to the response body', () async {
    final listened = Completer<void>();
    final paused = Completer<void>();
    final resumed = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: listened.complete,
      onPause: paused.complete,
      onResume: resumed.complete,
    );
    final subscription = _routes['chat']!(client, null).listen((_) {});
    await transport.waitForRequests(1);
    transport.responses.single.complete(
      http.StreamedResponse(body.stream, 200),
    );
    await listened.future;
    subscription.pause();
    await paused.future.timeout(_deadline);
    subscription.resume();
    await resumed.future.timeout(_deadline);
    await subscription.cancel();
    await body.close();
  });

  for (final name in ['SSE', 'SSE typed', 'NDJSON', 'NDJSON typed']) {
    test('$name parser cancellation cancels an idle source', () async {
      final canceled = Completer<void>();
      final body = StreamController<List<int>>(onCancel: canceled.complete);
      final Stream<Object> stream = switch (name) {
        'SSE typed' => parseSSEAs(body.stream, (json) => json),
        'NDJSON' => parseNDJSON(body.stream),
        'NDJSON typed' => parseNDJSONAs(body.stream, (json) => json),
        _ => parseSSE(body.stream),
      };
      final subscription = stream.listen((_) {});
      await subscription.cancel().timeout(_deadline);
      await canceled.future.timeout(_deadline);
      await body.close();
    });
  }
}
