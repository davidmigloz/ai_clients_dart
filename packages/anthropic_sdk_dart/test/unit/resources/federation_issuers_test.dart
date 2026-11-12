import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

const _route = '/proxy/v1/organizations/federation_issuers';
const _issuerId = 'fdis_fixture';
const _timestamp = '2026-11-11T00:00:00.000Z';
const _requestBeta = 'fixture-beta';
const _oauthBeta = 'oauth-2025-04-20';

void main() {
  for (final beta in [false, true]) {
    group(beta ? 'caller beta' : 'GA', () {
      final betas = [if (beta) _requestBeta];
      final authBeta = beta ? '$_requestBeta,$_oauthBeta' : _oauthBeta;
      late List<http.Request> requests;
      late http.Response response;
      late AnthropicClient client;
      late OrganizationFederationIssuersResource issuers;

      setUp(() {
        requests = [];
        response = _json(_issuer());
        final transport = MockClient((request) async {
          requests.add(request);
          return response;
        });
        addTearDown(transport.close);
        client = AnthropicClient.withAuthToken(
          'fixture-token',
          config: const AnthropicConfig(
            baseUrl: 'https://fixture.invalid/proxy',
            workspaceId: 'other-workspace',
            defaultHeaders: {'Anthropic-Workspace-Id': 'header-workspace'},
            retryPolicy: RetryPolicy(maxRetries: 0),
          ),
          httpClient: transport,
        );
        issuers = client.organization.federation.issuers;
        addTearDown(client.close);
      });

      void expectRequest(String method, String path) {
        final request = requests.last;
        expect(request.method, method);
        expect(request.url.path, path);
        expect(request.headers['authorization'], 'Bearer fixture-token');
        expect(request.headers['x-api-key'], isNull);
        expect(request.headers['anthropic-beta'], authBeta);
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['anthropic-workspace-id'], isNull);
        expect(request.followRedirects, isFalse);
        expect(request.url.queryParameters.containsKey('beta'), isFalse);
      }

      test('create sends issuer settings and typed discovery source', () async {
        final issuer = await issuers.create(
          const FederationIssuerCreateParams(
            name: 'fixture',
            issuerUrl: 'https://idp.invalid/trailing/',
            checkJti: false,
            maxJwtLifetimeSeconds: 3600,
            jwks: FederationJwksSource.discovery(
              discoveryBase: 'https://issuer.invalid',
              caCertPem: 'fixture-pem',
            ),
          ),
          betas: betas,
        );
        expectRequest('POST', _route);
        expect(jsonDecode(requests.last.body), {
          'name': 'fixture',
          'issuer_url': 'https://idp.invalid/trailing/',
          'check_jti': false,
          'max_jwt_lifetime_seconds': 3600,
          'jwks': {
            'type': 'discovery',
            'discovery_base': 'https://issuer.invalid',
            'ca_cert_pem': 'fixture-pem',
          },
        });
        expect(issuer.id, _issuerId);
        expect(issuer.checkJti, isTrue);
      });

      test('list preserves archived filter and opaque page', () async {
        response = _json({
          'data': [_issuer()],
          'next_page': 'a/+=?',
        });
        final page = await issuers.list(
          includeArchived: false,
          limit: 2,
          page: 'previous/+',
          betas: betas,
        );
        expectRequest('GET', _route);
        expect(requests.last.url.queryParameters, {
          'include_archived': 'false',
          'limit': '2',
          'page': 'previous/+',
        });
        expect(page.nextPage, 'a/+=?');
        expect(page.data.single.id, _issuerId);
        response = _json({'data': <Object>[], 'next_page': null});
        final next = await issuers.list(
          includeArchived: false,
          limit: 2,
          page: page.nextPage,
          betas: betas,
        );
        expectRequest('GET', _route);
        expect(requests.last.url.queryParameters['page'], 'a/+=?');
        expect(next.data, isEmpty);
        expect(next.nextPage, isNull);
      });

      test('retrieve encodes identifier and preserves polling state', () async {
        final issuer = await issuers.retrieve('fdis/a ?', betas: betas);
        expectRequest('GET', '$_route/fdis%2Fa%20%3F');
        expect(requests.last.url.pathSegments.last, 'fdis/a ?');
        expect(issuer.pollStatus?.consecutiveFailures, 2);
        expect(issuer.pollStatus?.nextPollAt, isNull);
        expect(issuer.pollStatus?.lastFetchedAt, DateTime.parse(_timestamp));
        expect(issuer.archivedByActorId, isNull);
      });

      test('unsafe issuer IDs fail before dispatch', () {
        for (final id in ['', '.', '..', '..;metadata']) {
          expect(() => issuers.retrieve(id, betas: betas), throwsArgumentError);
          expect(() => issuers.archive(id, betas: betas), throwsArgumentError);
        }
        expect(requests, isEmpty);
      });

      test('update preserves explicit nulls and re-enables polling', () async {
        final issuer = await issuers.update(
          _issuerId,
          FederationIssuerUpdateParams(
            checkJti: null,
            jwks: const FederationJwksSource.explicitUrl(
              url: 'https://idp.invalid/jwks',
            ),
            jwksPollingDisabled: false,
          ),
          betas: betas,
        );
        expectRequest('POST', '$_route/$_issuerId');
        expect(jsonDecode(requests.last.body), {
          'check_jti': null,
          'jwks': {'type': 'explicit_url', 'url': 'https://idp.invalid/jwks'},
          'jwks_polling_disabled': false,
        });
        expect(issuer.name, 'fixture');
      });

      test('archive uses action route without a request body', () async {
        response = _json({
          ..._issuer(),
          'archived_at': _timestamp,
          'archived_by_actor_id': 'svac_admin',
        });
        final issuer = await issuers.archive(_issuerId, betas: betas);
        expectRequest('POST', '$_route/$_issuerId/archive');
        expect(requests.last.bodyBytes, isEmpty);
        expect(issuer.archivedAt, DateTime.parse(_timestamp));
        expect(issuer.archivedByActorId, 'svac_admin');
      });
    });
  }

  test(
    'JWKS variants round-trip with deep equality and redact payload values',
    () {
      final payloads = <Map<String, dynamic>>[
        {'type': 'discovery', 'ca_cert_pem': 'fixture-pem'},
        {'type': 'explicit_url', 'url': 'https://fixture.invalid/jwks'},
        {
          'type': 'inline',
          'keys': [
            {
              'kty': 'RSA',
              'n': 'fixture-secret',
              'x5c': ['fixture-certificate'],
            },
          ],
        },
        {
          'type': 'future_source',
          'future': {
            'keys': ['fixture-secret'],
          },
        },
      ];
      for (final payload in payloads) {
        final parsed = FederationJwksSource.fromJson(payload);
        final roundTrip = FederationJwksSource.fromJson(parsed.toJson());
        expect(parsed.toJson(), payload);
        expect(parsed, roundTrip);
        expect(parsed.hashCode, roundTrip.hashCode);
        expect(parsed.toString(), isNot(contains('fixture-')));
      }
      final source =
          FederationJwksSource.fromJson(payloads[2]) as FederationJwksInline;
      final chain = source.keys.single['x5c'] as List<dynamic>;
      expect(() => chain.add('mutation'), throwsUnsupportedError);
      expect(() => source.keys.single['kty'] = 'new', throwsUnsupportedError);
    },
  );

  test('rejects malformed known JWKS and missing required issuer fields', () {
    expect(
      () => FederationJwksSource.fromJson(const {
        'type': 'inline',
        'keys': <Object>[],
      }),
      throwsFormatException,
    );
    expect(
      () => FederationJwksSource.fromJson(const {'type': 'explicit_url'}),
      throwsFormatException,
    );
    expect(
      () => FederationIssuer.fromJson(_issuer()..remove('poll_status')),
      throwsFormatException,
    );
  });

  test('issuer and write params preserve nullable values and equality', () {
    final payload = _issuer();
    final issuer = FederationIssuer.fromJson(payload);
    expect(issuer.toJson(), payload);
    expect(issuer, FederationIssuer.fromJson(issuer.toJson()));
    expect(
      issuer.hashCode,
      FederationIssuer.fromJson(issuer.toJson()).hashCode,
    );

    final archived = issuer.copyWith(archivedAt: DateTime.parse(_timestamp));
    expect(archived, isNot(issuer));
    expect(archived.copyWith(archivedAt: null), issuer);
    expect(
      issuer.pollStatus?.copyWith(lastFetchedAt: null).toJson(),
      containsPair('last_fetched_at', null),
    );

    final create = FederationIssuerCreateParams.fromJson(const {
      'issuer_url': 'https://idp.invalid',
      'name': 'fixture',
      'check_jti': false,
    });
    expect(create.toJson(), {
      'issuer_url': 'https://idp.invalid',
      'name': 'fixture',
      'check_jti': false,
    });
    expect(create, FederationIssuerCreateParams.fromJson(create.toJson()));

    final patch = FederationIssuerUpdateParams.fromJson(const {
      'jwks': null,
      'check_jti': false,
      'name': null,
    });
    expect(patch.toJson(), {'jwks': null, 'check_jti': false, 'name': null});
    expect(patch, FederationIssuerUpdateParams.fromJson(patch.toJson()));
    expect(
      () => FederationIssuerUpdateParams(jwksPollingDisabled: true),
      throwsArgumentError,
    );
  });

  test(
    'requires server-authorized OAuth scope and preserves request IDs',
    () async {
      final transport = MockClient(
        (_) async => http.Response(
          '{"error":{"type":"permission_error","message":"org:admin required"}}',
          403,
          headers: {
            'content-type': 'application/json',
            'request-id': 'req_admin_scope',
          },
        ),
      );
      addTearDown(transport.close);
      final client = AnthropicClient.withAuthToken(
        'insufficient-oauth-token',
        httpClient: transport,
      );
      addTearDown(client.close);
      await expectLater(
        client.organization.federation.issuers.list(),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 403)
              .having((error) => error.requestId, 'ID', 'req_admin_scope'),
        ),
      );
    },
  );

  test('buffered OAuth diagnostics redact echoed credentials', () async {
    const token = 'fake-org-admin-bearer-fixture';
    final logs = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(logs.add);
    addTearDown(subscription.cancel);
    final transport = MockClient((request) async {
      expect(request.headers['authorization'], 'Bearer $token');
      final body = jsonEncode({
        'type': 'error',
        'request_id': 'req_permission_failure',
        'error': {
          'type': 'permission_error',
          'message': 'Denied for Bearer $token',
          'details': {
            'error_code': 'issuer_scope_required',
            'scope': 'org:admin',
            'nested': [
              {'echo': token, 'token-$token': 'reflected key'},
            ],
          },
        },
      }).replaceAll(token, r'\u0066ake-org-admin-bearer-fixture');
      return http.Response(
        body,
        403,
        headers: {
          'content-type': 'application/json',
          'request-id': token,
          'x-reflected': 'Bearer $token',
          'retry-after': '5',
        },
      );
    });
    addTearDown(transport.close);
    final client = AnthropicClient.withAuthToken(token, httpClient: transport);
    addTearDown(client.close);
    await expectLater(
      client.organization.federation.issuers.list(),
      throwsA(
        isA<ApiException>()
            .having((e) => e.requestId, 'body ID', 'req_permission_failure')
            .having((e) => e.errorCode, 'error code', 'issuer_scope_required')
            .having((e) => e.message, 'safe message', 'Denied for [REDACTED]')
            .having((e) => e.errorDetails, 'safe details', {
              'error_code': 'issuer_scope_required',
              'scope': 'org:admin',
              'nested': [
                {'echo': '[REDACTED]'},
              ],
            })
            .having(
              (e) => e.responseMetadata?.bodyExcerpt,
              'safe excerpt',
              isEmpty,
            )
            .having((e) => e.responseMetadata?.headers, 'safe headers', {
              'content-type': 'application/json',
              'retry-after': '5',
            })
            .having(
              (e) => e.toString(),
              'safe diagnostic',
              isNot(contains(token)),
            ),
      ),
    );
    final warnings = logs.where((record) => record.level == Level.WARNING);
    expect(warnings, isNotEmpty);
    expect(
      warnings.map((record) => record.message),
      everyElement(isNot(contains(token))),
    );
  });
}

Map<String, dynamic> _issuer() => {
  'type': 'federation_issuer',
  'id': _issuerId,
  'name': 'fixture',
  'issuer_url': 'https://idp.invalid/trailing/',
  'jwks': {'type': 'discovery'},
  'check_jti': true,
  'max_jwt_lifetime_seconds': 3600,
  'created_at': _timestamp,
  'created_by_actor_id': 'user_creator',
  'updated_at': _timestamp,
  'updated_by_actor_id': null,
  'archived_at': null,
  'archived_by_actor_id': null,
  'jwks_polling_disabled_at': null,
  'poll_status': {
    'consecutive_failures': 2,
    'last_fetched_at': _timestamp,
    'next_poll_at': null,
  },
};

http.Response _json(Map<String, dynamic> value) => http.Response(
  jsonEncode(value),
  200,
  headers: {'content-type': 'application/json'},
);
