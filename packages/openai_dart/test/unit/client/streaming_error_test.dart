import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Streaming Inline Error Detection', () {
    /// Helper to create a mock OpenAI client that returns the given SSE data.
    OpenAIClient createMockClient(List<String> sseLines) {
      final mockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable(sseLines.map((line) => utf8.encode(line))),
          200,
        );
      });

      return OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );
    }

    /// Helper to create a chat stream from a mock client.
    Stream<ChatStreamEvent> createStream(OpenAIClient client) {
      return client.chat.completions.createStream(
        ChatCompletionCreateRequest(
          model: 'gpt-4',
          messages: [ChatMessage.user('Hello')],
        ),
      );
    }

    test('1. Bedrock-format inline error throws StreamException', () async {
      final client = createMockClient([
        'data: {"object":"chat.completion","error":{"error":"Too many tokens...","error_code":4001}}\n\n',
        'data: [DONE]\n\n',
      ]);

      await expectLater(
        createStream(client).toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'Too many tokens...',
          ),
        ),
      );
      client.close();
    });

    test('2. Standard OpenAI error format throws StreamException', () async {
      final client = createMockClient([
        'data: {"error":{"message":"Internal server error","type":"server_error","code":"500"}}\n\n',
        'data: [DONE]\n\n',
      ]);

      await expectLater(
        createStream(client).toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'Internal server error',
          ),
        ),
      );
      client.close();
    });

    test('3. SSE event: error type throws StreamException', () async {
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

    test('4. Error as plain string throws StreamException', () async {
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

    test(
      '5. SSE event: error with no error field throws StreamException',
      () async {
        final client = createMockClient([
          'event: error\ndata: {"info":"unknown"}\n\n',
          'data: [DONE]\n\n',
        ]);

        await expectLater(
          createStream(client).toList(),
          throwsA(
            isA<StreamException>().having(
              (e) => e.message,
              'message',
              'Stream error event received',
            ),
          ),
        );
        client.close();
      },
    );

    test('6. error: null does NOT throw', () async {
      final client = createMockClient([
        'data: {"object":"chat.completion.chunk","choices":[],"error":null}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = await createStream(client).toList();
      expect(events, hasLength(1));
      client.close();
    });

    test('7. Normal events pass through', () async {
      final client = createMockClient([
        'data: {"id":"x","object":"chat.completion.chunk","choices":[]}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = await createStream(client).toList();
      expect(events, hasLength(1));
      expect(events.first.id, 'x');
      client.close();
    });

    test('8. Partial stream: good events then error', () async {
      final client = createMockClient([
        'data: {"id":"chunk1","object":"chat.completion.chunk","choices":[]}\n\n',
        'data: {"object":"chat.completion","error":{"error":"Rate limit exceeded","error_code":4001}}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = <ChatStreamEvent>[];
      Object? caughtError;

      try {
        await createStream(client).forEach(events.add);
      } on StreamException catch (e) {
        caughtError = e;
      }

      expect(events, hasLength(1));
      expect(events.first.id, 'chunk1');
      expect(caughtError, isA<StreamException>());
      expect((caughtError! as StreamException).message, 'Rate limit exceeded');
      client.close();
    });

    test('9. createStreamWithAccumulator propagates StreamException', () async {
      final client = createMockClient([
        'data: {"object":"chat.completion","error":{"error":"Too many tokens...","error_code":4001}}\n\n',
        'data: [DONE]\n\n',
      ]);

      await expectLater(
        client.chat.completions
            .createStreamWithAccumulator(
              ChatCompletionCreateRequest(
                model: 'gpt-4',
                messages: [ChatMessage.user('Hello')],
              ),
            )
            .toList(),
        throwsA(isA<StreamException>()),
      );
      client.close();
    });

    test('10. Error partialData contains raw JSON', () async {
      final client = createMockClient([
        'data: {"object":"chat.completion","error":{"error":"Too many tokens...","error_code":4001}}\n\n',
        'data: [DONE]\n\n',
      ]);

      try {
        await createStream(client).toList();
        fail('Should have thrown');
      } on StreamException catch (e) {
        expect(e.partialData, isNotNull);
        // partialData should be valid JSON
        final parsed = jsonDecode(e.partialData!) as Map<String, dynamic>;
        expect(parsed['error'], isA<Map<String, dynamic>>());
        final error = parsed['error'] as Map<String, dynamic>;
        expect(error['error'], 'Too many tokens...');
        expect(error['error_code'], 4001);
        // Internal _event field should be stripped
        expect(parsed.containsKey('_event'), isFalse);
      }
      client.close();
    });
  });
}
