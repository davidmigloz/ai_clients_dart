@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import 'streaming_cancellation_test.dart' as fixture;

const _deadline = Duration(seconds: 5);
Future<void> _tick() => Future<void>.delayed(Duration.zero);

MessageCreateRequest _request() => MessageCreateRequest(
  model: 'test',
  maxTokens: 1,
  messages: [InputMessage.user('Hi')],
);

void main() {
  test(
    'error-handler abort after send failure adds no unhandled error',
    () async {
      final transport = fixture.Transport();
      final abort = Completer<void>();
      final done = Completer<void>();
      final errors = <Object>[];
      final sent = transport.sent.stream.first;
      fixture.Resource(transport, const AnthropicConfig())
          .getStream('/test', abortTrigger: abort.future)
          .listen(
            (_) {},
            onError: (Object error) {
              errors.add(error);
              abort.complete();
            },
            onDone: done.complete,
          );
      await sent.timeout(_deadline);
      transport.responses.single.completeError(StateError('send failed'));
      await done.future.timeout(_deadline);
      await _tick();
      expect(errors, hasLength(1));
      expect(errors.single, isA<StateError>());
      await transport.sent.close();
    },
  );

  for (final status in [200, 400]) {
    for (final closeBody in [false, true]) {
      test('$status body failure is terminal, closeBody=$closeBody', () async {
        final transport = fixture.Transport();
        final canceled = Completer<void>();
        final body = StreamController<List<int>>(onCancel: canceled.complete);
        final done = Completer<void>();
        final errors = <Object>[];
        fixture.Resource(transport, const AnthropicConfig())
            .getStream('/test')
            .listen((_) {}, onError: errors.add, onDone: done.complete);
        await _tick();
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, status),
        );
        await _tick();
        body.addError(StateError('connection reset'));
        if (closeBody) unawaited(body.close());
        await done.future.timeout(_deadline);
        await canceled.future.timeout(_deadline);
        expect(errors, hasLength(1));
        expect(errors.single, isA<StateError>());
        await body.close();
        await transport.sent.close();
      });
    }
  }

  for (final method in ['GET', 'POST']) {
    for (final status in [200, 400]) {
      test('$method abort cancels partial stalled $status body', () async {
        final transport = fixture.Transport();
        final body = StreamController<List<int>>();
        final abort = Completer<void>();
        final resource = fixture.Resource(transport, const AnthropicConfig());
        final stream = method == 'GET'
            ? resource.getStream('/test', abortTrigger: abort.future)
            : resource.postStream(
                '/test',
                body: {},
                abortTrigger: abort.future,
              );
        final sent = transport.sent.stream.first;
        final result = stream.toList();
        await sent.timeout(_deadline);
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, status),
        );
        body.add([0xf0, 0x9f]); // Incomplete UTF-8 character, no SSE event.
        await _tick();
        abort.complete();
        await expectLater(
          result.timeout(_deadline),
          throwsA(isA<AbortedException>()),
        );
        expect(body.hasListener, isFalse);
        expect(transport.closed, isFalse);
        await body.close();
        await transport.sent.close();
      });
    }
  }

  final helpers =
      <String, Stream<Object?> Function(Stream<MessageStreamEvent>)>{
        'textDeltas': (stream) => stream.textDeltas(),
        'thinkingDeltas': (stream) => stream.thinkingDeltas(),
        'inputJsonDeltas': (stream) => stream.inputJsonDeltas(),
        'accumulate': (stream) => stream.accumulate(),
      };
  for (final helper in helpers.entries) {
    for (final headersReceived in [false, true]) {
      test(
        '${helper.key} forwards idle cancellation, headers=$headersReceived',
        () async {
          final transport = fixture.Transport();
          final client = AnthropicClient(httpClient: transport);
          final subscription = helper
              .value(client.messages.createStream(_request()))
              .listen((_) {});
          await _tick();
          final body = StreamController<List<int>>();
          if (headersReceived) {
            transport.responses.single.complete(
              http.StreamedResponse(body.stream, 200),
            );
            body.add(utf8.encode('data: {"type":')); // Incomplete SSE frame.
            await _tick();
          }
          final nativeAbort =
              (transport.requests.single as http.Abortable).abortTrigger!;
          await subscription.cancel().timeout(_deadline);
          await nativeAbort.timeout(_deadline);
          if (!headersReceived) {
            transport.responses.single.complete(
              http.StreamedResponse(body.stream, 200),
            );
            await _tick();
          }
          expect(body.hasListener, isFalse);
          client.close();
          expect(transport.closed, isFalse);
          await body.close();
          await transport.sent.close();
        },
      );
    }
  }

  for (final thread in [false, true]) {
    test(
      'public session stream forwards idle cancellation, thread=$thread',
      () async {
        final transport = fixture.Transport();
        final client = AnthropicClient(httpClient: transport);
        final stream = thread
            ? client.sessions.threads('s').events('t').stream()
            : client.sessions.events('s').stream();
        final subscription = stream.listen((_) {});
        await _tick();
        final body = StreamController<List<int>>();
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, 200),
        );
        await _tick();
        await subscription.cancel().timeout(_deadline);
        expect(body.hasListener, isFalse);
        client.close();
        expect(transport.closed, isFalse);
        await body.close();
        await transport.sent.close();
      },
    );
  }

  for (final headersReceived in [false, true]) {
    test(
      'batch results forwards idle cancellation, headers=$headersReceived',
      () async {
        final transport = fixture.Transport();
        final client = AnthropicClient(httpClient: transport);
        final subscription = client.messages.batches
            .results('batch')
            .listen((_) {});
        await _tick();
        final body = StreamController<List<int>>();
        if (headersReceived) {
          transport.responses.single.complete(
            http.StreamedResponse(body.stream, 200),
          );
          body.add(utf8.encode('{"custom_id":')); // Incomplete JSONL line.
          await _tick();
        }
        await subscription.cancel().timeout(_deadline);
        await (transport.requests.single as http.Abortable).abortTrigger!
            .timeout(_deadline);
        if (!headersReceived) {
          transport.responses.single.complete(
            http.StreamedResponse(body.stream, 200),
          );
          await _tick();
        }
        expect(body.hasListener, isFalse);
        client.close();
        await body.close();
        await transport.sent.close();
      },
    );
  }

  for (final endpoint in ['messages', 'session', 'thread', 'batch']) {
    test('$endpoint conversion errors terminate and cancel the body', () async {
      final transport = fixture.Transport();
      final client = AnthropicClient(httpClient: transport);
      final Stream<Object?> stream = switch (endpoint) {
        'messages' => client.messages.createStream(_request()),
        'session' => client.sessions.events('s').stream(),
        'thread' => client.sessions.threads('s').events('t').stream(),
        _ => client.messages.batches.results('batch'),
      };
      final errors = <Object>[];
      final done = Completer<void>();
      stream.listen((_) {}, onError: errors.add, onDone: done.complete);
      await _tick();
      final body = StreamController<List<int>>();
      transport.responses.single.complete(
        http.StreamedResponse(body.stream, 200),
      );
      body.add(
        utf8.encode(
          endpoint == 'batch'
              ? '{"custom_id":123,"result":{"type":"canceled"}}\n'
              : 'data: {"type":123}\n\n',
        ),
      );
      await done.future.timeout(_deadline);
      expect(errors, hasLength(1));
      expect(body.hasListener, isFalse);
      await (transport.requests.single as http.Abortable).abortTrigger!.timeout(
        _deadline,
      );
      client.close();
      await body.close();
      await transport.sent.close();
    });
  }

  for (final status in [200, 400]) {
    test(
      '$status body failure keeps original error when cleanup fails',
      () async {
        final transport = fixture.Transport();
        final body = StreamController<List<int>>(
          onCancel: () => Future<void>.error(StateError('cleanup failed')),
        );
        final errors = <Object>[];
        final done = Completer<void>();
        final subscription =
            fixture.Resource(transport, const AnthropicConfig())
                .getStream('/test')
                .listen((_) {}, onError: errors.add, onDone: done.complete);
        addTearDown(() async {
          subscription.cancel().ignore();
          await body.close();
          await transport.sent.close();
        });
        await _tick();
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, status),
        );
        await _tick();
        final original = StateError('read failed');
        body.addError(original);
        await done.future.timeout(_deadline);
        expect(errors, [same(original)]);
      },
    );
  }

  test('listener cancellation consumes response cleanup failures', () async {
    final transport = fixture.Transport();
    final body = StreamController<List<int>>(
      onCancel: () => Future<void>.error(StateError('cleanup failed')),
    );
    final subscription = fixture.Resource(
      transport,
      const AnthropicConfig(),
    ).getStream('/test').listen((_) {});
    await _tick();
    transport.responses.single.complete(
      http.StreamedResponse(body.stream, 200),
    );
    await _tick();
    await subscription.cancel().timeout(_deadline);
    await _tick();
    await body.close();
    await transport.sent.close();
  });

  test('batch JSONL preserves blank lines and result parsing', () async {
    final transport = fixture.Transport();
    final client = AnthropicClient(httpClient: transport);
    final future = client.messages.batches.results('batch').toList();
    await _tick();
    transport.responses.single.complete(
      http.StreamedResponse(
        Stream.value(
          utf8.encode(
            '\n{"custom_id":"a","result":{"type":"canceled"}}\n'
            '   \n{"custom_id":"b","result":{"type":"expired"}}\n',
          ),
        ),
        200,
      ),
    );
    final results = await future;
    expect(results.map((result) => result.customId), ['a', 'b']);
    expect(results.first.result, isA<BatchResultCanceled>());
    expect(results.last.result, isA<BatchResultExpired>());
    client.close();
    await transport.sent.close();
  });

  final batchErrors = <int, Matcher>{
    400: isA<ValidationException>(),
    401: isA<AuthenticationException>(),
    429: isA<RateLimitException>(),
    500: isA<ApiException>(),
  };
  for (final entry in batchErrors.entries) {
    test('batch results preserves HTTP ${entry.key} error mapping', () async {
      final transport = fixture.Transport();
      final client = AnthropicClient(httpClient: transport);
      final future = client.messages.batches.results('batch').toList();
      await _tick();
      transport.responses.single.complete(
        http.StreamedResponse(
          Stream.value(utf8.encode('{"error":{"message":"bad request"}}')),
          entry.key,
        ),
      );
      await expectLater(future, throwsA(entry.value));
      client.close();
      await transport.sent.close();
    });
  }

  test('accumulate keeps independent state for broadcast listeners', () async {
    final events = StreamController<MessageStreamEvent>.broadcast();
    final stream = events.stream.accumulate();
    final first = <MessageStreamAccumulator>[];
    final second = <MessageStreamAccumulator>[];
    final firstSubscription = stream.listen(first.add);
    final secondSubscription = stream.listen(second.add);
    events.add(const PingEvent());
    await _tick();
    expect(identical(first.single, second.single), isFalse);
    await firstSubscription.cancel();
    await secondSubscription.cancel();
    await events.close();
  });

  test('batch abort during authentication sends nothing', () async {
    final auth = fixture.DelayedAuth();
    final transport = fixture.Transport();
    final client = AnthropicClient(
      config: AnthropicConfig(authProvider: auth),
      httpClient: transport,
    );
    final abort = Completer<void>();
    final result = client.messages.batches
        .results('batch', abortTrigger: abort.future)
        .toList();
    await _tick();
    abort.complete();
    await expectLater(
      result.timeout(_deadline),
      throwsA(isA<AbortedException>()),
    );
    auth.credentials.completeError(StateError('late authentication failure'));
    await _tick();
    expect(transport.requests, isEmpty);
    client.close();
    await transport.sent.close();
  });

  test('pause and resume propagate while body is idle', () async {
    final transport = fixture.Transport();
    final body = StreamController<List<int>>();
    final events = <Map<String, dynamic>>[];
    final subscription = fixture.Resource(
      transport,
      const AnthropicConfig(),
    ).getStream('/test').listen(events.add)..pause();
    await _tick();
    transport.responses.single.complete(
      http.StreamedResponse(body.stream, 200),
    );
    await _tick();
    expect(body.isPaused, isTrue);
    body.add(utf8.encode('data: {"type":"ping"}\n\n'));
    await _tick();
    expect(events, isEmpty);
    subscription.resume();
    await _tick();
    expect(events, [
      {'type': 'ping'},
    ]);
    expect(body.isPaused, isFalse);
    await subscription.cancel().timeout(_deadline);
    await body.close();
    await transport.sent.close();
  });

  test('abort after normal completion is ignored', () async {
    final transport = fixture.Transport();
    final abort = Completer<void>();
    final sent = transport.sent.stream.first;
    final future = fixture.Resource(
      transport,
      const AnthropicConfig(),
    ).getStream('/test', abortTrigger: abort.future).toList();
    await sent.timeout(_deadline);
    var nativeAborted = false;
    unawaited(
      (transport.requests.single as http.Abortable).abortTrigger!.then((_) {
        nativeAborted = true;
      }),
    );
    transport.responses.single.complete(
      http.StreamedResponse(const Stream.empty(), 200),
    );
    expect(await future, isEmpty);
    abort.complete();
    await _tick();
    expect(nativeAborted, isFalse);
    await transport.sent.close();
  });

  test('native successful SSE requests reuse their connection', () async {
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    final ports = <int>[];
    final serverSubscription = server.listen((request) async {
      ports.add(request.connectionInfo!.remotePort);
      await request.drain<void>();
      request.response
        ..headers.contentType = ContentType('text', 'event-stream')
        ..write('data: {"type":"ping"}\n\n');
      await request.response.flush();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      request.response.write('data: [DONE]\n\n');
      await request.response.close();
    });
    final client = AnthropicClient(
      config: AnthropicConfig(baseUrl: 'http://127.0.0.1:${server.port}'),
    );
    addTearDown(() async {
      client.close();
      await serverSubscription.cancel();
      await server.close(force: true);
    });
    for (var i = 0; i < 2; i++) {
      final events = await client.messages.createStream(_request()).toList();
      expect(events.single, isA<PingEvent>());
    }
    expect(ports, hasLength(2));
    expect(ports.first, ports.last);
  });

  for (final headersReceived in [false, true]) {
    for (final listenerCancel in [false, true]) {
      test(
        'native peer disconnects, headers=$headersReceived listenerCancel=$listenerCancel',
        () async {
          final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
          final ready = Completer<void>();
          final disconnected = Completer<void>();
          Socket? peer;
          StreamSubscription<List<int>>? peerSubscription;
          final serverSubscription = server.listen((request) async {
            await request.drain<void>();
            peer = await request.response.detachSocket(writeHeaders: false);
            peerSubscription = peer!.listen(
              (_) {},
              onError: (Object _) {
                if (!disconnected.isCompleted) disconnected.complete();
              },
              onDone: () {
                if (!disconnected.isCompleted) disconnected.complete();
              },
            );
            if (headersReceived) {
              peer!.write(
                'HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nTransfer-Encoding: chunked\r\n\r\n',
              );
              await peer!.flush();
            }
            ready.complete();
          });
          final client = AnthropicClient(
            config: AnthropicConfig(baseUrl: 'http://127.0.0.1:${server.port}'),
          );
          addTearDown(() async {
            client.close();
            peer?.destroy();
            await peerSubscription?.cancel();
            await serverSubscription.cancel();
            await server.close(force: true);
          });
          final abort = Completer<void>();
          final errors = <Object>[];
          final done = Completer<void>();
          final subscription = client.messages
              .createStream(_request(), abortTrigger: abort.future)
              .listen((_) {}, onError: errors.add, onDone: done.complete);
          await ready.future.timeout(_deadline);
          if (headersReceived) await _tick();
          if (listenerCancel) {
            await subscription.cancel().timeout(_deadline);
          } else {
            abort.complete();
            await done.future.timeout(_deadline);
            expect(errors.single, isA<AbortedException>());
          }
          // The client is still open and the server has not closed the response.
          // Removing AbortableRequest must make the pending-header cases fail.
          await disconnected.future.timeout(_deadline);
        },
      );
    }
  }
}
