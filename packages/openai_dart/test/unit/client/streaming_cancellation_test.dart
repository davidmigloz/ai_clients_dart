@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

const _deadline = Duration(seconds: 2);

class _Transport extends http.BaseClient {
  final requests = <http.BaseRequest>[];
  final responses = <Completer<http.StreamedResponse>>[];
  final _sent = <int, Completer<http.BaseRequest>>{};
  bool closed = false;

  Future<http.BaseRequest> requestAt(int index) {
    if (requests.length > index) return Future.value(requests[index]);
    return (_sent[index] ??= Completer<http.BaseRequest>()).future.timeout(
      _deadline,
    );
  }

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    final index = requests.length;
    requests.add(request);
    final response = Completer<http.StreamedResponse>();
    responses.add(response);
    _sent[index]?.complete(request);
    return response.future;
  }

  @override
  void close() => closed = true;
}

Stream<ChatStreamEvent> _chat(OpenAIClient client, [Future<void>? abort]) =>
    client.chat.completions.createStream(
      ChatCompletionCreateRequest(
        model: 'test',
        messages: [ChatMessage.user('Hi')],
      ),
      abortTrigger: abort,
    );

Stream<ResponseStreamEvent> _responses(
  OpenAIClient client, [
  Future<void>? abort,
]) => client.responses.createStream(
  const CreateResponseRequest(model: 'test', input: ResponseInput.text('Hi')),
  abortTrigger: abort,
);

final _paths =
    <
      ({
        String name,
        Stream<Object?> Function(OpenAIClient) stream,
        String event,
      })
    >[
      (
        name: 'chat text',
        stream: (client) => _chat(client).textDeltas(),
        event: 'data: {"choices":[{"index":0,"delta":{"content":"Hi"}}]}\n\n',
      ),
      (
        name: 'chat accumulator',
        stream: (client) => _chat(client).accumulate(),
        event: 'data: {"choices":[{"index":0,"delta":{"content":"Hi"}}]}\n\n',
      ),
      (
        name: 'response text',
        stream: (client) => _responses(client).textDeltas(),
        event: 'data: {"type":"response.output_text.delta","output_index":0,"content_index":0,"delta":"Hi"}\n\n',
      ),
      (
        name: 'response accumulator',
        stream: (client) => _responses(client).accumulate(),
        event: 'data: {"type":"response.output_text.delta","output_index":0,"content_index":0,"delta":"Hi"}\n\n',
      ),
    ];

void main() {
  for (final path in _paths) {
    test(
      '${path.name} cancels before response headers and disposes a late body',
      () async {
        final transport = _Transport();
        final client = OpenAIClient(httpClient: transport);
        addTearDown(client.close);
        final subscription = path.stream(client).listen((_) {});
        final sent = await transport.requestAt(0);
        final aborted = (sent as http.Abortable).abortTrigger!;
        await subscription.cancel().timeout(_deadline);
        await aborted.timeout(_deadline);
        expect(transport.closed, isFalse);

        final disposed = Completer<void>();
        final lateBody = StreamController<List<int>>(
          onCancel: disposed.complete,
        );
        transport.responses.single.complete(
          http.StreamedResponse(lateBody.stream, 200),
        );
        await disposed.future.timeout(_deadline);
        await lateBody.close();
      },
    );

    for (final emitted in [false, true]) {
      test(
        '${path.name} cancels an idle body ${emitted ? 'after an event' : 'before an event'}',
        () async {
          final transport = _Transport();
          final client = OpenAIClient(httpClient: transport);
          addTearDown(client.close);
          final received = Completer<void>();
          final subscription = path.stream(client).listen((_) {
            if (!received.isCompleted) received.complete();
          });
          await transport.requestAt(0);
          final listening = Completer<void>();
          final canceled = Completer<void>();
          final body = StreamController<List<int>>(
            onListen: listening.complete,
            onCancel: canceled.complete,
          );
          transport.responses.single.complete(
            http.StreamedResponse(body.stream, 200),
          );
          await listening.future.timeout(_deadline);
          if (emitted) {
            body.add(utf8.encode(path.event));
            await received.future.timeout(_deadline);
          } else {
            // An incomplete event must not hold cancellation until its next byte.
            body.add(utf8.encode('data: {"partial":'));
            await Future<void>.delayed(Duration.zero);
          }
          await subscription.cancel().timeout(_deadline);
          await canceled.future.timeout(_deadline);
          expect(transport.closed, isFalse);
          await body.close();
        },
      );
    }
  }

  for (final api in [(_chat, 'chat'), (_responses, 'responses')]) {
    test(
      '${api.$2} aborts pending headers without closing a borrowed client or sibling',
      () async {
        final transport = _Transport();
        final client = OpenAIClient(httpClient: transport);
        addTearDown(client.close);
        final abort = Completer<void>();
        final first = api.$1(client, abort.future).toList();
        final sibling = api.$1(client).toList();
        final firstRequest = await transport.requestAt(0);
        final secondRequest = await transport.requestAt(1);
        var siblingAborted = false;
        unawaited(
          (secondRequest as http.Abortable).abortTrigger!.then(
            (_) => siblingAborted = true,
          ),
        );
        final firstAborted = (firstRequest as http.Abortable).abortTrigger!;
        final failed = expectLater(
          first.timeout(_deadline),
          throwsA(isA<AbortedException>()),
        );
        abort.complete();
        await failed;
        await firstAborted.timeout(_deadline);
        expect(siblingAborted, isFalse);
        expect(transport.closed, isFalse);
        transport.responses[1].complete(
          http.StreamedResponse(
            Stream.value(utf8.encode('data: [DONE]\n\n')),
            200,
          ),
        );
        expect(await sibling.timeout(_deadline), isEmpty);
        transport.responses[0].complete(
          http.StreamedResponse(const Stream.empty(), 200),
        );
      },
    );
  }

  for (final payload in [
    (
      'event: error\ndata: {"error":{"message":"edit failed"}}\n\n',
      isA<StreamException>(),
    ),
    ('data: {"type":"image_edit.partial_image"}\n\n', isA<ParseException>()),
  ]) {
    test('multipart image edits terminate on ${payload.$2}', () async {
      final transport = _Transport();
      final client = OpenAIClient(httpClient: transport);
      addTearDown(client.close);
      final errors = <Object>[];
      final done = Completer<void>();
      client.images
          .editStream(
            ImageEditRequest(
              image: Uint8List.fromList([1]),
              imageFilename: 'image.png',
              prompt: 'Edit',
              model: ImageModels.gptImage2,
            ),
          )
          .listen((_) {}, onError: errors.add, onDone: done.complete);
      await transport.requestAt(0);
      final listening = Completer<void>();
      final canceled = Completer<void>();
      final body = StreamController<List<int>>(
        onListen: listening.complete,
        onCancel: canceled.complete,
      );
      transport.responses.single.complete(
        http.StreamedResponse(body.stream, 200),
      );
      await listening.future.timeout(_deadline);
      body.add(utf8.encode(payload.$1));
      await done.future.timeout(_deadline);
      await canceled.future.timeout(_deadline);
      expect(errors, [payload.$2]);
      expect(transport.closed, isFalse);
      await body.close();
    });
  }

  for (final aborting in [false, true]) {
    test(
      '${aborting ? 'abort' : 'listener cancellation'} finishes while body cleanup is pending',
      () async {
        final transport = _Transport();
        final client = OpenAIClient(httpClient: transport);
        addTearDown(client.close);
        final abort = Completer<void>();
        final stream = _chat(
          client,
          aborting ? abort.future : null,
        ).textDeltas();
        final result = aborting ? stream.toList() : null;
        final subscription = aborting ? null : stream.listen((_) {});
        await transport.requestAt(0);
        final listening = Completer<void>();
        final cleanupStarted = Completer<void>();
        final releaseCleanup = Completer<void>();
        final body = StreamController<List<int>>(
          onListen: listening.complete,
          onCancel: () {
            cleanupStarted.complete();
            return releaseCleanup.future;
          },
        );
        transport.responses.single.complete(
          http.StreamedResponse(body.stream, 200),
        );
        await listening.future.timeout(_deadline);
        if (aborting) {
          final expectation = expectLater(
            result!.timeout(_deadline),
            throwsA(isA<AbortedException>()),
          );
          abort.complete();
          await expectation;
        } else {
          await subscription!.cancel().timeout(_deadline);
        }
        await cleanupStarted.future.timeout(_deadline);
        expect(releaseCleanup.isCompleted, isFalse);
        releaseCleanup.complete();
        await body.close();
      },
    );
  }

  test(
    'owned factory body cleanup failure does not escape terminal stream error',
    () async {
      final shared = _Transport();
      final dedicated = _Transport();
      final client = OpenAIClient(
        httpClient: shared,
        streamClientFactory: () => dedicated,
      );
      addTearDown(client.close);
      final abort = Completer<void>();
      final errors = <Object>[];
      final done = Completer<void>();
      _chat(
        client,
        abort.future,
      ).listen((_) {}, onError: errors.add, onDone: done.complete);
      await dedicated.requestAt(0);
      final listening = Completer<void>();
      final canceled = Completer<void>();
      final body = StreamController<List<int>>(
        onListen: listening.complete,
        onCancel: () {
          canceled.complete();
          return Future<void>.error(StateError('cleanup failed'));
        },
      );
      dedicated.responses.single.complete(
        http.StreamedResponse(body.stream, 200),
      );
      await listening.future.timeout(_deadline);
      final failure = StateError('read failed');
      body.addError(failure);
      await done.future.timeout(_deadline);
      await canceled.future.timeout(_deadline);
      await Future<void>.delayed(Duration.zero);
      expect(errors, [same(failure)]);
      expect(dedicated.closed, isTrue);
      expect(shared.closed, isFalse);
      await body.close();
    },
  );

  test('pre-completed cancellation prevents dispatch', () async {
    final transport = _Transport();
    final client = OpenAIClient(httpClient: transport);
    addTearDown(client.close);
    await expectLater(
      _chat(client, Future.value()).toList(),
      throwsA(isA<AbortedException>()),
    );
    expect(transport.requests, isEmpty);
    expect(transport.closed, isFalse);
  });

  test('HTTP error body failures terminate once and cancel the body', () async {
    final transport = _Transport();
    final client = OpenAIClient(httpClient: transport);
    addTearDown(client.close);
    final errors = <Object>[];
    final done = Completer<void>();
    _chat(client).listen((_) {}, onError: errors.add, onDone: done.complete);
    await transport.requestAt(0);
    final listening = Completer<void>();
    final canceled = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: listening.complete,
      onCancel: canceled.complete,
    );
    transport.responses.single.complete(
      http.StreamedResponse(body.stream, 400),
    );
    await listening.future.timeout(_deadline);
    final failure = StateError('body failed');
    body.addError(failure);
    await done.future.timeout(_deadline);
    await canceled.future.timeout(_deadline);
    expect(errors, [same(failure)]);
    await body.close();
  });

  test('late abort from a terminal error handler is harmless', () async {
    final transport = _Transport();
    final client = OpenAIClient(httpClient: transport);
    addTearDown(client.close);
    final abort = Completer<void>();
    final done = Completer<void>();
    final errors = <Object>[];
    _chat(client, abort.future).listen(
      (_) {},
      onError: (Object error) {
        errors.add(error);
        abort.complete();
      },
      onDone: done.complete,
    );
    await transport.requestAt(0);
    final failure = StateError('send failed');
    transport.responses.single.completeError(failure);
    await done.future.timeout(_deadline);
    await Future<void>.delayed(Duration.zero);
    expect(errors, [same(failure)]);
  });

  test('pause and resume reach the body through text filtering', () async {
    final transport = _Transport();
    final client = OpenAIClient(httpClient: transport);
    addTearDown(client.close);
    final data = <String>[];
    final received = Completer<void>();
    final subscription = _chat(client).textDeltas().listen((text) {
      data.add(text);
      received.complete();
    });
    await transport.requestAt(0);
    final listening = Completer<void>();
    final paused = Completer<void>();
    final resumed = Completer<void>();
    final body = StreamController<List<int>>(
      onListen: listening.complete,
      onPause: paused.complete,
      onResume: resumed.complete,
    );
    transport.responses.single.complete(
      http.StreamedResponse(body.stream, 200),
    );
    await listening.future.timeout(_deadline);
    subscription.pause();
    await paused.future.timeout(_deadline);
    body.add(utf8.encode(_paths.first.event));
    await Future<void>.delayed(Duration.zero);
    expect(data, isEmpty);
    subscription.resume();
    await resumed.future.timeout(_deadline);
    await received.future.timeout(_deadline);
    expect(data, ['Hi']);
    await subscription.cancel().timeout(_deadline);
    await body.close();
  });

  for (final afterHeaders in [false, true]) {
    test(
      'native request disconnects ${afterHeaders ? 'on idle-body listener cancellation' : 'on abort before headers'}',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        addTearDown(() => server.close(force: true));
        final connected = Completer<Socket>();
        final disconnected = Completer<void>();
        final serverSubscription = server.listen((request) async {
          await request.drain<void>();
          final socket = await request.response.detachSocket(
            writeHeaders: false,
          );
          socket.listen((_) {}, onError: (_) {}, onDone: disconnected.complete);
          if (afterHeaders) {
            socket.write(
              'HTTP/1.1 200 OK\r\nContent-Type: text/event-stream\r\nTransfer-Encoding: chunked\r\n\r\n',
            );
            final event = utf8.encode(_paths.first.event);
            socket
              ..write('${event.length.toRadixString(16)}\r\n')
              ..add(event)
              ..write('\r\n');
            await socket.flush();
          }
          connected.complete(socket);
        });
        addTearDown(serverSubscription.cancel);
        final client = OpenAIClient(
          config: OpenAIConfig(baseUrl: 'http://127.0.0.1:${server.port}'),
        );
        addTearDown(client.close);
        final abort = Completer<void>();
        final done = Completer<void>();
        final errors = <Object>[];
        final firstEvent = Completer<void>();
        final subscription = _chat(client, abort.future).textDeltas().listen(
          (_) => firstEvent.complete(),
          onError: errors.add,
          onDone: done.complete,
        );
        final socket = await connected.future.timeout(_deadline);
        addTearDown(socket.destroy);
        if (afterHeaders) {
          await firstEvent.future.timeout(_deadline);
          await subscription.cancel().timeout(_deadline);
        } else {
          abort.complete();
          await done.future.timeout(_deadline);
          expect(errors, [isA<AbortedException>()]);
        }
        await disconnected.future.timeout(_deadline);
      },
    );
  }
}
