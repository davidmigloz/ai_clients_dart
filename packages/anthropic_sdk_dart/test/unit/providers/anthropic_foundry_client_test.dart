import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _key = 'fixture-foundry-key';
const _model = 'fixture-deployment';
final _request = MessageCreateRequest(
  model: _model,
  maxTokens: 16,
  messages: [InputMessage.user('Hello')],
);

void main() {
  test(
    'Foundry Files and Skills malformed success do not echo API key',
    () async {
      const key = 'synthetic-foundry-direct-key';
      final client = AnthropicFoundryClient(
        resource: 'fixture',
        apiKey: key,
        httpClient: MockClient(
          (request) async => http.Response(
            '$key not JSON',
            200,
            headers: const {'content-type': 'application/json'},
          ),
        ),
      );
      addTearDown(client.close);
      for (final call in <Future<Object> Function()>[
        client.files.list,
        client.skills.list,
      ]) {
        await expectLater(
          call(),
          throwsA(
            isA<FormatException>().having(
              (error) => '${error.source} $error',
              'no raw key',
              isNot(contains(key)),
            ),
          ),
        );
      }
    },
  );

  test('Foundry carries the native Messages thread request', () async {
    final client = AnthropicFoundryClient(
      resource: 'fixture-resource',
      apiKey: _key,
      httpClient: MockClient((request) async {
        expect(request.url.path, '/anthropic/v1/messages');
        expect(request.headers['x-api-key'], _key);
        expect(
          request.headers['anthropic-beta'],
          contains('message-threads-2026-08-12'),
        );
        expect(
          jsonDecode(request.body),
          containsPair('thread', {'type': 'create'}),
        );
        return _message();
      }),
    );
    addTearDown(client.close);
    expect(
      (await client.messages.createThread(_request).send()).id,
      'msg_fixture',
    );
  });

  test(
    'Foundry API key uses native Messages, streaming and count tokens',
    () async {
      final requests = <http.Request>[];
      final client = AnthropicFoundryClient(
        resource: 'fixture-resource',
        apiKey: _key,
        config: const AnthropicConfig(
          workspaceId: 'unused-workspace',
          defaultHeaders: {
            'X-Api-Key': 'discard-claude-key',
            'Api-Key': 'discard-legacy-key',
            'Authorization': 'discard-claude-bearer',
          },
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          if (request.url.path.endsWith('/count_tokens')) {
            return _json('{"input_tokens":3}');
          }
          if ((jsonDecode(request.body) as Map<String, dynamic>)['stream'] ==
              true) {
            return http.Response(
              'data: {"type":"message_stop"}\n\n',
              200,
              headers: {'content-type': 'text/event-stream'},
            );
          }
          return _message();
        }),
      );
      addTearDown(client.close);
      expect((await client.messages.create(_request)).id, 'msg_fixture');
      expect(
        await client.messages.createStream(_request).single,
        isA<MessageStopEvent>(),
      );
      expect(
        (await client.messages.countTokens(
          TokenCountRequest(model: _model, messages: _request.messages),
        )).inputTokens,
        3,
      );
      expect(requests.map((r) => r.url.path), [
        '/anthropic/v1/messages',
        '/anthropic/v1/messages',
        '/anthropic/v1/messages/count_tokens',
      ]);
      for (final request in requests) {
        expect(request.url.host, 'fixture-resource.services.ai.azure.com');
        expect(request.headers['x-api-key'], _key);
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers, isNot(contains('authorization')));
        expect(request.headers, isNot(contains('api-key')));
        expect(request.headers, isNot(contains('anthropic-workspace-id')));
        expect(jsonDecode(request.body), containsPair('model', _model));
      }
    },
  );

  test(
    'Foundry Entra transport refreshes the caller token and keeps proxy routing',
    () async {
      final requests = <http.Request>[];
      var tokens = 0;
      final client = AnthropicFoundryClient(
        baseUrl: 'https://fixture.invalid/proxy/?tag=a&tag=b',
        tokenProvider: () => Future.value('fixture-entra-${++tokens}'),
        httpClient: MockClient((request) async {
          requests.add(request);
          return _json('{"data":[],"next_page":null}');
        }),
      );
      addTearDown(client.close);
      expect((await client.files.list()).data, isEmpty);
      expect((await client.skills.list()).data, isEmpty);
      expect(requests.map((r) => r.url.path), [
        '/proxy/v1/files',
        '/proxy/v1/skills',
      ]);
      for (final (index, request) in requests.indexed) {
        expect(request.url.queryParametersAll, {
          'tag': ['a', 'b'],
        });
        expect(
          request.headers['authorization'],
          'Bearer fixture-entra-${index + 1}',
        );
        expect(request.headers, isNot(contains('x-api-key')));
      }
    },
  );

  test(
    'Foundry rejects unsupported operations before acquiring credentials',
    () async {
      var sends = 0;
      var tokens = 0;
      final client = AnthropicFoundryClient(
        resource: 'fixture-resource',
        azureHosted: true,
        tokenProvider: () => 'fixture-entra-${++tokens}',
        httpClient: MockClient((_) async {
          sends++;
          return _message();
        }),
      );
      addTearDown(client.close);
      await expectLater(client.files.list(), throwsUnsupportedError);
      await expectLater(client.skills.list(), throwsUnsupportedError);
      await expectLater(client.models.list(), throwsUnsupportedError);
      await expectLater(client.messages.batches.list(), throwsUnsupportedError);
      await expectLater(
        client.userProfiles.current.list(),
        throwsUnsupportedError,
      );
      await expectLater(
        client.messages.create(
          _request.copyWith(fallbacks: const FallbacksParam.defaultMode()),
        ),
        throwsUnsupportedError,
      );
      expect(sends, 0);
      expect(tokens, 0);
    },
  );

  test(
    'Foundry removes encoded Azure trace credentials in both paths',
    () async {
      const token = 'fixture-entra-token';
      final client = AnthropicFoundryClient(
        resource: 'fixture-resource',
        tokenProvider: () => token,
        config: const AnthropicConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
        httpClient: MockClient((request) async {
          expect(request.headers['authorization'], 'Bearer $token');
          return http.Response(
            '{"error":{"type":"api_error","message":"fixture failure"}}',
            503,
            headers: {
              'content-type': 'application/json',
              'request-id': 'req_safe',
              'apim-request-id': token.replaceAll('-', '%2D'),
            },
          );
        }),
      );
      addTearDown(client.close);
      for (final result in [
        client.messages.create(_request),
        client.messages.createStream(_request).drain<void>(),
      ]) {
        await expectLater(
          result,
          throwsA(
            isA<ApiException>()
                .having(
                  (error) => error.requestId,
                  'Claude request ID',
                  'req_safe',
                )
                .having(
                  (error) => error.responseMetadata!.headers['apim-request-id'],
                  'echoed Azure trace removed',
                  isNull,
                ),
          ),
        );
      }
    },
  );

  test(
    'Foundry retains Azure trace and prefers a Claude header or body ID',
    () async {
      var calls = 0;
      final client = AnthropicFoundryClient(
        resource: 'fixture-resource',
        apiKey: _key,
        config: const AnthropicConfig(
          retryPolicy: RetryPolicy(maxRetries: 0),
          defaultHeaders: {'Api-Key': 'discarded-azure-secret'},
        ),
        httpClient: MockClient((_) async {
          calls++;
          return http.Response(
            calls == 3
                ? '{"message":"Unavailable"}'
                : '{"type":"error","error":{"type":"api_error","message":"Unavailable"},'
                      '"request_id":"req_body"}',
            503,
            headers: {
              'content-type': 'application/json',
              if (calls == 1) 'request-id': 'req_header',
              'apim-request-id': 'azure_gateway_id',
            },
          );
        }),
      );
      addTearDown(client.close);
      for (final (Future<void> Function() request, String id, bool hasHeader)
          in [
            (
              () async {
                await client.messages.create(_request);
              },
              'req_header',
              true,
            ),
            (
              () => client.messages.createStream(_request).drain<void>(),
              'req_body',
              false,
            ),
            (
              () async {
                await client.messages.create(_request);
              },
              'azure_gateway_id',
              false,
            ),
          ]) {
        await expectLater(
          request(),
          throwsA(
            isA<ApiException>()
                .having((error) => error.statusCode, 'status code', 503)
                .having((error) => error.requestId, 'preferred trace ID', id)
                .having(
                  (error) => error.responseMetadata!.headers['apim-request-id'],
                  'Azure trace ID',
                  'azure_gateway_id',
                )
                .having(
                  (error) =>
                      error.responseMetadata!.headers.containsKey('request-id'),
                  'original Claude header retained',
                  hasHeader,
                )
                .having(
                  (error) =>
                      error.requestMetadata?.headers.values.contains(
                        'discarded-azure-secret',
                      ) ??
                      false,
                  'inherited key exposed in diagnostics',
                  isFalse,
                ),
          ),
        );
      }
    },
  );
}

http.Response _message() => _json(
  '{"id":"msg_fixture","type":"message","role":"assistant",'
  '"model":"fixture-deployment","content":[],"stop_reason":"end_turn",'
  '"stop_sequence":null,"usage":{"input_tokens":3,"output_tokens":1}}',
);

http.Response _json(String body) =>
    http.Response(body, 200, headers: {'content-type': 'application/json'});
