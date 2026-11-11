import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        baseUrl: 'https://example.invalid/proxy',
        authProvider: ApiKeyProvider('scoped-compliance-key'),
        apiVersion: '2026-10-21',
        workspaceId: 'workspace-config',
        defaultHeaders: {'Anthropic-Workspace-ID': 'workspace-header'},
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
  });
  tearDown(() => client.close());

  void expectRequest(
    String route, {
    Map<String, List<String>> query = const {},
  }) {
    final request = transport.lastRequest!;
    expect(request.method, 'GET');
    expect(request.url.path, '/proxy/v1/compliance/$route');
    expect(request.url.queryParametersAll, query);
    expect(request.headers['x-api-key'], 'scoped-compliance-key');
    expect(request.headers['anthropic-version'], '2026-10-21');
    expect(request.headers['authorization'], isNull);
    expect(request.headers['anthropic-workspace-id'], isNull);
    expect(request.headers['anthropic-beta'], isNull);
    expect(request.headers['accept'], 'application/json');
    expect(request.headers['content-type'], isNull);
    expect(request.followRedirects, isFalse);
  }

  test(
    'Activity Feed preserves cursor, unknown actors and unknown fields',
    () async {
      final entry = <String, dynamic>{
        'id': 'activity-1',
        'type': 'future_activity',
        'created_at': '2026-11-11T07:12:13.123456Z',
        'organization_id': 'org-1',
        'actor': {
          'type': 'future_actor',
          'email_address': 'synthetic@example.invalid',
          'extra': [
            'one',
            {'two': 2},
          ],
        },
        'details': {'system': 'synthetic', 'future_flag': true},
      };
      final body = <String, dynamic>{
        'data': [entry],
        'has_more': true,
        'first_id': 'before/+',
        'last_id': 'after/+',
      };
      transport
        ..queueJsonResponse(body)
        ..queueJsonResponse({'has_more': false});
      final activities = await client.compliance.listActivities(
        activityTypes: ['future_activity', 'claude_chat_created'],
        actorIds: ['user-1', 'key-2'],
        userIds: ['user-3'],
        organizationIds: ['org-1', 'org-2'],
        createdAt: ComplianceTimeRange(
          gte: DateTime.parse('2026-11-11T08:00:00+01:00'),
          lt: DateTime.utc(2026, 11, 12),
        ),
        order: ComplianceOrder.asc,
        limit: 50,
      );
      expectRequest(
        'activities',
        query: {
          'activity_types[]': ['future_activity', 'claude_chat_created'],
          'actor_ids[]': ['user-1', 'key-2'],
          'user_ids[]': ['user-3'],
          'organization_ids[]': ['org-1', 'org-2'],
          'created_at.gte': ['2026-11-11T07:00:00.000Z'],
          'created_at.lt': ['2026-11-12T00:00:00.000Z'],
          'order': ['asc'],
          'limit': ['50'],
        },
      );
      expect(activities.hasMore, isTrue);
      expect(activities.firstId, 'before/+');
      expect(activities.lastId, 'after/+');
      expect(activities.toJson(), body);
      final activity = activities.data.single;
      expect(activity.id, 'activity-1');
      expect(activity.type, 'future_activity');
      expect(
        activity.createdAt,
        DateTime.utc(2026, 11, 11, 7, 12, 13, 123, 456),
      );
      expect(activity.organizationId, 'org-1');
      expect(activity.actor?.type, 'future_actor');
      expect(activity.actor?.emailAddress, 'synthetic@example.invalid');
      expect(activity, ComplianceActivity.fromJson(entry));
      expect(activity.hashCode, ComplianceActivity.fromJson(entry).hashCode);
      expect(activity.toString(), isNot(contains('synthetic')));
      final rawActor = activity.raw['actor'] as Map<String, dynamic>;
      expect(() => rawActor['type'] = 'mutated', throwsUnsupportedError);
      final nested = rawActor['extra'] as List<dynamic>;
      expect(() => nested.add('mutated'), throwsUnsupportedError);

      final next = await client.compliance.listActivities(
        excludeActivityTypes: ['claude_chat_created'],
        afterId: activities.lastId,
        order: ComplianceOrder.asc,
      );
      expectRequest(
        'activities',
        query: {
          'exclude_activity_types[]': ['claude_chat_created'],
          'after_id': ['after/+'],
          'order': ['asc'],
        },
      );
      expect(next.data, isEmpty);
      expect(next.hasMore, isFalse);
    },
  );

  test('conflicting activity type filters fail before transport', () async {
    await expectLater(
      client.compliance.listActivities(
        activityTypes: ['one'],
        excludeActivityTypes: ['two'],
      ),
      throwsArgumentError,
    );
    expect(transport.requests, isEmpty);
  });

  test(
    'organizations list follows opaque next_page on an empty page',
    () async {
      transport
        ..queueJsonResponse({
          'data': <Map<String, dynamic>>[],
          'has_more': true,
          'next_page': 'a/+=b',
        })
        ..queueJsonResponse({
          'data': [
            {
              'uuid': 'org-uuid',
              'name': 'Café',
              'created_at': '2026-01-01T00:00:00Z',
            },
          ],
          'has_more': false,
          'next_page': null,
        });
      final first = await client.compliance.listOrganizations(limit: 1);
      expectRequest(
        'organizations',
        query: {
          'limit': ['1'],
        },
      );
      expect(first.data, isEmpty);
      expect(first.hasMore, isTrue);
      final next = await client.compliance.listOrganizations(
        limit: 1,
        page: first.nextPage,
      );
      expectRequest(
        'organizations',
        query: {
          'limit': ['1'],
          'page': ['a/+=b'],
        },
      );
      expect(next.nextPage, isNull);
      expect(next.data.single.uuid, 'org-uuid');
      expect(next.data.single.name, 'Café');
    },
  );

  test('organization users encode path IDs as a single segment', () async {
    transport.queueJsonResponse({
      'data': [
        {'id': 'user-1', 'email': 'user@example.invalid', 'full_name': null},
      ],
      'has_more': false,
      'next_page': null,
    });
    final response = await client.compliance.listOrganizationUsers('a/b ?');
    expectRequest('organizations/a%2Fb%20%3F/users');
    expect(transport.lastRequest!.url.pathSegments, [
      'proxy',
      'v1',
      'compliance',
      'organizations',
      'a/b ?',
      'users',
    ]);
    expect(response.data.single.id, 'user-1');
    expect(response.data.single.email, 'user@example.invalid');
    expect(response.data.single.fullName, isNull);
  });

  test(
    'organization preferences send repeated filters and explicit false',
    () async {
      transport.queueJsonResponse({
        'data': [
          {
            'user': {'id': 'user-1', 'email_address': null},
            'conversation_preferences': 'Test preference',
            'cowork_global_instructions': null,
          },
        ],
        'has_more': true,
        'next_page': 'opaque',
      });
      final page = await client.compliance.listOrganizationUserPreferences(
        'org-uuid',
        userIds: ['user-1', 'user-2'],
        includeUnset: false,
        page: 'previous',
      );
      expectRequest(
        'organizations/org-uuid/user_preferences',
        query: {
          'user_ids[]': ['user-1', 'user-2'],
          'include_unset': ['false'],
          'page': ['previous'],
        },
      );
      expect(page.nextPage, 'opaque');
      expect(page.data.single.user.id, 'user-1');
      expect(page.data.single.conversationPreferences, 'Test preference');
      expect(page.data.single.coworkGlobalInstructions, isNull);
    },
  );

  test('roles list decodes stable fields and cursor', () async {
    transport.queueJsonResponse({
      'data': [
        {'id': 'role-1', 'name': 'Viewer', 'description': 'Test role'},
      ],
      'has_more': false,
      'next_page': null,
    });
    final page = await client.compliance.listOrganizationRoles('org-uuid');
    expectRequest('organizations/org-uuid/roles');
    expect(page.data.single.name, 'Viewer');
  });

  test('retrieve role uses both identifiers', () async {
    transport.queueJsonResponse({
      'id': 'role-1',
      'name': 'Viewer',
      'description': 'Test role',
    });
    final role = await client.compliance.retrieveOrganizationRole(
      'org-uuid',
      'role-1',
    );
    expectRequest('organizations/org-uuid/roles/role-1');
    expect(role.id, 'role-1');
  });

  test('role permissions preserve action and nullable resource id', () async {
    transport.queueJsonResponse({
      'data': [
        {'action': 'read', 'resource_type': 'group', 'resource_id': null},
      ],
      'has_more': false,
      'next_page': null,
    });
    final page = await client.compliance.listOrganizationRolePermissions(
      'org-uuid',
      'role-1',
      limit: 3,
    );
    expectRequest(
      'organizations/org-uuid/roles/role-1/permissions',
      query: {
        'limit': ['3'],
      },
    );
    expect(page.data.single.action, 'read');
    expect(page.data.single.resourceId, isNull);
  });

  test(
    'organization settings retain unknown setting values and key metadata',
    () async {
      transport.queueJsonResponse({
        'organization_id': 'org-1',
        'settings': [
          {
            'type': 'future_setting',
            'value': {'future': true},
          },
        ],
        'api_keys': [
          {
            'id': 'key-1',
            'name': 'Test key',
            'scopes': ['read:org_audit'],
            'is_active': true,
          },
        ],
      });
      final settings = await client.compliance.retrieveOrganizationSettings(
        'org-uuid',
      );
      expectRequest('organizations/org-uuid/settings');
      expect(settings.organizationId, 'org-1');
      expect(settings.settings.single.type, 'future_setting');
      expect(settings.settings.single.value, {'future': true});
      expect(settings.apiKeys.single.scopes, ['read:org_audit']);
    },
  );

  test(
    'Security Posture omits configured query parameters and preserves enums',
    () async {
      transport.queueJsonResponse({
        'type': 'security_posture',
        'organization_id': 'org-1',
        'comments_status': 'future_status',
        'evaluated_at': '2026-11-11T00:00:00Z',
        'controls': [
          {
            'id': 'ctrl-1',
            'display_name': 'Example control',
            'status': 'future_control_status',
            'rating': 'info',
            'attestation': {'status': 'future_attestation'},
          },
        ],
      });
      final clientWithQueries = AnthropicClient(
        config: client.config.copyWith(
          baseUrl: 'https://example.invalid/proxy?proxy_query=one',
          defaultQueryParams: {'request_query': 'two'},
        ),
        httpClient: transport,
      );
      addTearDown(clientWithQueries.close);
      final report = await clientWithQueries.compliance.retrieveSecurityPosture(
        'org-uuid',
      );
      expectRequest('organizations/org-uuid/security_posture');
      expect(transport.lastRequest!.url.hasQuery, isFalse);
      expect(report.commentsStatus, 'future_status');
      expect(report.controls.single.status, 'future_control_status');
      expect(report.controls.single.attestation, {
        'status': 'future_attestation',
      });
    },
  );

  test('groups list sends name prefix and keeps roles', () async {
    transport.queueJsonResponse({
      'data': [
        {
          'id': 'group-1',
          'name': 'One',
          'roles': ['role-1'],
        },
      ],
      'has_more': false,
      'next_page': null,
    });
    final page = await client.compliance.listGroups(namePrefix: 'O n');
    expectRequest(
      'groups',
      query: {
        'name_prefix': ['O n'],
      },
    );
    expect(page.data.single.roles, ['role-1']);
  });

  test('retrieve group preserves nullable roles', () async {
    transport.queueJsonResponse({
      'id': 'group-1',
      'name': 'One',
      'roles': null,
    });
    final group = await client.compliance.retrieveGroup('group-1');
    expectRequest('groups/group-1');
    expect(group.id, 'group-1');
    expect(group.roles, isNull);
  });

  test('group members use opaque cursor and return member IDs', () async {
    transport.queueJsonResponse({
      'data': [
        {'user_id': 'user-1', 'email': null},
      ],
      'has_more': false,
      'next_page': null,
    });
    final page = await client.compliance.listGroupMembers(
      'group-1',
      page: 'a/+',
    );
    expectRequest(
      'groups/group-1/members',
      query: {
        'page': ['a/+'],
      },
    );
    expect(page.data.single.userId, 'user-1');
    expect(page.data.single.email, isNull);
  });

  test('preserves the provider request ID on a scoped access error', () async {
    transport.queueJsonResponse(
      {
        'type': 'error',
        'error': {'type': 'permission_error', 'message': 'Scope missing'},
      },
      statusCode: 403,
      headers: {'request-id': 'provider-id'},
    );
    await expectLater(
      client.compliance.listOrganizations(),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 403)
            .having((error) => error.requestId, 'requestId', 'provider-id')
            .having((error) => error.message, 'message', 'Scope missing'),
      ),
    );
    expectRequest('organizations');
  });

  test(
    'rejects redirects without forwarding the key or exposing Location',
    () async {
      transport.queueResponse(
        const MockResponse(
          statusCode: 302,
          headers: {
            'location': 'https://elsewhere.invalid/secret',
            'request-id': 'redirect-request',
          },
        ),
      );
      await expectLater(
        client.compliance.listOrganizations(),
        throwsA(
          isA<ApiException>()
              .having((error) => error.statusCode, 'status', 302)
              .having(
                (error) => error.requestId,
                'requestId',
                'redirect-request',
              )
              .having(
                (error) => error.responseMetadata?.headers,
                'headers',
                isNot(contains('location')),
              ),
        ),
      );
      expectRequest('organizations');
      expect(transport.requests, hasLength(1));
    },
  );

  test('rejects empty and dot-segment identifiers before transport', () {
    for (final id in ['', '.', '..', '.;example', '..;example']) {
      expect(() => client.compliance.listGroupMembers(id), throwsArgumentError);
    }
    expect(transport.requests, isEmpty);
  });

  test('rejects non-object success and invalid page entries', () async {
    transport
      ..queueResponse(const MockResponse(body: '[]'))
      ..queueJsonResponse({
        'data': ['not an object'],
      });
    await expectLater(client.compliance.listGroups(), throwsFormatException);
    await expectLater(client.compliance.listGroups(), throwsFormatException);
  });

  test(
    'a closed client rejects requests before invoking the transport',
    () async {
      client.close();
      await expectLater(client.compliance.listActivities(), throwsStateError);
      expect(transport.requests, isEmpty);
    },
  );
}
