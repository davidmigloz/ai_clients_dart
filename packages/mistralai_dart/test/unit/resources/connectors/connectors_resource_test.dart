@TestOn('vm')
library;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('ConnectorsResource', () {
    late http.Request captured;

    MistralClient clientReturning(Object body, {int statusCode = 200}) {
      final mockClient = MockClient((request) async {
        captured = request;
        return http.Response(
          jsonEncode(body),
          statusCode,
          headers: {'content-type': 'application/json'},
        );
      });
      return MistralClient(
        config: const MistralConfig(authProvider: ApiKeyProvider('test-key')),
        httpClient: mockClient,
      );
    }

    Map<String, dynamic> connectorJson(String id) => {
      'id': id,
      'name': 'my_connector',
      'description': 'desc',
      'created_at': '2024-01-01T00:00:00Z',
      'modified_at': '2024-01-02T00:00:00Z',
      'owner_type': 2,
      'visibility': 'shared_org',
      'private_tool_execution': false,
    };

    test('create issues POST with request body', () async {
      final client = clientReturning(connectorJson('c-1'), statusCode: 201);
      addTearDown(client.close);

      final result = await client.connectors.create(
        request: const CreateConnectorRequest(
          name: 'my_connector',
          description: 'desc',
          server: 'https://mcp.example.com',
          visibility: ResourceVisibility.sharedOrg,
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/connectors');
      expect(jsonDecode(captured.body), {
        'name': 'my_connector',
        'description': 'desc',
        'server': 'https://mcp.example.com',
        'protocol': 'mcp',
        'visibility': 'shared_org',
      });
      expect(result.id, 'c-1');
      expect(result.visibility, ResourceVisibility.sharedOrg);
      expect(result.ownerType, ResourceType.org);
    });

    test('list plumbs filter and pagination query params', () async {
      final client = clientReturning({
        'items': [connectorJson('c-1')],
        'pagination': {'page_size': 100, 'next_cursor': 'next'},
      });
      addTearDown(client.close);

      final result = await client.connectors.list(
        queryFilters: const ConnectorsQueryFilters(active: true),
        cursor: 'abc',
        pageSize: 50,
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/connectors');
      expect(captured.url.queryParameters['active'], 'true');
      expect(captured.url.queryParameters['cursor'], 'abc');
      expect(captured.url.queryParameters['page_size'], '50');
      expect(result.length, 1);
      expect(result.pagination.nextCursor, 'next');
      expect(result.pagination.hasMore, isTrue);
    });

    test('get retrieves by id or name', () async {
      final client = clientReturning(connectorJson('c-1'));
      addTearDown(client.close);

      final result = await client.connectors.get(connectorIdOrName: 'my_name');

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/connectors/my_name');
      expect(result.id, 'c-1');
    });

    test('update issues PATCH with request body', () async {
      final client = clientReturning(connectorJson('c-1'));
      addTearDown(client.close);

      await client.connectors.update(
        connectorId: 'c-1',
        request: const UpdateConnectorRequest(
          name: 'renamed',
          server: 'https://new.example.com',
        ),
      );

      expect(captured.method, 'PATCH');
      expect(captured.url.path, '/v1/connectors/c-1');
      expect(jsonDecode(captured.body), {
        'name': 'renamed',
        'protocol': 'mcp',
        'server': 'https://new.example.com',
      });
    });

    test('delete issues DELETE and parses message', () async {
      final client = clientReturning({'message': 'deleted'});
      addTearDown(client.close);

      final result = await client.connectors.delete(connectorId: 'c-1');

      expect(captured.method, 'DELETE');
      expect(captured.url.path, '/v1/connectors/c-1');
      expect(result.message, 'deleted');
    });

    test('getAuthUrl plumbs query params', () async {
      final client = clientReturning({'auth_url': 'https://auth', 'ttl': 600});
      addTearDown(client.close);

      final result = await client.connectors.getAuthUrl(
        connectorIdOrName: 'c-1',
        appReturnUrl: 'https://app',
        methodType: OutboundAuthenticationType.oauth2,
        credentialsName: 'cred',
        githubInstallationLink: true,
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/connectors/c-1/auth_url');
      expect(captured.url.queryParameters['app_return_url'], 'https://app');
      expect(captured.url.queryParameters['method_type'], 'oauth2');
      expect(captured.url.queryParameters['credentials_name'], 'cred');
      expect(captured.url.queryParameters['github_installation_link'], 'true');
      expect(result.authUrl, 'https://auth');
      expect(result.ttl, 600);
    });

    test('getAuthenticationMethods parses a JSON array', () async {
      final client = clientReturning([
        {
          'method_type': 'oauth2',
          'has_default_credentials': true,
          'headers': [
            {'name': 'X-Token', 'is_required': true, 'is_secret': true},
          ],
        },
      ]);
      addTearDown(client.close);

      final result = await client.connectors.getAuthenticationMethods(
        connectorIdOrName: 'c-1',
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/connectors/c-1/authentication_methods');
      expect(result, hasLength(1));
      expect(result.first.methodType, OutboundAuthenticationType.oauth2);
      expect(result.first.headers!.first.name, 'X-Token');
    });

    test('listTools returns the raw list and plumbs query params', () async {
      final client = clientReturning([
        {'id': 't-1', 'name': 'search'},
      ]);
      addTearDown(client.close);

      final result = await client.connectors.listTools(
        connectorIdOrName: 'c-1',
        page: 2,
        pageSize: 10,
        refresh: true,
        pretty: true,
        credentialsName: 'cred',
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/connectors/c-1/tools');
      expect(captured.url.queryParameters['page'], '2');
      expect(captured.url.queryParameters['page_size'], '10');
      expect(captured.url.queryParameters['refresh'], 'true');
      expect(captured.url.queryParameters['pretty'], 'true');
      expect(captured.url.queryParameters['credentials_name'], 'cred');
      expect(result, hasLength(1));
      expect(result.first['name'], 'search');
    });

    test('callTool POSTs arguments and parses response', () async {
      final client = clientReturning({
        'content': [
          {'type': 'text', 'text': 'hi'},
        ],
        'metadata': {
          'mcp_meta': {'isError': false},
        },
      });
      addTearDown(client.close);

      final result = await client.connectors.callTool(
        connectorIdOrName: 'c-1',
        toolName: 'search',
        request: const ConnectorCallToolRequest(arguments: {'q': 'mistral'}),
        credentialsName: 'cred',
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/connectors/c-1/tools/search/call');
      expect(captured.url.queryParameters['credentials_name'], 'cred');
      expect(jsonDecode(captured.body), {
        'arguments': {'q': 'mistral'},
      });
      expect(result.content, hasLength(1));
      expect(result.content.first['text'], 'hi');
      expect(result.metadata!.mcpMeta!.isError, isFalse);
    });

    test('listOrganizationCredentials hits the org path', () async {
      final client = clientReturning({
        'credentials': [
          {
            'name': 'default',
            'authentication_type': 'bearer',
            'scope': 'org',
            'is_default': true,
          },
        ],
        'connector_preset_credentials_for_auth': ['oauth2'],
      });
      addTearDown(client.close);

      final result = await client.connectors.listOrganizationCredentials(
        connectorIdOrName: 'c-1',
        authType: OutboundAuthenticationType.bearer,
        fetchDefault: true,
      );

      expect(captured.method, 'GET');
      expect(captured.url.path, '/v1/connectors/c-1/organization/credentials');
      expect(captured.url.queryParameters['auth_type'], 'bearer');
      expect(captured.url.queryParameters['fetch_default'], 'true');
      expect(result.credentials.first.name, 'default');
      expect(result.connectorPresetCredentialsForAuth, [
        OutboundAuthenticationType.oauth2,
      ]);
    });

    test('createOrUpdateUserCredentials POSTs to the user path', () async {
      final client = clientReturning({'message': 'ok'});
      addTearDown(client.close);

      final result = await client.connectors.createOrUpdateUserCredentials(
        connectorIdOrName: 'c-1',
        request: const CredentialsCreateOrUpdate(
          name: 'my-cred',
          isDefault: true,
          credentials: ConnectionCredentials(bearerToken: 'secret'),
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/connectors/c-1/user/credentials');
      expect(jsonDecode(captured.body), {
        'name': 'my-cred',
        'is_default': true,
        'credentials': {'bearer_token': 'secret'},
      });
      expect(result.message, 'ok');
    });

    test('deleteWorkspaceCredentials hits the workspace path', () async {
      final client = clientReturning({'message': 'removed'});
      addTearDown(client.close);

      final result = await client.connectors.deleteWorkspaceCredentials(
        connectorIdOrName: 'c-1',
        credentialsName: 'my-cred',
      );

      expect(captured.method, 'DELETE');
      expect(
        captured.url.path,
        '/v1/connectors/c-1/workspace/credentials/my-cred',
      );
      expect(result.message, 'removed');
    });

    test('activateForOrganization POSTs tool configuration body', () async {
      final client = clientReturning({'message': 'activated'});
      addTearDown(client.close);

      final result = await client.connectors.activateForOrganization(
        connectorId: 'c-1',
        toolConfiguration: const ToolExecutionConfiguration(
          include: ['search'],
          exclude: ['delete'],
        ),
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/connectors/c-1/organization/activate');
      expect(jsonDecode(captured.body), {
        'include': ['search'],
        'exclude': ['delete'],
      });
      expect(result.message, 'activated');
    });

    test('deactivateForUser POSTs to the user deactivate path', () async {
      final client = clientReturning({'message': 'deactivated'});
      addTearDown(client.close);

      final result = await client.connectors.deactivateForUser(
        connectorId: 'c-1',
      );

      expect(captured.method, 'POST');
      expect(captured.url.path, '/v1/connectors/c-1/user/deactivate');
      expect(result.message, 'deactivated');
    });
  });
}
