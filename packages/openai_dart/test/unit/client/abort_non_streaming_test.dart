import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Non-streaming with abortTrigger', () {
    test(
      'chat.completions.create with abortTrigger does not throw StateError',
      () async {
        // Regression test for https://github.com/davidmigloz/ai_clients_dart/issues/209
        // The _AbortableRequestWrapper.finalize() previously called
        // super.finalize() before setting contentLength, which marked the
        // wrapper as finalized and made the contentLength setter throw
        // StateError.
        final mockClient = MockClient((request) async {
          final body = await _readBody(request);
          // Ensure body actually flowed through to the transport.
          expect(body, contains('"messages"'));
          return http.Response(
            jsonEncode({
              'id': 'chat-1',
              'object': 'chat.completion',
              'created': 1234567890,
              'model': 'gpt-4',
              'choices': [
                {
                  'index': 0,
                  'message': {'role': 'assistant', 'content': 'hi'},
                  'finish_reason': 'stop',
                },
              ],
              'usage': {
                'prompt_tokens': 1,
                'completion_tokens': 1,
                'total_tokens': 2,
              },
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: mockClient,
        );

        final neverAbort = Completer<void>().future;

        final response = await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello')],
          ),
          abortTrigger: neverAbort,
        );

        expect(response.id, equals('chat-1'));

        client.close();
      },
    );

    test(
      'content-length header reflects body when abortTrigger is set',
      () async {
        // The wrapper must mirror the inner request's contentLength so that the
        // HTTP transport sends the correct Content-Length header.
        int? observedContentLength;
        final mockClient = MockClient((request) async {
          observedContentLength = request.contentLength;
          return http.Response(
            jsonEncode({
              'id': 'chat-2',
              'object': 'chat.completion',
              'created': 1,
              'model': 'gpt-4',
              'choices': [
                {
                  'index': 0,
                  'message': {'role': 'assistant', 'content': 'ok'},
                  'finish_reason': 'stop',
                },
              ],
              'usage': {
                'prompt_tokens': 1,
                'completion_tokens': 1,
                'total_tokens': 2,
              },
            }),
            200,
          );
        });

        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: mockClient,
        );

        final neverAbort = Completer<void>().future;
        await client.chat.completions.create(
          ChatCompletionCreateRequest(
            model: 'gpt-4',
            messages: [ChatMessage.user('Hello world')],
          ),
          abortTrigger: neverAbort,
        );

        expect(observedContentLength, isNotNull);
        expect(observedContentLength, greaterThan(0));

        client.close();
      },
    );
  });
}

Future<String> _readBody(http.BaseRequest request) async {
  if (request is http.Request) {
    return request.body;
  }
  final bytes = await request.finalize().toBytes();
  return utf8.decode(bytes);
}
