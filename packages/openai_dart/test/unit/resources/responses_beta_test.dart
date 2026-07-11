import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Responses beta opt-in', () {
    OpenAIClient buildClient(http.Client mockClient) => OpenAIClient(
      config: const OpenAIConfig(authProvider: ApiKeyProvider('sk-test-key')),
      httpClient: mockClient,
    );

    group('create', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            jsonEncode({
              'id': 'resp_123',
              'object': 'response',
              'created_at': 1234567890,
              'status': 'completed',
              'model': 'gpt-4o',
              'output': <dynamic>[],
            }),
            200,
          );
        });
        final client = buildClient(mockClient);

        await client.responses.create(
          const CreateResponseRequest(
            model: 'gpt-4o',
            input: ResponseInput.text('Hello'),
          ),
          beta: beta,
        );

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    group('createStream', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient.streaming((request, _) async {
          requestCompleter.complete(request);
          return http.StreamedResponse(
            Stream.fromIterable([utf8.encode('data: [DONE]\n\n')]),
            200,
          );
        });
        final client = buildClient(mockClient);

        await client.responses
            .createStream(
              const CreateResponseRequest(
                model: 'gpt-4o',
                input: ResponseInput.text('Hello'),
              ),
              beta: beta,
            )
            .drain<void>();

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    group('createStreamWithAccumulator', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient.streaming((request, _) async {
          requestCompleter.complete(request);
          return http.StreamedResponse(
            Stream.fromIterable([utf8.encode('data: [DONE]\n\n')]),
            200,
          );
        });
        final client = buildClient(mockClient);

        await client.responses
            .createStreamWithAccumulator(
              const CreateResponseRequest(
                model: 'gpt-4o',
                input: ResponseInput.text('Hello'),
              ),
              beta: beta,
            )
            .drain<void>();

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    group('retrieve', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            jsonEncode({
              'id': 'resp_123',
              'object': 'response',
              'created_at': 1234567890,
              'status': 'completed',
              'model': 'gpt-4o',
              'output': <dynamic>[],
            }),
            200,
          );
        });
        final client = buildClient(mockClient);

        await client.responses.retrieve('resp_123', beta: beta);

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    group('delete', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            jsonEncode({
              'id': 'resp_123',
              'object': 'response',
              'deleted': true,
            }),
            200,
          );
        });
        final client = buildClient(mockClient);

        await client.responses.delete('resp_123', beta: beta);

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    group('cancel', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            jsonEncode({
              'id': 'resp_123',
              'object': 'response',
              'created_at': 1234567890,
              'status': 'cancelled',
              'model': 'gpt-4o',
              'output': <dynamic>[],
            }),
            200,
          );
        });
        final client = buildClient(mockClient);

        await client.responses.cancel('resp_123', beta: beta);

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    group('compact', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            jsonEncode({
              'id': 'cmp_123',
              'object': 'response.compaction',
              'created_at': 1234567890,
              'output': <dynamic>[],
              'usage': {
                'input_tokens': 10,
                'output_tokens': 2,
                'total_tokens': 12,
              },
            }),
            200,
          );
        });
        final client = buildClient(mockClient);

        await client.responses.compact(
          const CompactResponseRequest(
            model: 'gpt-4o',
            input: ResponseInput.text('compact this'),
          ),
          beta: beta,
        );

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    group('inputItems.list', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(
            jsonEncode({
              'object': 'list',
              'data': <dynamic>[],
              'has_more': false,
            }),
            200,
          );
        });
        final client = buildClient(mockClient);

        await client.responses.inputItems.list('resp_123', beta: beta);

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    group('inputTokens.count', () {
      Future<http.BaseRequest> capture({required bool beta}) async {
        final requestCompleter = Completer<http.BaseRequest>();
        final mockClient = MockClient((request) async {
          requestCompleter.complete(request);
          return http.Response(jsonEncode({'input_tokens': 10}), 200);
        });
        final client = buildClient(mockClient);

        await client.responses.inputTokens.count(
          model: 'gpt-4o',
          input: const ResponseInput.text('Hello'),
          beta: beta,
        );

        return requestCompleter.future;
      }

      test('beta: true adds query param and header', () async {
        final request = await capture(beta: true);
        expect(request.url.queryParameters['beta'], equals('true'));
        expect(
          request.headers['OpenAI-Beta'],
          equals('responses_multi_agent=v1'),
        );
      });

      test('default (beta: false) omits query param and header', () async {
        final request = await capture(beta: false);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
        expect(request.headers.containsKey('OpenAI-Beta'), isFalse);
      });
    });

    test('plain list() has no beta parameter (no beta variant exists)', () {
      // GET /responses (list) has no `?beta=true` variant in the spec, so
      // ResponsesResource.list() intentionally does not accept `beta`.
      // This test exists to document that decision; nothing to assert here
      // beyond the type signature compiling without a `beta` argument.
    });
  });
}
