import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

const _accountId = 'svac_fixture';
const _workspaceId = 'wrkspc_fixture';
const _org = '/proxy/v1/organizations';
const _accounts = '$_org/service_accounts';
const _account = '$_accounts/$_accountId';
const _workspace = '$_org/workspaces/$_workspaceId/service_accounts';
const _membership = '$_workspace/$_accountId';
const _time = '2026-11-11T00:00:00.000Z';

void main() {
  for (final betas in [
    <String>[],
    ['caller-beta'],
  ]) {
    group(betas.isEmpty ? 'GA' : 'caller beta', () {
      late List<http.Request> requests;
      late Map<String, dynamic> response;
      late AnthropicClient client;
      late OrganizationServiceAccountsResource accounts;
      late OrganizationServiceAccountWorkspacesResource accountWorkspaces;
      late OrganizationWorkspaceServiceAccountsResource workspaceAccounts;

      setUp(() {
        requests = [];
        response = _record();
        final transport = MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode(response),
            200,
            headers: {'content-type': 'application/json'},
          );
        });
        addTearDown(transport.close);
        client = AnthropicClient.withAuthToken(
          'fixture-org-token',
          config: const AnthropicConfig(
            baseUrl: 'https://fixture.invalid/proxy',
            workspaceId: 'ignored-config-workspace',
            defaultHeaders: {'Anthropic-Workspace-ID': 'ignored-header'},
          ),
          httpClient: transport,
        );
        addTearDown(client.close);
        accounts = client.organization.serviceAccounts;
        accountWorkspaces = accounts.workspaces;
        workspaceAccounts = client.organization.workspaces.serviceAccounts;
      });

      void expectRequest(
        String method,
        String path, {
        Map<String, String> query = const {},
        Map<String, Object?>? body,
      }) {
        final request = requests.last;
        expect(request.method, method);
        expect(request.url.path, path);
        expect(request.url.queryParameters, query);
        expect(request.headers['authorization'], 'Bearer fixture-org-token');
        expect(request.headers['x-api-key'], isNull);
        expect(request.headers['anthropic-version'], '2026-10-21');
        expect(request.headers['anthropic-workspace-id'], isNull);
        expect(
          request.headers['anthropic-beta'],
          [...betas, 'oauth-2025-04-20'].join(','),
        );
        expect(request.followRedirects, isFalse);
        if (body == null) {
          expect(request.bodyBytes, isEmpty);
        } else {
          expect(jsonDecode(request.body), body);
        }
      }

      test('list and continue using opaque page', () async {
        response = {
          'data': [_record()],
          'next_page': 'a/+=?',
        };
        final first = await accounts.list(
          limit: 2,
          includeArchived: false,
          betas: betas,
        );
        expectRequest(
          'GET',
          _accounts,
          query: {'limit': '2', 'include_archived': 'false'},
        );
        expect(first.data.single.id, _accountId);
        expect(first.nextPage, 'a/+=?');
        response = {'data': <Object>[], 'next_page': null};
        final next = await accounts.list(
          limit: 2,
          includeArchived: false,
          page: first.nextPage,
          betas: betas,
        );
        expectRequest(
          'GET',
          _accounts,
          query: {'limit': '2', 'include_archived': 'false', 'page': 'a/+=?'},
        );
        expect(next.data, isEmpty);
        expect(next.nextPage, isNull);
      });

      test('create sends organization role and description', () async {
        final account = await accounts.create(
          name: 'fixture',
          description: 'Role description',
          organizationRole: ServiceAccountRole.developer,
          betas: betas,
        );
        expect(account.name, 'fixture');
        expectRequest(
          'POST',
          _accounts,
          body: {
            'name': 'fixture',
            'description': 'Role description',
            'organization_role': 'developer',
          },
        );
      });

      test('retrieve escapes identifier in the path', () async {
        final account = await accounts.retrieve('svac/a ?', betas: betas);
        expect(account.id, _accountId);
        expectRequest('GET', '$_accounts/svac%2Fa%20%3F');
        expect(requests.last.url.pathSegments.last, 'svac/a ?');
      });

      test('update clears description and changes organization role', () async {
        final updated = await accounts.update(
          _accountId,
          description: null,
          organizationRole: ServiceAccountRole.admin,
          betas: betas,
        );
        expect(updated.description, isNull);
        expectRequest(
          'POST',
          _account,
          body: {'description': null, 'organization_role': 'admin'},
        );
        await accounts.update(_accountId, betas: betas);
        expectRequest('POST', _account, body: {});
      });

      test('archive uses action path without a request body', () async {
        response['archived_at'] = _time;
        final archived = await accounts.archive(_accountId, betas: betas);
        expect(archived.archivedAt, DateTime.parse(_time));
        expectRequest('POST', '$_account/archive');
      });

      test('account workspace list retains implicit membership', () async {
        response = {
          'data': [_member(implicit: true)],
          'next_page': 'a/+',
        };
        final page = await accountWorkspaces.list(
          _accountId,
          limit: 3,
          page: 'older',
          betas: betas,
        );
        expect(page.data.single.implicit, isTrue);
        expect(page.nextPage, 'a/+');
        expectRequest(
          'GET',
          '$_account/workspaces',
          query: {'limit': '3', 'page': 'older'},
        );
      });

      test(
        'account workspace add sends workspace ID and assigned role',
        () async {
          response = _member();
          final member = await accountWorkspaces.add(
            _accountId,
            workspaceId: _workspaceId,
            workspaceRole: ServiceAccountWorkspaceRole.restrictedDeveloper,
            betas: betas,
          );
          expect(member.workspaceId, _workspaceId);
          expectRequest(
            'POST',
            '$_account/workspaces',
            body: {
              'workspace_id': _workspaceId,
              'workspace_role': 'workspace_restricted_developer',
            },
          );
        },
      );

      test('account workspace remove parses delete receipt', () async {
        response = _deleted();
        final receipt = await accountWorkspaces.remove(
          _accountId,
          _workspaceId,
          betas: betas,
        );
        expect(receipt.workspaceId, _workspaceId);
        expectRequest('DELETE', '$_account/workspaces/$_workspaceId');
      });

      test('workspace account list retains cursor', () async {
        response = {
          'data': [_member()],
          'next_page': null,
        };
        final page = await workspaceAccounts.list(
          _workspaceId,
          page: 'a/+',
          limit: 20,
          betas: betas,
        );
        expect(page.data.single.serviceAccountId, _accountId);
        expect(page.nextPage, isNull);
        expectRequest('GET', _workspace, query: {'page': 'a/+', 'limit': '20'});
      });

      test(
        'workspace account create sends service account ID and role',
        () async {
          response = _member();
          final member = await workspaceAccounts.create(
            _workspaceId,
            serviceAccountId: _accountId,
            workspaceRole: ServiceAccountWorkspaceRole.developer,
            betas: betas,
          );
          expect(member.implicit, isNull);
          expectRequest(
            'POST',
            _workspace,
            body: {
              'service_account_id': _accountId,
              'workspace_role': 'workspace_developer',
            },
          );
        },
      );

      test('workspace account retrieve uses both identifiers', () async {
        response = _member();
        final member = await workspaceAccounts.retrieve(
          _workspaceId,
          _accountId,
          betas: betas,
        );
        expect(member.workspaceRole, 'workspace_user');
        expectRequest('GET', _membership);
      });

      test('workspace account update sends only the role', () async {
        response = _member()..['workspace_role'] = 'workspace_admin';
        final member = await workspaceAccounts.update(
          _workspaceId,
          _accountId,
          workspaceRole: ServiceAccountWorkspaceRole.admin,
          betas: betas,
        );
        expect(member.workspaceRole, 'workspace_admin');
        expectRequest(
          'POST',
          _membership,
          body: {'workspace_role': 'workspace_admin'},
        );
      });

      test('workspace account delete parses receipt', () async {
        response = _deleted();
        final receipt = await workspaceAccounts.delete(
          _workspaceId,
          _accountId,
          betas: betas,
        );
        expect(receipt.serviceAccountId, _accountId);
        expectRequest('DELETE', _membership);
      });

      test('unsafe nested membership identifiers fail before dispatch', () {
        for (final id in ['', '.', '..', '..;metadata']) {
          expect(
            () => accounts.retrieve(id, betas: betas),
            throwsArgumentError,
          );
          expect(
            () => accountWorkspaces.remove(_accountId, id, betas: betas),
            throwsArgumentError,
          );
          expect(
            () => workspaceAccounts.delete(id, _accountId, betas: betas),
            throwsArgumentError,
          );
          expect(
            () => workspaceAccounts.delete(_workspaceId, id, betas: betas),
            throwsArgumentError,
          );
        }
        expect(requests, isEmpty);
      });

      test(
        'Default Workspace supports both implicit and explicit views',
        () async {
          response = {
            'data': [_member(implicit: true)],
            'next_page': null,
          };
          final accountPage = await accountWorkspaces.list(
            _accountId,
            betas: betas,
          );
          expect(accountPage.data.single.implicit, isTrue);
          expectRequest('GET', '$_account/workspaces');

          response = {'data': <Object>[], 'next_page': null};
          final workspacePage = await workspaceAccounts.list(
            _workspaceId,
            betas: betas,
          );
          expect(workspacePage.data, isEmpty);
          expectRequest('GET', _workspace);

          response = _member(implicit: false)
            ..['workspace_role'] = 'workspace_admin';
          final explicit = await workspaceAccounts.create(
            _workspaceId,
            serviceAccountId: _accountId,
            workspaceRole: ServiceAccountWorkspaceRole.admin,
            betas: betas,
          );
          expect(explicit.implicit, isFalse);
          expectRequest(
            'POST',
            _workspace,
            body: {
              'service_account_id': _accountId,
              'workspace_role': 'workspace_admin',
            },
          );

          response = _deleted();
          await accountWorkspaces.remove(
            _accountId,
            _workspaceId,
            betas: betas,
          );
          expectRequest('DELETE', '$_account/workspaces/$_workspaceId');

          response = _member(implicit: true);
          final restored = await workspaceAccounts.retrieve(
            _workspaceId,
            _accountId,
            betas: betas,
          );
          expect(restored.implicit, isTrue);
          expect(restored.workspaceRole, 'workspace_user');
          expectRequest('GET', _membership);
          expect(requests, hasLength(5));
        },
      );
    });
  }

  test(
    'federated Admin keeps the exchange workspace and sends scoped OAuth',
    () async {
      final paths = <String>[];
      final transport = MockClient((request) async {
        paths.add(request.url.path);
        if (request.url.path.endsWith('/oauth/token')) {
          expect(
            jsonDecode(request.body),
            containsPair('workspace_id', 'wrkspc_exchange'),
          );
          return http.Response(
            jsonEncode({
              'access_token': 'fixture-token',
              'expires_in': 600,
              'token_type': 'Bearer',
              'scope': 'org:admin',
            }),
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        expect(request.headers['authorization'], 'Bearer fixture-token');
        expect(request.headers['x-api-key'], isNull);
        expect(request.headers['anthropic-workspace-id'], isNull);
        expect(
          request.headers['anthropic-beta'],
          'caller-beta,oauth-2025-04-20',
        );
        return http.Response(
          '{"data":[],"next_page":null}',
          200,
          headers: {'content-type': 'application/json'},
        );
      });
      addTearDown(transport.close);
      final client = AnthropicClient.withWorkloadIdentity(
        identityTokenProvider: () => 'fixture.jwt.assertion',
        federationRuleId: 'fdrl_fixture',
        organizationId: 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        serviceAccountId: _accountId,
        workspaceId: 'wrkspc_exchange',
        config: const AnthropicConfig(
          baseUrl: 'https://fixture.invalid/proxy',
          defaultHeaders: {'Anthropic-Workspace-ID': 'ignored-header'},
        ),
        httpClient: transport,
      );
      addTearDown(client.close);
      await client.organization.serviceAccounts.list(betas: ['caller-beta']);
      await client.organization.workspaces.serviceAccounts.list(
        _workspaceId,
        betas: ['caller-beta'],
      );
      expect(paths, ['/proxy/v1/oauth/token', _accounts, _workspace]);
    },
  );

  test('nullable response data and future roles round-trip', () {
    final json = _record()..['organization_role'] = 'future_role';
    final account = ServiceAccount.fromJson(json);
    expect(account.organizationRole, 'future_role');
    expect(account.toJson(), json);
    expect(ServiceAccount.fromJson(account.toJson()), account);
    expect(
      ServiceAccount.fromJson(account.toJson()).hashCode,
      account.hashCode,
    );
    expect(
      account.copyWith(description: 'updated').copyWith(description: null),
      account,
    );
    expect(
      () => ServiceAccount.fromJson(json..remove('archived_at')),
      throwsFormatException,
    );

    final member = ServiceAccountWorkspaceMember.fromJson(_member());
    expect(ServiceAccountWorkspaceMember.fromJson(member.toJson()), member);
    expect(
      ServiceAccountWorkspaceMember.fromJson(member.toJson()).hashCode,
      member.hashCode,
    );
    expect(member.copyWith(implicit: true).copyWith(implicit: null), member);
    expect(
      () => DeletedServiceAccountWorkspaceMember.fromJson(
        _deleted()..['type'] = 'unknown',
      ),
      throwsFormatException,
    );
  });
}

Map<String, dynamic> _record() => {
  'type': 'service_account',
  'id': _accountId,
  'name': 'fixture',
  'description': null,
  'organization_role': 'developer',
  'created_at': _time,
  'created_by_actor_id': 'user_fixture',
  'updated_at': _time,
  'updated_by_actor_id': null,
  'archived_at': null,
  'archived_by_actor_id': null,
};

Map<String, dynamic> _member({bool? implicit}) => {
  'type': 'service_account_workspace_member',
  'service_account_id': _accountId,
  'workspace_id': _workspaceId,
  'workspace_role': 'workspace_user',
  'implicit': implicit,
  'created_by_actor_id': null,
};

Map<String, dynamic> _deleted() => {
  'type': 'service_account_workspace_member_deleted',
  'service_account_id': _accountId,
  'workspace_id': _workspaceId,
};
