import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final profile in ['populated', 'zero', 'provider']) {
    test('ordinary completion preserves $profile usage (CHAT-001)', () async {
      final wireUsage = _usageJson(profile);
      var sends = 0;
      final transport = MockClient((request) async {
        sends++;
        _expectRequest(request, streaming: false, options: null);
        return http.Response(
          jsonEncode({
            ..._chatJson(streaming: false),
            'choices': [
              {
                'index': 0,
                'message': {'role': 'assistant', 'content': 'ok'},
                'finish_reason': 'stop',
                'logprobs': null,
              },
            ],
            'usage': wireUsage,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      final client = _client(transport);
      addTearDown(() {
        client.close();
        transport.close();
      });

      final completion = await client.chat.completions.create(_request());
      expect(completion.text, 'ok');
      _expectUsage(completion.usage!, profile);
      expect(sends, 1);
    });
  }

  for (final control in <bool?>[null, false, true]) {
    for (final profile in ['populated', 'zero', 'provider']) {
      test(
        'stream padding=$control preserves $profile usage separately (CHAT-001/002)',
        () async {
          final options = StreamOptions(
            includeUsage: true,
            includeObfuscation: control,
          );
          final paddingEnabled = control != false;
          final chunks = [
            {
              ..._chatJson(streaming: true),
              'choices': [
                {
                  'index': 0,
                  'delta': {
                    'role': 'assistant',
                    'content': 'Hello',
                    'reasoning_content': 'Reasoning ',
                    'reasoning': 'Summary ',
                    'tool_calls': [
                      {
                        'index': 0,
                        'id': 'call_fixture',
                        'type': 'function',
                        'function': {
                          'name': 'get_value',
                          'arguments': '{"value":',
                        },
                      },
                    ],
                  },
                  'finish_reason': null,
                  'logprobs': null,
                },
              ],
              'usage': null,
              if (paddingEnabled) 'obfuscation': 'padding-private',
            },
            {
              ..._chatJson(streaming: true),
              'choices': [
                {
                  'index': 0,
                  'delta': {
                    'content': ' world',
                    'reasoning_content': 'step',
                    'reasoning': 'done',
                    'tool_calls': [
                      {
                        'index': 0,
                        'function': {'arguments': '1}'},
                      },
                    ],
                  },
                  'finish_reason': null,
                  'logprobs': null,
                },
              ],
              'usage': null,
              if (paddingEnabled) 'obfuscation': '',
            },
            {
              ..._chatJson(streaming: true),
              'choices': [
                {
                  'index': 0,
                  'delta': <String, dynamic>{},
                  'finish_reason': 'tool_calls',
                  'logprobs': null,
                },
              ],
              'usage': null,
            },
            {
              ..._chatJson(streaming: true),
              'choices': <Object>[],
              'usage': _usageJson(profile),
              if (paddingEnabled) 'obfuscation': 'usage-padding-private',
            },
          ];
          var sends = 0;
          final transport = MockClient((request) async {
            sends++;
            _expectRequest(request, streaming: true, options: options.toJson());
            return _sseResponse(chunks);
          });
          final client = _client(transport);
          addTearDown(() {
            client.close();
            transport.close();
          });

          final events = await client.chat.completions
              .createStream(_request().copyWith(streamOptions: options))
              .toList();
          expect(events, hasLength(4));
          expect(
            events.take(3).map((event) => event.usage),
            everyElement(isNull),
          );
          expect(
            events[0].obfuscation,
            paddingEnabled ? 'padding-private' : null,
          );
          expect(events[1].obfuscation, paddingEnabled ? '' : null);
          expect(events[1].toJson().containsKey('obfuscation'), paddingEnabled);
          expect(events.last.choices, isEmpty);
          expect(events.last.firstChoice, isNull);
          expect(events.last.textDelta, isNull);
          _expectUsage(events.last.usage!, profile);

          final accumulator = ChatStreamAccumulator();
          events.forEach(accumulator.add);
          expect(accumulator.content, 'Hello world');
          expect(accumulator.refusal, isEmpty);
          expect(accumulator.reasoningContent, 'Reasoning step');
          expect(accumulator.reasoning, 'Summary done');
          expect(accumulator.toolCalls, hasLength(1));
          expect(accumulator.toolCalls.single.id, 'call_fixture');
          expect(accumulator.toolCalls.single.function.name, 'get_value');
          expect(
            accumulator.toolCalls.single.function.arguments,
            '{"value":1}',
          );
          expect(accumulator.finishReason, FinishReason.toolCalls);
          expect(accumulator.usage, events.last.usage);
          final completion = accumulator.toChatCompletion();
          expect(completion.text, 'Hello world');
          expect(completion.choices.single.message.toJson(), {
            'role': 'assistant',
            'content': 'Hello world',
            'tool_calls': [
              {
                'id': 'call_fixture',
                'type': 'function',
                'function': {'name': 'get_value', 'arguments': '{"value":1}'},
              },
            ],
            'reasoning_content': 'Reasoning step',
            'reasoning': 'Summary done',
          });
          _expectUsage(completion.usage!, profile);
          expect(completion.toJson(), isNot(contains('obfuscation')));
          expect(
            jsonEncode(completion.toJson()),
            isNot(contains('padding-private')),
          );
          expect(sends, 1);
        },
      );
    }
  }

  test(
    'omitting stream options preserves the server padding default',
    () async {
      var sends = 0;
      final transport = MockClient((request) async {
        sends++;
        _expectRequest(request, streaming: true, options: null);
        return _sseResponse([
          {
            ..._chatJson(streaming: true),
            'choices': [
              {
                'index': 0,
                'delta': {'content': 'ok'},
                'finish_reason': 'stop',
                'logprobs': null,
              },
            ],
            'obfuscation': 'default-padding-private',
          },
        ]);
      });
      final client = _client(transport);
      addTearDown(() {
        client.close();
        transport.close();
      });
      final events = await client.chat.completions
          .createStream(_request())
          .toList();
      expect(events.single.obfuscation, 'default-padding-private');
      expect(events.single.textDelta, 'ok');
      expect(events.single.usage, isNull);
      final accumulator = ChatStreamAccumulator()..add(events.single);
      expect(accumulator.content, 'ok');
      expect(sends, 1);
    },
  );

  for (final invalid in <Object?>[null, false]) {
    test(
      'public stream rejects invalid present obfuscation: $invalid',
      () async {
        var sends = 0;
        final transport = MockClient((request) async {
          sends++;
          _expectRequest(request, streaming: true, options: null);
          return _sseResponse([
            {..._chatJson(streaming: true), 'obfuscation': invalid},
          ]);
        });
        final client = _client(transport);
        addTearDown(() {
          client.close();
          transport.close();
        });
        await expectLater(
          client.chat.completions.createStream(_request()).toList(),
          throwsA(
            isA<ParseException>().having(
              (error) => error.cause,
              'cause',
              isA<FormatException>().having(
                (error) => error.message,
                'context',
                contains('ChatStreamEvent.obfuscation'),
              ),
            ),
          ),
        );
        expect(sends, 1);
      },
    );
  }
}

ChatCompletionCreateRequest _request() => ChatCompletionCreateRequest(
  model: 'fixture-model',
  messages: [ChatMessage.user('Hello')],
);

OpenAIClient _client(http.Client transport) => OpenAIClient(
  config: const OpenAIConfig(
    authProvider: ApiKeyProvider('sk-fixture'),
    baseUrl: 'https://api.example.invalid/v1',
    retryPolicy: RetryPolicy(maxRetries: 0),
  ),
  httpClient: transport,
);

void _expectRequest(
  http.Request request, {
  required bool streaming,
  required Map<String, dynamic>? options,
}) {
  expect(request.method, 'POST');
  expect(request.url.path, '/v1/chat/completions');
  expect(request.url.queryParameters, isEmpty);
  expect(request.headers['authorization'], 'Bearer sk-fixture');
  expect(request.headers['content-type'], 'application/json');
  if (streaming) expect(request.headers['accept'], 'text/event-stream');
  expect(jsonDecode(request.body), {
    'model': 'fixture-model',
    'messages': [
      {'role': 'user', 'content': 'Hello'},
    ],
    'stream_options': ?options,
    if (streaming) 'stream': true,
  });
}

Map<String, dynamic> _chatJson({required bool streaming}) => {
  'id': 'chatcmpl_fixture',
  'object': streaming ? 'chat.completion.chunk' : 'chat.completion',
  'created': 0,
  'model': 'fixture-model',
  'choices': <Object>[],
};

http.Response _sseResponse(List<Map<String, dynamic>> chunks) => http.Response(
  '${chunks.map((chunk) => 'data: ${jsonEncode(chunk)}\n\n').join()}data: [DONE]\n\n',
  200,
  headers: {'content-type': 'text/event-stream'},
);

Map<String, dynamic> _usageJson(String profile) {
  if (profile == 'provider') {
    return {
      'prompt_tokens': 5,
      'total_tokens': 5,
      'prompt_tokens_details': null,
      'completion_tokens_details': null,
    };
  }
  final zero = profile == 'zero';
  return {
    'prompt_tokens': zero ? 0 : 100,
    'completion_tokens': zero ? 0 : 10,
    'total_tokens': zero ? 0 : 110,
    'prompt_tokens_details': {
      'audio_tokens': 0,
      'cached_tokens': zero ? 0 : 70,
      'cache_write_tokens': zero ? 0 : 20,
      'image_tokens': zero ? 0 : 4,
      'text_tokens': zero ? 0 : 96,
    },
    'completion_tokens_details': {
      'audio_tokens': 0,
      'reasoning_tokens': zero ? 0 : 2,
      'accepted_prediction_tokens': 0,
      'rejected_prediction_tokens': 0,
      'text_tokens': zero ? 0 : 8,
    },
  };
}

void _expectUsage(Usage usage, String profile) {
  if (profile == 'provider') {
    expect(usage.promptTokens, 5);
    expect(usage.totalTokens, 5);
    expect(usage.completionTokens, isNull);
    expect(usage.promptTokensDetails, isNull);
    expect(usage.completionTokensDetails, isNull);
    expect(usage.toJson(), {'prompt_tokens': 5, 'total_tokens': 5});
    return;
  }
  final zero = profile == 'zero';
  expect(usage.promptTokens, zero ? 0 : 100);
  expect(usage.completionTokens, zero ? 0 : 10);
  expect(usage.totalTokens, zero ? 0 : 110);
  expect(usage.promptTokensDetails!.cacheWriteTokens, zero ? 0 : 20);
  expect(usage.promptTokensDetails!.imageTokens, zero ? 0 : 4);
  expect(usage.promptTokensDetails!.textTokens, zero ? 0 : 96);
  expect(usage.completionTokensDetails!.textTokens, zero ? 0 : 8);
  expect(usage.toJson(), _usageJson(profile));
}
