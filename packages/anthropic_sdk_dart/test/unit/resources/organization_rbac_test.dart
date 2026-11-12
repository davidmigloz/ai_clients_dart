import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

const _date = '2026-11-11T00:00:00.000Z';
const Map<String, String?> _group = {
  'type': 'rbac_group',
  'id': 'group_fixture',
  'name': 'Reviewers',
  'source_type': 'future_source',
  'role_ids': null,
  'created_at': _date,
  'updated_at': _date,
};
const Map<String, String> _member = {
  'type': 'rbac_group_member',
  'rbac_group_id': 'group_fixture',
  'user_id': 'user_fixture',
  'email': 'fixture@example.invalid',
  'created_at': _date,
};
const Map<String, String> _role = {
  'type': 'rbac_role',
  'id': 'role_fixture',
  'display_name': 'Reviewer',
  'created_at': _date,
  'updated_at': _date,
};
const Map<String, Object> _permission = {
  'type': 'rbac_role_permission',
  'action': 'use',
  'resource': {
    'type': 'connector_tool',
    'connector_id': 'connector_fixture',
    'tool_name': 'lookup',
  },
};

Map<String, dynamic> _page(Map<String, dynamic> row) => {
  'data': [row],
  'has_more': true,
  'next_page': 'next/=+',
};

Map<String, dynamic> _body(http.BaseRequest request) =>
    jsonDecode((request as http.Request).body) as Map<String, dynamic>;

void main() {
  late MockHttpClient transport;
  late AnthropicClient client;

  setUp(() {
    transport = MockHttpClient();
    client = AnthropicClient(
      httpClient: transport,
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin-key'),
        baseUrl: 'https://example.invalid/proxy',
        workspaceId: 'workspace-unrelated',
        retryPolicy: RetryPolicy(maxRetries: 0),
        defaultHeaders: {'Anthropic-Beta': 'configured-beta'},
      ),
    );
    addTearDown(client.close);
  });

  void checkRequest(
    String method,
    String path, {
    Map<String, List<String>> query = const {},
    Map<String, dynamic>? body,
    String beta = 'configured-beta',
  }) {
    final request = transport.requests.last as http.Request;
    expect(request.method, method);
    expect(request.url.path, '/proxy/v1/organizations$path');
    expect(request.url.queryParametersAll, query);
    expect(request.headers['anthropic-beta'], beta);
    expect(request.headers['anthropic-version'], '2026-10-21');
    expect(request.headers['anthropic-workspace-id'], isNull);
    expect(request.headers['x-api-key'], 'fixture-admin-key');
    expect(request.followRedirects, isFalse);
    if (body == null) {
      expect(request.body, isEmpty);
    } else {
      expect(_body(request), body);
    }
  }

  test(
    'list groups follows opaque cursors and preserves nullable role IDs',
    () async {
      final groups = client.organization.rbacGroups;
      transport
        ..queueJsonResponse(_page(_group))
        ..queueJsonResponse({
          'data': <Object>[],
          'has_more': false,
          'next_page': null,
        });
      final first = await groups.list(limit: 10);
      checkRequest(
        'GET',
        '/rbac_groups',
        query: {
          'limit': ['10'],
        },
      );
      expect(first.hasMore, isTrue);
      expect(first.data.single.sourceType, 'future_source');
      expect(first.data.single.roleIds, isNull);
      expect(first.toJson((group) => group.toJson()), _page(_group));
      expect(first.data.single, OrganizationRbacGroup.fromJson(_group));
      expect(
        first.data.single.hashCode,
        OrganizationRbacGroup.fromJson(_group).hashCode,
      );
      final next = await groups.list(limit: 10, page: first.nextPage);
      expect(next.hasMore, isFalse);
      checkRequest(
        'GET',
        '/rbac_groups',
        query: {
          'limit': ['10'],
          'page': ['next/=+'],
        },
      );
    },
  );

  test(
    'create, retrieve, update, and delete groups use their exact routes',
    () async {
      final groups = client.organization.rbacGroups;
      transport
        ..queueJsonResponse(_group)
        ..queueJsonResponse(_group)
        ..queueJsonResponse(_group)
        ..queueJsonResponse(_group)
        ..queueJsonResponse({
          'type': 'rbac_group_deleted',
          'id': 'group_fixture',
        });
      await groups.create(name: 'Reviewers');
      checkRequest('POST', '/rbac_groups', body: {'name': 'Reviewers'});
      await groups.retrieve('group_fixture');
      checkRequest('GET', '/rbac_groups/group_fixture');
      await groups.update('group_fixture', name: null);
      checkRequest('POST', '/rbac_groups/group_fixture', body: {'name': null});
      await groups.update('group_fixture');
      checkRequest('POST', '/rbac_groups/group_fixture', body: {});
      final removed = await groups.delete('group_fixture');
      expect(removed.id, 'group_fixture');
      checkRequest('DELETE', '/rbac_groups/group_fixture');
    },
  );

  test('legacy aliases decode and current fields take precedence', () async {
    final legacy = AnthropicClient(
      httpClient: transport,
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('fixture-admin-key'),
        apiVersion: AnthropicConfig.legacyApiVersion,
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
    );
    addTearDown(legacy.close);
    transport
      ..queueJsonResponse(
        {
          ..._group,
          'roles': ['role_legacy'],
        }..remove('role_ids'),
      )
      ..queueJsonResponse({
        ..._group,
        'roles': ['role_ignored'],
      })
      ..queueJsonResponse(
        {..._member, 'group_id': 'group_fixture'}..remove('rbac_group_id'),
      )
      ..queueJsonResponse({
        'type': 'rbac_group_member_deleted',
        'group_id': 'group_fixture',
        'user_id': 'user_fixture',
      })
      ..queueJsonResponse(
        {..._role, 'name': 'Legacy Reviewer'}..remove('display_name'),
      );
    final groups = legacy.organization.rbacGroups;
    final group = await groups.retrieve('group_fixture');
    expect(group.roleIds, ['role_legacy']);
    expect(group.toJson()['role_ids'], ['role_legacy']);
    expect(group.toJson().containsKey('roles'), isFalse);
    expect(transport.requests.last.headers['anthropic-version'], '2023-06-01');
    expect((await groups.retrieve('group_fixture')).roleIds, isNull);
    expect(
      (await groups.addMember('group_fixture', 'user_fixture')).toJson(),
      _member,
    );
    final deleted = await groups.removeMember('group_fixture', 'user_fixture');
    expect(deleted.toJson()['rbac_group_id'], 'group_fixture');
    final role = await legacy.organization.rbacRoles.retrieve('role_fixture');
    expect(role.displayName, 'Legacy Reviewer');
    expect(role.toJson().containsKey('name'), isFalse);
  });

  test('list, add, and remove RBAC group members', () async {
    final groups = client.organization.rbacGroups;
    transport
      ..queueJsonResponse(_page(_member))
      ..queueJsonResponse(_member)
      ..queueJsonResponse({
        'type': 'rbac_group_member_deleted',
        'rbac_group_id': 'group_fixture',
        'user_id': 'user_fixture',
      });
    final members = await groups.listMembers('group_fixture', page: 'a/+');
    expect(members.data.single.toJson(), _member);
    checkRequest(
      'GET',
      '/rbac_groups/group_fixture/members',
      query: {
        'page': ['a/+'],
      },
    );
    await groups.addMember('group_fixture', 'user_fixture');
    checkRequest(
      'POST',
      '/rbac_groups/group_fixture/members',
      body: {'user_id': 'user_fixture'},
    );
    final removed = await groups.removeMember('group_fixture', 'user_fixture');
    expect(removed.userId, 'user_fixture');
    checkRequest('DELETE', '/rbac_groups/group_fixture/members/user_fixture');
  });

  test(
    'read custom roles and their known and future permission targets',
    () async {
      const futurePermission = {
        'type': 'rbac_role_permission',
        'action': 'future_action',
        'resource': {
          'type': 'future_target',
          'ids': ['fixture'],
        },
      };
      transport
        ..queueJsonResponse(_page(_role))
        ..queueJsonResponse(_role)
        ..queueJsonResponse({
          'data': [_permission, futurePermission],
          'has_more': false,
          'next_page': null,
        });
      final roles = client.organization.rbacRoles;
      expect((await roles.list(limit: 4)).data.single.displayName, 'Reviewer');
      checkRequest(
        'GET',
        '/rbac_roles',
        query: {
          'limit': ['4'],
        },
      );
      await roles.retrieve('role_fixture');
      checkRequest('GET', '/rbac_roles/role_fixture');
      final permissions = await roles.listPermissions('role_fixture', limit: 5);
      checkRequest(
        'GET',
        '/rbac_roles/role_fixture/permissions',
        query: {
          'limit': ['5'],
        },
      );
      expect(permissions.data.first.resource.toolName, 'lookup');
      expect(permissions.data.last.resource.type, 'future_target');
      expect(permissions.data.last.toJson(), futurePermission);
      expect(
        permissions.data.last,
        OrganizationRbacRolePermission.fromJson(futurePermission),
      );
    },
  );

  test(
    'RBAC pages reject missing metadata and unusable continuation tokens',
    () async {
      transport
        ..queueJsonResponse({'data': <Object>[], 'next_page': null})
        ..queueJsonResponse({
          'data': <Object>[],
          'next_page': null,
          'has_more': true,
        });
      final roles = client.organization.rbacRoles;
      await expectLater(roles.list(), throwsFormatException);
      await expectLater(roles.list(), throwsFormatException);
      expect(
        () => OrganizationRbacPermissionResource.fromJson(const {
          'type': 'connector_tool',
        }),
        throwsFormatException,
      );
    },
  );

  test(
    'sign-out appends its required beta and returns the current membership',
    () async {
      const user = {
        'type': 'user',
        'id': 'user_fixture',
        'name': 'Fixture User',
        'email': 'fixture@example.invalid',
        'role': 'user',
        'added_at': _date,
      };
      transport
        ..queueJsonResponse(user)
        ..queueJsonResponse(user);
      final users = client.organization.users;
      final signedOut = await users.signOut('user_fixture');
      expect(signedOut.id, 'user_fixture');
      checkRequest(
        'POST',
        '/users/user_fixture/sign_out',
        beta: 'configured-beta,admin-user-sign-out-2026-10-08',
      );
      await users.signOut(
        'user_fixture',
        betas: const ['caller-beta', 'admin-user-sign-out-2026-10-08'],
      );
      checkRequest(
        'POST',
        '/users/user_fixture/sign_out',
        beta: 'caller-beta,admin-user-sign-out-2026-10-08',
      );
    },
  );

  test('sign-out preserves the documented structured beta error', () async {
    transport.queueJsonResponse({
      'type': 'error',
      'request_id': 'req_signout',
      'error': {
        'type': 'invalid_request_error',
        'message': 'Beta not enabled',
        'details': {'error_code': 'organization_not_enrolled_in_beta'},
      },
    }, statusCode: 400);
    await expectLater(
      client.organization.users.signOut('user_fixture'),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 400)
            .having((e) => e.requestId, 'request ID', 'req_signout')
            .having(
              (e) => e.errorCode,
              'code',
              'organization_not_enrolled_in_beta',
            ),
      ),
    );
  });
}
