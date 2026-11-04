import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:googleai_dart/src/client/interceptor_chain.dart';
import 'package:googleai_dart/src/client/request_builder.dart';
import 'package:googleai_dart/src/resources/base_resource.dart';
import 'package:googleai_dart/src/resources/streaming_resource.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

class PendingRequest {
  final http.BaseRequest request;
  final response = Completer<http.StreamedResponse>();
  PendingRequest(this.request);
}

class PendingTransport extends http.BaseClient {
  final sent = StreamController<PendingRequest>.broadcast(sync: true);
  final requests = <PendingRequest>[];
  int closeCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final pending = PendingRequest(request);
    requests.add(pending);
    sent.add(pending);
    return pending.response.future;
  }

  @override
  void close() => closeCount++;

  Future<void> dispose() async {
    for (final pending in requests) {
      if (!pending.response.isCompleted) {
        pending.response.complete(
          http.StreamedResponse(const Stream.empty(), 200),
        );
      }
    }
    await sent.close();
  }
}

class DelayedAuth implements AuthProvider {
  final started = Completer<void>();
  final credentials = Completer<AuthCredentials>();
  @override
  Future<AuthCredentials> getCredentials() {
    started.complete();
    return credentials.future;
  }
}

class TestResource extends ResourceBase with StreamingResource {
  TestResource(http.Client client)
    : super(
        config: const GoogleAIConfig(),
        httpClient: client,
        interceptorChain: InterceptorChain(
          interceptors: [],
          httpClient: client,
        ),
        requestBuilder: const RequestBuilder(config: GoogleAIConfig()),
      );
}

const deadline = Duration(seconds: 2);
const generationRequest = GenerateContentRequest(
  contents: [
    Content(parts: [TextPart('Hi')], role: 'user'),
  ],
);

Stream<dynamic> startStream(
  GoogleAIClient client,
  String endpoint, {
  Future<void>? abortTrigger,
}) => switch (endpoint) {
  'model' => client.models.streamGenerateContent(
    model: 'test',
    request: generationRequest,
    abortTrigger: abortTrigger,
  ),
  'dynamic' => client.models.dynamicStreamGenerateContent(
    dynamicId: 'test',
    request: generationRequest,
    abortTrigger: abortTrigger,
  ),
  'tuned' => client.tunedModels.streamGenerateContent(
    tunedModel: 'test',
    request: generationRequest,
    abortTrigger: abortTrigger,
  ),
  'interaction' => client.interactions.createStream(
    model: 'test',
    abortTrigger: abortTrigger,
  ),
  _ => client.interactions.resumeStream('test', abortTrigger: abortTrigger),
};

void main() {
  late PendingTransport transport;
  late GoogleAIClient client;
  setUp(() {
    transport = PendingTransport();
    client = GoogleAIClient(httpClient: transport);
  });
  tearDown(() async {
    client.close();
    await transport.dispose();
  });

  for (final endpoint in [
    'model',
    'dynamic',
    'tuned',
    'interaction',
    'resume',
  ]) {
    test(
      '$endpoint aborts before headers without closing a borrowed client',
      () async {
        final sent = transport.sent.stream.first;
        final abort = Completer<void>();
        final result = startStream(
          client,
          endpoint,
          abortTrigger: abort.future,
        ).toList();
        final pending = await sent;
        final nativeAbort = (pending.request as http.Abortable).abortTrigger!;
        final aborted = expectLater(result, throwsA(isA<AbortedException>()));
        abort.complete();
        await aborted.timeout(deadline);
        await nativeAbort.timeout(deadline);
        expect(transport.closeCount, 0);
      },
    );

    test(
      '$endpoint idle listener cancellation reaches the transport',
      () async {
        final sent = transport.sent.stream.first;
        final subscription = startStream(client, endpoint).listen((_) {});
        final pending = await sent;
        await subscription.cancel().timeout(deadline);
        await (pending.request as http.Abortable).abortTrigger!.timeout(
          deadline,
        );
        expect(transport.closeCount, 0);
      },
    );
  }

  for (final status in [200, 400]) {
    test(
      'abort releases a stalled $status response body and preserves a sibling',
      () async {
        final sent = transport.sent.stream.first;
        final abort = Completer<void>();
        final result = startStream(
          client,
          'model',
          abortTrigger: abort.future,
        ).toList();
        final pending = await sent;
        final bodyStarted = Completer<void>();
        final bodyCanceled = Completer<void>();
        final body = StreamController<List<int>>(
          onListen: bodyStarted.complete,
          onCancel: bodyCanceled.complete,
        );
        pending.response.complete(http.StreamedResponse(body.stream, status));
        await bodyStarted.future;
        // An incomplete UTF-8 sequence/SSE frame must not delay cancellation.
        body.add([0xe2]);
        final siblingSent = transport.sent.stream.first;
        final sibling = startStream(client, 'model').toList();
        final other = await siblingSent;
        var siblingAborted = false;
        unawaited(
          (other.request as http.Abortable).abortTrigger!.then((_) {
            siblingAborted = true;
          }),
        );
        final aborted = expectLater(result, throwsA(isA<AbortedException>()));
        abort.complete();
        await aborted.timeout(deadline);
        await bodyCanceled.future.timeout(deadline);
        expect(siblingAborted, isFalse);
        other.response.complete(
          http.StreamedResponse(const Stream.empty(), 200),
        );
        expect(await sibling, isEmpty);
        expect(transport.closeCount, 0);
        await body.close();
      },
    );
  }

  test('listener cancellation releases an idle response body', () async {
    final sent = transport.sent.stream.first;
    final subscription = startStream(client, 'model').listen((_) {});
    final pending = await sent;
    final started = Completer<void>();
    final canceled = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: started.complete,
      onCancel: canceled.complete,
    );
    pending.response.complete(http.StreamedResponse(body.stream, 200));
    await started.future;
    await subscription.cancel().timeout(deadline);
    await canceled.future.timeout(deadline);
    await body.close();
  });

  for (final cancelListener in [false, true]) {
    test(
      'cancellation during authentication prevents a later send ($cancelListener)',
      () async {
        final auth = DelayedAuth();
        client.close();
        client = GoogleAIClient(
          config: GoogleAIConfig(authProvider: auth),
          httpClient: transport,
        );
        final abort = Completer<void>();
        final stream = startStream(client, 'model', abortTrigger: abort.future);
        final subscription = stream.listen((_) {}, onError: (Object _) {});
        final done = Completer<void>();
        subscription.onDone(done.complete);
        await auth.started.future;
        if (cancelListener) {
          await subscription.cancel().timeout(deadline);
        } else {
          abort.complete();
          await done.future.timeout(deadline);
        }
        auth.credentials.complete(const NoAuthCredentials());
        await Future<void>.delayed(Duration.zero);
        expect(transport.requests, isEmpty);
      },
    );
  }

  test(
    'pre-cancellation prevents sending and late authentication errors are handled',
    () async {
      final auth = DelayedAuth();
      client.close();
      client = GoogleAIClient(
        config: GoogleAIConfig(authProvider: auth),
        httpClient: transport,
      );
      await expectLater(
        startStream(client, 'model', abortTrigger: Future.value()).toList(),
        throwsA(isA<AbortedException>()),
      );
      auth.credentials.completeError(StateError('late credential failure'));
      await Future<void>.delayed(Duration.zero);
      expect(transport.requests, isEmpty);
    },
  );

  test(
    'a late response after cancellation is canceled when native abort is unsupported',
    () async {
      final sent = transport.sent.stream.first;
      final subscription = startStream(client, 'model').listen((_) {});
      final pending = await sent;
      await subscription.cancel().timeout(deadline);
      final canceled = Completer<void>();
      final body = StreamController<List<int>>(onCancel: canceled.complete);
      pending.response.complete(http.StreamedResponse(body.stream, 200));
      await canceled.future.timeout(deadline);
      await body.close();
    },
  );

  test(
    'pausing before headers propagates backpressure and resume preserves events',
    () async {
      final sent = transport.sent.stream.first;
      final events = <dynamic>[];
      final done = Completer<void>();
      final subscription = startStream(
        client,
        'model',
      ).listen(events.add, onDone: done.complete);
      final pending = await sent;
      subscription.pause();
      final started = Completer<void>();
      final paused = Completer<void>();
      final resumed = Completer<void>();
      final body = StreamController<List<int>>(
        onListen: started.complete,
        onPause: () {
          if (!paused.isCompleted) paused.complete();
        },
        onResume: () {
          if (!resumed.isCompleted) resumed.complete();
        },
      );
      pending.response.complete(http.StreamedResponse(body.stream, 200));
      // A paused parser may defer subscribing to the body until resumed.
      await Future<void>.delayed(Duration.zero);
      body.add(utf8.encode('data: {}\n\n'));
      await Future<void>.delayed(Duration.zero);
      expect(events, isEmpty);
      subscription.resume();
      await started.future.timeout(deadline);
      await Future<void>.delayed(Duration.zero);
      subscription.pause();
      await paused.future.timeout(deadline);
      subscription.resume();
      await resumed.future.timeout(deadline);
      await body.close();
      await done.future.timeout(deadline);
      expect(events, hasLength(1));
      await subscription.cancel();
    },
  );

  test('[DONE] releases the body without requiring socket closure', () async {
    final sent = transport.sent.stream.first;
    final result = startStream(client, 'model').toList();
    final pending = await sent;
    final canceled = Completer<void>();
    final body = StreamController<List<int>>(onCancel: canceled.complete);
    pending.response.complete(http.StreamedResponse(body.stream, 200));
    body.add(utf8.encode('data: {}\n\ndata: [DONE]\n\n'));
    expect(await result.timeout(deadline), hasLength(1));
    await canceled.future.timeout(deadline);
    await body.close();
  });

  for (final failure in [
    'transport',
    'body',
    'decoder',
    'converter',
    'inline',
    'http',
  ]) {
    test(
      '$failure errors terminate listeners and release active transport',
      () async {
        final sent = transport.sent.stream.first;
        final errors = <Object>[];
        final done = Completer<void>();
        startStream(
          client,
          'model',
        ).listen((_) {}, onError: errors.add, onDone: done.complete);
        final pending = await sent;
        final canceled = Completer<void>();
        final body = StreamController<List<int>>(onCancel: canceled.complete);
        if (failure == 'transport') {
          pending.response.completeError(StateError('transport failure'));
        } else {
          pending.response.complete(
            http.StreamedResponse(body.stream, failure == 'http' ? 401 : 200),
          );
          switch (failure) {
            case 'body':
              body.addError(StateError('body failure'));
            case 'decoder':
              body.add([0xff]);
            case 'converter':
              body.add(utf8.encode('data: {"candidates":"invalid"}\n\n'));
            case 'inline':
              body.add(
                utf8.encode(
                  'event: error\ndata: {"error":{"message":"failed"}}\n\n',
                ),
              );
            case 'http':
              body.add(utf8.encode('{"error":{"message":"denied"}}'));
              unawaited(body.close());
          }
        }
        await done.future.timeout(deadline);
        expect(errors, hasLength(1));
        if (failure == 'inline') expect(errors.single, isA<StreamException>());
        if (failure == 'http') {
          expect(errors.single, isA<AuthenticationException>());
        }
        await (pending.request as http.Abortable).abortTrigger!.timeout(
          deadline,
        );
        if (failure != 'transport') await canceled.future.timeout(deadline);
        if (failure != 'transport') await body.close();
      },
    );
  }

  test('the standalone monitor aborts despite slow source cleanup', () async {
    final source = StreamController<Map<String, dynamic>>(
      onCancel: () => Completer<void>().future,
    );
    final abort = Completer<void>();
    final result = TestResource(transport)
        .streamWithAbortMonitoring(
          source: source.stream,
          abortTrigger: abort.future,
          requestId: 'request',
          fromJson: (json) => json,
        )
        .toList();
    final aborted = expectLater(result, throwsA(isA<AbortedException>()));
    abort.complete();
    await aborted.timeout(deadline);
  });

  test(
    'request construction stays lazy and failures are stream errors',
    () async {
      var constructed = false;
      final stream = TestResource(transport)
          .streamRequest<Map<String, dynamic>>(
            createRequest: () {
              constructed = true;
              throw StateError('invalid request');
            },
            fromJson: (json) => json,
          );
      expect(constructed, isFalse);
      await expectLater(stream.toList(), throwsA(isA<StateError>()));
      expect(constructed, isTrue);
      expect(transport.requests, isEmpty);
    },
  );

  test('failed abort futures do not become unhandled stream errors', () async {
    final sent = transport.sent.stream.first;
    final signal = Completer<void>();
    final result = startStream(
      client,
      'model',
      abortTrigger: signal.future,
    ).toList();
    final pending = await sent;
    signal.completeError(StateError('not an abort signal'));
    await Future<void>.delayed(Duration.zero);
    pending.response.complete(http.StreamedResponse(const Stream.empty(), 200));
    expect(await result.timeout(deadline), isEmpty);
  });

  test(
    'standalone monitor forwards pause/resume and closes on source errors',
    () async {
      final paused = Completer<void>();
      final resumed = Completer<void>();
      final canceled = Completer<void>();
      final source = StreamController<Map<String, dynamic>>(
        onPause: paused.complete,
        onResume: resumed.complete,
        onCancel: canceled.complete,
      );
      final done = Completer<void>();
      final errors = <Object>[];
      final subscription =
          TestResource(transport)
              .streamWithAbortMonitoring(
                source: source.stream,
                abortTrigger: Completer<void>().future,
                requestId: 'test',
                fromJson: (json) => json,
              )
              .listen((_) {}, onError: errors.add, onDone: done.complete)
            ..pause();
      await paused.future.timeout(deadline);
      subscription.resume();
      await resumed.future.timeout(deadline);
      source.addError(StateError('source failure'));
      await done.future.timeout(deadline);
      await canceled.future.timeout(deadline);
      expect(errors, hasLength(1));
      await source.close();
      await subscription.cancel();
    },
  );
  test(
    'an abort after normal completion does not emit another terminal event',
    () async {
      final sent = transport.sent.stream.first;
      final signal = Completer<void>();
      final result = startStream(
        client,
        'model',
        abortTrigger: signal.future,
      ).toList();
      final pending = await sent;
      pending.response.complete(
        http.StreamedResponse(Stream.value(utf8.encode('data: {}\n\n')), 200),
      );
      expect(await result.timeout(deadline), hasLength(1));
      signal.complete();
      await Future<void>.delayed(Duration.zero);
    },
  );
}
