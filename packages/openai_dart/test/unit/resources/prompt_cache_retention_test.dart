import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  // Fixture models exercise serialization without claiming model support.
  const retentionCases = <(PromptCacheRetention?, String?)>[
    (PromptCacheRetention.inMemory, 'in_memory'),
    (PromptCacheRetention.h24, '24h'),
    (PromptCacheRetention.unknown, 'unknown'),
    (null, null),
  ];

  group('Chat retention wire (CACHE-005)', () {
    for (final (retention, wire) in retentionCases) {
      for (final streaming in [false, true]) {
        test('${wire ?? 'omitted'} stream=$streaming exact request', () async {
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/chat/completions');
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'messages': [
                  {'role': 'user', 'content': 'Hello'},
                ],
                'prompt_cache_retention': ?wire,
                if (streaming) 'stream': true,
              });
              if (streaming) {
                return _sse(_chatJson(streaming: true));
              }
              return http.Response(jsonEncode(_chatJson()), 200);
            }),
          );

          final original = ChatCompletionCreateRequest(
            model: 'fixture-model',
            messages: [ChatMessage.user('Hello')],
            promptCacheRetention: retention ?? PromptCacheRetention.inMemory,
          );
          final request = retention == null
              ? original.copyWith(promptCacheRetention: null)
              : original;
          if (streaming) {
            final events = await client.chat.completions
                .createStream(request)
                .toList();
            expect(events.single.id, 'chatcmpl_fixture');
          } else {
            final result = await client.chat.completions.create(request);
            expect(result.id, 'chatcmpl_fixture');
          }
          expect(sends, 1);
        });
      }
    }
  });

  group('Compaction retention wire (CACHE-005)', () {
    for (final (retention, wire) in retentionCases) {
      for (final beta in [false, true]) {
        test('${wire ?? 'omitted'} beta=$beta exact request', () async {
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/responses/compact');
              expect(
                request.url.queryParameters,
                beta ? {'beta': 'true'} : <String, String>{},
              );
              expect(request.headers.containsKey('openai-beta'), beta);
              if (beta) {
                expect(
                  request.headers['openai-beta'],
                  'responses_multi_agent=v1',
                );
              }
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': 'compact text',
                'prompt_cache_retention': ?wire,
              });
              return http.Response(
                jsonEncode({
                  'id': 'cmp_fixture',
                  'object': 'response.compaction',
                  'created_at': 0,
                  'output': <Object>[],
                  'usage': {
                    'input_tokens': 0,
                    'input_tokens_details': {
                      'cached_tokens': 0,
                      'cache_write_tokens': 0,
                    },
                    'output_tokens': 0,
                    'output_tokens_details': {'reasoning_tokens': 0},
                    'total_tokens': 0,
                  },
                }),
                200,
              );
            }),
          );

          final original = CompactResponseRequest(
            model: 'fixture-model',
            input: const ResponseInput.text('compact text'),
            promptCacheRetention: retention ?? PromptCacheRetention.inMemory,
          );
          final request = retention == null
              ? original.copyWith(promptCacheRetention: null)
              : original;
          final result = await client.responses.compact(request, beta: beta);
          expect(result.id, 'cmp_fixture');
          expect(result.usage.totalTokens, 0);
          expect(sends, 1);
        });
      }
    }
  });

  group('Response retention parsing and serialization (CACHE-005)', () {
    const responseCases = <(String?, PromptCacheRetention?, String?)>[
      ('in_memory', PromptCacheRetention.inMemory, 'in_memory'),
      ('in-memory', PromptCacheRetention.inMemory, 'in_memory'),
      ('24h', PromptCacheRetention.h24, '24h'),
      ('future-retention', PromptCacheRetention.unknown, 'unknown'),
      (null, null, null),
    ];
    for (final (wire, retention, canonical) in responseCases) {
      for (final streaming in [false, true]) {
        test('${wire ?? 'omitted'} stream=$streaming', () async {
          var sends = 0;
          final client = _client(
            MockClient((request) async {
              sends++;
              expect(request.method, 'POST');
              expect(request.url.path, '/v1/responses');
              // CACHE-006 adds a Responses request control in a separate ticket.
              expect(jsonDecode(request.body), {
                'model': 'fixture-model',
                'input': 'Hello',
                if (streaming) 'stream': true,
              });
              if (streaming) {
                return _sse({
                  'type': 'response.completed',
                  'sequence_number': 7,
                  'response': _responseJson(wire),
                });
              }
              return http.Response(jsonEncode(_responseJson(wire)), 200);
            }),
          );
          const request = CreateResponseRequest(
            model: 'fixture-model',
            input: ResponseInput.text('Hello'),
          );

          late final Response response;
          if (streaming) {
            final events = await client.responses
                .createStream(request)
                .toList();
            expect(events, hasLength(1));
            expect(events.single, isA<ResponseCompletedEvent>());
            final event = events.single as ResponseCompletedEvent;
            expect(event.sequenceNumber, 7);
            response = event.response;
            final nested = event.toJson()['response'] as Map<String, dynamic>;
            expect(nested['prompt_cache_retention'], canonical);
            expect(
              nested.containsKey('prompt_cache_retention'),
              canonical != null,
            );
          } else {
            response = await client.responses.create(request);
          }
          expect(response.id, 'resp_fixture');
          expect(response.promptCacheRetention, retention);
          expect(response.toJson()['prompt_cache_retention'], canonical);
          expect(
            response.toJson().containsKey('prompt_cache_retention'),
            canonical != null,
          );
          expect(sends, 1);
        });
      }
    }

    test('explicit response null normalizes to omitted JSON', () {
      final response = Response.fromJson({
        ..._responseJson(null),
        'prompt_cache_retention': null,
      });
      expect(response.promptCacheRetention, isNull);
      expect(response.toJson().containsKey('prompt_cache_retention'), isFalse);
    });
  });
}

OpenAIClient _client(http.Client transport) {
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
  return client;
}

http.Response _sse(Map<String, dynamic> json) => http.Response(
  'data: ${jsonEncode(json)}\n\ndata: [DONE]\n\n',
  200,
  headers: {'content-type': 'text/event-stream'},
);

Map<String, dynamic> _chatJson({bool streaming = false}) => {
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

Map<String, dynamic> _responseJson(String? retention) => {
  'access_programs': null,
  'id': 'resp_fixture',
  'object': 'response',
  'created_at': 0,
  'status': 'completed',
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'model': 'fixture-model',
  'tools': <Object>[],
  'output': <Object>[],
  'parallel_tool_calls': false,
  'metadata': <String, String>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
  'prompt_cache_retention': ?retention,
};
