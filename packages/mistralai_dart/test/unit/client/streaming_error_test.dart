import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Streaming Inline Error Detection', () {
    MistralClient createMockClient(List<String> sseLines) {
      final mockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable(sseLines.map((line) => utf8.encode(line))),
          200,
        );
      });

      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    Stream<ChatCompletionStreamResponse> createStream(MistralClient client) {
      return client.chat.createStream(
        request: ChatCompletionRequest(
          model: 'mistral-small-latest',
          messages: [ChatMessage.user('Hello')],
        ),
      );
    }

    test('inline error object throws StreamException', () async {
      final client = createMockClient([
        'data: {"error":{"message":"Rate limit exceeded","type":"rate_limit_error"}}\n\n',
        'data: [DONE]\n\n',
      ]);

      await expectLater(
        createStream(client).toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'Rate limit exceeded',
          ),
        ),
      );
      client.close();
    });

    test('SSE event: error with JSON throws StreamException', () async {
      final client = createMockClient([
        'event: error\ndata: {"error":{"message":"Timeout"}}\n\n',
        'data: [DONE]\n\n',
      ]);

      await expectLater(
        createStream(client).toList(),
        throwsA(
          isA<StreamException>().having((e) => e.message, 'message', 'Timeout'),
        ),
      );
      client.close();
    });

    test('SSE event: error with non-JSON throws StreamException', () async {
      final client = createMockClient([
        'event: error\ndata: Service temporarily unavailable\n\n',
        'data: [DONE]\n\n',
      ]);

      await expectLater(
        createStream(client).toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'Service temporarily unavailable',
          ),
        ),
      );
      client.close();
    });

    test('error as plain string throws StreamException', () async {
      final client = createMockClient([
        'data: {"error":"Something went wrong"}\n\n',
        'data: [DONE]\n\n',
      ]);

      await expectLater(
        createStream(client).toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'Something went wrong',
          ),
        ),
      );
      client.close();
    });

    test('normal events pass through', () async {
      final client = createMockClient([
        'data: {"id":"x","object":"chat.completion.chunk","choices":[]}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = await createStream(client).toList();
      expect(events, hasLength(1));
      client.close();
    });

    test('good events then error', () async {
      final client = createMockClient([
        'data: {"id":"chunk1","object":"chat.completion.chunk","choices":[]}\n\n',
        'data: {"error":{"message":"Server error","type":"server_error"}}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = <ChatCompletionStreamResponse>[];
      Object? caughtError;

      try {
        await createStream(client).forEach(events.add);
      } on StreamException catch (e) {
        caughtError = e;
      }

      expect(events, hasLength(1));
      expect(caughtError, isA<StreamException>());
      client.close();
    });

    test('error: null does NOT throw', () async {
      final client = createMockClient([
        'data: {"id":"x","object":"chat.completion.chunk","choices":[],"error":null}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = await createStream(client).toList();
      expect(events, hasLength(1));
      client.close();
    });
  });
}
