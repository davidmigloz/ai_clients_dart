import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _workspace = 'wrkspc_fixture';
const _user = 'user_fixture';
const _time = '2026-11-11T00:00:00.000Z';
const Map<String, Object?> _key = {
  'id': 'apikey_fixture',
  'type': 'api_key',
  'name': 'Fixture key',
  'status': 'active',
  'created_at': _time,
  'expires_at': null,
  'partial_key_hint': 'hint',
  'created_by': {'id': _user, 'type': 'user'},
  'principal': {'type': 'user_actor', 'user_id': _user},
  'scope': {'type': 'workspace', 'workspace_id': _workspace},
};
const Map<String, Object?> _workspaceRecord = {
  'id': _workspace,
  'type': 'workspace',
  'name': 'Default',
  'created_at': _time,
  'archived_at': null,
  'compartment_id': 'compartment_fixture',
  'display_color': '#abcabc',
  'data_residency': {
    'workspace_geo': 'us',
    'default_inference_geo': 'global',
    'allowed_inference_geos': 'unrestricted',
  },
  'external_key_id': null,
  'user_profile_id': null,
  'tags': {'env': 'test'},
};
const Map<String, String> _userRecord = {
  'id': _user,
  'type': 'user',
  'name': 'Fixture',
  'email': 'user@example.com',
  'role': 'developer',
  'added_at': _time,
};
const Map<String, Object?> _invite = {
  'id': 'invite_fixture',
  'type': 'invite',
  'role': 'user',
  'email': 'user@example.com',
  'status': 'pending',
  'invited_at': _time,
  'expires_at': '2026-11-20T00:00:00.000Z',
  'accepted_at': null,
  'rbac_group_ids': ['rbac_group_fixture'],
};
const Map<String, String> _member = {
  'type': 'workspace_member',
  'workspace_id': _workspace,
  'user_id': _user,
  'workspace_role': 'workspace_user',
};
const Map<String, Object?> _orgRateLimit = {
  'type': 'rate_limit',
  'id': 'rl_fixture',
  'group': {'id': 'rlg_fixture', 'type': 'batch'},
  'models': null,
  'limits': [
    {'type': 'requests_per_minute', 'value': 50},
  ],
};
const Map<String, Object> _workspaceRateLimit = {
  'type': 'workspace_rate_limit',
  'rate_limit_id': 'rl_fixture',
  'workspace_id': _workspace,
  'group': {
    'id': 'rlg_fixture',
    'type': 'model_group',
    'display_name': 'Claude model group',
  },
  'models': ['claude-sonnet-5-5'],
  'limits': [
    {
      'type': 'requests_per_minute',
      'value': 50,
      'source': {'type': 'organization'},
      'org_limit': 50,
    },
  ],
};

void main() {
  late AnthropicClient client;
  late MockHttpClient transport;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        baseUrl: 'https://claude.fixture/prefix',
        authProvider: ApiKeyProvider('fixture-admin'),
        workspaceId: 'wrkspc_unrelated',
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: transport,
    );
    addTearDown(client.close);
  });

  void route(
    String method,
    String path,
    Future<Object> Function(OrganizationResource) invoke,
    Map<String, dynamic> response,
    Matcher result, {
    Map<String, List<String>> query = const {},
    Map<String, Object?>? body,
  }) {
    test('$method $path', () async {
      transport.queueJsonResponse(response);

      expect(await invoke(client.organization), result);

      final request = transport.requests.single as http.Request;
      expect(request.method, method);
      expect(request.url.path, '/prefix/v1/organizations$path');
      expect(request.url.queryParametersAll, query);
      expect(request.headers['x-api-key'], 'fixture-admin');
      expect(request.headers['anthropic-version'], '2026-10-21');
      expect(request.headers['anthropic-workspace-id'], isNull);
      expect(request.headers['anthropic-beta'], isNull);
      expect(request.followRedirects, isFalse);
      if (body == null) {
        expect(request.body, isEmpty);
      } else {
        expect(jsonDecode(request.body), body);
      }
    });
  }

  route('GET', '/me', (org) => org.retrieve(), {
    'type': 'organization',
    'id': 'org_fixture',
    'name': 'Example',
  }, isA<OrganizationInfo>().having((org) => org.name, 'name', 'Example'));

  route(
    'GET',
    '/api_keys',
    (org) => org.apiKeys.list(
      workspaceId: _workspace,
      status: 'active',
      createdByUserId: _user,
      afterId: 'prior',
      limit: 10,
    ),
    _page(_key, 'apikey_fixture'),
    isA<OrganizationPage<OrganizationApiKey>>().having(
      (page) => page.data.single.scope?.workspaceId,
      'key workspace',
      _workspace,
    ),
    query: {
      'workspace_id': [_workspace],
      'created_by_user_id': [_user],
      'status': ['active'],
      'after_id': ['prior'],
      'limit': ['10'],
    },
  );
  route(
    'GET',
    '/api_keys/apikey_fixture',
    (org) => org.apiKeys.retrieve('apikey_fixture'),
    {
      ..._key,
      'scope': {'type': 'organization'},
    },
    isA<OrganizationApiKey>().having(
      (key) => key.scope?.type,
      'scope',
      'organization',
    ),
  );
  route(
    'POST',
    '/api_keys/apikey_fixture',
    (org) => org.apiKeys.update(
      'apikey_fixture',
      name: 'Renamed',
      status: OrganizationApiKeyStatus.inactive,
    ),
    {..._key, 'name': 'Renamed', 'status': 'inactive'},
    isA<OrganizationApiKey>().having((key) => key.status, 'status', 'inactive'),
    body: {'name': 'Renamed', 'status': 'inactive'},
  );

  route(
    'GET',
    '/users',
    (org) =>
        org.users.list(email: 'user@example.com', roles: ['developer', 'user']),
    _page(_userRecord, _user),
    isA<OrganizationPage<OrganizationUser>>().having(
      (page) => page.lastId,
      'last cursor',
      _user,
    ),
    query: {
      'email': ['user@example.com'],
      'roles[]': ['developer', 'user'],
    },
  );
  route(
    'GET',
    '/users/$_user',
    (org) => org.users.retrieve(_user),
    _userRecord,
    isA<OrganizationUser>().having((user) => user.id, 'id', _user),
  );
  route(
    'POST',
    '/users/$_user',
    (org) => org.users.update(_user, role: AssignableOrganizationRole.user),
    {..._userRecord, 'role': 'user'},
    isA<OrganizationUser>().having((user) => user.role, 'role', 'user'),
    body: {'role': 'user'},
  );
  route('DELETE', '/users/$_user', (org) => org.users.remove(_user), {
    'id': _user,
    'type': 'user_deleted',
  }, isA<DeletedOrganizationUser>().having((user) => user.id, 'id', _user));

  route(
    'GET',
    '/invites',
    (org) => org.invites.list(
      beforeId: 'next',
      statuses: ['pending', 'expired'],
      roles: ['user', 'developer'],
    ),
    _page(_invite, 'invite_fixture'),
    isA<OrganizationPage<OrganizationInvite>>().having(
      (page) => page.data.single.status,
      'status',
      'pending',
    ),
    query: {
      'before_id': ['next'],
      'statuses[]': ['pending', 'expired'],
      'roles[]': ['user', 'developer'],
    },
  );
  route(
    'POST',
    '/invites',
    (org) => org.invites.create(
      email: 'user@example.com',
      role: AssignableOrganizationRole.user,
      rbacGroupIds: ['rbac_group_fixture'],
    ),
    _invite,
    isA<OrganizationInvite>().having(
      (invite) => invite.id,
      'id',
      'invite_fixture',
    ),
    body: {
      'email': 'user@example.com',
      'role': 'user',
      'rbac_group_ids': ['rbac_group_fixture'],
    },
  );
  route(
    'GET',
    '/invites/invite_fixture',
    (org) => org.invites.retrieve('invite_fixture'),
    _invite,
    isA<OrganizationInvite>().having(
      (invite) => invite.acceptedAt,
      'acceptedAt',
      isNull,
    ),
  );
  route(
    'DELETE',
    '/invites/invite_fixture',
    (org) => org.invites.delete('invite_fixture'),
    {'type': 'invite_deleted', 'id': 'invite_fixture'},
    isA<DeletedOrganizationInvite>().having(
      (invite) => invite.id,
      'id',
      'invite_fixture',
    ),
  );

  route(
    'GET',
    '/workspaces',
    (org) => org.workspaces.list(
      includeDefault: true,
      includeArchived: false,
      ids: [_workspace, 'wrkspc_other'],
    ),
    _page(_workspaceRecord, _workspace),
    isA<OrganizationPage<OrganizationWorkspace>>().having(
      (page) => page.data.single.name,
      'workspace name',
      'Default',
    ),
    query: {
      'include_default': ['true'],
      'include_archived': ['false'],
      'ids[]': [_workspace, 'wrkspc_other'],
    },
  );
  route(
    'POST',
    '/workspaces',
    (org) => org.workspaces.create(
      name: 'Fixture',
      displayColor: '#abcabc',
      workspaceGeo: 'us',
      defaultInferenceGeo: 'us',
      allowedInferenceGeos: AllowedInferenceGeos.only(const ['us']),
      userProfileId: 'uprof_fixture',
      tags: {'env': 'test'},
    ),
    {..._workspaceRecord, 'user_profile_id': 'uprof_fixture'},
    isA<OrganizationWorkspace>().having(
      (workspace) => workspace.userProfileId,
      'profile',
      'uprof_fixture',
    ),
    body: {
      'name': 'Fixture',
      'display_color': '#abcabc',
      'user_profile_id': 'uprof_fixture',
      'tags': {'env': 'test'},
      'data_residency': {
        'workspace_geo': 'us',
        'default_inference_geo': 'us',
        'allowed_inference_geos': ['us'],
      },
    },
  );
  route(
    'GET',
    '/workspaces/$_workspace',
    (org) => org.workspaces.retrieve(_workspace),
    _workspaceRecord,
    isA<OrganizationWorkspace>().having(
      (workspace) => workspace.id,
      'id',
      _workspace,
    ),
  );
  route(
    'POST',
    '/workspaces/$_workspace',
    (org) => org.workspaces.update(
      _workspace,
      tags: null,
      defaultInferenceGeo: 'us',
    ),
    {..._workspaceRecord, 'tags': <String, String>{}},
    isA<OrganizationWorkspace>().having(
      (workspace) => workspace.tags,
      'tags',
      isEmpty,
    ),
    body: {
      'tags': null,
      'data_residency': {'default_inference_geo': 'us'},
    },
  );
  route(
    'POST',
    '/workspaces/$_workspace/archive',
    (org) => org.workspaces.archive(_workspace),
    {..._workspaceRecord, 'archived_at': _time},
    isA<OrganizationWorkspace>().having(
      (workspace) => workspace.archivedAt,
      'archive time',
      DateTime.utc(2026, 11, 11),
    ),
  );

  route(
    'GET',
    '/workspaces/$_workspace/members',
    (org) =>
        org.workspaces.members.list(_workspace, afterId: 'prior', limit: 3),
    _page(_member, _user),
    isA<OrganizationPage<OrganizationWorkspaceMember>>().having(
      (page) => page.data.single.userId,
      'user id',
      _user,
    ),
    query: {
      'after_id': ['prior'],
      'limit': ['3'],
    },
  );
  route(
    'POST',
    '/workspaces/$_workspace/members',
    (org) => org.workspaces.members.create(
      _workspace,
      userId: _user,
      workspaceRole: 'workspace_user',
    ),
    _member,
    isA<OrganizationWorkspaceMember>().having(
      (member) => member.workspaceRole,
      'role',
      'workspace_user',
    ),
    body: {'user_id': _user, 'workspace_role': 'workspace_user'},
  );
  route(
    'GET',
    '/workspaces/$_workspace/members/$_user',
    (org) => org.workspaces.members.retrieve(_workspace, _user),
    _member,
    isA<OrganizationWorkspaceMember>().having(
      (member) => member.workspaceId,
      'workspace',
      _workspace,
    ),
  );
  route(
    'POST',
    '/workspaces/$_workspace/members/$_user',
    (org) => org.workspaces.members.update(
      _workspace,
      _user,
      workspaceRole: 'workspace_billing',
    ),
    {..._member, 'workspace_role': 'workspace_billing'},
    isA<OrganizationWorkspaceMember>().having(
      (member) => member.workspaceRole,
      'role',
      'workspace_billing',
    ),
    body: {'workspace_role': 'workspace_billing'},
  );
  route(
    'DELETE',
    '/workspaces/$_workspace/members/$_user',
    (org) => org.workspaces.members.delete(_workspace, _user),
    {
      'type': 'workspace_member_deleted',
      'workspace_id': _workspace,
      'user_id': _user,
    },
    isA<DeletedOrganizationWorkspaceMember>().having(
      (member) => member.userId,
      'id',
      _user,
    ),
  );

  route(
    'GET',
    '/rate_limits',
    (org) => org.rateLimits.list(
      groupType: 'batch',
      model: 'claude-sonnet-5-5',
      limit: 2,
      page: 'cursor+/',
    ),
    {
      'data': [_orgRateLimit],
      'next_page': 'next',
    },
    isA<OrganizationCursorPage<OrganizationRateLimit>>()
        .having((page) => page.data.single.groupType, 'group type', 'batch')
        .having((page) => page.nextPage, 'next page', 'next'),
    query: {
      'group_type': ['batch'],
      'model': ['claude-sonnet-5-5'],
      'limit': ['2'],
      'page': ['cursor+/'],
    },
  );
  route(
    'GET',
    '/workspaces/$_workspace/rate_limits',
    (org) => org.workspaces.rateLimits.list(
      _workspace,
      includeInherited: true,
      groupType: 'model_group',
    ),
    {
      'data': [_workspaceRateLimit],
      'next_page': null,
    },
    isA<OrganizationCursorPage<OrganizationRateLimit>>().having(
      (page) => page.data.single.limits.single.source,
      'limiter source',
      'organization',
    ),
    query: {
      'include_inherited': ['true'],
      'group_type': ['model_group'],
    },
  );
  route(
    'POST',
    '/workspaces/$_workspace/rate_limits/rl_fixture',
    (org) => org.workspaces.rateLimits.update(
      _workspace,
      'rl_fixture',
      limits: [
        WorkspaceRateLimitUpdate(type: 'requests_per_minute', value: null),
        WorkspaceRateLimitUpdate(type: 'tokens_per_minute', value: 10),
      ],
    ),
    _workspaceRateLimit,
    isA<OrganizationRateLimit>().having(
      (limit) => limit.group?.id,
      'group id',
      'rlg_fixture',
    ),
    body: {
      'limits': [
        {'type': 'requests_per_minute', 'value': null},
        {'type': 'tokens_per_minute', 'value': 10},
      ],
    },
  );

  route(
    'GET',
    '/compliance_settings',
    (org) => org.complianceSettings.retrieve(),
    {
      'type': 'compliance_settings',
      'state': {'type': 'enabled'},
    },
    isA<OrganizationComplianceSettings>().having(
      (settings) => settings.state,
      'state',
      'enabled',
    ),
  );
  route(
    'POST',
    '/compliance_settings',
    (org) =>
        org.complianceSettings.update(OrganizationComplianceState.disabled),
    {
      'type': 'compliance_settings',
      'state': {'type': 'disabled'},
    },
    isA<OrganizationComplianceSettings>().having(
      (settings) => settings.state,
      'state',
      'disabled',
    ),
    body: {
      'state': {'type': 'disabled'},
    },
  );

  test('legacy version keeps nullable workspace and group_type', () async {
    final legacyClient = AnthropicClient(
      config: const AnthropicConfig(
        apiVersion: AnthropicConfig.legacyApiVersion,
      ),
      httpClient: transport,
    );
    addTearDown(legacyClient.close);
    final legacyKey = {..._key, 'workspace_id': null}..remove('scope');
    final legacyLimit = {..._orgRateLimit, 'group_type': 'batch'}
      ..remove('group');
    transport
      ..queueJsonResponse(legacyKey)
      ..queueJsonResponse({
        'data': [legacyLimit],
        'next_page': null,
      });

    final key = await legacyClient.organization.apiKeys.retrieve(
      'apikey_fixture',
    );
    final limits = await legacyClient.organization.rateLimits.list();
    expect(key.scope, isNull);
    expect(key.legacyWorkspaceId, isNull);
    expect(key.toJson(), legacyKey);
    expect(limits.data.single.groupType, 'batch');
    expect(limits.data.single.toJson(), legacyLimit);
    expect(
      transport.requests.map((request) => request.headers['anthropic-version']),
      everyElement('2023-06-01'),
    );
  });

  test('transport preserves HTTP failure metadata', () async {
    transport.queueJsonResponse(
      {
        'type': 'error',
        'error': {'type': 'permission_error', 'message': 'scope required'},
      },
      statusCode: 403,
      headers: {'request-id': 'req_fixture'},
    );

    await expectLater(
      client.organization.retrieve(),
      throwsA(
        isA<ApiException>()
            .having((error) => error.statusCode, 'status', 403)
            .having((error) => error.requestId, 'request ID', 'req_fixture'),
      ),
    );
    expect(transport.requests.single.url.path, '/prefix/v1/organizations/me');
  });

  test('escapes path identifiers as single segments', () async {
    transport.queueJsonResponse(_userRecord);
    final result = await client.organization.users.retrieve('org/user?x#y');
    expect(result.id, _user);
    expect(transport.requests.single.url.pathSegments, [
      'prefix',
      'v1',
      'organizations',
      'users',
      'org/user?x#y',
    ]);
    expect(transport.requests.single.url.queryParameters, isEmpty);
  });

  test('invalid required fields and discriminators fail at decode', () {
    expect(
      () => OrganizationInfo.fromJson(const {
        'type': 'organization',
        'name': 'Missing id',
      }),
      throwsFormatException,
    );
    final invalidKey = {..._key}..['type'] = 'workspace';
    expect(
      () => OrganizationApiKey.fromJson(invalidKey),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _page(Map<String, dynamic> entry, String id) => {
  'data': [entry],
  'has_more': true,
  'first_id': id,
  'last_id': id,
};
