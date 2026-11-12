import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const Map<String, Object> _endpoint = {
  'id': 'wep_fixture',
  'url': 'https://example.test/anthropic',
  'name': 'Fixture',
  'description': '',
  'state': 'enabled',
  'disabled_reason': '',
  'enabled_events': [
    'user_profile.enforcement_action_opened',
    'user_profile.enforcement_action_resolved',
    'user_profile.program_status_updated',
  ],
  'created_at': '2026-11-10T22:01:00.000Z',
  'updated_at': '2026-11-10T22:01:00.000Z',
};

const _secret = 'whsec_fixtureSecret';
const _replacement = 'whsec_fixtureReplacement';

void main() {
  late AnthropicClient client;
  late MockHttpClient transport;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin-key'),
        baseUrl: 'https://proxy.fixture/admin',
        workspaceId: 'wrkspc_ignored',
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  test('keeps configured and explicit betas with the required gate', () async {
    final betaClient = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin-key'),
        defaultHeaders: {
          'Anthropic-Beta': 'configured-beta,webhooks-2026-10-07',
        },
      ),
      httpClient: transport,
    );
    addTearDown(betaClient.close);
    for (var index = 0; index < 2; index++) {
      transport.queueJsonResponse({
        'data': <Object>[],
        'has_more': false,
        'next_page': null,
      });
    }
    final resource = betaClient.organization.webhooks;
    await resource.list();
    await resource.list(betas: ['explicit-beta', 'webhooks-2026-10-07']);
    expect(
      transport.requests.map((request) => request.headers['anthropic-beta']),
      [
        'configured-beta,webhooks-2026-10-07',
        'explicit-beta,webhooks-2026-10-07',
      ],
    );
  });

  void checkRequest(
    String method,
    String path, {
    Map<String, String> query = const {},
    Map<String, Object?>? body,
  }) {
    final request = transport.lastRequest! as http.Request;
    expect(request.method, method);
    expect(request.url.path, '/admin/v1/organizations/webhooks$path');
    expect(request.url.queryParameters, query);
    expect(request.headers['anthropic-version'], '2026-10-21');
    expect(request.headers['anthropic-beta'], 'webhooks-2026-10-07');
    expect(request.headers['anthropic-workspace-id'], isNull);
    expect(request.headers['x-api-key'], 'fixture-admin-key');
    expect(request.followRedirects, isFalse);
    if (body == null) {
      expect(request.body, isEmpty);
    } else {
      expect(jsonDecode(request.body), body);
    }
  }

  test(
    'create sends all pinned event types and protects the returned secret',
    () async {
      transport.queueJsonResponse({..._endpoint, 'signing_secret': _secret});
      final created = await client.organization.webhooks.create(
        url: 'https://example.test/anthropic',
        enabledEvents: OrganizationWebhookEventType.values,
        name: 'Fixture',
      );
      expect(created.endpoint.id, 'wep_fixture');
      expect(created.signingSecret, _secret);
      expect(created.endpoint.toJson(), _endpoint);
      expect(created.toJson()['signing_secret'], _secret);
      expect(created.toString(), isNot(contains(_secret)));
      checkRequest(
        'POST',
        '',
        body: {
          'url': 'https://example.test/anthropic',
          'name': 'Fixture',
          'enabled_events': _endpoint['enabled_events'],
        },
      );
    },
  );

  test(
    'malformed create and rotation responses omit one-time secrets',
    () async {
      const truncated = '{"signing_secret": "$_secret",';
      final responses = [
        utf8.encode(truncated),
        [...utf8.encode(truncated), 0xff],
        utf8.encode(
          jsonEncode({
            ..._endpoint,
            'created_at': _secret,
            'signing_secret': _secret,
          }),
        ),
        utf8.encode(truncated),
        [...utf8.encode(truncated), 0xff],
      ];
      final isolated = AnthropicClient.withApiKey(
        'fixture-admin-key',
        httpClient: MockClient(
          (_) async => http.Response.bytes(
            responses.removeAt(0),
            200,
            headers: {'content-type': 'application/json'},
          ),
        ),
      );
      addTearDown(isolated.close);
      final webhooks = isolated.organization.webhooks;
      final invalidResponse = throwsA(
        isA<FormatException>()
            .having((error) => error.source, 'source', isNull)
            .having(
              (error) => error.toString(),
              'diagnostic',
              isNot(contains(_secret)),
            ),
      );
      for (var index = 0; index < 3; index++) {
        await expectLater(
          webhooks.create(
            url: 'https://example.test/anthropic',
            enabledEvents: [
              OrganizationWebhookEventType.enforcementActionOpened,
            ],
          ),
          invalidResponse,
        );
      }
      for (var index = 0; index < 2; index++) {
        await expectLater(
          webhooks.regenerateSigningSecret('wep_fixture'),
          invalidResponse,
        );
      }
      expect(responses, isEmpty);
    },
  );

  test('list uses ID pagination and keeps future event names', () async {
    transport.queueJsonResponse({
      'data': [
        {
          ..._endpoint,
          'enabled_events': ['user_profile.future_event'],
        },
      ],
      'first_id': 'wep_fixture',
      'last_id': 'wep_fixture',
      'has_more': true,
    });
    final page = await client.organization.webhooks.list(
      afterId: 'wep_cursor',
      limit: 10,
      order: 'asc',
    );
    expect(page.data.single.enabledEvents, ['user_profile.future_event']);
    expect(page.hasMore, isTrue);
    expect(page.lastId, 'wep_fixture');
    checkRequest(
      'GET',
      '',
      query: {'after_id': 'wep_cursor', 'limit': '10', 'order': 'asc'},
    );
  });

  test(
    'retrieve and update preserve omission and an explicit empty event list',
    () async {
      transport
        ..queueJsonResponse(_endpoint)
        ..queueJsonResponse({..._endpoint, 'state': 'disabled'});
      final webhooks = client.organization.webhooks;
      final endpoint = await webhooks.retrieve('wep_fixture');
      expect(endpoint.toJson(), _endpoint);
      checkRequest('GET', '/wep_fixture');
      final updated = await webhooks.update(
        'wep_fixture',
        enabledEvents: [],
        state: OrganizationWebhookState.disabled,
        description: '',
      );
      expect(updated.state, 'disabled');
      checkRequest(
        'POST',
        '/wep_fixture',
        body: {
          'enabled_events': <String>[],
          'state': 'disabled',
          'description': '',
        },
      );
    },
  );

  test(
    'rotation and delete use exact routes and do not stringify a secret',
    () async {
      transport
        ..queueJsonResponse({'signing_secret': _replacement})
        ..queueJsonResponse({
          'id': 'wep_fixture',
          'type': 'webhook_endpoint_deleted',
        });
      final webhooks = client.organization.webhooks;
      final rotated = await webhooks.regenerateSigningSecret('wep_fixture');
      expect(rotated.signingSecret, _replacement);
      expect(rotated.toString(), isNot(contains(_replacement)));
      checkRequest('POST', '/wep_fixture/regenerate_signing_secret');
      final deleted = await webhooks.delete('wep_fixture');
      expect(deleted.id, 'wep_fixture');
      expect(deleted.type, 'webhook_endpoint_deleted');
      checkRequest('DELETE', '/wep_fixture');
    },
  );

  test(
    'invalid create and feature-gated failure preserve the public error paths',
    () async {
      expect(
        () => client.organization.webhooks.create(
          url: 'https://example.test',
          enabledEvents: [],
        ),
        throwsArgumentError,
      );
      expect(transport.requests, isEmpty);
      transport.queueErrorResponse(
        statusCode: 404,
        errorType: 'not_found_error',
        message: 'Webhook access unavailable',
      );
      await expectLater(
        client.organization.webhooks.list(),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 404),
        ),
      );
      checkRequest('GET', '');
    },
  );
}
