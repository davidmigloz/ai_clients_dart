import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _apiKey = 'fixture-demo-api-key';
const _webhookSecret = 'fixture-signing-secret';

const Map<String, Object?> _account = {
  'id': 'service-1',
  'name': 'Worker',
  'customer_id': 'customer-1',
  'organization_id': 'org-1',
  'workspace_id': 'workspace-1',
  'description': null,
  'created_at': '2026-11-27T10:00:00.123456Z',
  'updated_at': '2026-11-27T10:01:00.123456Z',
  'deleted_at': null,
};

const Map<String, Object?> _webhook = {
  'id': 'source-1',
  'creator_id': 'creator-1',
  'organization_id': 'org-1',
  'workspace_id': 'workspace-1',
  'owner_type': 'workspace',
  'provider': 'github',
  'name': 'Provider deliveries',
  'url': 'https://example.test/providers/github/sources/source-1',
  'http_method': 'POST',
  'url_verified': true,
  'signature_hash_algorithm': 'sha256',
  'signature_header_name': 'X-Hub-Signature-256',
  'validity_period_second': null,
  'signature_extractor_regex': null,
  'timestamp_extractor_regex': null,
  'signature_payload_pattern': null,
  'signature_encoding': 'hex',
  'success_status_code': 200,
  'url_verification_token': 'fixture-provider-token',
  'expires_at': null,
  'created_at': '2026-11-27T10:00:00Z',
  'updated_at': '2026-11-27T10:00:00Z',
};

const Map<String, Object?> _trigger = {
  'id': 'trigger-1',
  'creator_id': 'creator-1',
  'workspace_id': 'workspace-1',
  'organization_id': 'org-1',
  'customer_id': 'customer-1',
  'owner_type': 'workspace',
  'event_source': _webhook,
  'handler': 'workflows',
  'action': {'type': 'start_workflow', 'primitive_id': 'workflow-1'},
  'filters': null,
  'title': 'Start workflow',
};

const Map<String, Object> _roles = {
  'items': [
    {'role_id': 'role-1'},
  ],
};

http.Response _json(Object value, [int status = 200]) => http.Response(
  jsonEncode(value),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  late MistralClient client;
  late List<http.Request> requests;
  late http.Response Function(http.Request) reply;

  setUp(() {
    requests = [];
    client = MistralClient(
      config: const MistralConfig(authProvider: ApiKeyProvider(_apiKey)),
      httpClient: MockClient((request) async {
        requests.add(request);
        return reply(request);
      }),
    );
    addTearDown(client.close);
  });

  test(
    'identifies human users and service accounts using either auth form',
    () async {
      reply = (request) {
        if (request.url.path == '/v1/users/me') {
          return _json({
            'id': 'user-1',
            'email': 'fixture@example.test',
            'first_name': 'Tester',
            'last_name': null,
          });
        }
        return _json({
          'principal': request.headers.containsKey('x-api-key')
              ? {
                  'principal_type': 'service_account',
                  'service_account_id': 'worker-1',
                  'name': 'Worker',
                }
              : {
                  'principal_type': 'user',
                  'id': 'user-1',
                  'email': 'fixture@example.test',
                },
          'workspace': {'id': 'workspace-1', 'name': 'Build'},
          'organization': {'id': 'org-1', 'name': 'Organization'},
          'customer_id': 'customer-1',
        });
      };

      expect((await client.users.me()).id, 'user-1');
      final user = await client.users.whoami();
      final service = await client.users.whoami(authInApiKeyHeader: true);
      expect(user.principal, isA<WhoamiUserPrincipal>());
      expect(
        (service.principal as WhoamiServiceAccountPrincipal).serviceAccountId,
        'worker-1',
      );
      expect(service.organization?.id, 'org-1');
      expect(service.workspace?.id, 'workspace-1');
      expect(service.customerId, 'customer-1');
      expect(WhoamiResponse.fromJson(service.toJson()), service);
      expect(requests.map((request) => request.method), ['GET', 'GET', 'GET']);
      expect(requests.map((request) => request.url.path), [
        '/v1/users/me',
        '/v1/whoami',
        '/v1/whoami',
      ]);
      expect(requests[0].headers['authorization'], 'Bearer $_apiKey');
      expect(requests[1].headers['authorization'], 'Bearer $_apiKey');
      expect(requests[2].headers['x-api-key'], _apiKey);
      expect(requests[2].headers['authorization'], isNull);
    },
  );

  test(
    'pages member organizations and organization-scoped workspaces',
    () async {
      reply = (request) => request.url.path.endsWith('/organizations')
          ? _json({
              'organizations': [
                {'id': 'org-1', 'name': 'Organization'},
              ],
            })
          : _json({
              'workspaces': [
                {
                  'id': 'workspace-1',
                  'name': 'Build',
                  'organization_id': 'org-1',
                },
              ],
            });
      final organizations = await client.users.listOrganizations(
        offset: 10,
        limit: 10,
      );
      final scoped = await client.users.listWorkspaces(
        organizationId: organizations.organizations.single.id,
        offset: 2,
        limit: 10,
        authInApiKeyHeader: true,
      );

      expect(requests.map((request) => request.url.path), [
        '/v1/users/me/organizations',
        '/v1/users/me/workspaces',
      ]);
      expect(requests[0].url.queryParameters, {'offset': '10', 'limit': '10'});
      expect(requests[1].url.queryParameters, {
        'organization_id': 'org-1',
        'offset': '2',
        'limit': '10',
      });
      expect(requests[1].headers['x-api-key'], _apiKey);
      expect(scoped.workspaces.single.organizationId, 'org-1');
    },
  );

  test(
    'fetches billing budget and subscription using dashboard auth',
    () async {
      const detail = {
        'usage_percentage': 25,
        'initial_budget': 10.50,
        'reset_at': '2026-12-01T00:00:00Z',
        'currency': 'EUR',
        'payg_enabled': true,
      };
      reply = (request) => request.url.path.endsWith('/budget')
          ? _json({'api_budget': detail, 'vibe_budget': detail})
          : _json({
              'plan_name': 'Fixture plan',
              'payg_enabled': true,
              'vibe_payg_enabled': false,
              'enterprise': false,
            });

      final budget = await client.billing.getBudget();
      final subscription = await client.billing.getSubscription();
      expect(requests.map((request) => request.method), ['GET', 'GET']);
      expect(requests.map((request) => request.url.path), [
        '/v1/billing/budget',
        '/v1/billing/subscription',
      ]);
      for (final request in requests) {
        expect(request.headers['x-api-key'], _apiKey);
        expect(request.headers['authorization'], isNull);
      }
      expect(budget.apiBudget.initialBudget, 10.5);
      expect(budget.vibeBudget.currency, 'EUR');
      expect(subscription.paygEnabled, isTrue);
      expect(subscription.vibePaygEnabled, isFalse);
    },
  );

  test(
    'paginates, creates, retrieves, updates and deletes service accounts',
    () async {
      reply = (request) {
        if (request.method == 'DELETE') return http.Response('', 204);
        if (request.url.path == '/v1/service-accounts' &&
            request.method == 'GET') {
          return _json({
            'items': [_account],
          });
        }
        return _json(_account, request.method == 'POST' ? 201 : 200);
      };

      final listed = await client.serviceAccounts.list(
        workspaceId: 'workspace-1',
        includeDeleted: true,
        query: 'work',
        order: ServiceAccountSortOrder.desc,
        offset: 25,
        limit: 25,
      );
      final created = await client.serviceAccounts.create(
        request: const CreateServiceAccountRequest(
          name: 'Worker',
          workspaceId: 'workspace-1',
          roleIds: ['role-1'],
        ),
      );
      final found = await client.serviceAccounts.get(
        serviceAccountId: created.id,
      );
      await client.serviceAccounts.update(
        serviceAccountId: found.id,
        request: const UpdateServiceAccountRequest(clearDescription: true),
      );
      await client.serviceAccounts.delete(serviceAccountId: found.id);

      expect(listed.items.single, created);
      expect(found, created);
      expect(found.toJson(), _account);
      expect(requests.map((request) => request.method), [
        'GET',
        'POST',
        'GET',
        'PATCH',
        'DELETE',
      ]);
      expect(requests.map((request) => request.url.path), [
        '/v1/service-accounts',
        '/v1/service-accounts',
        '/v1/service-accounts/service-1',
        '/v1/service-accounts/service-1',
        '/v1/service-accounts/service-1',
      ]);
      expect(requests.first.url.queryParameters, {
        'workspace_id': 'workspace-1',
        'include_deleted': 'true',
        'q': 'work',
        'order': 'desc',
        'offset': '25',
        'limit': '25',
      });
      expect(
        requests[1].headers['content-type'],
        startsWith('application/json'),
      );
      expect(jsonDecode(requests[1].body), {
        'name': 'Worker',
        'workspace_id': 'workspace-1',
        'role_ids': ['role-1'],
      });
      expect(jsonDecode(requests[3].body), {'description': null});
      for (final request in requests) {
        expect(request.headers['authorization'], 'Bearer $_apiKey');
      }
    },
  );

  test(
    'lists assignable roles in a workspace and replaces assigned roles',
    () async {
      reply = (request) => request.url.path.endsWith('/assignable-roles')
          ? _json({
              'items': [
                {
                  'uuid': 'role-1',
                  'name': 'Worker',
                  'description': 'Run jobs',
                  'is_custom_role': true,
                },
              ],
            })
          : _json(_roles);

      final roles = await client.serviceAccounts.listAssignableRoles(
        workspaceId: 'workspace-1',
      );
      final roleId = roles.items.single.uuid;
      final assigned = await client.serviceAccounts.setRoles(
        serviceAccountId: 'service-1',
        request: SetServiceAccountRolesRequest(roleIds: [roleId]),
      );
      final listed = await client.serviceAccounts.listRoles(
        serviceAccountId: 'service-1',
      );

      expect(assigned.items.single.roleId, roleId);
      expect(listed, assigned);
      expect(requests.map((request) => request.method), ['GET', 'PUT', 'GET']);
      expect(requests.map((request) => request.url.path), [
        '/v1/service-accounts/assignable-roles',
        '/v1/service-accounts/service-1/roles',
        '/v1/service-accounts/service-1/roles',
      ]);
      expect(requests.first.url.queryParameters, {
        'workspace_id': 'workspace-1',
      });
      expect(jsonDecode(requests[1].body), {
        'role_ids': ['role-1'],
      });
    },
  );

  test(
    'manages provider webhooks and keeps secrets out of model descriptions',
    () async {
      reply = (request) {
        if (request.method == 'DELETE') return http.Response('', 204);
        if (request.url.path.endsWith('/signing-secret')) {
          return _json({'signing_secret': _webhookSecret});
        }
        if (request.url.path == '/v1/webhooks' && request.method == 'GET') {
          return _json([_webhook]);
        }
        return _json(_webhook, request.method == 'POST' ? 201 : 200);
      };
      const creation = CreateWebhookRequest(
        provider: WebhookProvider.github,
        name: 'Provider deliveries',
        ownerType: TriggerOwnerType.workspace,
        secret: _webhookSecret,
        encryptionKey: 'fixture-encryption-key',
        urlVerificationToken: 'fixture-provider-token',
      );

      final created = await client.webhooks.create(request: creation);
      expect((await client.webhooks.list()).single, created);
      expect(await client.webhooks.get(webhookId: created.id), created);
      final signing = await client.webhooks.getSigningSecret(
        webhookId: created.id,
      );
      await client.webhooks.delete(webhookId: created.id);

      expect(created.toJson(), _webhook);
      expect(signing.signingSecret, _webhookSecret);
      expect(creation.toString(), isNot(contains(_webhookSecret)));
      expect(creation.toString(), isNot(contains('fixture-encryption-key')));
      expect(created.toString(), isNot(contains('fixture-provider-token')));
      expect(signing.toString(), isNot(contains(_webhookSecret)));
      expect(jsonDecode(requests.first.body), {
        'provider': 'github',
        'name': 'Provider deliveries',
        'owner_type': 'workspace',
        'secret': _webhookSecret,
        'encryption_key': 'fixture-encryption-key',
        'url_verification_token': 'fixture-provider-token',
      });
      expect(requests.map((request) => request.method), [
        'POST',
        'GET',
        'GET',
        'GET',
        'DELETE',
      ]);
      expect(requests.map((request) => request.url.path), [
        '/v1/webhooks',
        '/v1/webhooks',
        '/v1/webhooks/source-1',
        '/v1/webhooks/source-1/signing-secret',
        '/v1/webhooks/source-1',
      ]);
      expect(
        requests.every(
          (request) => request.headers['authorization'] == 'Bearer $_apiKey',
        ),
        isTrue,
      );
    },
  );

  test('manages triggers and reads recent event state', () async {
    reply = (request) {
      if (request.method == 'DELETE') return http.Response('', 204);
      if (request.url.path.endsWith('/events')) {
        return _json({
          'data': [
            {
              'event_id': 'event-1',
              'trigger_id': 'trigger-1',
              'source_id': 'source-1',
              'status': 'SUBMISSION_FAILED',
              'received_at': '2026-11-27T10:00:00Z',
              'submitted_at': null,
              'triggered_at': null,
              'detail': 'Execution unavailable',
              'url': null,
            },
          ],
        });
      }
      if (request.url.path == '/v1/triggers' && request.method == 'GET') {
        return _json([_trigger]);
      }
      return _json(_trigger, request.method == 'POST' ? 201 : 200);
    };

    final created = await client.triggers.create(
      request: const CreateTriggerRequest(
        eventSourceId: 'source-1',
        handler: TriggerHandler.workflows,
        action: TriggerAction(
          primitiveId: 'workflow-1',
          type: TriggerActionType.startWorkflow,
        ),
        ownerType: TriggerOwnerType.workspace,
        title: 'Start workflow',
      ),
    );
    final matching = await client.triggers.list(
      handler: TriggerHandler.workflows,
      primitiveId: 'workflow-1',
      eventSourceId: 'source-1',
    );
    final found = await client.triggers.get(triggerId: created.id);
    final recent = await client.triggers.listEvents(
      triggerId: created.id,
      limit: 25,
    );
    await client.triggers.delete(triggerId: created.id);

    expect(matching.single, created);
    expect(found.toJson(), _trigger);
    expect(recent.data.single.status, TriggerStatus.submissionFailed);
    expect(recent.data.single.triggeredAt, isNull);
    expect(requests.map((request) => request.method), [
      'POST',
      'GET',
      'GET',
      'GET',
      'DELETE',
    ]);
    expect(requests.map((request) => request.url.path), [
      '/v1/triggers',
      '/v1/triggers',
      '/v1/triggers/trigger-1',
      '/v1/triggers/trigger-1/events',
      '/v1/triggers/trigger-1',
    ]);
    expect(jsonDecode(requests[0].body), {
      'event_source_id': 'source-1',
      'handler': 'workflows',
      'action': {'primitive_id': 'workflow-1', 'type': 'start_workflow'},
      'owner_type': 'workspace',
      'title': 'Start workflow',
    });
    expect(requests[1].url.queryParameters, {
      'handler': 'workflows',
      'primitive_id': 'workflow-1',
      'event_source_id': 'source-1',
    });
    expect(requests[3].url.queryParameters, {'limit': '25'});
  });

  test(
    'webhook failures redact echoed secrets while preserving status',
    () async {
      reply = (_) => http.Response(
        jsonEncode({'message': 'Invalid secret: $_webhookSecret'}),
        401,
        headers: {'x-secret': _webhookSecret},
      );

      try {
        await client.webhooks.create(
          request: const CreateWebhookRequest(
            provider: WebhookProvider.github,
            name: 'fixture',
            secret: _webhookSecret,
          ),
        );
        fail('Expected an authentication exception');
      } on AuthenticationException catch (error) {
        expect(error.toString(), isNot(contains(_webhookSecret)));
        expect(error.details, isEmpty);
        expect(error.responseMetadata?.bodyExcerpt, '[REDACTED]');
        expect(error.responseMetadata?.headers, isNot(contains('x-secret')));
      }
      expect(requests.single.headers['authorization'], 'Bearer $_apiKey');
    },
  );

  test(
    'preserves omission and explicit clearing in service account updates',
    () {
      final unresolved = UpdateServiceAccountRequest.fromJson({});
      final cleared = UpdateServiceAccountRequest.fromJson({
        'description': null,
      });
      final set = cleared.copyWith(description: 'New role');
      expect(unresolved.toJson(), isEmpty);
      expect(cleared.toJson(), {'description': null});
      expect(set.toJson(), {'description': 'New role'});
      expect(set.copyWith(clearDescription: true).toJson(), {
        'description': null,
      });
      expect(set.copyWith(description: null).toJson(), {'description': null});
    },
  );

  test('preserves JSON for a future identity principal', () {
    const wire = {
      'principal': {
        'principal_type': 'application',
        'application_id': 'app-1',
        'context': {
          'permissions': ['reports'],
        },
      },
    };
    final identity = WhoamiResponse.fromJson(wire);
    expect(identity.principal, isA<UnknownWhoamiPrincipal>());
    expect(identity.toJson(), wire);
  });
}
