import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
// ignore: deprecated_member_use_from_same_package
import 'package:openai_dart/openai_dart_assistants.dart';
import 'package:test/test.dart';

void main() {
  group('Runs Streaming Headers', () {
    test(
      'runs stream includes all required headers including OpenAI-Beta',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient.streaming((request, _) async {
          requestCompleter.complete(request);
          return http.StreamedResponse(
            Stream.fromIterable([
              utf8.encode(
                'data: {"object":"thread.run.step.delta","data":{}}\n\n',
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
        await client.beta.threads.runs
            .createStream(
              'thread_123',
              const CreateRunRequest(assistantId: 'asst_456'),
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

        // IMPORTANT: Verify OpenAI-Beta header for Assistants API
        expect(request.headers['OpenAI-Beta'], equals('assistants=v2'));

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
      },
    );

    test('runs stream sets stream=true in request body', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"object":"thread.run.step.delta","data":{}}\n\n',
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

      await client.beta.threads.runs
          .createStream(
            'thread_123',
            const CreateRunRequest(assistantId: 'asst_456'),
          )
          .drain<void>();

      final request = await requestCompleter.future as http.Request;
      final body = jsonDecode(request.body) as Map<String, dynamic>;

      expect(body['stream'], isTrue);

      client.close();
    });

    test('runs stream uses proper URL with thread ID', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"object":"thread.run.step.delta","data":{}}\n\n',
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

      await client.beta.threads.runs
          .createStream(
            'thread_abc123',
            const CreateRunRequest(assistantId: 'asst_xyz'),
          )
          .drain<void>();

      final request = await requestCompleter.future;

      // Verify URL includes thread ID
      expect(request.url.path, endsWith('/threads/thread_abc123/runs'));

      client.close();
    });

    test('runs stream handles Azure-style base URL correctly', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient.streaming((request, _) async {
        requestCompleter.complete(request);
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"object":"thread.run.step.delta","data":{}}\n\n',
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

      await client.beta.threads.runs
          .createStream(
            'thread_123',
            const CreateRunRequest(assistantId: 'asst_456'),
          )
          .drain<void>();

      final request = await requestCompleter.future;

      // Verify URL is properly normalized
      expect(request.url.scheme, equals('https'));
      expect(request.url.host, equals('example.openai.azure.com'));
      expect(
        request.url.path,
        equals('/openai/deployments/my-deploy/threads/thread_123/runs'),
      );
      // Verify query params are preserved
      expect(request.url.queryParameters['api-version'], equals('2024-10-01'));

      client.close();
    });

    test('runs stream accepts abortTrigger parameter', () async {
      // This test verifies that the abortTrigger parameter is accepted by
      // runs.createStream(). The actual abort behavior is tested in
      // streaming_abort_test.dart.
      //
      // Note: When abortTrigger is provided, sendStream() creates its own
      // internal HTTP client, so we can't mock the actual request here.
      // Instead, we verify the type signature accepts the parameter.

      final mockClient = MockClient.streaming((request, _) async {
        return http.StreamedResponse(
          Stream.fromIterable([
            utf8.encode(
              'data: {"object":"thread.run.step.delta","data":{}}\n\n',
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
        final stream = c.beta.threads.runs.createStream(
          'thread_123',
          const CreateRunRequest(assistantId: 'asst_456'),
          abortTrigger: Completer<void>().future,
        );
      }

      // Not called, just here for compile-time verification
      // ignore: unused_local_variable
      final _ = verifyAbortTriggerAccepted;

      // Actually test streaming without abortTrigger (uses mock client)
      await client.beta.threads.runs
          .createStream(
            'thread_123',
            const CreateRunRequest(assistantId: 'asst_456'),
          )
          .drain<void>();

      client.close();
    });
  });
}
