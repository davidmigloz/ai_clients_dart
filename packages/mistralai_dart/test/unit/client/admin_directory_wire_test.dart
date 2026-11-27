import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:logging/logging.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

const _adminKey = 'admin-fixture-key';

MistralAdminClient _client(
  http.Client transport, {
  Level logLevel = Level.OFF,
}) {
  final client = MistralAdminClient.withApiKey(
    _adminKey,
    httpClient: transport,
    logLevel: logLevel,
  );
  addTearDown(client.close);
  return client;
}

void main() {
  group('Mistral Admin directory', () {
    test('GET /v1/admin/roles', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/roles',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"organization_roles":[{"description":"fixture","is_custom_role":true,"name":"fixture","uuid":"fixture"}],"workspace_roles":[{"description":"fixture","is_custom_role":true,"name":"fixture","uuid":"fixture"}]}''',
            200,
          );
        }),
      );
      final result = await client.roles.list();
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"organization_roles":[{"description":"fixture","is_custom_role":true,"name":"fixture","uuid":"fixture"}],"workspace_roles":[{"description":"fixture","is_custom_role":true,"name":"fixture","uuid":"fixture"}]}''',
        ),
      );
    });

    test('POST /v1/admin/scim/sync', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/scim/sync',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(
              r'''{"dry_run":true,"sync_config":{"sync_users":true,"sync_groups":true,"sync_memberships":true}}''',
            ),
          );
          return http.Response(r'''{"run_id":"fixture"}''', 202);
        }),
      );
      final result = await client.scim.startSync(
        request: StartAdminScimSyncRequest.fromJson(
          jsonDecode(
                r'''{"dry_run":true,"sync_config":{"sync_users":true,"sync_groups":true,"sync_memberships":true}}''',
              )
              as Map<String, dynamic>,
        ),
      );
      expect(result.toJson(), jsonDecode(r'''{"run_id":"fixture"}'''));
    });

    test('an active SCIM sync exposes the existing run on HTTP 409', () async {
      final client = _client(
        MockClient(
          (_) async =>
              http.Response('{"run_id":"run-42","status":"RUNNING"}', 409),
        ),
      );
      await expectLater(
        client.scim.startSync(request: const StartAdminScimSyncRequest()),
        throwsA(
          isA<AdminScimSyncConflictException>()
              .having((error) => error.statusCode, 'HTTP status', 409)
              .having((error) => error.activeRun.runId, 'run ID', 'run-42')
              .having(
                (error) => error.activeRun.status,
                'status',
                AdminScimRunStatus.running,
              )
              .having(
                (error) => error.requestMetadata?.method,
                'method',
                'POST',
              ),
        ),
      );
    });

    test('GET /v1/admin/scim/sync/{run_id}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/scim/sync/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"created_at":"2026-11-27T13:00:00.123Z","dry_run":true,"error_message":null,"finished_at":null,"run_id":"fixture","started_at":"2026-11-27T13:00:00Z","status":"PENDING","summary":null,"sync_config":null}''',
            200,
          );
        }),
      );
      final result = await client.scim.getRun(runId: 'fixture / id');
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"created_at":"2026-11-27T13:00:00.123Z","dry_run":true,"error_message":null,"finished_at":null,"run_id":"fixture","started_at":"2026-11-27T13:00:00Z","status":"PENDING","summary":null,"sync_config":null}''',
        ),
      );
    });

    test('GET /v1/admin/user-groups', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'page': ['2'],
            'page_size': ['2'],
            'search': ['fixture'],
            'workspace_uuid': ['fixture'],
            'role': ['user'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"items":[{"description":null,"name":"fixture","uuid":"fixture"}],"page":2,"page_size":2,"total":2}''',
            200,
          );
        }),
      );
      final result = await client.groups.list(
        page: 2,
        pageSize: 2,
        search: 'fixture',
        workspaceUuid: 'fixture',
        role: 'user',
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"items":[{"description":null,"name":"fixture","uuid":"fixture"}],"page":2,"page_size":2,"total":2}''',
        ),
      );
    });

    test('POST /v1/admin/user-groups', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"name":"fixture"}'''),
          );
          return http.Response(
            r'''{"description":null,"name":"fixture","uuid":"fixture"}''',
            200,
          );
        }),
      );
      final result = await client.groups.create(
        request: CreateAdminUserGroupRequest.fromJson(
          jsonDecode(r'''{"name":"fixture"}''') as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"description":null,"name":"fixture","uuid":"fixture"}''',
        ),
      );
    });

    test('DELETE /v1/admin/user-groups/{group_uuid}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response('', 204);
        }),
      );
      await client.groups.delete(groupUuid: 'fixture / id');
    });

    test('GET /v1/admin/user-groups/{group_uuid}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"description":null,"name":"fixture","uuid":"fixture"}''',
            200,
          );
        }),
      );
      final result = await client.groups.get(groupUuid: 'fixture / id');
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"description":null,"name":"fixture","uuid":"fixture"}''',
        ),
      );
    });

    test('PATCH /v1/admin/user-groups/{group_uuid}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"description":"Team group"}'''),
          );
          return http.Response(
            r'''{"description":null,"name":"fixture","uuid":"fixture"}''',
            200,
          );
        }),
      );
      final result = await client.groups.update(
        groupUuid: 'fixture / id',
        request: UpdateAdminUserGroupRequest.fromJson(
          jsonDecode(r'''{"description":"Team group"}''')
              as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"description":null,"name":"fixture","uuid":"fixture"}''',
        ),
      );
    });

    test('DELETE /v1/admin/user-groups/{group_uuid}/members', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id/members',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"user_uuids":["fixture"]}'''),
          );
          return http.Response('', 204);
        }),
      );
      await client.groups.removeUsers(
        groupUuid: 'fixture / id',
        request: AdminGroupUsersRequest.fromJson(
          jsonDecode(r'''{"user_uuids":["fixture"]}''') as Map<String, dynamic>,
        ),
      );
    });

    test('GET /v1/admin/user-groups/{group_uuid}/members', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id/members',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'page': ['2'],
            'page_size': ['2'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"members":[{"email":null,"name":null,"user_uuid":"fixture"}],"page":2,"page_size":2,"total":2}''',
            200,
          );
        }),
      );
      final result = await client.groups.listUsers(
        groupUuid: 'fixture / id',
        page: 2,
        pageSize: 2,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"members":[{"email":null,"name":null,"user_uuid":"fixture"}],"page":2,"page_size":2,"total":2}''',
        ),
      );
    });

    test('POST /v1/admin/user-groups/{group_uuid}/members', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id/members',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"user_uuids":["fixture"]}'''),
          );
          return http.Response('', 204);
        }),
      );
      await client.groups.addUsers(
        groupUuid: 'fixture / id',
        request: AdminGroupUsersRequest.fromJson(
          jsonDecode(r'''{"user_uuids":["fixture"]}''') as Map<String, dynamic>,
        ),
      );
    });

    test('PATCH /v1/admin/user-groups/{group_uuid}/organization-role', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id/organization-role',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"organization_role":"member"}'''),
          );
          return http.Response('', 204);
        }),
      );
      await client.groups.setOrganizationRole(
        groupUuid: 'fixture / id',
        request: SetAdminGroupOrganizationRoleRequest.fromJson(
          jsonDecode(r'''{"organization_role":"member"}''')
              as Map<String, dynamic>,
        ),
      );
    });

    test('GET /v1/admin/user-groups/{group_uuid}/workspaces', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id/workspaces',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'page': ['2'],
            'page_size': ['2'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"items":[{"created":"2026-11-27T13:00:00.123Z","roles":[{"name":"fixture","uuid":"fixture"}],"workspace_name":"fixture","workspace_uuid":"fixture"}],"page":2,"page_size":2,"total":2}''',
            200,
          );
        }),
      );
      final result = await client.groups.listWorkspaceAssignments(
        groupUuid: 'fixture / id',
        page: 2,
        pageSize: 2,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"items":[{"created":"2026-11-27T13:00:00.123Z","roles":[{"name":"fixture","uuid":"fixture"}],"workspace_name":"fixture","workspace_uuid":"fixture"}],"page":2,"page_size":2,"total":2}''',
        ),
      );
    });

    test('POST /v1/admin/user-groups/{group_uuid}/workspaces', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id/workspaces',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"workspace_uuid":"fixture"}'''),
          );
          return http.Response('', 201);
        }),
      );
      await client.groups.assignWorkspace(
        groupUuid: 'fixture / id',
        request: AssignAdminGroupWorkspaceRequest.fromJson(
          jsonDecode(r'''{"workspace_uuid":"fixture"}''')
              as Map<String, dynamic>,
        ),
      );
    });

    test(
      'DELETE /v1/admin/user-groups/{group_uuid}/workspaces/{workspace_uuid}',
      () async {
        final client = _client(
          MockClient((request) async {
            expect(request.method, 'DELETE');
            expect(
              request.url.toString().split('?').first,
              'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id/workspaces/fixture%20%2F%20id',
            );
            expect(request.headers['x-api-key'], _adminKey);
            expect(request.headers['authorization'], isNull);
            expect(request.followRedirects, isFalse);
            expect(request.url.queryParametersAll, isEmpty);
            expect(request.body, isEmpty);
            return http.Response('', 204);
          }),
        );
        await client.groups.removeWorkspace(
          groupUuid: 'fixture / id',
          workspaceUuid: 'fixture / id',
        );
      },
    );

    test(
      'PATCH /v1/admin/user-groups/{group_uuid}/workspaces/{workspace_uuid}',
      () async {
        final client = _client(
          MockClient((request) async {
            expect(request.method, 'PATCH');
            expect(
              request.url.toString().split('?').first,
              'https://api.mistral.ai/v1/admin/user-groups/fixture%20%2F%20id/workspaces/fixture%20%2F%20id',
            );
            expect(request.headers['x-api-key'], _adminKey);
            expect(request.headers['authorization'], isNull);
            expect(request.followRedirects, isFalse);
            expect(request.url.queryParametersAll, isEmpty);
            expect(
              jsonDecode(request.body),
              jsonDecode(r'''{"add_role_names":["Member"]}'''),
            );
            return http.Response('', 204);
          }),
        );
        await client.groups.updateWorkspaceAssignment(
          groupUuid: 'fixture / id',
          workspaceUuid: 'fixture / id',
          request: UpdateAdminGroupWorkspaceRequest.fromJson(
            jsonDecode(r'''{"add_role_names":["Member"]}''')
                as Map<String, dynamic>,
          ),
        );
      },
    );

    test('GET /v1/admin/users', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'page': ['2'],
            'page_size': ['2'],
            'email': ['user@example.test'],
            'include_inactive': ['true'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"invites":[{"created_at":"2026-11-27T13:00:00.123Z","email":"user@example.test","expired":true,"raw_role":"0d48f530-095c-43fe-8aea-6673bcacabe6","raw_roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"],"uuid":"fixture"}],"members":[{"created_at":"2026-11-27T13:00:00.123Z","email":null,"name":null,"oid_id":null,"raw_role":"0d48f530-095c-43fe-8aea-6673bcacabe6","raw_roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"],"uuid":"fixture"}],"page":null,"page_size":null,"total":null}''',
            200,
          );
        }),
      );
      final result = await client.users.list(
        page: 2,
        pageSize: 2,
        email: 'user@example.test',
        includeInactive: true,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"invites":[{"created_at":"2026-11-27T13:00:00.123Z","email":"user@example.test","expired":true,"raw_role":"0d48f530-095c-43fe-8aea-6673bcacabe6","raw_roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"],"uuid":"fixture"}],"members":[{"created_at":"2026-11-27T13:00:00.123Z","email":null,"name":null,"oid_id":null,"raw_role":"0d48f530-095c-43fe-8aea-6673bcacabe6","raw_roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"],"uuid":"fixture"}],"page":null,"page_size":null,"total":null}''',
        ),
      );
    });

    test('POST /v1/admin/users', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(
              r'''[{"email":"user@example.test","first_name":"fixture","last_name":"fixture"}]''',
            ),
          );
          return http.Response(
            r'''{"email_to_user_id":{},"invalid_emails":["fixture"]}''',
            200,
          );
        }),
      );
      final result = await client.users.create(
        request: [
          for (final item
              in jsonDecode(
                    r'''[{"email":"user@example.test","first_name":"fixture","last_name":"fixture"}]''',
                  )
                  as List)
            CreateAdminUserRequest.fromJson(item as Map<String, dynamic>),
        ],
      );
      expect(
        result.toJson(),
        jsonDecode(r'''{"email_to_user_id":{},"invalid_emails":["fixture"]}'''),
      );
    });

    test('GET /v1/admin/users-invite', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users-invite',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(
            r'''[{"email":null,"invite_uuid":"fixture","role":"0d48f530-095c-43fe-8aea-6673bcacabe6","roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"]}]''',
            200,
          );
        }),
      );
      final result = await client.users.listInvites();
      expect(
        result.map((item) => item.toJson()).toList(),
        jsonDecode(
          r'''[{"email":null,"invite_uuid":"fixture","role":"0d48f530-095c-43fe-8aea-6673bcacabe6","roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"]}]''',
        ),
      );
    });

    test('POST /v1/admin/users-invite', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users-invite',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"email":"user@example.test"}'''),
          );
          return http.Response(
            r'''{"already_members":["fixture"],"invalid_emails":["fixture"]}''',
            200,
          );
        }),
      );
      final result = await client.users.invite(
        request: InviteAdminUserRequest.fromJson(
          jsonDecode(r'''{"email":"user@example.test"}''')
              as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"already_members":["fixture"],"invalid_emails":["fixture"]}''',
        ),
      );
    });

    test('DELETE /v1/admin/users-invite/{invite_uuid}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users-invite/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(r'''{"message":"fixture"}''', 200);
        }),
      );
      final result = await client.users.deleteInvite(
        inviteUuid: 'fixture / id',
      );
      expect(result.toJson(), jsonDecode(r'''{"message":"fixture"}'''));
    });

    test('DELETE /v1/admin/users/{user_id}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(r'''{"message":"fixture"}''', 200);
        }),
      );
      final result = await client.users.delete(userId: 'fixture / id');
      expect(result.toJson(), jsonDecode(r'''{"message":"fixture"}'''));
    });

    test('GET /v1/admin/users/{user_id}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"created_at":"2026-11-27T13:00:00.123Z","email":null,"first_name":null,"last_name":null,"name":null,"oid_id":null,"raw_role":"0d48f530-095c-43fe-8aea-6673bcacabe6","raw_roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"],"status":"blocked","uuid":"fixture"}''',
            200,
          );
        }),
      );
      final result = await client.users.get(userId: 'fixture / id');
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"created_at":"2026-11-27T13:00:00.123Z","email":null,"first_name":null,"last_name":null,"name":null,"oid_id":null,"raw_role":"0d48f530-095c-43fe-8aea-6673bcacabe6","raw_roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"],"status":"blocked","uuid":"fixture"}''',
        ),
      );
      expect(result.status, AdminMemberStatus.blocked);
      expect(result.copyWith(status: null).toJson(), isNot(contains('status')));
    });

    test('PATCH /v1/admin/users/{user_id}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"role_name":"Member"}'''),
          );
          return http.Response(
            r'''{"created_at":"2026-11-27T13:00:00.123Z","email":null,"name":null,"oid_id":null,"raw_role":"0d48f530-095c-43fe-8aea-6673bcacabe6","raw_roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"],"status":"deactivated","uuid":"fixture"}''',
            200,
          );
        }),
      );
      final result = await client.users.update(
        userId: 'fixture / id',
        request: UpdateAdminUserRequest.fromJson(
          jsonDecode(r'''{"role_name":"Member"}''') as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"created_at":"2026-11-27T13:00:00.123Z","email":null,"name":null,"oid_id":null,"raw_role":"0d48f530-095c-43fe-8aea-6673bcacabe6","raw_roles":["0d48f530-095c-43fe-8aea-6673bcacabe6"],"status":"deactivated","uuid":"fixture"}''',
        ),
      );
      expect(result.status, AdminMemberStatus.deactivated);
    });

    test('POST /v1/admin/users/{user_id}/deactivate', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users/fixture%20%2F%20id/deactivate',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(r'''{"message":"fixture"}''', 200);
        }),
      );
      final result = await client.users.deactivate(userId: 'fixture / id');
      expect(result.toJson(), jsonDecode(r'''{"message":"fixture"}'''));
    });

    test('POST /v1/admin/users/{user_id}/reactivate', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users/fixture%20%2F%20id/reactivate',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response(r'''{"message":"fixture"}''', 200);
        }),
      );
      final result = await client.users.reactivate(userId: 'fixture / id');
      expect(result.toJson(), jsonDecode(r'''{"message":"fixture"}'''));
    });

    test('GET /v1/admin/users/{user_id}/workspaces', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/users/fixture%20%2F%20id/workspaces',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'page': ['2'],
            'page_size': ['2'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"items":[{"is_default":true,"name":"fixture","raw_role":"48436751-ee56-44bd-8a2d-712233977821","raw_roles":["48436751-ee56-44bd-8a2d-712233977821"],"uuid":"fixture"}],"page":2,"page_size":2,"total":2}''',
            200,
          );
        }),
      );
      final result = await client.users.listWorkspaces(
        userId: 'fixture / id',
        page: 2,
        pageSize: 2,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"items":[{"is_default":true,"name":"fixture","raw_role":"48436751-ee56-44bd-8a2d-712233977821","raw_roles":["48436751-ee56-44bd-8a2d-712233977821"],"uuid":"fixture"}],"page":2,"page_size":2,"total":2}''',
        ),
      );
    });

    test('GET /v1/admin/workspaces', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/workspaces',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'is_archived': ['true'],
            'page': ['2'],
            'page_size': ['2'],
            'search': ['fixture'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"items":[{"description":null,"icon":null,"is_default":true,"name":"fixture","uuid":"fixture"}],"object":"list","page":2,"page_size":2,"total":2}''',
            200,
          );
        }),
      );
      final result = await client.workspaces.list(
        isArchived: true,
        page: 2,
        pageSize: 2,
        search: 'fixture',
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"items":[{"description":null,"icon":null,"is_default":true,"name":"fixture","uuid":"fixture"}],"object":"list","page":2,"page_size":2,"total":2}''',
        ),
      );
      expect(result.object, AdminApiObjectType.list);
    });

    test('POST /v1/admin/workspaces', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/workspaces',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"admin_user_id":"fixture","name":"fixture"}'''),
          );
          return http.Response(
            r'''{"description":null,"icon":null,"is_default":true,"name":"fixture","raw_role":"48436751-ee56-44bd-8a2d-712233977821","raw_roles":["48436751-ee56-44bd-8a2d-712233977821"],"uuid":"fixture"}''',
            200,
          );
        }),
      );
      final result = await client.workspaces.create(
        request: CreateAdminWorkspaceRequest.fromJson(
          jsonDecode(r'''{"admin_user_id":"fixture","name":"fixture"}''')
              as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"description":null,"icon":null,"is_default":true,"name":"fixture","raw_role":"48436751-ee56-44bd-8a2d-712233977821","raw_roles":["48436751-ee56-44bd-8a2d-712233977821"],"uuid":"fixture"}''',
        ),
      );
    });

    test('DELETE /v1/admin/workspaces/{workspace_uuid}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/workspaces/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(request.body, isEmpty);
          return http.Response('', 204);
        }),
      );
      await client.workspaces.delete(workspaceUuid: 'fixture / id');
    });

    test('PATCH /v1/admin/workspaces/{workspace_uuid}', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/workspaces/fixture%20%2F%20id',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"name":"Updated Workspace"}'''),
          );
          return http.Response(
            r'''{"description":null,"icon":null,"is_default":true,"name":"fixture","uuid":"fixture"}''',
            200,
          );
        }),
      );
      final result = await client.workspaces.update(
        workspaceUuid: 'fixture / id',
        request: UpdateAdminWorkspaceRequest.fromJson(
          jsonDecode(r'''{"name":"Updated Workspace"}''')
              as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"description":null,"icon":null,"is_default":true,"name":"fixture","uuid":"fixture"}''',
        ),
      );
    });

    test('POST /v1/admin/workspaces/{workspace_uuid}/add-users', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'POST');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/workspaces/fixture%20%2F%20id/add-users',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(
              r'''{"members":[{"user_uuid":"fixture","role_name":"Member"}]}''',
            ),
          );
          return http.Response(r'''{"added_members_count":2}''', 200);
        }),
      );
      final result = await client.workspaces.addUsers(
        workspaceUuid: 'fixture / id',
        request: AddAdminWorkspaceUsersRequest.fromJson(
          jsonDecode(
                r'''{"members":[{"user_uuid":"fixture","role_name":"Member"}]}''',
              )
              as Map<String, dynamic>,
        ),
      );
      expect(result.toJson(), jsonDecode(r'''{"added_members_count":2}'''));
    });

    test('DELETE /v1/admin/workspaces/{workspace_uuid}/remove-users', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'DELETE');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/workspaces/fixture%20%2F%20id/remove-users',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(r'''{"members":[{"user_uuid":"fixture"}]}'''),
          );
          return http.Response(r'''{"deleted_members_count":2}''', 200);
        }),
      );
      final result = await client.workspaces.removeUsers(
        workspaceUuid: 'fixture / id',
        request: RemoveAdminWorkspaceUsersRequest.fromJson(
          jsonDecode(r'''{"members":[{"user_uuid":"fixture"}]}''')
              as Map<String, dynamic>,
        ),
      );
      expect(result.toJson(), jsonDecode(r'''{"deleted_members_count":2}'''));
    });

    test('GET /v1/admin/workspaces/{workspace_uuid}/users', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'GET');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/workspaces/fixture%20%2F%20id/users',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, {
            'page': ['2'],
            'page_size': ['2'],
            'include_inactive': ['true'],
          });
          expect(request.body, isEmpty);
          return http.Response(
            r'''{"items":[{"direct_member":true,"email":null,"externally_managed":true,"group_grants":[{"group_id":"fixture","group_name":"fixture","roles":["user"]}],"name":null,"roles":["user"],"status":"active","user_id":"fixture"}],"page":2,"page_size":2,"total":2}''',
            200,
          );
        }),
      );
      final result = await client.workspaces.listUsers(
        workspaceUuid: 'fixture / id',
        page: 2,
        pageSize: 2,
        includeInactive: true,
      );
      expect(
        result.toJson(),
        jsonDecode(
          r'''{"items":[{"direct_member":true,"email":null,"externally_managed":true,"group_grants":[{"group_id":"fixture","group_name":"fixture","roles":["user"]}],"name":null,"roles":["user"],"status":"active","user_id":"fixture"}],"page":2,"page_size":2,"total":2}''',
        ),
      );
    });

    test('PATCH /v1/admin/workspaces/{workspace_uuid}/users', () async {
      final client = _client(
        MockClient((request) async {
          expect(request.method, 'PATCH');
          expect(
            request.url.toString().split('?').first,
            'https://api.mistral.ai/v1/admin/workspaces/fixture%20%2F%20id/users',
          );
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          expect(request.followRedirects, isFalse);
          expect(request.url.queryParametersAll, isEmpty);
          expect(
            jsonDecode(request.body),
            jsonDecode(
              r'''{"members":[{"user_uuid":"fixture","role_name":"Member"}]}''',
            ),
          );
          return http.Response(
            r'''{"added_members_count":2,"updated_members_count":2}''',
            200,
          );
        }),
      );
      final result = await client.workspaces.upsertUsers(
        workspaceUuid: 'fixture / id',
        request: UpsertAdminWorkspaceUsersRequest.fromJson(
          jsonDecode(
                r'''{"members":[{"user_uuid":"fixture","role_name":"Member"}]}''',
              )
              as Map<String, dynamic>,
        ),
      );
      expect(
        result.toJson(),
        jsonDecode(r'''{"added_members_count":2,"updated_members_count":2}'''),
      );
    });
  });

  test('redacts credentials from Admin errors and keeps status', () async {
    final client = _client(
      MockClient((request) async {
        expect(request.headers['x-api-key'], _adminKey);
        return http.Response(
          '{"message":"Invalid $_adminKey","detail":{"client_secret":"another-secret"}}',
          401,
          headers: {'x-api-key': _adminKey},
        );
      }),
    );
    await expectLater(
      client.roles.list(),
      throwsA(
        isA<AuthenticationException>()
            .having(
              (error) => error.toString(),
              'error message',
              isNot(contains(_adminKey)),
            )
            .having(
              (error) => error.responseMetadata?.bodyExcerpt,
              'response excerpt',
              allOf(
                isNot(contains(_adminKey)),
                isNot(contains('another-secret')),
              ),
            )
            .having(
              (error) => error.responseMetadata?.headers['x-api-key'],
              'response header',
              '[REDACTED]',
            ),
      ),
    );
  });

  test('redacts reflected Admin keys from error metadata and logs', () async {
    final previousLevel = Logger.root.level;
    Logger.root.level = Level.ALL;
    final logs = <LogRecord>[];
    final subscription = Logger.root.onRecord.listen(logs.add);
    addTearDown(() async {
      await subscription.cancel();
      Logger.root.level = previousLevel;
    });
    final reflected = _client(
      MockClient(
        (_) async => http.Response(
          jsonEncode({_adminKey: 'invalid'}),
          409,
          headers: {_adminKey: 'invalid'},
        ),
      ),
      logLevel: Level.ALL,
    );
    await expectLater(
      reflected.roles.list(),
      throwsA(
        isA<ApiException>()
            .having(
              (error) => error.message,
              'message',
              isNot(contains(_adminKey)),
            )
            .having(
              (error) => error.responseMetadata?.bodyExcerpt,
              'body',
              isNot(contains(_adminKey)),
            )
            .having(
              (error) => error.responseMetadata?.headers.keys,
              'header names',
              isNot(contains(_adminKey)),
            ),
      ),
    );
    final throwing = _client(
      MockClient((request) {
        throw http.ClientException('Header: ${request.headers['x-api-key']}');
      }),
      logLevel: Level.ALL,
    );
    await expectLater(
      throwing.roles.list(),
      throwsA(
        isA<http.ClientException>().having(
          (error) => error.toString(),
          'message',
          isNot(contains(_adminKey)),
        ),
      ),
    );
    expect(logs.where((record) => record.level == Level.WARNING), hasLength(2));
    expect(
      logs.map((record) => record.message).join('\n'),
      isNot(contains(_adminKey)),
    );
  });

  test(
    'Admin and inference use separate credentials on a shared transport',
    () async {
      final transport = MockClient((request) async {
        if (request.url.path.startsWith('/v1/admin/')) {
          expect(request.headers['x-api-key'], _adminKey);
          expect(request.headers['authorization'], isNull);
          return http.Response(
            '{"organization_roles":[],"workspace_roles":[]}',
            200,
          );
        }
        expect(request.url.path, '/v1/models');
        expect(request.headers['x-api-key'], isNull);
        expect(
          request.headers['authorization'],
          'Bearer inference-fixture-key',
        );
        return http.Response('{"data":[],"object":"list"}', 200);
      });
      addTearDown(transport.close);
      final admin = MistralAdminClient.withApiKey(
        _adminKey,
        httpClient: transport,
      );
      final client = MistralClient(
        httpClient: transport,
        config: const MistralConfig(
          authProvider: ApiKeyProvider('inference-fixture-key'),
        ),
      );
      addTearDown(client.close);

      await admin.roles.list();
      admin.close();
      await expectLater(admin.roles.list(), throwsStateError);
      expect((await client.models.list()).data, isEmpty);
    },
  );

  test('Admin never follows HTTP redirects', () async {
    final client = _client(
      MockClient((request) async {
        expect(request.followRedirects, isFalse);
        return http.Response(
          '',
          302,
          headers: {'location': 'https://example.test/'},
        );
      }),
    );
    await expectLater(
      client.roles.list(),
      throwsA(
        isA<ApiException>().having((error) => error.statusCode, 'status', 302),
      ),
    );
  });
}
