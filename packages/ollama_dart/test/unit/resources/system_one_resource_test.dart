import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

void main() {
  final request = SystemOneRequest(
    model: 'nimble',
    state: SystemOneContent.object(const {'ticket': 'Refund €20'}),
    questions: {
      'team': SystemOneQuestion.choice(
        instructions: const SystemOneContent.string('Which team?'),
        criteria: const {'billing': 'Charges and refunds', 'technical': null},
      ),
      'refund': const SystemOneQuestion.noul(
        instructions: SystemOneContent.string('Refund requested?'),
      ),
    },
    keepAlive: const KeepAlive.number(1.5),
  );
  final responseJson = <String, dynamic>{
    'model': 'nimble',
    'answers': {
      'team': {
        'type': 'choice',
        'choice': 'billing',
        'probabilities': {'billing': 0.9, 'technical': 0.1},
        'confidence': 0.5,
      },
      'refund': {'type': 'noul', 'noul': 0.95},
    },
    'usage': {'input_tokens': 174, 'output_tokens': 2},
  };

  http.Response success() => http.Response(
    jsonEncode(responseJson),
    200,
    headers: {'content-type': 'application/json'},
  );

  group('SystemOneResource', () {
    test(
      'posts one JSON request to /v1/systemone and decodes mixed answers',
      () async {
        var calls = 0;
        final transport = MockClient((httpRequest) async {
          calls++;
          expect(httpRequest.method, 'POST');
          expect(
            httpRequest.url.toString(),
            'http://localhost:11434/v1/systemone',
          );
          expect(
            httpRequest.headers['content-type'],
            startsWith('application/json'),
          );
          final body = jsonDecode(httpRequest.body) as Map<String, dynamic>;
          expect(body, request.toJson());
          expect(body.containsKey('stream'), isFalse);
          expect((body['questions'] as Map<String, dynamic>).keys, [
            'team',
            'refund',
          ]);
          final choice =
              (body['questions'] as Map<String, dynamic>)['team']
                  as Map<String, dynamic>;
          expect((choice['criteria'] as Map<String, dynamic>).keys, [
            'billing',
            'technical',
          ]);
          expect(
            (choice['criteria'] as Map<String, dynamic>)['technical'],
            isNull,
          );
          return success();
        });
        final client = OllamaClient(httpClient: transport);
        addTearDown(client.close);
        addTearDown(transport.close);
        final response = await client.systemOne.create(request: request);
        expect(calls, 1);
        expect(response.answers['team'], isA<SystemOneChoiceAnswer>());
        expect(
          response.answers['refund'],
          const SystemOneNoulAnswer(noul: 0.95),
        );
        expect(
          response.usage,
          const SystemOneUsage(inputTokens: 174, outputTokens: 2),
        );
      },
    );

    test(
      'honors proxy path, query defaults, custom headers and bearer authentication',
      () async {
        final transport = MockClient((httpRequest) async {
          expect(httpRequest.url.path, '/proxy/ollama/v1/systemone');
          expect(httpRequest.url.queryParameters, {
            'tenant': 'a',
            'mode': 'new',
          });
          expect(httpRequest.headers['x-custom'], 'value');
          expect(httpRequest.headers['authorization'], 'Bearer test-token');
          expect(
            httpRequest.headers['content-type'],
            startsWith('application/json'),
          );
          return success();
        });
        final client = OllamaClient(
          config: const OllamaConfig(
            baseUrl: 'https://example.test/proxy/ollama/?tenant=a&mode=old',
            defaultQueryParams: {'mode': 'new'},
            defaultHeaders: {'X-Custom': 'value'},
            authProvider: BearerTokenProvider('test-token'),
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        addTearDown(transport.close);
        await client.systemOne.create(request: request);
      },
    );

    test('preserves explicit authorization headers', () async {
      final transport = MockClient((httpRequest) async {
        expect(httpRequest.headers['authorization'], 'Bearer explicit-token');
        return success();
      });
      final client = OllamaClient(
        config: const OllamaConfig(
          defaultHeaders: {'Authorization': 'Bearer explicit-token'},
          authProvider: BearerTokenProvider('provider-token'),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      addTearDown(transport.close);
      await client.systemOne.create(request: request);
    });

    for (final status in [400, 404, 413, 500]) {
      test('propagates $status through the shared error interceptor', () async {
        final transport = MockClient(
          (_) async =>
              http.Response(jsonEncode({'error': 'server $status'}), status),
        );
        final client = OllamaClient(
          config: const OllamaConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
          httpClient: transport,
        );
        addTearDown(client.close);
        addTearDown(transport.close);
        await expectLater(
          client.systemOne.create(request: request),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'statusCode', status)
                .having((error) => error.message, 'message', 'server $status')
                .having(
                  (error) => error.requestMetadata?.url.path,
                  'path',
                  '/v1/systemone',
                ),
          ),
        );
      });
    }

    test('rate-limit retries retain the complete body', () async {
      var calls = 0;
      final transport = MockClient((httpRequest) async {
        calls++;
        expect(jsonDecode(httpRequest.body), request.toJson());
        if (calls == 1) {
          return http.Response(jsonEncode({'error': 'rate limited'}), 429);
        }
        return success();
      });
      final client = OllamaClient(
        config: const OllamaConfig(
          retryPolicy: RetryPolicy(
            maxRetries: 1,
            initialDelay: Duration.zero,
            jitter: 0,
          ),
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      addTearDown(transport.close);
      await client.systemOne.create(request: request);
      expect(calls, 2);
    });

    test('reports malformed response roots and required fields', () async {
      for (final body in [
        '[]',
        jsonEncode({'model': 'nimble', 'answers': <String, dynamic>{}}),
      ]) {
        final transport = MockClient((_) async => http.Response(body, 200));
        final client = OllamaClient(httpClient: transport);
        addTearDown(client.close);
        addTearDown(transport.close);
        await expectLater(
          client.systemOne.create(request: request),
          throwsFormatException,
        );
      }
    });

    test('rejects use after the client is closed without sending', () async {
      var sent = false;
      final transport = MockClient((_) async {
        sent = true;
        return success();
      });
      final client = OllamaClient(httpClient: transport)..close();
      addTearDown(transport.close);
      await expectLater(
        client.systemOne.create(request: request),
        throwsStateError,
      );
      expect(sent, isFalse);
    });

    test('forwards abortTrigger and converts transport cancellation', () async {
      final abort = Completer<void>();
      final transport = _AbortingClient(abort.future);
      final client = OllamaClient(httpClient: transport);
      addTearDown(client.close);
      addTearDown(transport.close);
      final result = client.systemOne.create(
        request: request,
        abortTrigger: abort.future,
      );
      await transport.started.future;
      final expectation = expectLater(result, throwsA(isA<AbortedException>()));
      abort.complete();
      await expectation;
    });
  });
}

class _AbortingClient extends http.BaseClient {
  _AbortingClient(this.expectedTrigger);

  final Future<void> expectedTrigger;
  final Completer<void> started = Completer<void>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    expect(request, isA<http.Abortable>());
    final abortable = request as http.Abortable;
    expect(abortable.abortTrigger, same(expectedTrigger));
    started.complete();
    await abortable.abortTrigger;
    throw http.RequestAbortedException(request.url);
  }
}
