import 'dart:async' show unawaited;
import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Streaming Inline Error Detection (HTTP integration)', () {
    late HttpServer server;
    late OpenAIClient client;

    setUp(() async {
      server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      client = OpenAIClient(
        config: OpenAIConfig(
          authProvider: const ApiKeyProvider('sk-test-key'),
          baseUrl: 'http://${server.address.host}:${server.port}',
        ),
      );
    });

    tearDown(() async {
      client.close();
      await server.close();
    });

    /// Helper to create a chat stream.
    Stream<ChatStreamEvent> createStream() {
      return client.chat.completions.createStream(
        ChatCompletionCreateRequest(
          model: 'gpt-4',
          messages: [ChatMessage.user('Hello')],
        ),
      );
    }

    test('1. Error after valid chunks throws StreamException', () async {
      server.listen((request) {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('text', 'event-stream')
          ..write(
            'data: {"id":"c1","object":"chat.completion.chunk","choices":[]}\n\n',
          )
          ..write(
            'data: {"id":"c2","object":"chat.completion.chunk","choices":[]}\n\n',
          )
          ..write(
            'data: {"object":"chat.completion","error":{"error":"Token limit exceeded","error_code":4001}}\n\n',
          )
          ..write('data: [DONE]\n\n');
        unawaited(request.response.close());
      });

      final events = <ChatStreamEvent>[];
      Object? caughtError;

      try {
        await createStream().forEach(events.add);
      } on StreamException catch (e) {
        caughtError = e;
      }

      expect(events, hasLength(2));
      expect(caughtError, isA<StreamException>());
      expect((caughtError! as StreamException).message, 'Token limit exceeded');
    });

    test('2. Immediate error throws StreamException', () async {
      server.listen((request) {
        request.response
          ..statusCode = 200
          ..headers.contentType = ContentType('text', 'event-stream')
          ..write(
            'data: {"error":{"message":"Service unavailable","type":"server_error"}}\n\n',
          )
          ..write('data: [DONE]\n\n');
        unawaited(request.response.close());
      });

      await expectLater(
        createStream().toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'Service unavailable',
          ),
        ),
      );
    });

    test(
      '3. SSE event: error with proper headers throws StreamException',
      () async {
        server.listen((request) {
          request.response
            ..statusCode = 200
            ..headers.contentType = ContentType('text', 'event-stream')
            ..write(
              'event: error\ndata: {"error":{"message":"Request timeout"}}\n\n',
            );
          unawaited(request.response.close());
        });

        await expectLater(
          createStream().toList(),
          throwsA(
            isA<StreamException>().having(
              (e) => e.message,
              'message',
              'Request timeout',
            ),
          ),
        );
      },
    );
  });
}
