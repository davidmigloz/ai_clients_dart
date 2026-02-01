import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Include Query Parameters', () {
    test(
      'responses.retrieve sends include[] as repeated query params',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            '{"id":"resp_123","object":"response","created_at":1234567890,'
            '"model":"gpt-4","status":"completed","output":[],'
            '"parallel_tool_calls":true,"tool_choice":"auto"}',
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.responses.retrieve(
          'resp_123',
          include: [Include.fileSearchResults, Include.codeInterpreterOutputs],
        );

        final request = await requestCompleter.future;

        // Verify include[] is properly encoded as repeated query parameters
        final includeParams = request.url.queryParametersAll['include[]'];
        expect(includeParams, isNotNull);
        expect(includeParams, hasLength(2));
        expect(includeParams, contains('file_search_call.results'));
        expect(includeParams, contains('code_interpreter_call.outputs'));

        // Verify the path is clean (no query string embedded in path)
        expect(request.url.path, endsWith('/responses/resp_123'));
        expect(request.url.path, isNot(contains('?')));

        client.close();
      },
    );

    test(
      'conversations.items.list sends include[] with other query params',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            '{"object":"list","data":[],"has_more":false}',
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.conversations.items.list(
          'conv_123',
          limit: 50,
          order: 'desc',
          include: [
            'file_search_call.results',
            'message.input_image.image_url',
          ],
        );

        final request = await requestCompleter.future;

        // Verify include[] is properly encoded as repeated query parameters
        final includeParams = request.url.queryParametersAll['include[]'];
        expect(includeParams, isNotNull);
        expect(includeParams, hasLength(2));
        expect(includeParams, contains('file_search_call.results'));
        expect(includeParams, contains('message.input_image.image_url'));

        // Verify other query params are also present
        expect(request.url.queryParameters['limit'], equals('50'));
        expect(request.url.queryParameters['order'], equals('desc'));

        // Verify the path is clean
        expect(request.url.path, endsWith('/conversations/conv_123/items'));
        expect(request.url.path, isNot(contains('?')));

        client.close();
      },
    );

    test(
      'conversations.items.retrieve sends include[] as repeated params',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            '{"id":"item_123","type":"message","role":"user",'
            '"content":[{"type":"input_text","text":"Hello"}]}',
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
          ),
          httpClient: mockClient,
        );

        await client.conversations.items.retrieve(
          'conv_123',
          'item_123',
          include: ['file_search_call.results'],
        );

        final request = await requestCompleter.future;

        // Verify include[] is properly encoded
        final includeParams = request.url.queryParametersAll['include[]'];
        expect(includeParams, isNotNull);
        expect(includeParams, hasLength(1));
        expect(includeParams, contains('file_search_call.results'));

        client.close();
      },
    );

    test(
      'buildUrlWithQueryAll preserves Azure-style base URL query params',
      () async {
        final requestCompleter = Completer<http.BaseRequest>();

        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            '{"id":"resp_123","object":"response","created_at":1234567890,'
            '"model":"gpt-4","status":"completed","output":[],'
            '"parallel_tool_calls":true,"tool_choice":"auto"}',
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

        await client.responses.retrieve(
          'resp_123',
          include: [Include.fileSearchResults],
        );

        final request = await requestCompleter.future;

        // Verify base URL query params are preserved
        expect(
          request.url.queryParameters['api-version'],
          equals('2024-10-01'),
        );

        // Verify include[] is also present
        final includeParams = request.url.queryParametersAll['include[]'];
        expect(includeParams, isNotNull);
        expect(includeParams, contains('file_search_call.results'));

        client.close();
      },
    );

    test('works without include params', () async {
      final requestCompleter = Completer<http.BaseRequest>();

      final mockClient = MockClient((request) async {
        requestCompleter.complete(request);
        return http.Response(
          '{"id":"resp_123","object":"response","created_at":1234567890,'
          '"model":"gpt-4","status":"completed","output":[],'
          '"parallel_tool_calls":true,"tool_choice":"auto"}',
          200,
        );
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
        httpClient: mockClient,
      );

      await client.responses.retrieve('resp_123');

      final request = await requestCompleter.future;

      // Verify no include[] params when not specified
      expect(request.url.queryParametersAll['include[]'], isNull);

      client.close();
    });
  });
}
