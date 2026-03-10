import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Completions Streaming Inline Error Detection', () {
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

    /// Helper to create a completions stream from a mock client.
    Stream<Completion> createStream(OpenAIClient client) {
      return client.completions.createStream(
        const CompletionRequest(
          model: 'gpt-3.5-turbo-instruct',
          prompt: CompletionPrompt.text('Hello'),
        ),
      );
    }

    test('1. Bedrock-format inline error throws StreamException', () async {
      final client = createMockClient([
        'data: {"object":"text_completion","error":{"error":"Too many tokens...","error_code":4001}}\n\n',
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

    test('5. error: null does NOT throw', () async {
      final client = createMockClient([
        'data: {"id":"cmpl-test","object":"text_completion","created":1234567890,"model":"gpt-3.5-turbo-instruct","choices":[{"text":"Hi","index":0,"logprobs":null,"finish_reason":"stop"}],"error":null}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = await createStream(client).toList();
      expect(events, hasLength(1));
      client.close();
    });

    test('6. Normal events pass through', () async {
      final client = createMockClient([
        'data: {"id":"cmpl-test","object":"text_completion","created":1234567890,"model":"gpt-3.5-turbo-instruct","choices":[{"text":"Hello","index":0,"logprobs":null,"finish_reason":"stop"}]}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = await createStream(client).toList();
      expect(events, hasLength(1));
      expect(events.first.id, 'cmpl-test');
      client.close();
    });

    test('7. Good events then error', () async {
      final client = createMockClient([
        'data: {"id":"cmpl-1","object":"text_completion","created":1234567890,"model":"gpt-3.5-turbo-instruct","choices":[{"text":"Hi","index":0,"logprobs":null,"finish_reason":null}]}\n\n',
        'data: {"object":"text_completion","error":{"error":"Rate limit exceeded","error_code":4001}}\n\n',
        'data: [DONE]\n\n',
      ]);

      final events = <Completion>[];
      Object? caughtError;

      try {
        await createStream(client).forEach(events.add);
      } on StreamException catch (e) {
        caughtError = e;
      }

      expect(events, hasLength(1));
      expect(events.first.id, 'cmpl-1');
      expect(caughtError, isA<StreamException>());
      expect((caughtError! as StreamException).message, 'Rate limit exceeded');
      client.close();
    });
  });
}
