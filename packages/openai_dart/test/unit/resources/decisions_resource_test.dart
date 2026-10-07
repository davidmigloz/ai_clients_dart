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
