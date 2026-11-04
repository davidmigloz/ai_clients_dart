import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('DecisionsResource', () {
    test(
      'sends JSON to the configured URL with standard headers and no beta',
      () async {
        final requests = <http.Request>[];
        final transport = MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(_responseFixture()), 200);
        });
        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
            baseUrl: 'https://eu.api.openai.com/v1?gateway=decisions',
            organization: 'org-test',
            project: 'proj-test',
            apiVersion: '2026-10-07',
            defaultHeaders: {'X-Trace-Label': 'decisions-test'},
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: transport,
        );
        addTearDown(client.close);

        expect(client.decisions, same(client.decisions));
        final result = await client.decisions.create(_requestFixture());

        expect(requests, hasLength(1));
        final request = requests.single;
        expect(request.method, 'POST');
        expect(
          request.url,
          Uri.parse('https://eu.api.openai.com/v1/decisions?gateway=decisions'),
        );
        expect(request.headers['authorization'], 'Bearer sk-test-key');
        expect(request.headers['openai-organization'], 'org-test');
        expect(request.headers['openai-project'], 'proj-test');
        expect(request.headers['openai-version'], '2026-10-07');
        expect(request.headers['x-trace-label'], 'decisions-test');
        expect(request.headers['content-type'], contains('application/json'));
        expect(request.headers['x-request-id'], isNotEmpty);
        expect(request.headers.containsKey('openai-beta'), isFalse);
        expect(jsonDecode(request.body), _requestJson());
        expect(result, isA<DecisionResponse>());
        expect(result.answers.single, isA<PredicateDecisionAnswer>());
        expect(result.usage.inputTokensDetails!.cacheWriteTokens, 0);
      },
    );

    test('posts mixed image URL evidence without fetching remote images', () async {
      final requests = <http.Request>[];
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(jsonEncode(_responseFixture()), 200);
        }),
      );
      addTearDown(client.close);
      final request = DecisionRequest(
        model: 'future-decision-model',
        input: DecisionInput.messages([
          DecisionInputMessage(
            content: DecisionContent.parts([
              const DecisionInputPart.text('Inspect this photo.'),
              DecisionInputPart.imageBytes(
                const [0, 1, 2, 255],
                mediaType: 'image/png',
                detail: ImageDetail.original,
              ),
              DecisionInputPart.image(
                imageUrl: 'http://example.com/image%2Fone.png?v=1#preview',
                detail: ImageDetail.high,
              ),
            ]),
          ),
          DecisionInputMessage(
            content: DecisionContent.parts([
              DecisionInputPart.image(
                imageUrl:
                    'https://EXAMPLE.com:443/photo.png?signature=a%2Bb&v=1#frame',
              ),
              const DecisionInputPart.text('Compare their visible damage.'),
            ]),
          ),
        ]),
        questions: const [
          DecisionQuestion.predicate(
            instructions: 'Is it damaged?',
            name: 'damaged',
          ),
        ],
      );

      final response = await client.decisions.create(request);

      expect(requests, hasLength(1));
      expect(requests.single.method, 'POST');
      expect(
        requests.single.url,
        Uri.parse('https://api.openai.com/v1/decisions'),
      );
      expect(jsonDecode(requests.single.body), {
        'model': 'future-decision-model',
        'input': [
          {
            'type': 'message',
            'role': 'user',
            'content': [
              {'type': 'input_text', 'text': 'Inspect this photo.'},
              {
                'type': 'input_image',
                'image_url': 'data:image/png;base64,AAEC/w==',
                'detail': 'original',
              },
              {
                'type': 'input_image',
                'image_url': 'http://example.com/image%2Fone.png?v=1#preview',
                'detail': 'high',
              },
            ],
          },
          {
            'type': 'message',
            'role': 'user',
            'content': [
              {
                'type': 'input_image',
                'image_url':
                    'https://EXAMPLE.com:443/photo.png?signature=a%2Bb&v=1#frame',
              },
              {'type': 'input_text', 'text': 'Compare their visible damage.'},
            ],
          },
        ],
        'questions': [
          {
            'type': 'predicate',
            'instructions': 'Is it damaged?',
            'name': 'damaged',
          },
        ],
      });
      expect(response.model, 'future-decision-model');
      expect(response.answers.single, isA<PredicateDecisionAnswer>());
    });

    test(
      'posts all GA history variants, 400 multimodal questions and cache controls',
      () async {
        final history = <Map<String, dynamic>>[
          {'role': 'system', 'content': 'Classify captured evidence.'},
          {
            'role': 'developer',
            'content': [
              {
                'type': 'input_text',
                'text': 'Shared policy',
                'prompt_cache_breakpoint': {'mode': 'explicit'},
              },
            ],
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'input_json',
                'data': [
                  {'order': 1, 'damaged': true},
                ],
              },
              {
                'type': 'input_image',
                'image_url': 'https://example.invalid/photo.png',
                'prompt_cache_breakpoint': {'mode': 'explicit'},
              },
            ],
          },
          {
            'role': 'assistant',
            'content': [
              {'type': 'output_text', 'text': 'Checking'},
              {'type': 'refusal', 'refusal': 'Cannot infer identity'},
            ],
            'phase': 'commentary',
          },
          {
            'type': 'function_call',
            'call_id': 'f',
            'name': 'order.lookup',
            'arguments': '{}',
            'namespace': 'orders',
            'id': 'item_f',
            'status': 'completed',
          },
          {
            'type': 'function_call_output',
            'call_id': 'f',
            'output': [
              {'type': 'input_text', 'text': 'Delivered'},
              {
                'type': 'input_image',
                'image_url': 'https://example.invalid/receipt.png',
              },
            ],
            'id': 'output_f',
            'status': 'completed',
          },
          {
            'type': 'custom_tool_call',
            'call_id': 'c',
            'name': 'check',
            'input': 'order 1',
            'namespace': 'orders',
            'id': 'item_c',
            'status': 'completed',
          },
          {
            'type': 'custom_tool_call_output',
            'call_id': 'c',
            'output': 'Confirmed',
            'id': 'output_c',
            'status': 'completed',
          },
        ];
        final questions = List<Map<String, dynamic>>.generate(
          400,
          (i) => {
            'type': i % 3 == 0
                ? 'predicate'
                : i % 3 == 1
                ? 'choice'
                : 'score',
            'name': 'q$i',
            'instructions': [
              {'type': 'input_text', 'text': 'Compare evidence'},
              {
                'type': 'input_image',
                'image_url': 'https://example.invalid/reference.png',
              },
              {
                'type': 'input_json',
                'data': {'threshold': 2},
              },
            ],
            if (i % 3 == 1)
              'choices': [
                {'value': true},
                {'value': false},
              ],
            if (i % 3 == 2)
              'levels': [
                {'label': 'low'},
                {'label': 'high'},
              ],
          },
        );
        final fixture = <String, dynamic>{
          'model': 'gpt-6-luna',
          'input': history,
          'questions': questions,
          'prompt_cache_key': 'tenant-1',
          'prompt_cache_options': {'ttl': '30m', 'mode': 'explicit'},
        };
        final responseJson = <String, dynamic>{
          ..._responseFixture(),
          'model': 'gpt-6-luna',
          'answers': List<Map<String, dynamic>>.generate(
            400,
            (i) => {
              'type': i == 399
                  ? 'refusal'
                  : i % 3 == 0
                  ? 'predicate'
                  : i % 3 == 1
                  ? 'choice'
                  : 'score',
              'name': 'q$i',
              if (i != 399 && i % 3 == 0) 'probability': 0.9,
              if (i != 399 && i % 3 != 0) ...{
                'confidence': 0.9,
                'probabilities': i % 3 == 1
                    ? [
                        {'value': true, 'probability': 0.9},
                        {'value': false, 'probability': 0.1},
                      ]
                    : [
                        {'value': 0, 'label': 'low', 'probability': 0.1},
                        {'value': 1, 'label': 'high', 'probability': 0.9},
                      ],
                if (i % 3 == 1) 'choice': true,
                if (i % 3 == 2) 'score': 0.9,
              },
            },
          ),
        };
        var sends = 0;
        final transport = MockClient((request) async {
          sends++;
          expect(request.method, 'POST');
          expect(request.url.toString(), 'https://api.openai.com/v1/decisions');
          expect(
            request.headers['authorization'],
            'Bearer synthetic-decisions-key',
          );
          expect(request.headers.containsKey('openai-beta'), isFalse);
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body, {
            ...fixture,
            'input': history
                .map(
                  (item) => {
                    if (item.containsKey('role')) 'type': 'message',
                    ...item,
                  },
                )
                .toList(),
          });
          return http.Response(jsonEncode(responseJson), 200);
        });
        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('synthetic-decisions-key'),
          ),
          httpClient: transport,
        );
        addTearDown(transport.close);
        addTearDown(client.close);
        final response = await client.decisions.create(
          DecisionRequest.fromJson(fixture),
        );
        expect(sends, 1);
        expect(response.toJson(), responseJson);
        expect(response.answers, hasLength(400));
        expect(response.answers.first, isA<PredicateDecisionAnswer>());
        expect(response.answers[1], isA<ChoiceDecisionAnswer>());
        expect(response.answers[2], isA<ScoreDecisionAnswer>());
        expect(response.answers.last, isA<RefusalDecisionAnswer>());
        expect(
          response.answers.map((a) => a.name),
          List.generate(400, (i) => 'q$i'),
        );
        expect(response.usage.inputTokensDetails!.cacheWriteTokens, 0);
      },
    );

    test('surfaces typed HTTP 400 errors with metadata', () async {
      final body = <String, dynamic>{
        'error': {
          'message': 'Too many questions',
          'type': 'invalid_request_error',
          'param': 'questions',
          'code': 'too_many_questions',
        },
      };
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: MockClient((request) async {
          return http.Response(
            jsonEncode(body),
            400,
            headers: {'x-request-id': 'req_decision_error'},
          );
        }),
      );
      addTearDown(client.close);

      await expectLater(
        client.decisions.create(_requestFixture()),
        throwsA(
          isA<BadRequestException>()
              .having((e) => e.statusCode, 'statusCode', 400)
              .having((e) => e.message, 'message', 'Too many questions')
              .having((e) => e.type, 'type', 'invalid_request_error')
              .having((e) => e.param, 'param', 'questions')
              .having((e) => e.code, 'code', 'too_many_questions')
              .having((e) => e.requestId, 'requestId', 'req_decision_error')
              .having((e) => e.body, 'body', body),
        ),
      );
    });

    test('closed client fails before sending a request', () async {
      var sends = 0;
      final client = OpenAIClient(
        httpClient: MockClient((request) async {
          sends++;
          return http.Response(jsonEncode(_responseFixture()), 200);
        }),
      );
      final decisions = client.decisions;
      client.close();

      await expectLater(
        () => decisions.create(_requestFixture()),
        throwsStateError,
      );
      expect(sends, 0);
    });

    test('pending abort trigger preserves the complete request body', () async {
      final abort = Completer<void>();
      final transport = _AbortAwareClient(waitForAbort: false);
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test-key'),
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);

      final response = await client.decisions.create(
        _requestFixture(),
        abortTrigger: abort.future,
      );

      expect(transport.request, isA<http.Abortable>());
      expect(
        (transport.request! as http.Abortable).abortTrigger,
        same(abort.future),
      );
      expect(jsonDecode(transport.body!), _requestJson());
      expect(
        transport.request!.contentLength,
        utf8.encode(transport.body!).length,
      );
      expect(response.model, 'future-decision-model');
    });

    test(
      'in-flight abort reaches transport and becomes AbortedException',
      () async {
        final abort = Completer<void>();
        final transport = _AbortAwareClient(waitForAbort: true);
        final client = OpenAIClient(
          config: const OpenAIConfig(
            authProvider: ApiKeyProvider('sk-test-key'),
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: transport,
        );
        addTearDown(client.close);

        final pending = client.decisions.create(
          _requestFixture(),
          abortTrigger: abort.future,
        );
        final assertion = expectLater(
          pending,
          throwsA(
            isA<AbortedException>()
                .having((e) => e.stage, 'stage', AbortionStage.duringRequest)
                .having(
                  (e) => e.cause,
                  'cause',
                  isA<http.RequestAbortedException>(),
                )
                .having((e) => e.correlationId, 'correlationId', isNotEmpty),
          ),
        );
        await transport.sent.future;
        expect(jsonDecode(transport.body!), _requestJson());
        abort.complete();
        await assertion;
        expect(transport.sends, 1);
      },
    );
  });
}

DecisionRequest _requestFixture() => DecisionRequest(
  model: 'future-decision-model',
  input: const DecisionInput.text('The screen arrived broken.'),
  questions: const [
    DecisionQuestion.predicate(instructions: 'Is it damaged?', name: 'damaged'),
  ],
  safetyIdentifier: 'customer-123',
);

Map<String, dynamic> _requestJson() => {
  'model': 'future-decision-model',
  'input': 'The screen arrived broken.',
  'questions': [
    {'type': 'predicate', 'instructions': 'Is it damaged?', 'name': 'damaged'},
  ],
  'safety_identifier': 'customer-123',
};

Map<String, dynamic> _responseFixture() => {
  'model': 'future-decision-model',
  'answers': [
    {'type': 'predicate', 'name': 'damaged', 'probability': 0.99},
  ],
  'usage': {
    'input_tokens': 10,
    'output_tokens': 2,
    'total_tokens': 12,
    'input_tokens_details': {'cached_tokens': 0, 'cache_write_tokens': 0},
    'output_tokens_details': {'reasoning_tokens': 0},
  },
};

class _AbortAwareClient extends http.BaseClient {
  _AbortAwareClient({required this.waitForAbort});

  final bool waitForAbort;
  final sent = Completer<void>();
  http.BaseRequest? request;
  String? body;
  int sends = 0;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    sends++;
    this.request = request;
    body = utf8.decode(await request.finalize().toBytes());
    sent.complete();
    if (waitForAbort) {
      await (request as http.Abortable).abortTrigger;
      throw http.RequestAbortedException(request.url);
    }
    return http.StreamedResponse(
      Stream.value(utf8.encode(jsonEncode(_responseFixture()))),
      200,
      headers: {'content-type': 'application/json'},
    );
  }
}
