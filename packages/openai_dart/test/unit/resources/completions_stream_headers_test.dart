import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Completions Streaming Headers', () {
    test('completions stream includes all required headers', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"id":"cmpl-test","object":"text_completion","created":1234567890,"model":"gpt-3.5-turbo-instruct","choices":[{"text":"Hello","index":0,"logprobs":null,"finish_reason":"stop"}]}\n\n',
            ),
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
      await client.completions
          .createStream(
            const CompletionRequest(
              model: 'gpt-3.5-turbo-instruct',
              prompt: CompletionPrompt.text('Hello'),
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

    test('completions stream sets stream=true in request body', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"id":"cmpl-test","object":"text_completion","created":1234567890,"model":"gpt-3.5-turbo-instruct","choices":[{"text":"Hello","index":0,"logprobs":null,"finish_reason":"stop"}]}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.completions
          .createStream(
            const CompletionRequest(
              model: 'gpt-3.5-turbo-instruct',
              prompt: CompletionPrompt.text('Hello'),
            ),
          )
          .drain<void>();

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['stream'], isTrue);

      client.close();
    });

    test(
      'completions stream uses proper URL normalization with Azure-style base URL',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient.streaming((request, _) async {
          requestCompleter.complete(request);
          return http.StreamedResponse(
            Stream.fromIterable([
              utf8.encode(
                'data: {"id":"cmpl-test","object":"text_completion","created":1234567890,"model":"gpt-3.5-turbo-instruct","choices":[{"text":"Hello","index":0,"logprobs":null,"finish_reason":"stop"}]}\n\n',
              ),
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

        await client.completions
            .createStream(
              const CompletionRequest(
                model: 'gpt-3.5-turbo-instruct',
                prompt: CompletionPrompt.text('Hello'),
              ),
            )
            .drain<void>();

        final request = await requestCompleter.future;

        // Verify URL is properly normalized
        expect(request.url.scheme, equals('https'));
        expect(request.url.host, equals('example.openai.azure.com'));
        expect(
          request.url.path,
          equals('/openai/deployments/my-deploy/completions'),
        );
        // Verify query params are preserved
        expect(
          request.url.queryParameters['api-version'],
          equals('2024-10-01'),
        );

        client.close();
      },
    );

    test('completions stream accepts abortTrigger parameter', () async {
      // This test verifies that the abortTrigger parameter is accepted by
      // completions.createStream(). The actual abort behavior is tested in
      // streaming_abort_test.dart.
      //
      // Note: When abortTrigger is provided, sendStream() creates its own
      // internal HTTP client, so we can't mock the actual request here.
      // Instead, we verify the type signature accepts the parameter.

      final mockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"id":"cmpl-test","object":"text_completion","created":1234567890,"model":"gpt-3.5-turbo-instruct","choices":[{"text":"Hello","index":0,"logprobs":null,"finish_reason":"stop"}]}\n\n',
            ),
            utf8.encode('data: [DONE]\n\n'),
          ]),
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      // Verify the type signature accepts abortTrigger (compile-time check)
      // The function reference proves the parameter exists without invoking it
      void verifyAbortTriggerAccepted(OpenAIClient c) {
        // ignore: unused_local_variable
        final stream = c.completions.createStream(
          const CompletionRequest(
            model: 'gpt-3.5-turbo-instruct',
            prompt: CompletionPrompt.text('Hello'),
          ),
          abortTrigger: Completer<void>().future,
        );
      }

      // Not called, just here for compile-time verification
      // ignore: unused_local_variable
      final _ = verifyAbortTriggerAccepted;

      // Actually test streaming without abortTrigger (uses mock client)
      await client.completions
          .createStream(
            const CompletionRequest(
              model: 'gpt-3.5-turbo-instruct',
              prompt: CompletionPrompt.text('Hello'),
            ),
          )
          .drain<void>();

      client.close();
    });
  });
}
