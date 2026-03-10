import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Streaming Inline Error Detection', () {
    /// Helper to create a mock Ollama client that returns the given NDJSON data.
    OllamaClient createMockClient(List<String> ndjsonLines) {
      final mockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable(ndjsonLines.map((line) => utf8.encode(line))),
          200,
        );
      });

      return OllamaClient(
        config: const OllamaConfig(baseUrl: 'http://localhost:11434'),
        httpClient: mockClient,
      );
    }

    Stream<ChatStreamEvent> createChatStream(OllamaClient client) {
      return client.chat.createStream(
        request: const ChatRequest(
          model: 'llama2',
          messages: [ChatMessage(role: MessageRole.user, content: 'Hello')],
        ),
      );
    }

    test('inline error throws StreamException', () async {
      final client = createMockClient([
        '{"error":"model \'nonexistent\' not found"}\n',
      ]);

      await expectLater(
        createChatStream(client).toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            "model 'nonexistent' not found",
          ),
        ),
      );
      client.close();
    });

    test('normal events pass through', () async {
      final client = createMockClient([
        '{"model":"llama2","created_at":"2024-01-01T00:00:00Z","message":{"role":"assistant","content":"Hi"},"done":false}\n',
        '{"model":"llama2","created_at":"2024-01-01T00:00:00Z","message":{"role":"assistant","content":"!"},"done":true}\n',
      ]);

      final events = await createChatStream(client).toList();
      expect(events, hasLength(2));
      client.close();
    });

    test('good events then error — good events received', () async {
      final client = createMockClient([
        '{"model":"llama2","created_at":"2024-01-01T00:00:00Z","message":{"role":"assistant","content":"Hi"},"done":false}\n',
        '{"error":"context length exceeded"}\n',
      ]);

      final events = <ChatStreamEvent>[];
      Object? caughtError;

      try {
        await createChatStream(client).forEach(events.add);
      } on StreamException catch (e) {
        caughtError = e;
      }

      expect(events, hasLength(1));
      expect(caughtError, isA<StreamException>());
      expect(
        (caughtError! as StreamException).message,
        'context length exceeded',
      );
      client.close();
    });

    test('error: null does NOT throw', () async {
      final client = createMockClient([
        '{"model":"llama2","created_at":"2024-01-01T00:00:00Z","message":{"role":"assistant","content":"Hi"},"done":false,"error":null}\n',
        '{"model":"llama2","created_at":"2024-01-01T00:00:00Z","message":{"role":"assistant","content":""},"done":true,"error":null}\n',
      ]);

      final events = await createChatStream(client).toList();
      expect(events, hasLength(2));
      client.close();
    });

    test('error partialData contains raw JSON', () async {
      final client = createMockClient(['{"error":"model not found"}\n']);

      try {
        await createChatStream(client).toList();
        fail('Should have thrown');
      } on StreamException catch (e) {
        expect(e.partialData, isNotNull);
        final parsed = jsonDecode(e.partialData!) as Map<String, dynamic>;
        expect(parsed['error'], 'model not found');
      }
      client.close();
    });
  });
}
