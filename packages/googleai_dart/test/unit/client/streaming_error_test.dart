import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

void main() {
  group('Streaming Inline Error Detection', () {
    GoogleAIClient createMockClient(List<String> sseLines) {
      final mockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable(sseLines.map((line) => utf8.encode(line))),
          200,
        );
      });

      return GoogleAIClient(
        config: const GoogleAIConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    Stream<GenerateContentResponse> createStream(GoogleAIClient client) {
      return client.models.streamGenerateContent(
        model: 'gemini-2.0-flash',
        request: const GenerateContentRequest(
          contents: [
            Content(parts: [TextPart('Hello')]),
          ],
        ),
      );
    }

    test('inline error object throws StreamException', () async {
      final client = createMockClient([
        'data: {"error":{"message":"API key not valid","code":400}}\n\n',
        'data: [DONE]\n\n',
      ]);

      await expectLater(
        createStream(client).toList(),
        throwsA(
          isA<StreamException>().having(
            (e) => e.message,
            'message',
            'API key not valid',
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

    test('normal events pass through', () async {
      final client = createMockClient([
        'data: {"candidates":[{"content":{"parts":[{"text":"Hi"}]}}]}\n\n',
      ]);

      final events = await createStream(client).toList();
      expect(events, hasLength(1));
      client.close();
    });

    test('good events then error', () async {
      final client = createMockClient([
        'data: {"candidates":[{"content":{"parts":[{"text":"Hi"}]}}]}\n\n',
        'data: {"error":{"message":"Quota exceeded","code":429}}\n\n',
      ]);

      final events = <GenerateContentResponse>[];
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
        'data: {"candidates":[],"error":null}\n\n',
      ]);

      final events = await createStream(client).toList();
      expect(events, hasLength(1));
      client.close();
    });
  });
}
