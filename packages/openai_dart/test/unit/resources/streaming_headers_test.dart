import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Streaming Headers', () {
    test('chat stream includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        // Return an empty stream that ends immediately
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode('data: {"choices":[]}\n\n'),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          organization: 'test-org',
          project: 'test-project',
          apiVersion: '2024-01-01',
          defaultHeaders: {'X-Custom-Header': 'custom-value'},
        ),
        httpClient: mockClient,
      );

      // Consume the stream to trigger the request
      await client.chat.completions
          .createStream(
            ChatCompletionCreateRequest(
              model: 'gpt-4',
              messages: [ChatMessage.user('Hello')],
            ),
          )
          .drain<void>();

      final request = await requestCompleter.future;

      // Verify auth header
      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));

      // Verify organization and project headers
      expect(request.headers['OpenAI-Organization'], equals('test-org'));
      expect(request.headers['OpenAI-Project'], equals('test-project'));

      // Verify API version header
      expect(request.headers['OpenAI-Version'], equals('2024-01-01'));

      // Verify streaming header
      expect(request.headers['Accept'], equals('text/event-stream'));

      // Verify content type
      expect(request.headers['Content-Type'], equals('application/json'));

      // Verify X-Request-ID is present
      expect(request.headers['X-Request-ID'], isNotNull);
      expect(request.headers['X-Request-ID'], isNotEmpty);

      // Verify custom default header
      expect(request.headers['X-Custom-Header'], equals('custom-value'));

      client.close();
    });

    test('responses stream includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"type":"response.completed","response":{"id":"resp_123","object":"response","created_at":1234567890,"model":"gpt-4","status":"completed","output":[],"parallel_tool_calls":true,"tool_choice":"auto"}}\n\n',
            ),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          organization: 'test-org',
          project: 'test-project',
          apiVersion: '2024-01-01',
          defaultHeaders: {'X-Custom-Header': 'custom-value'},
        ),
        httpClient: mockClient,
      );

      // Consume the stream to trigger the request
      await client.responses
          .createStream(
            const CreateResponseRequest(
              model: 'gpt-4',
              input: ResponseInput.text('Hello'),
            ),
          )
          .drain<void>();

      final request = await requestCompleter.future;

      // Verify auth header
      expect(request.headers['Authorization'], equals('Bearer sk-test-key'));

      // Verify organization and project headers
      expect(request.headers['OpenAI-Organization'], equals('test-org'));
      expect(request.headers['OpenAI-Project'], equals('test-project'));

      // Verify API version header
      expect(request.headers['OpenAI-Version'], equals('2024-01-01'));

      // Verify streaming header
      expect(request.headers['Accept'], equals('text/event-stream'));

      // Verify X-Request-ID is present
      expect(request.headers['X-Request-ID'], isNotNull);

      // Verify custom default header
      expect(request.headers['X-Custom-Header'], equals('custom-value'));

      client.close();
    });

    test(
      'streaming uses proper URL normalization with Azure-style base URL',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient.streaming((request, _) async {
          requestCompleter.complete(request);
          return http.StreamedResponse(
            Stream.fromIterable([
              utf8.encode('data: {"choices":[]}\n\n'),
              utf8.encode('data: [DONE]\n\n'),
            ]),
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
            baseUrl:
                'https://example.openai.azure.com/openai/deployments/my-deploy?api-version=2024-10-01',
          ),
          httpClient: mockClient,
        );

        await client.chat.completions
            .createStream(
              ChatCompletionCreateRequest(
                model: 'gpt-4',
                messages: [ChatMessage.user('Hello')],
              ),
            )
            .drain<void>();

        final request = await requestCompleter.future;

        // Verify URL is properly normalized
        expect(request.url.scheme, equals('https'));
        expect(request.url.host, equals('example.openai.azure.com'));
        expect(
          request.url.path,
          equals('/openai/deployments/my-deploy/chat/completions'),
        );
        // Verify query params are preserved
        expect(
          request.url.queryParameters['api-version'],
          equals('2024-10-01'),
        );

        client.close();
      },
    );

    test('stream sets stream=true in request body', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode('data: {"choices":[]}\n\n'),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.chat.completions
          .createStream(
            ChatCompletionCreateRequest(
              model: 'gpt-4',
              messages: [ChatMessage.user('Hello')],
            ),
          )
          .drain<void>();

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['stream'], isTrue);

      client.close();
    });
  });
}
