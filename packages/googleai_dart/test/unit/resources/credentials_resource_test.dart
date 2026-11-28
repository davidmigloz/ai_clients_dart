import 'dart:async';
import 'dart:convert';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

const _config = GoogleAIConfig.googleAI(
  apiVersion: ApiVersion.v1beta,
  authProvider: ApiKeyProvider(
    'developer-key',
    placement: AuthPlacement.header,
  ),
);
const _metadata = {
  'id': 'deployment-token',
  'type': 'bearer_token',
  'status': 'active',
  'create_time': '2026-11-21T19:30:00.000Z',
  'update_time': '2026-11-21T19:31:00.000Z',
};
const _secret = 'credential-secret-with-é-"quote"';
const _refresh = 'fixture-refresh-token';

http.Response _jsonResponse(Object body, {int status = 200}) =>
    http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      status,
      headers: const {'content-type': 'application/json'},
    );

GoogleAIClient _client(
  http.Client transport, {
  GoogleAIConfig config = _config,
}) {
  addTearDown(transport.close);
  final client = GoogleAIClient(config: config, httpClient: transport);
  addTearDown(client.close);
  return client;
}

void main() {
  test('posts each credential shape and returns metadata only', () async {
    const payloads = <Map<String, dynamic>>[
      {
        'id': 'build-variable',
        'type': 'environment_variable',
        'value': _secret,
        'trusted_domains': ['api.example.com'],
        'injection_location': ['header', 'query'],
      },
      {
        'id': 'deployment-token',
        'type': 'bearer_token',
        'token': _secret,
        'header_name': 'X-Auth',
        'prefix': '',
      },
      {
        'id': 'oauth',
        'type': 'oauth2',
        'client_id': 'client',
        'client_secret': _secret,
        'refresh_token': _refresh,
        'token_url': 'https://example.com/token',
        'scopes': ['read'],
      },
    ];
    final requests = <http.Request>[];
    final client = _client(
      MockClient((request) async {
        final payload = payloads[requests.length];
        requests.add(request);
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://generativelanguage.googleapis.com/v1beta/credentials',
        );
        expect(request.headers['x-goog-api-key'], 'developer-key');
        expect(request.headers['content-type'], contains('application/json'));
        expect(jsonDecode(utf8.decode(request.bodyBytes)), payload);

        // An echoed field in a malformed provider response cannot enter the model.
        return _jsonResponse({...payload, 'status': 'active'});
      }),
    );

    for (final payload in payloads) {
      final credential = CredentialCreateParams.fromJson(payload);
      final created = await client.credentials.create(credential: credential);

      expect(credential.toJson(), payload);
      expect(credential.toString(), isNot(contains(_secret)));
      expect(created.toJson(), {
        'id': payload['id'],
        'type': payload['type'],
        'status': 'active',
      });
    }
    expect(requests, hasLength(3));
  });

  test('omits an unset create ID and accepts a generated UUID', () async {
    const generatedId = '9e545973-4330-49bb-9a44-930cea9fbe3c';
    const payloads = <Map<String, dynamic>>[
      {
        'type': 'environment_variable',
        'value': _secret,
        'injection_location': 'header',
      },
      {'type': 'bearer_token', 'token': _secret},
      {
        'type': 'oauth2',
        'client_id': 'client',
        'client_secret': _secret,
        'refresh_token': _refresh,
        'token_url': 'https://example.com/token',
      },
    ];
    var requests = 0;
    final client = _client(
      MockClient((request) async {
        final payload = payloads[requests++];
        expect(request.method, 'POST');
        expect(request.url.path, '/v1beta/credentials');
        expect(jsonDecode(utf8.decode(request.bodyBytes)), payload);
        return _jsonResponse({
          'id': generatedId,
          'type': payload['type'],
          'status': 'active',
        });
      }),
    );

    for (final payload in payloads) {
      final params = CredentialCreateParams.fromJson(payload);
      expect(params.id, isNull);
      expect(params.toJson(), payload);
      final created = await client.credentials.create(credential: params);
      expect(created.id, generatedId);
    }
    expect(requests, payloads.length);
  });

  test('routes get, list, masked patch, and delete', () async {
    final requests = <http.Request>[];
    final client = _client(
      MockClient((request) async {
        requests.add(request);
        if (request.method == 'DELETE') return http.Response('', 204);
        if (request.url.path.endsWith('/credentials')) {
          return _jsonResponse({
            'credentials': [_metadata],
            if (request.url.queryParameters['page_token'] == null)
              'next_page_token': 'page/+=',
          });
        }
        return _jsonResponse(_metadata);
      }),
    );
    const id = 'deployment/token?more';
    final credential = await client.credentials.get(id);
    final first = await client.credentials.list(pageSize: 20);
    final second = await client.credentials.list(
      pageSize: 20,
      pageToken: first.nextPageToken,
    );
    final updated = await client.credentials.update(
      id,
      credential: const HttpBearerUpdateConfig(token: _secret, prefix: ''),
      updateMask: 'token,prefix',
    );
    await client.credentials.delete(id);

    expect(requests.map((request) => request.method), [
      'GET',
      'GET',
      'GET',
      'PATCH',
      'DELETE',
    ]);
    expect(requests.first.url.pathSegments, ['v1beta', 'credentials', id]);
    expect(requests[1].url.queryParameters, {'page_size': '20'});
    expect(requests[2].url.queryParameters, {
      'page_size': '20',
      'page_token': 'page/+=',
    });
    expect(requests[3].url.pathSegments, ['v1beta', 'credentials', id]);
    expect(requests[3].url.queryParameters, {'update_mask': 'token,prefix'});
    expect(jsonDecode(utf8.decode(requests[3].bodyBytes)), {
      'type': 'bearer_token',
      'token': _secret,
      'prefix': '',
    });
    expect(requests.last.url.pathSegments, ['v1beta', 'credentials', id]);
    expect(requests.last.body, isEmpty);
    expect(credential.type, CredentialType.bearerToken);
    expect(credential.status, CredentialStatus.active);
    expect(credential.createTime, DateTime.utc(2026, 11, 21, 19, 30));
    expect(first.credentials?.single.id, _metadata['id']);
    expect(second.nextPageToken, isNull);
    expect(updated.toJson(), _metadata);
  });

  test('models preserve update shapes and reject malformed payloads', () {
    const environment = {
      'type': 'environment_variable',
      'trusted_domains': <String>[],
      'injection_location': 'body',
    };
    const oauth = {
      'type': 'oauth2',
      'client_id': 'new-client',
      'scopes': ['read'],
    };
    expect(CredentialUpdateParams.fromJson(environment).toJson(), environment);
    expect(CredentialUpdateParams.fromJson(oauth).toJson(), oauth);
    expect(
      () => HttpBearerConfig.fromJson({
        'id': 'test',
        'type': 'oauth2',
        'token': _secret,
      }),
      throwsFormatException,
    );
    expect(
      () => Credential.fromJson({'type': 'oauth2'}),
      throwsFormatException,
    );
    expect(
      () => CredentialCreateParams.fromJson({
        'id': 'env',
        'type': 'environment_variable',
        'value': _secret,
        'injection_location': <String>[],
      }),
      throwsFormatException,
    );
  });

  test(
    'blocks unsupported backends and validates empty IDs before transport',
    () async {
      final stable = _client(
        MockClient((_) => throw StateError('Unexpected HTTP request')),
        config: _config.copyWith(apiVersion: ApiVersion.v1),
      );
      final cloud = _client(
        MockClient((_) => throw StateError('Unexpected HTTP request')),
        config: GoogleAIConfig.vertexAI(
          projectId: 'test',
          apiVersion: ApiVersion.v1beta,
          authProvider: const BearerTokenProvider('oauth-token'),
        ),
      );

      await expectLater(stable.credentials.list(), throwsUnsupportedError);
      await expectLater(
        cloud.credentials.get('some-id'),
        throwsUnsupportedError,
      );
      final developer = _client(
        MockClient((_) => throw StateError('Unexpected HTTP request')),
      );
      await expectLater(developer.credentials.get('..'), throwsArgumentError);
    },
  );

  test('redacts credential-scoped errors and attached log metadata', () async {
    final logs = <LogRecord>[];
    final listener = Logger.root.onRecord.listen(logs.add);
    addTearDown(listener.cancel);
    final client = _client(
      MockClient((_) async {
        return http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'error': {
                'message': 'Rejected $_secret',
                'details': [
                  {
                    'reason': 'INVALID',
                    'context': [
                      {'value': _secret, 'field': 'trusted_domains'},
                      {'client_secret': _secret, 'refresh_token': _refresh},
                      'echo: $_refresh',
                    ],
                  },
                ],
              },
            }),
          ),
          400,
          headers: {
            'content-type': 'application/json; charset=utf-8',
            'x-extra': 'known request secret: $_secret',
          },
        );
      }),
      config: const GoogleAIConfig.googleAI(
        authProvider: ApiKeyProvider('developer-key'),
      ),
    );
    final matcher = isA<ApiException>()
        .having((error) => error.statusCode, 'status', 400)
        .having((error) => error.message, 'message', 'Rejected ***REDACTED***')
        .having((error) => error.details, 'details', [
          {
            'reason': 'INVALID',
            'context': [
              {'value': '***REDACTED***', 'field': 'trusted_domains'},
              {
                'client_secret': '***REDACTED***',
                'refresh_token': '***REDACTED***',
              },
              'echo: ***REDACTED***',
            ],
          },
        ])
        .having(
          (error) => error.responseMetadata?.bodyExcerpt,
          'response excerpt',
          allOf(
            contains('***REDACTED***'),
            isNot(contains('credential-secret')),
            isNot(contains(_refresh)),
          ),
        )
        .having(
          (error) => error.responseMetadata?.headers['x-extra'],
          'response headers',
          'known request secret: ***REDACTED***',
        )
        .having(
          (error) => error.requestMetadata?.url.queryParameters['key'],
          'diagnostic API key',
          '***REDACTED***',
        );

    await expectLater(
      client.credentials.update(
        'oauth',
        credential: const OAuth2UpdateConfig(
          clientSecret: _secret,
          refreshToken: _refresh,
        ),
      ),
      throwsA(matcher),
    );
    expect(
      logs.singleWhere((record) => record.error is ApiException).error,
      matcher,
    );
    expect(
      logs.map((record) => record.message),
      everyElement(isNot(contains(_secret))),
    );
    expect(
      logs.map((record) => record.message),
      everyElement(isNot(contains('developer-key'))),
    );
  });

  test('redacts encoded credential echoes and diagnostic keys', () async {
    const token = 'fixture+/=token';
    final encoded = Uri.encodeComponent(token);
    const lowerEscape = 'fixture%2b%2f%3dtoken';
    const replacement = '***REDACTED***';
    final logs = <LogRecord>[];
    final listener = Logger.root.onRecord.listen(logs.add);
    addTearDown(listener.cancel);
    final client = _client(
      MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['token'], token);
        expect(request.url.queryParameters['echo'], encoded);
        return http.Response(
          jsonEncode({
            'error': {
              'message': 'Rejected https://proxy.example/$encoded',
              'details': [
                {
                  'reason': 'INVALID',
                  'request-$token': {'echo': lowerEscape},
                },
              ],
            },
          }),
          400,
          headers: {
            'content-type': 'application/json',
            'x-redirect': 'https://proxy.example/$lowerEscape',
          },
        );
      }),
      config: _config.copyWith(
        defaultQueryParams: {'echo': encoded, token: 'visible'},
        defaultHeaders: {'x-client-marker': 'echo: $encoded'},
      ),
    );

    final matcher = isA<ApiException>()
        .having(
          (error) => error.message,
          'message',
          'Rejected https://proxy.example/$replacement',
        )
        .having((error) => error.details, 'details', [
          {
            'reason': 'INVALID',
            'request-$replacement': {'echo': replacement},
          },
        ])
        .having(
          (error) => error.requestMetadata?.url.queryParameters,
          'query',
          {'echo': replacement, replacement: 'visible'},
        )
        .having(
          (error) => error.requestMetadata?.headers['x-client-marker'],
          'request header',
          'echo: $replacement',
        )
        .having(
          (error) => error.responseMetadata?.headers['x-redirect'],
          'response header',
          'https://proxy.example/$replacement',
        )
        .having(
          (error) => error.responseMetadata?.bodyExcerpt,
          'response excerpt',
          contains('request-$replacement'),
        );

    await expectLater(
      client.credentials.create(
        credential: const HttpBearerConfig(token: token),
      ),
      throwsA(matcher),
    );
    expect(
      logs.singleWhere((record) => record.error is ApiException).error,
      matcher,
    );
    final logText = logs.map((record) => record.message).join('\n');
    for (final value in [token, encoded, lowerEscape]) {
      expect(logText, isNot(contains(value)));
    }
  });

  test('redacts credential echoes inside nested provider JSON', () async {
    const token = 'fixture+/="token';
    const escaped = r'fixture+/=\"token';
    const replacement = '***REDACTED***';
    final upstream = jsonEncode({'vendor_info': token});
    final safeUpstream = jsonEncode({'vendor_info': replacement});
    final encoded = Uri.encodeComponent(escaped);
    final logs = <LogRecord>[];
    final listener = Logger.root.onRecord.listen(logs.add);
    addTearDown(listener.cancel);
    final client = _client(
      MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['token'], token);
        return http.Response(
          jsonEncode({
            'error': {
              'message': 'Upstream rejected: $upstream',
              'details': [
                {'vendor_response': upstream, 'redirect': '/$encoded'},
              ],
            },
          }),
          400,
          headers: {
            'content-type': 'application/json',
            'x-redirect': 'https://proxy.example/$encoded',
          },
        );
      }),
    );
    expect(upstream, contains(escaped));

    final matcher = isA<ApiException>()
        .having(
          (error) => error.message,
          'message',
          'Upstream rejected: $safeUpstream',
        )
        .having((error) => error.details, 'details', [
          {'vendor_response': safeUpstream, 'redirect': '/$replacement'},
        ])
        .having(
          (error) => error.responseMetadata?.headers['x-redirect'],
          'response header',
          'https://proxy.example/$replacement',
        )
        .having(
          (error) => error.responseMetadata?.bodyExcerpt,
          'response excerpt',
          isNot(contains('fixture')),
        );

    await expectLater(
      client.credentials.create(
        credential: const HttpBearerConfig(token: token),
      ),
      throwsA(matcher),
    );
    expect(
      logs.singleWhere((record) => record.error is ApiException).error,
      matcher,
    );
    expect(
      logs.map((record) => record.message),
      everyElement(isNot(contains('fixture'))),
    );
  });

  test(
    'redacts unexpected credential response values in fine logging',
    () async {
      final level = Logger.root.level;
      Logger.root.level = Level.FINE;
      addTearDown(() => Logger.root.level = level);
      final logs = <String>[];
      final listener = Logger.root.onRecord.listen(
        (record) => logs.add(record.message),
      );
      addTearDown(listener.cancel);
      final client = _client(
        MockClient((_) async {
          return _jsonResponse({
            ..._metadata,
            'value': 'unexpected-echo',
            'note': 'unexpected exact echo: $_secret',
          });
        }),
      );
      final credential = await client.credentials.create(
        credential: const HttpBearerConfig(
          id: 'deployment-token',
          token: _secret,
        ),
      );
      expect(credential.toJson(), _metadata);
      expect(logs, contains(contains('"value":"***REDACTED***"')));
      expect(logs, everyElement(isNot(contains('unexpected-echo'))));
      expect(logs, everyElement(isNot(contains('credential-secret'))));
    },
  );

  test(
    'preserves HTTP diagnostics when a secret matches a URI component',
    () async {
      final client = _client(
        MockClient(
          (_) async => _jsonResponse({
            'error': {'message': 'Rejected https'},
          }, status: 400),
        ),
      );
      await expectLater(
        client.credentials.update(
          'https',
          credential: const HttpBearerUpdateConfig(token: 'https'),
        ),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 400)
              .having(
                (error) => error.message,
                'message',
                'Rejected ***REDACTED***',
              )
              .having(
                (error) => error.requestMetadata?.url.scheme,
                'scheme',
                'https',
              )
              .having(
                (error) => error.requestMetadata?.url.pathSegments.last,
                'credential ID',
                '***REDACTED***',
              ),
        ),
      );
    },
  );

  test('retains ordinary value fields on other resources', () async {
    final client = _client(
      MockClient(
        (_) async => _jsonResponse({
          'error': {
            'message': 'Invalid input',
            'details': [
              {'value': 'ordinary metadata'},
            ],
          },
        }, status: 400),
      ),
    );
    await expectLater(
      client.models.generateContent(
        model: 'gemini-4-hydrogen',
        request: GenerateContentRequest(contents: [Content.text('Test')]),
      ),
      throwsA(
        isA<ApiException>().having((error) => error.details, 'details', [
          {'value': 'ordinary metadata'},
        ]),
      ),
    );
  });

  test('forwards cancellation through the credential write request', () async {
    final transport = _AbortableClient();
    final client = _client(transport);
    final abort = Completer<void>();
    final request = client.credentials.create(
      credential: const HttpBearerConfig(id: 'deploy', token: _secret),
      abortTrigger: abort.future,
    );
    final assertion = expectLater(request, throwsA(isA<AbortedException>()));
    await transport.started.future;
    abort.complete();
    await assertion;
  });
}

class _AbortableClient extends http.BaseClient {
  final started = Completer<void>();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    started.complete();
    expect(request, isA<http.Abortable>());
    await (request as http.Abortable).abortTrigger;
    throw http.RequestAbortedException(request.url);
  }
}
