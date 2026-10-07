import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  final cases =
      <String, (ChatCompletionCreateRequest Function(), Map<String, dynamic>?)>{
        'mode and TTL': (
          () => _request(
            const PromptCacheOptionsParam(
              mode: PromptCacheMode.explicit,
              ttl: PromptCacheTtl.minutes30,
            ),
          ),
          {'mode': 'explicit', 'ttl': '30m'},
        ),
        'mode only': (
          () => _request(
            const PromptCacheOptionsParam(mode: PromptCacheMode.implicit),
          ),
          {'mode': 'implicit'},
        ),
        'TTL only': (
          () => _request(
            const PromptCacheOptionsParam(ttl: PromptCacheTtl.minutes30),
          ),
          {'ttl': '30m'},
        ),
        'empty': (
          () => _request(const PromptCacheOptionsParam()),
          <String, dynamic>{},
        ),
        'omitted': (() => _request(null), null),
        'cleared': (
          () => _request(
            const PromptCacheOptionsParam(mode: PromptCacheMode.explicit),
          ).copyWith(promptCacheOptions: null),
          null,
        ),
        'Responses-only members ignored': (
          () {
            final json = <String, dynamic>{
              'model': 'fixture-model',
              'messages': [
                {'role': 'user', 'content': 'Hello'},
              ],
              'prompt_cache_options': <dynamic, dynamic>{
                'mode': 'explicit',
                'ttl': '30m',
                'comparison_response_id': 'resp_must_not_be_sent',
                'prewarm': true,
              },
            };
            return ChatCompletionCreateRequest.fromJson(json);
          },
          {'mode': 'explicit', 'ttl': '30m'},
        ),
        'only Responses members become empty Chat options': (
          () {
            final json = <String, dynamic>{
              'model': 'fixture-model',
              'messages': [
                {'role': 'user', 'content': 'Hello'},
              ],
              'prompt_cache_options': {
                'comparison_response_id': 'resp_must_not_be_sent',
                'prewarm': false,
              },
            };
            return ChatCompletionCreateRequest.fromJson(json);
          },
          <String, dynamic>{},
        ),
      };

  for (final streaming in [false, true]) {
    group('Chat cache options stream=$streaming (CACHE-004)', () {
      for (final entry in cases.entries) {
        test('${entry.key} reaches the exact public request', () async {
          var sends = 0;
          final expectedOptions = entry.value.$2;
          final expectedBody = <String, dynamic>{
            'model': 'fixture-model',
            'messages': [
              {'role': 'user', 'content': 'Hello'},
            ],
            if (streaming) 'stream_options': {'include_usage': true},
            'prompt_cache_options': ?expectedOptions,
            if (streaming) 'stream': true,
          };
          final transport = MockClient((request) async {
            sends++;
            expect(request.method, 'POST');
            expect(request.url.path, '/v1/chat/completions');
            expect(request.url.queryParameters, isEmpty);
            expect(request.headers['authorization'], 'Bearer sk-fixture');
            expect(request.headers['content-type'], 'application/json');
            if (streaming) {
              expect(request.headers['accept'], 'text/event-stream');
            }
            expect(request.bodyBytes, utf8.encode(jsonEncode(expectedBody)));
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            expect(body, expectedBody);
            expect(
              body.containsKey('prompt_cache_options'),
              expectedOptions != null,
            );
            expect(body.containsKey('stream'), streaming);
            expect(request.body, isNot(contains('comparison_response_id')));
            expect(request.body, isNot(contains('prewarm')));
            expect(request.body, isNot(contains('resp_must_not_be_sent')));
            final responseJson = _chatJson(streaming: streaming);
            return http.Response(
              streaming
                  ? 'data: ${jsonEncode(responseJson)}\n\ndata: [DONE]\n\n'
                  : jsonEncode(responseJson),
              200,
              headers: {
                'content-type': streaming
                    ? 'text/event-stream'
                    : 'application/json',
              },
            );
          });
          final client = OpenAIClient(
            config: const OpenAIConfig(
              authProvider: ApiKeyProvider('sk-fixture'),
              baseUrl: 'https://api.example.invalid/v1',
              retryPolicy: RetryPolicy(maxRetries: 0),
            ),
            httpClient: transport,
          );
          addTearDown(() {
            client.close();
            transport.close();
          });

          final original = entry.value.$1();
          final request = streaming
              ? original.copyWith(
                  streamOptions: const StreamOptions(includeUsage: true),
                )
              : original;
          if (streaming) {
            final events = await client.chat.completions
                .createStream(request)
                .toList();
            expect(events, hasLength(1));
            expect(events.single.id, 'chatcmpl_fixture');
            expect(events.single.textDelta, 'ok');
          } else {
            final completion = await client.chat.completions.create(request);
            expect(completion.id, 'chatcmpl_fixture');
            expect(completion.text, 'ok');
          }
          expect(sends, 1);
        });
      }
    });
  }
}

ChatCompletionCreateRequest _request(PromptCacheOptionsParam? options) =>
    ChatCompletionCreateRequest(
      model: 'fixture-model',
      messages: [ChatMessage.user('Hello')],
      promptCacheOptions: options,
    );

Map<String, dynamic> _chatJson({required bool streaming}) => {
  'id': 'chatcmpl_fixture',
  'object': streaming ? 'chat.completion.chunk' : 'chat.completion',
  'created': 0,
  'model': 'fixture-model',
  'choices': [
    {
      'index': 0,
      'finish_reason': 'stop',
      'logprobs': null,
      if (streaming)
        'delta': {'role': 'assistant', 'content': 'ok'}
      else
        'message': {'role': 'assistant', 'content': 'ok'},
    },
  ],
};
