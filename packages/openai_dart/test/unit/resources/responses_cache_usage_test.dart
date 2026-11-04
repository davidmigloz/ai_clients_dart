import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final beta in [false, true]) {
    for (final streaming in [false, true]) {
      test(
        'cache override, hosted usage and missing find URL beta=$beta stream=$streaming',
        () async {
          var sends = 0;
          final expected = _response();
          final transport = MockClient((request) async {
            sends++;
            expect(request.method, 'POST');
            expect(request.url.path, '/v1/responses');
            expect(
              request.url.queryParameters,
              beta ? {'beta': 'true'} : <String, String>{},
            );
            expect(request.headers['authorization'], 'Bearer synthetic-key');
            expect(
              request.headers['openai-beta'],
              beta ? 'responses_multi_agent=v1' : null,
            );
            final body = jsonDecode(request.body) as Map<String, dynamic>;
            final input = body['input'] as List<dynamic>;
            final content =
                (input.single as Map<String, dynamic>)['content']
                    as List<dynamic>;
            expect(content, [
              {
                'type': 'input_text',
                'text': 'Long-lived policy',
                'prompt_cache_breakpoint': {'mode': 'explicit', 'ttl': '12h'},
              },
              {
                'type': 'input_text',
                'text': 'Session context',
                'prompt_cache_breakpoint': {'mode': 'explicit', 'ttl': '30m'},
              },
              {
                'type': 'input_text',
                'text': 'Current question',
                'prompt_cache_breakpoint': {'mode': 'explicit'},
              },
            ]);
            expect(body['prompt_cache_options'], {
              'ttl': '30m',
              'mode': 'explicit',
            });
            return _http(expected, streaming: streaming);
          });
          final client = _client(transport);
          final request = CreateResponseRequest(
            model: 'fixture-model',
            input: ResponseInput.items([
              MessageItem.user(const [
                InputTextContent(
                  'Long-lived policy',
                  promptCacheBreakpoint: PromptCacheBreakpointConfig(
                    ttl: PromptCacheBreakpointTtl.hours12,
                  ),
                ),
                InputTextContent(
                  'Session context',
                  promptCacheBreakpoint: PromptCacheBreakpointConfig(
                    ttl: PromptCacheBreakpointTtl.minutes30,
                  ),
                ),
                InputTextContent(
                  'Current question',
                  promptCacheBreakpoint: PromptCacheBreakpointConfig(),
                ),
              ]),
            ]),
            promptCacheOptions: const ResponsePromptCacheOptionsParam(
              ttl: PromptCacheTtl.minutes30,
              mode: PromptCacheMode.explicit,
            ),
          );
          final response = streaming
              ? (await client.responses
                        .createStream(request, beta: beta)
                        .toList())
                    .whereType<ResponseCompletedEvent>()
                    .single
                    .response
              : await client.responses.create(request, beta: beta);
          expect(sends, 1);
          expect(response.usage!.inputTokens, 100);
          expect(response.toolUsage!.imageGen.inputTokens, 10);
          expect(response.toolUsage!.imageGen.cachedTokens, isNull);
          expect(response.toolUsage!.webSearch.numRequests, 1);
          expect(response.toJson()['tool_usage'], expected['tool_usage']);
          expect(response.copyWith(), response);
          expect(
            response
                .copyWith(toolUsage: null)
                .toJson()
                .containsKey('tool_usage'),
            isFalse,
          );
          expect(Response.fromJson(response.toJson()), response);
          expect(
            Response.fromJson(response.toJson()).hashCode,
            response.hashCode,
          );
          final call = response.output.single as WebSearchCallOutputItem;
          expect((call.action! as WebSearchActionFind).url, isNull);
          expect(response.toString(), contains('toolUsage:'));
        },
      );

      test(
        'nullable provider error survives failed response beta=$beta stream=$streaming',
        () async {
          final fixture = _response()
            ..['status'] = 'failed'
            ..['output'] = <Object>[];
          fixture['error'] = {
            'code': 'server_error',
            'message': 'private',
            'type': null,
            'param': null,
            'misalignment': {'detailed_explanation': 'details'},
            'future': {
              'x': [1],
            },
          };
          final client = _client(
            MockClient(
              (_) async => _http(fixture, streaming: streaming, failed: true),
            ),
          );
          const request = CreateResponseRequest(
            model: 'fixture-model',
            input: ResponseInput.text('Hello'),
          );
          final response = streaming
              ? (await client.responses
                        .createStream(request, beta: beta)
                        .toList())
                    .whereType<ResponseFailedEvent>()
                    .single
                    .response
              : await client.responses.create(request, beta: beta);
          expect(response.error!.type, isNull);
          expect(response.error!.param, isNull);
          expect(response.error!.toJson(), fixture['error']);
        },
      );
    }

    test(
      'input-item retrieval preserves cached image/file/text boundaries beta=$beta',
      () async {
        final parts =
            <Map<String, dynamic>>[
                  {'type': 'input_text', 'text': 'policy'},
                  {
                    'type': 'input_image',
                    'image_url': 'https://example.invalid/a.png',
                  },
                  {'type': 'input_file', 'file_id': 'file_1'},
                ]
                .map(
                  (p) => {
                    ...p,
                    'prompt_cache_breakpoint': {
                      'mode': 'explicit',
                      'ttl': '12h',
                    },
                  },
                )
                .toList();
        final client = _client(
          MockClient((request) async {
            expect(request.method, 'GET');
            expect(request.url.path, '/v1/responses/resp_fixture/input_items');
            expect(
              request.headers['openai-beta'],
              beta ? 'responses_multi_agent=v1' : null,
            );
            return http.Response(
              jsonEncode({
                'object': 'list',
                'data': [
                  {
                    'type': 'message',
                    'id': 'msg_1',
                    'role': 'user',
                    'content': parts,
                  },
                ],
                'first_id': 'msg_1',
                'last_id': 'msg_1',
                'has_more': false,
              }),
              200,
            );
          }),
        );
        final result = await client.responses.inputItems.list(
          'resp_fixture',
          beta: beta,
        );
        expect(
          (result.data.single as MessageItem).content
              .map((p) => p.toJson())
              .toList(),
          parts,
        );
      },
    );
  }

  test('video retrieval exposes nullable Error-2 diagnostics', () async {
    final error = {
      'code': 'server_error',
      'message': 'private',
      'type': null,
      'param': null,
      'headers': {'retry-after': '1'},
      'misalignment': {'review_target': null},
    };
    final client = _client(
      MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.path, '/v1/videos/video_1');
        return http.Response(
          jsonEncode({
            'id': 'video_1',
            'object': 'video',
            'model': 'fixture-model',
            'status': 'failed',
            'progress': 0,
            'created_at': 0,
            'completed_at': null,
            'expires_at': null,
            'prompt': 'fixture',
            'size': '720x1280',
            'seconds': '4',
            'remixed_from_video_id': null,
            'error': error,
          }),
          200,
        );
      }),
    );
    final video = await client.videos.retrieve('video_1');
    expect(video.error!.toJson(), error);
  });

  test(
    'HTTP errors preserve explicit nullable diagnostics and original body',
    () async {
      final body = {
        'error': {
          'code': 'invalid_prompt',
          'message': 'private',
          'type': null,
          'param': null,
          'misalignment': {'detailed_explanation': 'details'},
        },
      };
      final client = _client(
        MockClient((_) async => http.Response(jsonEncode(body), 400)),
      );
      await expectLater(
        client.responses.create(
          const CreateResponseRequest(
            model: 'fixture-model',
            input: ResponseInput.text('Hello'),
          ),
        ),
        throwsA(
          isA<BadRequestException>()
              .having((e) => e.type, 'type', isNull)
              .having((e) => e.param, 'param', isNull)
              .having((e) => e.body, 'body', body),
        ),
      );
    },
  );

  test(
    'standalone SSE error retains explicit null parameter and legacy raw type',
    () async {
      final events = [
        {
          'type': 'error',
          'sequence_number': 1,
          'code': 'server_error',
          'message': 'failed',
          'param': null,
        },
        {
          'type': 'error',
          'sequence_number': 2,
          'error': {
            'type': null,
            'code': 'server_error',
            'message': 'failed',
            'param': null,
          },
        },
      ];
      final client = _client(
        MockClient(
          (_) async => http.Response(
            '${events.map((e) => 'event: error\ndata: ${jsonEncode(e)}\n\n').join()}data: [DONE]\n\n',
            200,
            headers: {'content-type': 'text/event-stream'},
          ),
        ),
      );
      final result = await client.responses
          .createStream(
            const CreateResponseRequest(
              model: 'fixture-model',
              input: ResponseInput.text('Hello'),
            ),
          )
          .toList();
      final errors = result.cast<ErrorEvent>();
      for (final e in errors) {
        expect(e.param, isNull);
        expect(e.toJson().containsKey('param'), isTrue);
      }
      expect(errors.last.rawJson['error'], events.last['error']);
    },
  );
}

OpenAIClient _client(http.Client transport) {
  final client = OpenAIClient(
    config: const OpenAIConfig(
      authProvider: ApiKeyProvider('synthetic-key'),
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

http.Response _http(
  Map<String, dynamic> body, {
  required bool streaming,
  bool failed = false,
}) {
  if (!streaming) return http.Response(jsonEncode(body), 200);
  final type = failed ? 'response.failed' : 'response.completed';
  return http.Response(
    'event: $type\ndata: ${jsonEncode({'type': type, 'sequence_number': 0, 'response': body})}\n\ndata: [DONE]\n\n',
    200,
    headers: {'content-type': 'text/event-stream'},
  );
}

Map<String, dynamic> _response() => {
  'access_programs': null,
  'id': 'resp_fixture',
  'object': 'response',
  'created_at': 0,
  'status': 'completed',
  'model': 'fixture-model',
  'error': null,
  'incomplete_details': null,
  'instructions': null,
  'tools': <Object>[],
  'output': [
    {
      'type': 'web_search_call',
      'id': 'ws_1',
      'status': 'completed',
      'action': {'type': 'find_in_page', 'pattern': 'text'},
    },
  ],
  'parallel_tool_calls': false,
  'metadata': <String, String>{},
  'tool_choice': 'auto',
  'temperature': 1.0,
  'top_p': 1.0,
  'usage': {
    'input_tokens': 100,
    'output_tokens': 2,
    'total_tokens': 102,
    'input_tokens_details': {'cached_tokens': 0, 'cache_write_tokens': 10},
    'output_tokens_details': {'reasoning_tokens': 0},
  },
  'tool_usage': {
    'image_gen': {
      'input_tokens': 10,
      'output_tokens': 20,
      'total_tokens': 30,
      'input_tokens_details': {'text_tokens': 3, 'image_tokens': 7},
    },
    'web_search': {'num_requests': 1},
  },
};
