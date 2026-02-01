import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Request Timeout', () {
    test('throws RequestTimeoutException when request exceeds timeout', () {
      final mockClient = MockClient((request) async {
        // Simulate a slow request that takes longer than the timeout
        await Future<void>.delayed(const Duration(seconds: 2));
        return http.Response('{}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          timeout: Duration(milliseconds: 100),
          maxRetries: 0, // Disable retries for this test
        ),
        httpClient: mockClient,
      );

      expect(
        () => client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        ),
        throwsA(isA<RequestTimeoutException>()),
      );

      client.close();
    });

    test('RequestTimeoutException includes timeout duration', () async {
      final mockClient = MockClient((request) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        return http.Response('{}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          timeout: Duration(milliseconds: 50),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      try {
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
        );
        fail('Expected RequestTimeoutException');
      } on RequestTimeoutException catch (e) {
        expect(e.timeout, equals(const Duration(milliseconds: 50)));
        // Message format: "Request timed out after Xs"
        expect(e.message, contains('timed out'));
      }

      client.close();
    });

    test('successful request completes before timeout', () async {
      final mockClient = MockClient((request) async {
        // Fast response
        return http.Response(
          '{"id":"chat-123","object":"chat.completion","created":1234567890,'
          '"model":"gpt-4","choices":[{"index":0,"message":{"role":"assistant",'
          '"content":"Hi!"},"finish_reason":"stop"}],"usage":{"prompt_tokens":10,'
          '"completion_tokens":5,"total_tokens":15}}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          timeout: Duration(seconds: 30),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      final response = await client.chat.completions.create(
        ChatCompletionCreateRequest(
          model: 'gpt-4',
          messages: [ChatMessage.user('Hello')],
        ),
      );

      expect(response.id, equals('chat-123'));

      client.close();
    });

    test('default timeout is 10 minutes', () {
      const config = OpenAIConfig();
      expect(config.timeout, equals(const Duration(minutes: 10)));
    });

    test('timeout can be customized', () {
      const config = OpenAIConfig(timeout: Duration(seconds: 60));
      expect(config.timeout, equals(const Duration(seconds: 60)));
    });

    test('timeout applies to multipart requests', () {
      final mockClient = MockClient((request) async {
        await Future<void>.delayed(const Duration(seconds: 2));
        return http.Response('{}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          timeout: Duration(milliseconds: 100),
          maxRetries: 0,
        ),
        httpClient: mockClient,
      );

      expect(
        () => client.files.upload(
          bytes: [1, 2, 3, 4],
          filename: 'test.txt',
          purpose: FilePurpose.fineTune,
        ),
        throwsA(isA<RequestTimeoutException>()),
      );

      client.close();
    });
  });
}
