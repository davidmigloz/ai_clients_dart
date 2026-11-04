import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:open_responses/open_responses.dart';
import 'package:test/test.dart';

const _deadline = Duration(seconds: 1);
const _request = CreateResponseRequest(
  model: 'test',
  input: ResponseTextInput('Hi'),
);

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
  late OpenResponsesClient client;

  setUp(() {
    transport = _Transport();
    client = OpenResponsesClient(httpClient: transport);
  });

  tearDown(() async {
    client.close();
    await transport.dispose();
  });

  test('pre-cancel prevents sending the request', () async {
    final result = client.responses
        .createStream(_request, abortTrigger: Future<void>.value())
        .toList();
    await expectLater(result, throwsA(isA<AbortedException>()));
    expect(transport.requests, isEmpty);
  });

  test(
    'abort during authentication finishes before credentials resolve',
    () async {
      final auth = _DelayedAuth();
      client.close();
      client = OpenResponsesClient(
        config: OpenResponsesConfig(authProvider: auth),
        httpClient: transport,
      );
      final abort = Completer<void>();
      final result = client.responses
          .createStream(_request, abortTrigger: abort.future)
          .toList();
      await auth.called.future;
      abort.complete();
      await expectLater(
        result.timeout(_deadline),
        throwsA(isA<AbortedException>()),
      );
      auth.credentials.completeError(StateError('late authentication failure'));
      await _tick();
      expect(transport.requests, isEmpty);
    },
  );

  test(
    'abort before headers preserves a concurrent request and borrowed client',
    () async {
      final abort = Completer<void>();
      final result = client.responses
          .createStream(_request, abortTrigger: abort.future)
          .toList();
      final sibling = client.responses.createStream(_request).toList();
      await transport.waitForRequests(2);
      final nativeAbort =
          (transport.requests.first as http.Abortable).abortTrigger!;
      var siblingAborted = false;
      unawaited(
        (transport.requests.last as http.Abortable).abortTrigger!.then((_) {
          siblingAborted = true;
        }),
      );
      abort.complete();
      await expectLater(
        result.timeout(_deadline),
        throwsA(isA<AbortedException>()),
      );
      await nativeAbort.timeout(_deadline);
      expect(siblingAborted, isFalse);
      expect(transport.closed, isFalse);
      transport.responses.last.complete(
        http.StreamedResponse(const Stream.empty(), 200),
      );
      expect(await sibling, isEmpty);
      final lateBodyCanceled = Completer<void>();
      final lateBody = StreamController<List<int>>(
        onCancel: lateBodyCanceled.complete,
      );
      transport.responses.first.complete(
        http.StreamedResponse(lateBody.stream, 200),
      );
      await lateBodyCanceled.future.timeout(_deadline);
      await lateBody.close();
      client.close();
      expect(transport.closed, isFalse);
    },
  );

  for (final wrapper in ['raw', 'builder', 'textDeltas', 'accumulate']) {
    test(
      '$wrapper listener cancellation reaches request before headers',
      () async {
        final Stream<Object?> stream = switch (wrapper) {
          'builder' => client.responses.stream(_request).asStream(),
          'textDeltas' => client.responses.createStream(_request).textDeltas,
          'accumulate' => client.responses.createStream(_request).accumulate(),
          _ => client.responses.createStream(_request),
        };
        final subscription = stream.listen((_) {});
        await transport.waitForRequests(1);
        final abort =
            (transport.requests.single as http.Abortable).abortTrigger!;
        await subscription.cancel().timeout(_deadline);
        await abort.timeout(_deadline);
        transport.responses.single.complete(
          http.StreamedResponse(const Stream.empty(), 200),
        );
        expect(transport.closed, isFalse);
      },
    );
  }

  for (final status in [200, 500]) {
    for (final cancelListener in [false, true]) {
      test(
        '$status stalled body canceled by ${cancelListener ? 'listener' : 'abort'}',
        () async {
          final abort = Completer<void>();
          final bodyListened = Completer<void>();
          final bodyCanceled = Completer<void>();
          final body = StreamController<List<int>>(
            onListen: bodyListened.complete,
            onCancel: bodyCanceled.complete,
          );
          final errors = <Object>[];
          final done = Completer<void>();
          final subscription = client.responses
              .createStream(_request, abortTrigger: abort.future)
              .listen((_) {}, onError: errors.add, onDone: done.complete);
          await transport.waitForRequests(1);
          transport.responses.single.complete(
            http.StreamedResponse(body.stream, status),
          );
          await bodyListened.future;
          if (cancelListener) {
            await subscription.cancel().timeout(_deadline);
          } else {
            abort.complete();
            await done.future.timeout(_deadline);
            expect(errors, [isA<AbortedException>()]);
          }
          await bodyCanceled.future.timeout(_deadline);
          await body.close();
        },
      );
    }

    test('$status body transport failure terminates with one error', () async {
      final bodyListened = Completer<void>();
      final bodyCanceled = Completer<void>();
      final body = StreamController<List<int>>(
        onListen: bodyListened.complete,
        onCancel: bodyCanceled.complete,
      );
      final errors = <Object>[];
      final done = Completer<void>();
      client.responses
          .createStream(_request)
          .listen((_) {}, onError: errors.add, onDone: done.complete);
      await transport.waitForRequests(1);
      transport.responses.single.complete(
        http.StreamedResponse(body.stream, status),
      );
      await bodyListened.future;
      final failure = StateError('broken connection');
      body.addError(failure);
      await done.future.timeout(_deadline);
      await bodyCanceled.future.timeout(_deadline);
      await body.close();
      expect(errors, [same(failure)]);
    });
  }

  for (final status in [400, 401, 429, 500]) {
    test('stream preserves HTTP $status exception mapping', () async {
      final result = client.responses.createStream(_request).toList();
      await transport.waitForRequests(1);
      transport.responses.single.complete(
        http.StreamedResponse(
          Stream.value(
            utf8.encode('{"error":{"message":"bad request","param":"model"}}'),
          ),
          status,
        ),
      );
      final matcher = switch (status) {
        400 => isA<ValidationException>().having(
          (e) => e.fieldErrors,
          'fieldErrors',
          {
            'model': ['bad request'],
          },
        ),
        401 => isA<AuthenticationException>(),
        429 => isA<RateLimitException>(),
        _ => isA<ApiException>(),
      };
      await expectLater(result, throwsA(matcher));
    });
  }

  test('late abort after normal completion emits no further error', () async {
    final abort = Completer<void>();
    final result = client.responses
        .createStream(_request, abortTrigger: abort.future)
        .toList();
    await transport.waitForRequests(1);
    transport.responses.single.complete(
      http.StreamedResponse(const Stream.empty(), 200),
    );
    expect(await result, isEmpty);
    abort.complete();
    await _tick();
  });

  test('malformed event terminates and cancels the response body', () async {
    final bodyCanceled = Completer<void>();
    final body = StreamController<List<int>>(onCancel: bodyCanceled.complete);
    final result = client.responses.createStream(_request).toList();
    await transport.waitForRequests(1);
    transport.responses.single.complete(
      http.StreamedResponse(body.stream, 200),
    );
    body.add(utf8.encode('data: {"type":"response.output_text.delta"}\n\n'));
    await expectLater(result.timeout(_deadline), throwsA(isA<TypeError>()));
    await bodyCanceled.future.timeout(_deadline);
    await body.close();
  });

  test('pause and resume reach the underlying response body', () async {
    final paused = Completer<void>();
    final resumed = Completer<void>();
    final listened = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: listened.complete,
      onPause: paused.complete,
      onResume: resumed.complete,
    );
    final subscription = client.responses.createStream(_request).listen((_) {});
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
}
