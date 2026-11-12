import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _date = '2026-11-12T00:00:00.000Z';
const _tunnelId = 'tunnel_fixture/a?b';
const _certificateId = 'certificate_fixture/c?d';
const _wif = 'fixture-workspace-bearer';
const _tunnelSecret = 'fixture-tunnel-secret';
const _pem = '-----BEGIN CERTIFICATE-----\nfixture\n-----END CERTIFICATE-----';
const _beta = 'mcp-tunnels-2026-06-22';
const Map<String, Object?> _tunnel = {
  'id': _tunnelId,
  'type': 'tunnel',
  'created_at': _date,
  'archived_at': null,
  'display_name': null,
  'domain': 'tunnel.fixture.invalid',
};
const Map<String, Object?> _cert = {
  'id': _certificateId,
  'type': 'tunnel_certificate',
  'created_at': _date,
  'archived_at': null,
  'expires_at': null,
  'fingerprint': 'fixture-fingerprint',
  'tunnel_id': _tunnelId,
};
const Map<String, Object?> _token = {
  'id': 'token_fixture',
  'type': 'tunnel_token',
  'tunnel_token': _tunnelSecret,
};

void main() {
  test(
    'every tunnel and certificate route sends scoped credentials and beta',
    () async {
      final requests = <http.Request>[];
      final client = AnthropicClient(
        config: const AnthropicConfig(
          baseUrl: 'https://fixture.invalid/proxy/?keep=a&keep=b',
          workspaceId: 'wrkspc_default',
          authProvider: ApiKeyProvider('should-not-send'),
          defaultHeaders: {
            'X-API-KEY': 'default-key',
            'Authorization': 'Bearer inherited-bearer',
            'Anthropic-Beta': 'inherited-beta',
          },
          retryPolicy: RetryPolicy(maxRetries: 0),
        ),
        httpClient: MockClient((request) async {
          requests.add(request);
          final path = request.url.pathSegments;
          final last = path.last;
          final certificates = path.contains('certificates');
          final item = certificates ? _cert : _tunnel;
          final Object body;
          if (last.endsWith('_token')) {
            body = _token;
          } else if (request.method == 'GET' &&
              (last == 'tunnels' || last == 'certificates')) {
            body = {
              'data': [item],
              'next_page': request.url.queryParameters.containsKey('page')
                  ? null
                  : 'page +/',
            };
          } else if (last == 'archive') {
            body = {...item, 'archived_at': _date};
          } else {
            body = item;
          }
          return _json(body);
        }),
      );
      addTearDown(client.close);

      final tunnels = client.tunnels.withToken(_wif);
      final created = await tunnels.create(
        displayName: 'Fixture',
        workspaceId: 'wrkspc_override',
        betas: const ['extra-beta', _beta],
      );
      expect(created.toJson(), _tunnel);
      expect(
        (await tunnels.retrieve(_tunnelId)).domain,
        'tunnel.fixture.invalid',
      );
      final first = await tunnels.list(limit: 1, includeArchived: true);
      final second = await tunnels.list(
        limit: 1,
        includeArchived: true,
        page: first.nextPage,
      );
      expect(second.toJson(), {
        'data': [_tunnel],
        'next_page': null,
      });
      expect(
        (await tunnels.archive(_tunnelId)).archivedAt,
        DateTime.parse(_date),
      );
      final revealed = await tunnels.revealToken(_tunnelId);
      expect(revealed.tunnelToken, _tunnelSecret);
      expect(revealed.toJson(), _token);
      expect(revealed.toString(), isNot(contains(_tunnelSecret)));
      expect(
        await tunnels.rotateToken(_tunnelId, reason: 'rotation'),
        revealed,
      );

      final certs = tunnels.certificates(_tunnelId);
      final cert = await certs.create(caCertificatePem: _pem);
      expect(cert.toJson(), _cert);
      expect((await certs.retrieve(_certificateId)).id, _certificateId);
      final firstCert = await certs.list(limit: 1, includeArchived: false);
      final lastCert = await certs.list(
        limit: 1,
        includeArchived: false,
        page: firstCert.nextPage,
      );
      expect(lastCert.toJson(), {
        'data': [_cert],
        'next_page': null,
      });
      expect(
        (await certs.archive(_certificateId)).archivedAt,
        DateTime.parse(_date),
      );

      await client.tunnels.retrieve(_tunnelId);
      expect(requests.map((r) => r.method), [
        'POST',
        'GET',
        'GET',
        'GET',
        'POST',
        'POST',
        'POST',
        'POST',
        'GET',
        'GET',
        'GET',
        'POST',
        'GET',
      ]);
      expect(requests.map((r) => r.url.pathSegments.skip(3).toList()), [
        <String>[],
        [_tunnelId],
        <String>[],
        <String>[],
        [_tunnelId, 'archive'],
        [_tunnelId, 'reveal_token'],
        [_tunnelId, 'rotate_token'],
        [_tunnelId, 'certificates'],
        [_tunnelId, 'certificates', _certificateId],
        [_tunnelId, 'certificates'],
        [_tunnelId, 'certificates'],
        [_tunnelId, 'certificates', _certificateId, 'archive'],
        [_tunnelId],
      ]);
      for (final (i, request) in requests.indexed) {
        expect(request.url.pathSegments.take(3).toList(), [
          'proxy',
          'v1',
          'tunnels',
        ]);
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['anthropic-beta'], switch (i) {
          0 => 'inherited-beta,extra-beta,$_beta,oauth-2025-04-20',
          _ => 'inherited-beta,$_beta,oauth-2025-04-20',
        });
        expect(
          request.headers['anthropic-workspace-id'],
          i == 0 ? 'wrkspc_override' : 'wrkspc_default',
        );
        expect(
          request.headers['authorization'],
          i == 12 ? 'Bearer inherited-bearer' : 'Bearer $_wif',
        );
        expect(request.headers['x-api-key'], isNull);
        expect(request.followRedirects, isFalse);
        expect(request.url.queryParametersAll['keep'], ['a', 'b']);
      }
      expect(jsonDecode(requests[0].body), {'display_name': 'Fixture'});
      expect(
        requests[2].url.queryParameters,
        containsPair('include_archived', 'true'),
      );
      expect(requests[3].url.queryParameters, containsPair('page', 'page +/'));
      expect(requests[5].body, isEmpty);
      expect(jsonDecode(requests[6].body), {'reason': 'rotation'});
      expect(jsonDecode(requests[7].body), {'ca_certificate_pem': _pem});
      expect(
        requests[9].url.queryParameters,
        containsPair('include_archived', 'false'),
      );
      expect(requests[10].url.queryParameters, containsPair('page', 'page +/'));
    },
  );

  test('dot identifiers never dispatch scoped credentials', () {
    var requests = 0;
    final client = AnthropicClient(
      httpClient: MockClient((_) async {
        requests++;
        return _json(_tunnel);
      }),
    );
    addTearDown(client.close);
    final tunnels = client.tunnels.withToken(_wif);
    for (final id in ['', '.', '..']) {
      expect(() => tunnels.retrieve(id), throwsArgumentError);
      expect(() => tunnels.certificates(id).list(), throwsArgumentError);
      expect(
        () => tunnels.certificates(_tunnelId).retrieve(id),
        throwsArgumentError,
      );
    }
    expect(requests, 0);
  });

  test(
    'provider-issued WIF token does not leak through tunnel metadata',
    () async {
      const mintedToken = 'fixture-minted-workspace-bearer';
      final paths = <String>[];
      final client = AnthropicClient.withWorkloadIdentity(
        identityTokenProvider: () => 'fixture.jwt.assertion',
        federationRuleId: 'fdrl_fixture',
        organizationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        serviceAccountId: 'svac_fixture',
        workspaceId: 'wrkspc_fixture',
        config: const AnthropicConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
        httpClient: _RequestlessResponse(
          MockClient((request) async {
            paths.add(request.url.path);
            if (request.url.path == '/v1/oauth/token') {
              expect(
                jsonDecode(request.body),
                containsPair('workspace_id', 'wrkspc_fixture'),
              );
              return _json({
                'access_token': mintedToken,
                'expires_in': 600,
                'token_type': 'Bearer',
                'scope': 'workspace:manage_beta',
              });
            }
            expect(request.headers['authorization'], 'Bearer $mintedToken');
            expect(request.headers['anthropic-workspace-id'], isNull);
            expect(
              request.headers['anthropic-beta']?.split(','),
              containsAll(['oauth-2025-04-20', _beta]),
            );
            return _json(
              {
                'request_id': 'req_safe',
                'error': {
                  'details': {'error_code': 'echo-$mintedToken'},
                },
              },
              status: 401,
              headers: {
                'request-id': 'echo-$mintedToken',
                'retry-after': mintedToken,
              },
            );
          }),
        ),
      );
      addTearDown(client.close);
      await expectLater(
        client.tunnels.list(),
        throwsA(
          isA<AuthenticationException>()
              .having((error) => error.requestId, 'safe body ID', 'req_safe')
              .having(
                (error) => error.errorCode,
                'credential-free code',
                isNull,
              )
              .having(
                (error) => error.responseMetadata?.headers,
                'safe headers',
                isEmpty,
              ),
        ),
      );
      expect(paths, ['/v1/oauth/token', '/v1/tunnels']);
    },
  );

  test('echoed scoped bearer is removed from error metadata', () async {
    final client = AnthropicClient(
      config: const AnthropicConfig(retryPolicy: RetryPolicy(maxRetries: 0)),
      httpClient: MockClient(
        (_) async => _json(
          {
            'request_id': 'req_safe',
            'error': {
              'details': {'error_code': _wif},
            },
          },
          status: 429,
          headers: {'request-id': _wif, 'retry-after': '1'},
        ),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.tunnels.withToken(_wif).revealToken(_tunnelId),
      throwsA(
        isA<RateLimitException>()
            .having((e) => e.requestId, 'safe body request ID', 'req_safe')
            .having((e) => e.errorCode, 'sanitized code', isNull)
            .having((e) => e.retryAfter, 'retry deadline', isNotNull)
            .having(
              (e) => e.toString(),
              'redacted diagnostic',
              isNot(contains(_wif)),
            ),
      ),
    );
  });

  test(
    'certificate errors omit echoed token, PEM, and sensitive headers',
    () async {
      final client = AnthropicClient(
        httpClient: MockClient(
          (_) async => _json(
            {
              'error': {'message': 'Bad credential $_wif, certificate $_pem'},
              'request_id': 'req_fixture',
            },
            status: 400,
            headers: {'x-debug': _wif},
          ),
        ),
      );
      addTearDown(client.close);
      final certificates = client.tunnels
          .withToken(_wif)
          .certificates(_tunnelId);
      await expectLater(
        certificates.create(caCertificatePem: _pem),
        throwsA(
          isA<ApiException>()
              .having((e) => e.statusCode, 'status', 400)
              .having((e) => e.requestId, 'provider ID', 'req_fixture')
              .having(
                (e) => e.responseMetadata!.bodyExcerpt,
                'excerpt',
                isEmpty,
              )
              .having((e) => e.responseMetadata!.headers, 'headers', isEmpty)
              .having(
                (e) => e.toString(),
                'diagnostic',
                allOf(isNot(contains(_pem)), isNot(contains(_wif))),
              ),
        ),
      );
    },
  );

  test('malformed successful token response is redacted', () async {
    final client = AnthropicClient(
      httpClient: MockClient(
        (_) async => http.Response(
          'token: $_tunnelSecret',
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
    addTearDown(client.close);
    await expectLater(
      client.tunnels.withToken(_wif).revealToken(_tunnelId),
      throwsA(
        isA<FormatException>().having(
          (e) => e.toString(),
          'diagnostic',
          isNot(contains(_tunnelSecret)),
        ),
      ),
    );
  });
}

http.Response _json(
  Object body, {
  int status = 200,
  Map<String, String> headers = const {},
}) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json', ...headers},
);

class _RequestlessResponse extends http.BaseClient {
  _RequestlessResponse(this.delegate);

  final http.Client delegate;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await delegate.send(request);
    return http.StreamedResponse(
      response.stream,
      response.statusCode,
      headers: response.headers,
    );
  }

  @override
  void close() => delegate.close();
}
