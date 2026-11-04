@TestOn('vm')
library;

import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

class _ObservedClient extends http.BaseClient {
  final _inner = http.Client();
  final failure = Completer<Object>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      return await _inner.send(request);
    } catch (error) {
      failure.complete(error);
      rethrow;
    }
  }

  @override
  void close() => _inner.close();
}

void main() {
  test(
    'consecutive completed streams reuse the native HTTP connection',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      final ports = <int>{};
      final serverSubscription = server.listen((request) async {
        ports.add(request.connectionInfo!.remotePort);
        await request.drain<void>();
        request.response.headers.contentType = ContentType(
          'text',
          'event-stream',
        );
        for (var i = 0; i < 3; i++) {
          request.response.write('data: {"id":"chunk_$i"}\n\n');
          await request.response.flush();
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        request.response.write('data: [DONE]\n\n');
        await request.response.close();
      });
      final transport = http.Client();
      final client = MistralClient(
        config: MistralConfig(baseUrl: 'http://127.0.0.1:${server.port}'),
        httpClient: transport,
      );
      addTearDown(() async {
        client.close();
        transport.close();
        await serverSubscription.cancel();
        await server.close(force: true);
      });
      for (var i = 0; i < 2; i++) {
        final events = await client.chat
            .createStream(
              request: ChatCompletionRequest(
                model: 'test',
                messages: [ChatMessage.user('Hi')],
              ),
            )
            .toList();
        expect(events.map((event) => event.id), [
          'chunk_0',
          'chunk_1',
          'chunk_2',
        ]);
      }
      expect(ports, hasLength(1));
    },
  );

  for (final multipart in [false, true]) {
    test(
      'native ${multipart ? 'multipart' : 'JSON'} request aborts before headers',
      () async {
        final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
        final received = Completer<HttpRequest>();
        final serverSubscription = server.listen(received.complete);
        final transport = _ObservedClient();
        final client = MistralClient(
          config: MistralConfig(
            baseUrl: 'http://127.0.0.1:${server.port}',
            authProvider: const ApiKeyProvider('test-key'),
            sendRequestIdHeader: true,
          ),
          httpClient: transport,
        );
        addTearDown(() async {
          client.close();
          transport.close();
          await serverSubscription.cancel();
          await server.close(force: true);
        });
        final abort = Completer<void>();
        final Stream<Object> stream = multipart
            ? client.audio.transcriptions.createStream(
                request: const TranscriptionRequest(
                  fileBytes: [1, 2, 3],
                  fileName: 'clip.wav',
                ),
                abortTrigger: abort.future,
              )
            : client.chat.createStream(
                request: ChatCompletionRequest(
                  model: 'test',
                  messages: [ChatMessage.user('Hi')],
                ),
                abortTrigger: abort.future,
              );
        final result = stream.toList();
        await received.future.timeout(const Duration(seconds: 2));
        abort.complete();
        await expectLater(result, throwsA(isA<AbortedException>()));
        // Observe the real HTTP send independently of the local stream error.
        // Removing the native abort trigger must make this assertion fail.
        expect(
          await transport.failure.future.timeout(const Duration(seconds: 2)),
          isA<http.RequestAbortedException>(),
        );
      },
    );
  }
}
