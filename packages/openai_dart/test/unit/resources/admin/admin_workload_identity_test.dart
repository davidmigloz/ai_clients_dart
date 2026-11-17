import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart_admin.dart';
import 'package:test/test.dart';

const _providerId = 'provider / % ?';
const _ruleId = 'rule / % ?';
const _prefix = ['proxy', 'v1', 'organization', 'workload_identity_providers'];
const Map<String, dynamic> _provider = {
  'object': 'organization.workload_identity_provider',
  'id': _providerId,
  'type': 'oidc',
  'name': 'Fixture issuer',
  'issuer': 'https://issuer.invalid',
  'audience': 'fixture-audience',
  'verification': {'type': 'discovery', 'discovery_url': null},
  'description': null,
  'attribute_transformations': <Object>[],
  'enabled': true,
  'created_at': 1,
  'updated_at': 2,
};
const Map<String, dynamic> _rule = {
  'object': 'organization.workload_identity_federation_rule',
  'id': _ruleId,
  'workload_identity_provider_id': _providerId,
  'project_id': 'fixture-project',
  'service_account_id': 'fixture-account',
  'name': null,
  'description': null,
  'attribute_matchers': {'subject': 'job', 'active': true, 'version': 1.5},
  'permissions': {'type': 'service_account_default'},
  'enabled': true,
  'created_at': 1,
  'updated_at': 2,
};

void main() {
  test('provider CRUD and cursor page through the Admin entrypoint', () async {
    final requests = <http.Request>[];
    final client = _client((request) async {
      requests.add(request);
      return switch (requests.length) {
        2 => _ok(_page(_provider, _providerId)),
        4 => _ok({..._provider, 'enabled': false}),
        5 => _ok(const {
          'object': 'organization.workload_identity_provider.deleted',
          'id': _providerId,
          'deleted': true,
        }),
        _ => _ok(_provider),
      };
    });
    final providers = client.organization.workloadIdentityProviders;
    expect(providers, same(client.organization.workloadIdentityProviders));
    final create = CreateWorkloadIdentityProviderRequest.fromJson(const {
      'type': 'oidc',
      'issuer': 'https://issuer.invalid',
      'name': 'Fixture issuer',
      'audience': 'fixture-audience',
      'verification': {
        'type': 'uploaded_jwks',
        'jwks': {'keys': <Object>[]},
      },
    });
    final created = await providers.create(
      create,
      additionalHeaders: const {
        'Authorization': 'Bearer per-call-placeholder',
        'X-Caller': 'sent',
      },
    );
    final page = await providers.list(
      limit: 100,
      order: AdminListOrder.desc,
      after: 'cursor / % ?',
    );
    expect(created.toJson(), _provider);
    expect(page.data.single, created);
    expect(page.lastId, _providerId);
    expect(page.hasMore, isTrue);
    expect(page.data.clear, throwsUnsupportedError);
    expect(await providers.retrieve(_providerId), created);
    final update = UpdateWorkloadIdentityProviderRequest.fromJson(const {
      'description': null,
      'enabled': false,
    });
    final updated = await providers.update(_providerId, update);
    expect(updated.enabled, isFalse);
    final deleted = await providers.delete(_providerId);
    expect(deleted.id, _providerId);
    expect(deleted.deleted, isTrue);

    expect(requests.map((request) => request.method), [
      'POST',
      'GET',
      'GET',
      'POST',
      'DELETE',
    ]);
    for (final (index, request) in requests.indexed) {
      expect(request.url.pathSegments, [
        ..._prefix,
        if (index >= 2) _providerId,
      ]);
      _expectAdminRequest(request);
    }
    expect(requests[0].headers['x-caller'], 'sent');
    expect(jsonDecode(requests[0].body), create.toJson());
    expect(requests[1].url.queryParameters, {
      'limit': '100',
      'order': 'desc',
      'after': 'cursor / % ?',
    });
    expect(jsonDecode(requests[3].body), {
      'description': null,
      'enabled': false,
    });
  });

  test('nested rule CRUD, filters and cursors preserve opaque IDs', () async {
    final requests = <http.Request>[];
    final client = _client((request) async {
      requests.add(request);
      return switch (requests.length) {
        2 => _ok(_page(_rule, _ruleId)),
        5 => _ok(const {
          'object': 'organization.workload_identity_federation_rule.deleted',
          'id': _ruleId,
          'deleted': true,
        }),
        _ => _ok(_rule),
      };
    });
    final providers = client.organization.workloadIdentityProviders;
    final rules = providers.federationRules;
    expect(rules, same(providers.federationRules));
    final create = CreateWorkloadIdentityFederationRuleRequest.fromJson(const {
      'project_id': 'fixture-project',
      'service_account_id': 'fixture-account',
      'attribute_matchers': {'subject': 'job', 'active': true, 'version': 1.5},
      'permissions': {
        'type': 'restricted',
        'scopes': ['fixture.read'],
      },
    });
    final created = await rules.create(_providerId, create);
    final page = await rules.list(
      _providerId,
      limit: 1,
      order: AdminListOrder.asc,
      after: 'cursor / % ?',
      serviceAccountId: 'account / % ?',
    );
    expect(page.data.single, created);
    expect(page.firstId, _ruleId);
    expect(await rules.retrieve(_providerId, _ruleId), created);
    expect(
      await rules.update(
        _providerId,
        _ruleId,
        UpdateWorkloadIdentityFederationRuleRequest.fromJson(const {
          'name': null,
          'permissions': {'type': 'service_account_default'},
        }),
      ),
      created,
    );
    expect((await rules.delete(_providerId, _ruleId)).deleted, isTrue);

    expect(requests.map((request) => request.method), [
      'POST',
      'GET',
      'GET',
      'POST',
      'DELETE',
    ]);
    for (final (index, request) in requests.indexed) {
      expect(request.url.pathSegments, [
        ..._prefix,
        _providerId,
        'federation_rules',
        if (index >= 2) _ruleId,
      ]);
      _expectAdminRequest(request);
    }
    expect(jsonDecode(requests[0].body), create.toJson());
    expect(requests[1].url.queryParameters, {
      'limit': '1',
      'order': 'asc',
      'after': 'cursor / % ?',
      'service_account_id': 'account / % ?',
    });
    expect(jsonDecode(requests[3].body), {
      'name': null,
      'permissions': {'type': 'service_account_default'},
    });
  });

  test(
    'path, pagination, pre-abort and closed guards avoid dispatch',
    () async {
      final client = _client((_) async => fail('Unexpected request'));
      final providers = client.organization.workloadIdentityProviders;
      final rules = providers.federationRules;
      for (final invalidId in ['', '.', '..']) {
        expect(() => providers.retrieve(invalidId), throwsFormatException);
        expect(
          () => rules.retrieve(_providerId, invalidId),
          throwsFormatException,
        );
      }
      expect(() => providers.list(limit: 0), throwsFormatException);
      expect(() => rules.list(_providerId, limit: 101), throwsFormatException);
      expect(() => providers.list(after: ''), throwsFormatException);
      expect(
        () => rules.list(_providerId, serviceAccountId: ''),
        throwsFormatException,
      );
      expect(
        () => providers.list(order: AdminListOrder.fromJson('future')),
        throwsFormatException,
      );
      await expectLater(
        rules.list(_providerId, abortTrigger: Future<void>.value()),
        throwsA(isA<AbortedException>()),
      );
      client.close();
      expect(() => providers.federationRules, throwsStateError);
      expect(providers.list, throwsStateError);
      expect(() => rules.retrieve(_providerId, _ruleId), throwsStateError);
    },
  );

  test(
    'rule permission errors and verbose logs keep Admin values private',
    () async {
      final wasHierarchical = hierarchicalLoggingEnabled;
      hierarchicalLoggingEnabled = true;
      final logger = Logger('OpenAIAdminClient');
      final oldLevel = logger.level;
      final messages = <String>[];
      final records = logger.onRecord.listen(
        (record) => messages.add(record.message),
      );
      addTearDown(() async {
        await records.cancel();
        logger.level = oldLevel;
        hierarchicalLoggingEnabled = wasHierarchical;
      });
      final client = _client(
        (_) async => http.Response(
          jsonEncode(const {
            'error': {
              'message': 'private-response-fixture',
              'code': 'permission_denied',
            },
          }),
          403,
        ),
        logLevel: Level.FINEST,
      );
      await expectLater(
        client.organization.workloadIdentityProviders.federationRules.update(
          _providerId,
          _ruleId,
          UpdateWorkloadIdentityFederationRuleRequest.fromJson(const {
            'description': 'private-request-fixture',
          }),
        ),
        throwsA(
          isA<PermissionDeniedException>()
              .having((error) => error.code, 'code', 'permission_denied')
              .having(
                (error) => error.toString(),
                'private diagnostics',
                isNot(contains('private-response-fixture')),
              ),
        ),
      );
      expect(messages.join('\n'), contains('[REDACTED'));
      for (final private in [
        'private-request-fixture',
        'private-response-fixture',
        'admin-fixture-token',
        'provider%20',
        'rule%20',
      ]) {
        expect(messages.join('\n'), isNot(contains(private)));
      }
    },
  );
}

OpenAIAdminClient _client(
  Future<http.Response> Function(http.Request) send, {
  Level? logLevel,
}) {
  final transport = MockClient(send);
  final client = OpenAIAdminClient(
    config: OpenAIAdminConfig(
      authProvider: const ApiKeyProvider('admin-fixture-token'),
      baseUrl: 'https://fixture.invalid/proxy/v1',
      organization: 'admin-fixture-organization',
      logLevel: logLevel,
      retryPolicy: const RetryPolicy(maxRetries: 0),
    ),
    httpClient: transport,
  );
  addTearDown(transport.close);
  addTearDown(client.close);
  return client;
}

void _expectAdminRequest(http.Request request) {
  expect(request.headers['authorization'], 'Bearer admin-fixture-token');
  expect(request.headers['openai-organization'], 'admin-fixture-organization');
  expect(request.headers['openai-project'], isNull);
  expect(request.headers['accept'], 'application/json');
  expect(request.followRedirects, isFalse);
  if (request.method != 'POST') {
    expect(request.body, isEmpty);
    expect(request.headers['content-type'], isNull);
  }
}

http.Response _ok(Map<String, dynamic> body) => http.Response(
  jsonEncode(body),
  200,
  headers: const {'content-type': 'application/json'},
);

Map<String, dynamic> _page(Map<String, dynamic> item, String cursor) => {
  'object': 'list',
  'data': [item],
  'first_id': cursor,
  'last_id': cursor,
  'has_more': true,
};
