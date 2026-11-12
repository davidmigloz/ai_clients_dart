import 'dart:async' hide TimeoutException;
import 'dart:convert';
import 'dart:typed_data';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

const _timeout = Duration(seconds: 17);
const _retryPolicy = RetryPolicy(
  maxRetries: 1,
  initialDelay: Duration.zero,
  maxDelay: Duration.zero,
  jitter: 0,
);
const _noRetry = RetryPolicy(maxRetries: 0);
final _message = MessageCreateRequest(
  model: 'claude-sonnet-5-5',
  maxTokens: 1,
  messages: [InputMessage.user('Hello')],
);

void main() {
  _nativeAbortTests();
  _streamAndDirectTimeoutTests();

  test('POST timeout signals transport and cancels a late response', () async {
    final timers = _ControlledTimeouts();
    await timers.run(() async {
      final first = _Exchange();
      final second = _Exchange();
      final transport = _Transport([first, second]);
      final client = _client(transport, _retryPolicy);
      addTearDown(client.close);

      final request = client.messages.create(_message);
      final sent = await first.sent.future;
      expect(timers.attempts, hasLength(1));
      final failed = expectLater(request, throwsA(_timeoutError));
      final signaled = (sent as http.Abortable).abortTrigger!;
      timers.attempts.single.fire();
      await failed;
      await signaled;
      expect(transport.requests, hasLength(1));

      final canceled = Completer<void>();
      final late = StreamController<List<int>>(onCancel: canceled.complete);
      first.response.complete(http.StreamedResponse(late.stream, 200));
      await canceled.future;
      await late.close();

      final next = client.models.list();
      await second.sent.future;
      second.respondWithModels();
      expect((await next).data, isEmpty);
      expect(timers.attempts, hasLength(2));
      expect(timers.attempts.last.isActive, isFalse);
      expect(transport.closeCount, 0);
      client.close();
      expect(transport.closeCount, 0);
    });
  });

  test('timeout cancels a stalled response body exactly once', () async {
    final timers = _ControlledTimeouts();
    await timers.run(() async {
      final exchange = _Exchange();
      final transport = _Transport([exchange]);
      final client = _client(transport, _noRetry);
      addTearDown(client.close);

      final result = client.models.list();
      final sent = await exchange.sent.future;
      final listening = Completer<void>();
      var cancellations = 0;
      final body = StreamController<List<int>>(
        onListen: listening.complete,
        onCancel: () => cancellations++,
      );
      exchange.response.complete(http.StreamedResponse(body.stream, 200));
      await listening.future;
      body.add(utf8.encode('{"data":'));
      expect(timers.attempts, hasLength(1));
      final failed = expectLater(result, throwsA(_timeoutError));
      timers.attempts.single.fire();
      await failed;
      await (sent as http.Abortable).abortTrigger;
      expect(cancellations, 1);
      expect(transport.closeCount, 0);
      await body.close();
    });
  });

  test('idempotent retry gets a fresh deadline and transport signal', () async {
    final timers = _ControlledTimeouts();
    await timers.run(() async {
      final first = _Exchange();
      final second = _Exchange();
      final transport = _Transport([first, second]);
      final client = _client(transport, _retryPolicy);
      addTearDown(client.close);

      final result = client.models.list();
      final sent = await first.sent.future;
      expect(timers.attempts, hasLength(1));
      final firstAbort = (sent as http.Abortable).abortTrigger;
      timers.attempts.single.fire();
      await firstAbort;
      final retried = await second.sent.future;
      expect(timers.attempts, hasLength(2));
      expect(timers.attempts.last.isActive, isTrue);
      expect(retried, isNot(same(sent)));
      expect(retried.headers['x-request-id'], sent.headers['x-request-id']);
      expect((retried as http.Abortable).abortTrigger, isNot(same(firstAbort)));
      second.respondWithModels();
      expect((await result).data, isEmpty);
      expect(timers.attempts.last.isActive, isFalse);
      final discarded = Completer<void>();
      final body = StreamController<List<int>>(onCancel: discarded.complete);
      first.response.complete(http.StreamedResponse(body.stream, 200));
      await discarded.future;
      await body.close();
    });
  });

  test('user abort wins over a pending timeout on a stalled body', () async {
    final timers = _ControlledTimeouts();
    await timers.run(() async {
      final exchange = _Exchange();
      final transport = _Transport([exchange]);
      final client = _client(transport, _retryPolicy);
      addTearDown(client.close);
      final abort = Completer<void>();

      final result = client.models.list(abortTrigger: abort.future);
      final sent = await exchange.sent.future;
      final listening = Completer<void>();
      var cancellations = 0;
      final body = StreamController<List<int>>(
        onListen: listening.complete,
        onCancel: () => cancellations++,
      );
      exchange.response.complete(http.StreamedResponse(body.stream, 200));
      await listening.future;
      expect(timers.attempts, hasLength(1));
      final failed = expectLater(
        result,
        throwsA(
          isA<AbortedException>()
              .having(
                (error) => error.stage,
                'stage',
                AbortionStage.duringResponse,
              )
              .having(
                (error) => error.correlationId,
                'correlation ID',
                sent.headers['x-request-id'],
              ),
        ),
      );
      abort.complete();
      await failed;
      expect(timers.attempts.single.isActive, isFalse);
      expect(cancellations, 1);
      expect(transport.requests, hasLength(1));
      await body.close();
    });
  });

  test(
    'deadline starts after authentication, including custom providers',
    () async {
      final timers = _ControlledTimeouts();
      await timers.run(() async {
        final exchange = _Exchange();
        final transport = _Transport([exchange]);
        final auth = _BlockingAuthProvider();
        final client = _client(transport, _noRetry, authProvider: auth);
        addTearDown(client.close);

        final result = client.models.list();
        await auth.started.future;
        expect(timers.attempts, isEmpty);
        expect(transport.requests, isEmpty);
        auth.credentials.complete(const ApiKeyCredentials('fixture-key'));
        final request = await exchange.sent.future;
        expect(request.headers['x-api-key'], 'fixture-key');
        expect(timers.attempts, hasLength(1));
        exchange.respondWithModels();
        expect((await result).data, isEmpty);
      });
    },
  );

  test(
    'protected environment work calls use the same configured deadline',
    () async {
      final timers = _ControlledTimeouts();
      await timers.run(() async {
        final exchange = _Exchange();
        final transport = _Transport([exchange]);
        final client = _client(transport, _noRetry);
        addTearDown(client.close);

        final result = client.environments
            .work('env_fixture', bearerToken: 'environment-fixture')
            .poll();
        final request = await exchange.sent.future;
        expect(timers.attempts, hasLength(1));
        expect(request.headers['authorization'], 'Bearer environment-fixture');
        final failed = expectLater(result, throwsA(_timeoutError));
        timers.attempts.single.fire();
        await failed;
        await (request as http.Abortable).abortTrigger;
        exchange.response.complete(
          http.StreamedResponse(const Stream.empty(), 200),
        );
      });
    },
  );
}

final TypeMatcher<TimeoutException> _timeoutError = isA<TimeoutException>()
    .having((error) => error.timeout, 'configured timeout', _timeout);

AnthropicClient _client(
  _Transport transport,
  RetryPolicy policy, {
  AuthProvider? authProvider,
}) => AnthropicClient(
  config: AnthropicConfig(
    timeout: _timeout,
    retryPolicy: policy,
    authProvider: authProvider,
  ),
  httpClient: transport,
);

class _BlockingAuthProvider implements AuthProvider {
  final started = Completer<void>();
  final credentials = Completer<AuthCredentials>();

  @override
  Future<AuthCredentials> getCredentials() {
    started.complete();
    return credentials.future;
  }
}

class _Transport extends http.BaseClient {
  _Transport(this.exchanges);

  final List<_Exchange> exchanges;
  final requests = <http.BaseRequest>[];
  int closeCount = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final exchange = exchanges[requests.length];
    requests.add(request);
    exchange.sent.complete(request);
    return exchange.response.future;
  }

  @override
  void close() => closeCount++;
}

class _Exchange {
  final sent = Completer<http.BaseRequest>();
  final response = Completer<http.StreamedResponse>();

  void respondWithModels() => response.complete(
    http.StreamedResponse(
      Stream.value(utf8.encode('{"data":[],"has_more":false}')),
      200,
      headers: {'content-type': 'application/json'},
    ),
  );
}

class _ControlledTimeouts {
  final attempts = <_ManualTimer>[];

  Future<void> run(Future<void> Function() scenario) => runZoned(
    scenario,
    zoneSpecification: ZoneSpecification(
      createTimer: (self, parent, zone, duration, callback) {
        if (duration != _timeout) {
          return parent.createTimer(zone, duration, callback);
        }
        final timer = _ManualTimer(zone.bindCallback(callback));
        attempts.add(timer);
        return timer;
      },
    ),
  );
}

class _ManualTimer implements Timer {
  _ManualTimer(this.callback);

  final void Function() callback;
  bool _active = true;
  int _tick = 0;

  @override
  bool get isActive => _active;

  @override
  int get tick => _tick;

  void fire() {
    if (!_active) throw StateError('Attempt timer is inactive');
    _active = false;
    _tick++;
    callback();
  }

  @override
  void cancel() => _active = false;
}

void _streamAndDirectTimeoutTests() {
  test(
    'SSE header timeout aborts and discards a late borrowed response',
    () async {
      final timers = _ControlledTimeouts();
      await timers.run(() async {
        final exchange = _Exchange();
        final transport = _Transport([exchange]);
        final client = _client(transport, _noRetry);
        addTearDown(client.close);

        final output = _StreamObservation(
          client.messages.createStream(_message),
        );
        addTearDown(output.cancel);
        final request = await exchange.sent.future;
        expect(timers.attempts, hasLength(1));
        timers.attempts.single.fire();
        await output.expectTimeout();
        await (request as http.Abortable).abortTrigger;

        final canceled = Completer<void>();
        final body = StreamController<List<int>>(onCancel: canceled.complete);
        exchange.response.complete(http.StreamedResponse(body.stream, 200));
        await canceled.future;
        await body.close();
        expect(transport.closeCount, 0);
      });
    },
  );

  for (final (name, status, open)
      in <(String, int, Stream<Object?> Function(AnthropicClient))>[
        ('SSE', 200, (client) => client.messages.createStream(_message)),
        (
          'SSE error body',
          403,
          (client) => client.messages.createStream(_message),
        ),
        (
          'batch JSONL',
          200,
          (client) => client.messages.batches.results('batch'),
        ),
      ]) {
    test(
      '$name timeout resets on raw body chunks and terminates once',
      () async {
        final timers = _ControlledTimeouts();
        await timers.run(() async {
          final exchange = _Exchange();
          final transport = _Transport([exchange]);
          final client = _client(transport, _noRetry);
          addTearDown(client.close);

          final output = _StreamObservation(open(client));
          addTearDown(output.cancel);
          final request = await exchange.sent.future;
          final listening = Completer<void>();
          var canceled = 0;
          final body = StreamController<List<int>>(
            onListen: listening.complete,
            onCancel: () => canceled++,
          );
          exchange.response.complete(
            http.StreamedResponse(body.stream, status),
          );
          await listening.future;
          expect(timers.attempts, hasLength(2));
          expect(timers.attempts.first.isActive, isFalse);
          expect(timers.attempts.last.isActive, isTrue);

          // Partial input produces no parsed event or complete error body.
          body.add(utf8.encode('{"partial"'));
          await Future<void>.delayed(Duration.zero);
          expect(timers.attempts, hasLength(3));
          expect(timers.attempts[1].isActive, isFalse);
          timers.attempts.last.fire();
          await output.expectTimeout();
          await (request as http.Abortable).abortTrigger;
          expect(canceled, 1);
          expect(transport.closeCount, 0);
          await body.close();
        });
      },
    );
  }

  test(
    'Compliance binary idle deadline suspends while caller pauses',
    () async {
      final timers = _ControlledTimeouts();
      await timers.run(() async {
        final exchange = _Exchange();
        final transport = _Transport([exchange]);
        final client = _client(transport, _noRetry);
        addTearDown(client.close);
        final received = Completer<void>();
        final failure = Completer<Object>();
        final closed = Completer<void>();
        String? requestId;
        final stream = client.compliance.apps.downloadChatFile(
          'file_fixture',
          onResponse: (headers) => requestId = headers.requestId,
        );
        final listener = stream.listen(
          (bytes) {
            expect(bytes, [1, 2]);
            received.complete();
          },
          onError: failure.complete,
          onDone: closed.complete,
        );
        addTearDown(listener.cancel);
        final request = await exchange.sent.future;
        final listening = Completer<void>();
        var canceled = 0;
        final body = StreamController<List<int>>(
          onListen: listening.complete,
          onCancel: () => canceled++,
        );
        exchange.response.complete(
          http.StreamedResponse(
            body.stream,
            200,
            headers: {'request-id': 'req_fixture'},
          ),
        );
        await listening.future;
        expect(requestId, 'req_fixture');
        expect(timers.attempts, hasLength(2));
        listener.pause();
        expect(timers.attempts.last.isActive, isFalse);
        body.add([1, 2]);
        listener.resume();
        await received.future;
        expect(timers.attempts.last.isActive, isTrue);
        timers.attempts.last.fire();
        expect(await failure.future, _timeoutError);
        await closed.future;
        await (request as http.Abortable).abortTrigger;
        expect(canceled, 1);
        expect(transport.closeCount, 0);
        await body.close();
      });
    },
  );

  final skill = SkillFile(
    path: 'fixture/SKILL.md',
    bytes: Uint8List.fromList(utf8.encode('Fixture')),
  );
  for (final (name, method, multipart, invoke)
      in <(String, String, bool, Future<Object?> Function(AnthropicClient))>[
        (
          'Files upload',
          'POST',
          true,
          (client) => client.files.uploadBytes(
            bytes: Uint8List.fromList([1]),
            fileName: 'fixture.txt',
          ),
        ),
        (
          'Files download',
          'GET',
          false,
          (client) => client.files.download(fileId: 'file_fixture'),
        ),
        (
          'Skills create',
          'POST',
          true,
          (client) => client.skills.create(files: [skill]),
        ),
        (
          'Skills version create',
          'POST',
          true,
          (client) => client.skills.createVersion(
            skillId: 'skill_fixture',
            files: [skill],
          ),
        ),
      ]) {
    test(
      '$name direct timeout preserves body type and never retries',
      () async {
        final timers = _ControlledTimeouts();
        await timers.run(() async {
          final exchange = _Exchange();
          final transport = _Transport([exchange]);
          final client = _client(transport, _retryPolicy);
          addTearDown(client.close);

          final result = invoke(client);
          final request = await exchange.sent.future;
          expect(request.method, method);
          expect(
            request,
            multipart ? isA<http.MultipartRequest>() : isA<http.Request>(),
          );
          expect(request, isA<http.Abortable>());
          if (request is http.MultipartRequest) {
            expect(request.files.single.length, greaterThan(0));
          }
          final failed = expectLater(result, throwsA(_timeoutError));
          final listening = Completer<void>();
          var canceled = 0;
          final body = StreamController<List<int>>(
            onListen: listening.complete,
            onCancel: () => canceled++,
          );
          exchange.response.complete(http.StreamedResponse(body.stream, 200));
          await listening.future;
          expect(timers.attempts, hasLength(1));
          timers.attempts.single.fire();
          await failed;
          await (request as http.Abortable).abortTrigger;
          expect(canceled, 1);
          expect(transport.requests, hasLength(1));
          expect(transport.closeCount, 0);
          await body.close();
        });
      },
    );
  }
}

class _StreamObservation {
  _StreamObservation(Stream<Object?> stream) {
    _listener = stream.listen(
      _events.add,
      onError: _errors.add,
      onDone: _closed.complete,
    );
  }

  final _events = <Object?>[];
  final _errors = <Object>[];
  final _closed = Completer<void>();
  late final StreamSubscription<Object?> _listener;

  Future<void> cancel() => _listener.cancel();

  Future<void> expectTimeout() async {
    await _closed.future;
    expect(_events, isEmpty);
    expect(_errors, [_timeoutError]);
  }
}

void _nativeAbortTests() {
  for (final multipart in [false, true]) {
    for (final (description, hasSdkAbort, sdkWins) in [
      ('native signal', false, false),
      ('native signal with SDK signal pending', true, false),
      ('SDK signal with native signal pending', true, true),
    ]) {
      test(
        'advanced ${multipart ? 'multipart' : 'cloneable'} uses the $description',
        () async {
          final timers = _ControlledTimeouts();
          await timers.run(() async {
            final exchange = _Exchange();
            final transport = _Transport([exchange]);
            final client = _client(
              transport,
              _retryPolicy,
              authProvider: const ApiKeyProvider('fixture-key'),
            );
            addTearDown(client.close);
            final nativeAbort = Completer<void>();
            final sdkAbort = Completer<void>();
            final url = Uri.https('fixture.invalid', '/advanced');
            final original = multipart
                ? http.AbortableMultipartRequest(
                    'POST',
                    url,
                    abortTrigger: nativeAbort.future,
                  )
                : http.AbortableRequest(
                    'GET',
                    url,
                    abortTrigger: nativeAbort.future,
                  );
            final result = client.interceptorChain.execute(
              original,
              abortTrigger: hasSdkAbort ? sdkAbort.future : null,
            );
            final sent = await exchange.sent.future;
            expect(sent.headers['x-api-key'], 'fixture-key');
            final listening = Completer<void>();
            var cancellations = 0;
            final body = StreamController<List<int>>(
              onListen: listening.complete,
              onCancel: () => cancellations++,
            );
            exchange.response.complete(http.StreamedResponse(body.stream, 200));
            await listening.future;
            final failed = expectLater(
              result,
              throwsA(
                sdkWins
                    ? isA<AbortedException>().having(
                        (error) => error.stage,
                        'stage',
                        AbortionStage.duringResponse,
                      )
                    : isA<http.RequestAbortedException>().having(
                        (error) => error.uri,
                        'request URL',
                        url,
                      ),
              ),
            );
            (sdkWins ? sdkAbort : nativeAbort).complete();
            await failed;
            await (sent as http.Abortable).abortTrigger;
            (sdkWins ? nativeAbort : sdkAbort).complete();
            expect(transport.requests, hasLength(1));
            expect(transport.closeCount, 0);
            expect(cancellations, 1);
            expect(timers.attempts.single.isActive, isFalse);
            await body.close();
          });
        },
      );
    }
  }
}
