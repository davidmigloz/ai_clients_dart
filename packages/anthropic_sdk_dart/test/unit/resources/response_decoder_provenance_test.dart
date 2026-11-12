import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _key = 'independent-fixture-key+/=opaque';
const _oauth = 'independent-fixture-oauth+/=opaque';

Matcher _safeFormat(String secret) => throwsA(
  isA<FormatException>()
      .having((error) => error.source, 'source', isNull)
      .having(
        (error) => error.toString(),
        'safe error',
        isNot(contains(secret)),
      ),
);

void main() {
  for (final withBearer in [false, true]) {
    test(
      'effective auth survives sanitized response request provenance ($withBearer)',
      () async {
        final credential = withBearer ? _oauth : _key;
        final encoded = Uri.encodeComponent(credential);
        final transport = MockClient((request) async {
          expect(
            request.headers[withBearer ? 'authorization' : 'x-api-key'],
            withBearer ? 'Bearer $credential' : credential,
          );
          final metadataRequest = http.Request(request.method, request.url)
            ..headers['x-request-id'] = 'req_fixture';
          return http.Response(
            '{"name":"$encoded',
            200,
            request: metadataRequest,
            headers: {'content-type': 'application/json'},
          );
        });
        final client = withBearer
            ? AnthropicClient.withAuthToken(_oauth, httpClient: transport)
            : AnthropicClient.withApiKey(_key, httpClient: transport);
        addTearDown(client.close);
        await expectLater(client.models.list(), _safeFormat(encoded));
      },
    );
  }

  test('JSON-escaped API key in invalid JSON is redacted', () async {
    final escaped = _key.replaceAll('+', r'\u002b').replaceAll('/', r'\/');
    final transport = MockClient((request) async {
      expect(request.headers['x-api-key'], _key);
      return http.Response('{"name":"$escaped', 200);
    });
    final client = AnthropicClient.withApiKey(_key, httpClient: transport);
    addTearDown(client.close);
    await expectLater(client.models.list(), _safeFormat(escaped));
  });

  test(
    'typed environment discriminator with effective OAuth is redacted',
    () async {
      final encoded = Uri.encodeComponent(_oauth);
      final transport = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer $_oauth');
        return http.Response(
          jsonEncode({'id': 'env_fixture', 'type': encoded}),
          200,
        );
      });
      final client = AnthropicClient.withAuthToken(
        _oauth,
        httpClient: transport,
      );
      addTearDown(client.close);
      await expectLater(
        client.environments.retrieve('env_fixture'),
        _safeFormat(encoded),
      );
    },
  );

  test('malformed top-level type cannot expose the raw API key', () async {
    final transport = MockClient((request) async {
      expect(request.headers['x-api-key'], _key);
      return http.Response(
        jsonEncode(_key),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = AnthropicClient.withApiKey(_key, httpClient: transport);
    addTearDown(client.close);
    await expectLater(
      client.models.list(),
      throwsA(
        isA<Object>().having(
          (Object? error) => error.toString(),
          'safe type diagnostic',
          isNot(contains(_key)),
        ),
      ),
    );
  });

  test('nested telemetry cast cannot expose Admin key', () async {
    final transport = MockClient((request) async {
      expect(request.headers['x-api-key'], _key);
      return http.Response(
        jsonEncode({
          'data': [_key],
          'next_page': null,
        }),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = AnthropicClient.withApiKey(_key, httpClient: transport);
    addTearDown(client.close);
    await expectLater(
      client.organization.telemetryDestinations.list(),
      throwsA(
        isA<Object>().having(
          (error) => error.toString(),
          'safe type diagnostic',
          isNot(contains(_key)),
        ),
      ),
    );
  });

  test(
    'nested protected work cast cannot expose a newly issued secret',
    () async {
      const issued = 'independent-fixture-work-new-secret';
      final transport = MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer $_oauth');
        return http.Response(
          jsonEncode({
            'type': 'work',
            'id': 'work_fixture',
            'environment_id': 'env_fixture',
            'state': 'active',
            'data': issued,
            'secret': issued,
          }),
          200,
        );
      });
      final client = AnthropicClient(httpClient: transport);
      addTearDown(client.close);
      await expectLater(
        client.environments.work('env_fixture', bearerToken: _oauth).poll(),
        throwsA(
          isA<Object>().having(
            (error) => error.toString(),
            'safe type diagnostic',
            isNot(contains(issued)),
          ),
        ),
      );
    },
  );

  test('protected tunnel shape cannot expose a newly issued secret', () async {
    const issued = 'independent-fixture-tunnel-new-secret';
    final transport = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer $_oauth');
      return http.Response(jsonEncode(issued), 200);
    });
    final client = AnthropicClient(httpClient: transport);
    addTearDown(client.close);
    await expectLater(
      client.tunnels.withToken(_oauth).revealToken('tunnel_fixture'),
      throwsA(
        isA<Object>().having(
          (error) => error.toString(),
          'safe type diagnostic',
          isNot(contains(issued)),
        ),
      ),
    );
  });

  test('HTTP structured metadata drops encoded credential keys', () async {
    final encoded = Uri.encodeComponent(_key);
    final transport = MockClient((request) async {
      expect(request.headers['x-api-key'], _key);
      return http.Response(
        jsonEncode({
          'type': 'error',
          'request_id': 'req_fixture',
          'error': {
            'type': 'invalid_request_error',
            'message': 'Safe message',
            'details': {
              'error_code': 'real_code',
              'nested': {encoded: 'must be omitted', 'safe-key': 'safe-value'},
            },
          },
        }),
        400,
        headers: {'content-type': 'application/json'},
      );
    });
    final client = AnthropicClient.withApiKey(_key, httpClient: transport);
    addTearDown(client.close);
    await expectLater(
      client.models.list(),
      throwsA(
        isA<ApiException>()
            .having(
              (error) => error.requestId,
              'safe request ID',
              'req_fixture',
            )
            .having((error) => error.errorCode, 'safe error code', 'real_code')
            .having((error) => error.errorDetails, 'safe structured fields', {
              'error_code': 'real_code',
              'nested': {'safe-key': 'safe-value'},
            }),
      ),
    );
  });

  for (final connectionDrop in [false, true]) {
    test(
      'later AWS attempt cannot expose credential from earlier attempt (connectionDrop=$connectionDrop)',
      () async {
        const first = 'independent-fixture-aws-session-one+/=';
        const second = 'independent-fixture-aws-session-two+/=';
        var attempts = 0;
        var credentialCalls = 0;
        final encoded = Uri.encodeComponent(first);
        final transport = MockClient((request) async {
          attempts++;
          expect(
            request.headers['x-amz-security-token'],
            attempts == 1 ? first : second,
          );
          if (attempts == 1 && connectionDrop) {
            throw http.ClientException('fixture closed connection');
          }
          return attempts == 1
              ? http.Response('', 500)
              : http.Response(
                  jsonEncode({
                    'type': 'model',
                    'id': 'model_fixture',
                    'display_name': 'Fixture',
                    'created_at': encoded,
                  }),
                  200,
                );
        });
        final client = AnthropicAwsClient(
          region: 'us-west-2',
          workspaceId: 'wrkspc_fixture',
          credentials: () => ClaudeAwsCredentials(
            accessKeyId: 'AKIDFIXTURE',
            secretAccessKey: 'fixture-signing-secret',
            sessionToken: ++credentialCalls == 1 ? first : second,
          ),
          config: const AnthropicConfig(
            retryPolicy: RetryPolicy(
              maxRetries: 1,
              initialDelay: Duration.zero,
            ),
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        await expectLater(
          client.models.retrieve('model_fixture'),
          _safeFormat(encoded),
        );
        expect(attempts, 2);
      },
    );
  }
}
