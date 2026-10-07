import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  for (final beta in [false, true]) {
    for (final streaming in [false, true]) {
      group('Responses cache controls beta=$beta stream=$streaming', () {
        for (final prewarm in [false, true]) {
          test(
            'prewarm=$prewarm, retention, and comparison reach the wire',
            () async {
              var sends = 0;
              final client = _client(
                MockClient((request) async {
                  sends++;
                  _expectProtocol(request, beta: beta, streaming: streaming);
                  expect(jsonDecode(request.body), {
                    'model': 'fixture-model',
                    'input': 'Hello',
                    'prompt_cache_key': 'fixture-key',
                    'prompt_cache_retention': '24h',
                    'prompt_cache_options': {
                      'mode': 'explicit',
                      'ttl': '30m',
                      'comparison_response_id': 'resp_previous',
                      'prewarm': prewarm,
                    },
                    if (streaming) 'stream': true,
                  });
                  return _httpResponse({
                    ..._responseJson(),
                    'prompt_cache_options': {
                      'mode': 'explicit',
                      'ttl': '30m',
                      'comparison_response_id': prewarm
                          ? 'resp_previous'
                          : null,
                    },
                    'prompt_cache_diagnostics': {
                      'type': 'cache_miss',
                      'reason': 'input_changed',
                      'cache_missed_tokens': 0,
                      'comparison_reusable_tokens': 0,
                    },
                  }, streaming: streaming);
                }),
              );
              final request = CreateResponseRequest(
                model: 'fixture-model',
                input: const ResponseInput.text('Hello'),
                promptCacheKey: 'fixture-key',
                promptCacheRetention: PromptCacheRetention.h24,
                promptCacheOptions: ResponsePromptCacheOptionsParam(
                  mode: PromptCacheMode.explicit,
                  ttl: PromptCacheTtl.minutes30,
                  comparisonResponseId: 'resp_previous',
                  prewarm: prewarm,
                ),
              );
              final response = await _create(
                client,
                request,
                beta: beta,
                streaming: streaming,
              );
              expect(
                response.promptCacheOptions!.comparisonResponseId,
                prewarm ? 'resp_previous' : null,
              );
              expect(response.promptCacheOptions!.toJson(), {
                'mode': 'explicit',
                'ttl': '30m',
                if (prewarm) 'comparison_response_id': 'resp_previous',
              });
              final miss =
                  response.promptCacheDiagnostics!
                      as PromptCacheMissDiagnostics;
              expect(miss.cacheMissedTokens, 0);
              expect(miss.comparisonReusableTokens, 0);
              expect(sends, 1);
            },
          );
        }

        for (final empty in [false, true]) {
          test(
            empty
                ? 'empty options are transmitted'
                : 'cleared controls are omitted',
            () async {
              var sends = 0;
              final client = _client(
                MockClient((request) async {
                  sends++;
                  _expectProtocol(request, beta: beta, streaming: streaming);
                  expect(jsonDecode(request.body), {
                    'model': 'fixture-model',
                    'input': 'Hello',
                    if (empty) 'prompt_cache_options': <String, dynamic>{},
                    if (streaming) 'stream': true,
                  });
                  return _httpResponse(_responseJson(), streaming: streaming);
                }),
              );
              const original = CreateResponseRequest(
                model: 'fixture-model',
                input: ResponseInput.text('Hello'),
                promptCacheRetention: PromptCacheRetention.h24,
                promptCacheOptions: ResponsePromptCacheOptionsParam(
                  prewarm: true,
                ),
              );
              final request = original.copyWith(
                promptCacheRetention: null,
                promptCacheOptions: empty
                    ? const ResponsePromptCacheOptionsParam()
                    : null,
              );
              final response = await _create(
                client,
                request,
                beta: beta,
                streaming: streaming,
              );
              expect(response.promptCacheDiagnostics, isNull);
              expect(sends, 1);
            },
          );
        }

        final diagnostics = <Map<String, dynamic>?>[
          for (final reason in [
            'model_changed',
            'prompt_cache_key_changed',
            'tools_changed',
            'text_format_changed',
            'reasoning_effort_changed',
            'verbosity_changed',
            'context_compacted',
            'input_changed',
            'service_tier_changed',
            'future_reason',
          ])
            {'type': 'cache_miss', 'reason': reason, 'cache_missed_tokens': 0},
          {'type': 'cache_hit'},
          {'type': 'comparison_response_not_found'},
          {'type': 'unavailable'},
          {
            'type': 'future_diagnostic',
            'nested': {'zero': 0, 'values': <Object>[]},
          },
          null,
        ];
        for (final diagnostic in diagnostics) {
          final label = diagnostic == null
              ? 'omitted'
              : '${diagnostic['type']} ${diagnostic['reason'] ?? ''}';
          test(
            '$label diagnostics survive the public response boundary',
            () async {
              var sends = 0;
              final client = _client(
                MockClient((request) async {
                  sends++;
                  _expectProtocol(request, beta: beta, streaming: streaming);
                  return _httpResponse({
                    ..._responseJson(),
                    'prompt_cache_diagnostics': ?diagnostic,
                  }, streaming: streaming);
                }),
              );
              final response = await _create(
                client,
                _request(),
                beta: beta,
                streaming: streaming,
              );
              expect(response.toJson()['prompt_cache_diagnostics'], diagnostic);
              expect(
                response.toJson().containsKey('prompt_cache_diagnostics'),
                diagnostic != null,
              );
              if (diagnostic?['type'] == 'cache_miss') {
                final miss =
                    response.promptCacheDiagnostics!
                        as PromptCacheMissDiagnostics;
                expect(miss.reason.toJson(), diagnostic!['reason']);
                expect(miss.comparisonReusableTokens, isNull);
              }
              expect(sends, 1);
            },
          );
        }

        test(
          'explicit diagnostics null fails contextually without replay',
          () async {
            var sends = 0;
            final client = _client(
              MockClient((request) async {
                sends++;
                return _httpResponse({
                  ..._responseJson(),
                  'prompt_cache_diagnostics': null,
                }, streaming: streaming);
              }),
            );
            await expectLater(
              _create(client, _request(), beta: beta, streaming: streaming),
              throwsA(
                isA<FormatException>().having(
                  (e) => e.message,
                  'context',
                  contains('Response.prompt_cache_diagnostics'),
                ),
              ),
            );
            expect(sends, 1);
          },
        );
      });
    }
  }
}

CreateResponseRequest _request() => const CreateResponseRequest(
  model: 'fixture-model',
  input: ResponseInput.text('Hello'),
);

Future<Response> _create(
  OpenAIClient client,
  CreateResponseRequest request, {
  required bool beta,
  required bool streaming,
}) async {
  if (!streaming) return client.responses.create(request, beta: beta);
  final events = await client.responses
      .createStream(request, beta: beta)
      .toList();
  expect(events, hasLength(1));
  expect(events.single, isA<ResponseCompletedEvent>());
  final completed = events.single as ResponseCompletedEvent;
  expect(completed.sequenceNumber, 0);
  final serialized = completed.toJson()['response'] as Map<String, dynamic>;
  expect(
    serialized['prompt_cache_diagnostics'],
    completed.response.promptCacheDiagnostics?.toJson(),
  );
  return completed.response;
}

void _expectProtocol(
  http.Request request, {
  required bool beta,
  required bool streaming,
}) {
  expect(request.method, 'POST');
  expect(request.url.path, '/v1/responses');
  expect(
    request.url.queryParameters,
    beta ? {'beta': 'true'} : <String, String>{},
  );
  expect(request.headers['authorization'], 'Bearer sk-fixture');
  expect(request.headers.containsKey('openai-beta'), beta);
  if (beta) expect(request.headers['openai-beta'], 'responses_multi_agent=v1');
  if (streaming) expect(request.headers['accept'], 'text/event-stream');
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

http.Response _httpResponse(
  Map<String, dynamic> response, {
  required bool streaming,
}) {
  if (!streaming) return http.Response(jsonEncode(response), 200);
  final event = {
    'type': 'response.completed',
    'sequence_number': 0,
    'response': response,
  };
  return http.Response(
    'event: response.completed\ndata: ${jsonEncode(event)}\n\ndata: [DONE]\n\n',
    200,
    headers: {'content-type': 'text/event-stream'},
  );
}

Map<String, dynamic> _responseJson() => {
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
};
