import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

import '../../mocks/mock_http_client.dart';

/// Fixture helpers for managed agents API responses.
class ManagedAgentsFixtures {
  ManagedAgentsFixtures._();

  static Map<String, dynamic> agent({
    String id = 'agent_test123',
    int version = 1,
    String name = 'Test Agent',
  }) {
    return {
      'id': id,
      'type': 'agent',
      'version': version,
      'name': name,
      'description': 'A test agent',
      'model': {'id': 'claude-sonnet-4-5', 'type': 'model'},
      'system': 'You are a helpful assistant.',
      'tools': <Map<String, dynamic>>[],
      'mcp_servers': <Map<String, dynamic>>[],
      'skills': <Map<String, dynamic>>[],
      'metadata': <String, String>{},
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': null,
    };
  }

  static Map<String, dynamic> session({
    String id = 'session_test123',
    String status = 'idle',
    String agentId = 'agent_test123',
  }) {
    return {
      'id': id,
      'type': 'session',
      'status': status,
      'agent': {
        'id': agentId,
        'type': 'agent',
        'version': 1,
        'name': 'Test Agent',
        'model': {'id': 'claude-sonnet-4-5', 'type': 'model'},
        'mcp_servers': <Map<String, dynamic>>[],
        'skills': <Map<String, dynamic>>[],
        'tools': <Map<String, dynamic>>[],
      },
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
    };
  }

  static Map<String, dynamic> vault({
    String id = 'vault_test123',
    String displayName = 'Test Vault',
  }) {
    return {
      'id': id,
      'type': 'vault',
      'display_name': displayName,
      'metadata': <String, String>{},
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': null,
    };
  }

  static Map<String, dynamic> credential({
    String id = 'cred_test123',
    String vaultId = 'vault_test123',
  }) {
    return {
      'id': id,
      'type': 'vault_credential',
      'vault_id': vaultId,
      'display_name': 'Test Credential',
      'auth': {
        'type': 'static_bearer',
        'mcp_server_url': 'https://mcp.example.com',
        'token_hint': '****abcd',
      },
      'metadata': <String, String>{},
      'created_at': '2026-04-01T00:00:00Z',
      'updated_at': '2026-04-01T00:00:00Z',
      'archived_at': null,
    };
  }

  static Map<String, dynamic> sessionEvent({
    String type = 'user.message',
    String id = 'event_test123',
  }) {
    return {
      'type': type,
      'id': id,
      'content': [
        {'type': 'text', 'text': 'Hello'},
      ],
      'processed_at': '2026-04-01T00:00:00Z',
    };
  }
}

void main() {
  late MockHttpClient mockHttpClient;
  late AnthropicClient client;

  setUp(() {
    mockHttpClient = MockHttpClient();
    client = AnthropicClient(
      config: const AnthropicConfig(
        authProvider: ApiKeyProvider('test-api-key'),
        retryPolicy: RetryPolicy(maxRetries: 0),
      ),
      httpClient: mockHttpClient,
    );
  });

  tearDown(() {
    client.close();
  });

  group('AgentsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        ManagedAgentsFixtures.agent(name: 'My Agent'),
      );

      final agent = await client.agents.create(
        const CreateAgentParams(
          name: 'My Agent',
          model: ModelParamsId(id: 'claude-sonnet-4-5'),
        ),
      );

      expect(agent.id, 'agent_test123');
      expect(agent.name, 'My Agent');
      expect(agent.version, 1);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
      expect(request.headers['x-api-key'], 'test-api-key');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['name'], 'My Agent');
      expect(body['model'], 'claude-sonnet-4-5');
    });

    test('list sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.agent()],
        'next_page': null,
      });

      final response = await client.agents.list(limit: 5);

      expect(response.data, hasLength(1));
      expect(response.data.first.id, 'agent_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents');
      expect(request.method, 'GET');
      expect(request.url.queryParameters['limit'], '5');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.agent());

      final agent = await client.agents.retrieve('agent_test123');

      expect(agent.id, 'agent_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents/agent_test123');
      expect(request.method, 'GET');
    });

    test('retrieve with version sends query parameter', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.agent(version: 3));

      final agent = await client.agents.retrieve('agent_test123', version: 3);

      expect(agent.version, 3);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.queryParameters['version'], '3');
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        ManagedAgentsFixtures.agent(name: 'Updated Agent', version: 2),
      );

      final agent = await client.agents.update(
        'agent_test123',
        const UpdateAgentParams(version: 1, name: 'Updated Agent'),
      );

      expect(agent.name, 'Updated Agent');
      expect(agent.version, 2);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents/agent_test123');
      expect(request.method, 'POST');
    });

    test('archive sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.agent(),
        'archived_at': '2026-04-01T12:00:00Z',
      });

      final agent = await client.agents.archive('agent_test123');

      expect(agent.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents/agent_test123/archive');
      expect(request.method, 'POST');
    });

    test('listVersions sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [
          ManagedAgentsFixtures.agent(version: 1),
          ManagedAgentsFixtures.agent(version: 2),
        ],
        'next_page': null,
      });

      final response = await client.agents.listVersions('agent_test123');

      expect(response.data, hasLength(2));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/agents/agent_test123/versions');
      expect(request.method, 'GET');
    });
  });

  group('SessionsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.session());

      final session = await client.sessions.create(
        const CreateSessionParams(
          agent: AgentParamsId(id: 'agent_test123'),
          environmentId: 'env_123',
        ),
      );

      expect(session.id, 'session_test123');
      expect(session.status, SessionStatus.idle);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('list sends correct request with query params', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.session()],
      });

      final response = await client.sessions.list(
        agentId: 'agent_test123',
        limit: 10,
      );

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions');
      expect(request.url.queryParameters['agent_id'], 'agent_test123');
      expect(request.url.queryParameters['limit'], '10');
    });

    test('retrieve sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.session());

      final session = await client.sessions.retrieve('session_test123');

      expect(session.id, 'session_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123');
      expect(request.method, 'GET');
    });

    test('update sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.session(),
        'title': 'Updated Title',
      });

      final session = await client.sessions.update(
        'session_test123',
        const UpdateSessionParams(title: 'Updated Title'),
      );

      expect(session.id, 'session_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123');
      expect(request.method, 'POST');
    });

    test('delete sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'session_test123',
        'type': 'session_deleted',
      });

      final deleted = await client.sessions.delete('session_test123');

      expect(deleted.id, 'session_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123');
      expect(request.method, 'DELETE');
    });

    test('archive sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.session(),
        'archived_at': '2026-04-01T12:00:00Z',
      });

      final session = await client.sessions.archive('session_test123');

      expect(session.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/archive');
      expect(request.method, 'POST');
    });
  });

  group('SessionEventsResource', () {
    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.sessionEvent()],
      });

      final response = await client.sessions
          .events('session_test123')
          .list(limit: 20);

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('send sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [
          {
            'type': 'user.message',
            'id': 'event_123',
            'content': [
              {'type': 'text', 'text': 'Hello'},
            ],
            'processed_at': '2026-04-01T00:00:00Z',
          },
        ],
      });

      final response = await client.sessions
          .events('session_test123')
          .send(
            const SendSessionEventsParams(
              events: [
                UserMessageEventParams(
                  content: [
                    {'type': 'text', 'text': 'Hello'},
                  ],
                ),
              ],
            ),
          );

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events');
      expect(request.method, 'POST');
    });

    test('stream sends correct request and parses SSE events', () async {
      mockHttpClient.queueStreamingResponse([
        {
          'type': 'user.message',
          'id': 'event_001',
          'content': [
            {'type': 'text', 'text': 'Hello'},
          ],
          'processed_at': '2026-04-01T00:00:00Z',
        },
        {
          'type': 'agent.message',
          'id': 'event_002',
          'content': [
            {'type': 'text', 'text': 'Hi there!'},
          ],
          'processed_at': '2026-04-01T00:00:01Z',
        },
      ]);

      final events = await client.sessions
          .events('session_test123')
          .stream()
          .toList();

      expect(events, hasLength(2));
      expect(events[0], isA<UserMessageEvent>());
      expect((events[0] as UserMessageEvent).id, 'event_001');
      expect(events[1], isA<AgentMessageEvent>());
      expect((events[1] as AgentMessageEvent).id, 'event_002');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/events/stream');
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });
  });

  group('SessionResourcesResource', () {
    test('create sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'type': 'file',
        'id': 'res_123',
        'file_id': 'file_abc',
        'mount_path': '/workspace/data.csv',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-01T00:00:00Z',
      });

      final resource = await client.sessions
          .resources('session_test123')
          .create(const FileResourceParams(fileId: 'file_abc'));

      expect(resource, isA<FileResource>());
      expect((resource as FileResource).fileId, 'file_abc');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/resources');
      expect(request.method, 'POST');
    });

    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [
          {
            'type': 'file',
            'id': 'res_123',
            'file_id': 'file_abc',
            'mount_path': '/workspace/data.csv',
            'created_at': '2026-04-01T00:00:00Z',
            'updated_at': '2026-04-01T00:00:00Z',
          },
        ],
      });

      final response = await client.sessions
          .resources('session_test123')
          .list();

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/sessions/session_test123/resources');
      expect(request.method, 'GET');
    });

    test('retrieve sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse({
        'type': 'file',
        'id': 'res_123',
        'file_id': 'file_abc',
        'mount_path': '/workspace/data.csv',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-01T00:00:00Z',
      });

      final resource = await client.sessions
          .resources('session_test123')
          .retrieve('res_123');

      expect(resource, isA<FileResource>());
      expect((resource as FileResource).id, 'res_123');
      expect(resource.fileId, 'file_abc');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/resources/res_123',
      );
      expect(request.method, 'GET');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse({
        'type': 'github_repository',
        'id': 'res_456',
        'url': 'https://github.com/example/repo',
        'mount_path': '/workspace/repo',
        'created_at': '2026-04-01T00:00:00Z',
        'updated_at': '2026-04-01T00:00:00Z',
      });

      final resource = await client.sessions
          .resources('session_test123')
          .update(
            'res_456',
            const UpdateSessionResourceParams(authorizationToken: 'new-token'),
          );

      expect(resource, isA<GitHubRepositoryResource>());
      expect((resource as GitHubRepositoryResource).id, 'res_456');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/resources/res_456',
      );
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['authorization_token'], 'new-token');
    });

    test('delete sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'res_123',
        'type': 'session_resource_deleted',
      });

      final deleted = await client.sessions
          .resources('session_test123')
          .delete('res_123');

      expect(deleted.id, 'res_123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/sessions/session_test123/resources/res_123',
      );
      expect(request.method, 'DELETE');
    });
  });

  group('VaultsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.vault());

      final vault = await client.vaults.create(
        const CreateVaultParams(displayName: 'Test Vault'),
      );

      expect(vault.id, 'vault_test123');
      expect(vault.displayName, 'Test Vault');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.vault()],
      });

      final response = await client.vaults.list(limit: 10);

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults');
      expect(request.url.queryParameters['limit'], '10');
    });

    test('retrieve sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.vault());

      final vault = await client.vaults.retrieve('vault_test123');

      expect(vault.id, 'vault_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123');
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(
        ManagedAgentsFixtures.vault(displayName: 'Updated Vault'),
      );

      final vault = await client.vaults.update(
        'vault_test123',
        const UpdateVaultParams(displayName: 'Updated Vault'),
      );

      expect(vault.id, 'vault_test123');
      expect(vault.displayName, 'Updated Vault');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['display_name'], 'Updated Vault');
    });

    test('delete sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'vault_test123',
        'type': 'vault_deleted',
      });

      final deleted = await client.vaults.delete('vault_test123');

      expect(deleted.id, 'vault_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123');
      expect(request.method, 'DELETE');
    });

    test('archive sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        ...ManagedAgentsFixtures.vault(),
        'archived_at': '2026-04-01T12:00:00Z',
      });

      final vault = await client.vaults.archive('vault_test123');

      expect(vault.archivedAt, isNotNull);

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123/archive');
      expect(request.method, 'POST');
    });
  });

  group('VaultCredentialsResource', () {
    test('create sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.credential());

      final credential = await client.vaults
          .credentials('vault_test123')
          .create(
            const CreateCredentialParams(
              auth: StaticBearerCreateParams(
                token: 'secret-token',
                mcpServerUrl: 'https://mcp.example.com',
              ),
            ),
          );

      expect(credential.id, 'cred_test123');
      expect(credential.vaultId, 'vault_test123');

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123/credentials');
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');
    });

    test('list sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'data': [ManagedAgentsFixtures.credential()],
      });

      final response = await client.vaults.credentials('vault_test123').list();

      expect(response.data, hasLength(1));

      final request = mockHttpClient.lastRequest!;
      expect(request.url.path, '/v1/vaults/vault_test123/credentials');
      expect(request.method, 'GET');
    });

    test('retrieve sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.credential());

      final credential = await client.vaults
          .credentials('vault_test123')
          .retrieve('cred_test123');

      expect(credential.id, 'cred_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/vaults/vault_test123/credentials/cred_test123',
      );
    });

    test('update sends correct request and parses response', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.credential());

      final credential = await client.vaults
          .credentials('vault_test123')
          .update(
            'cred_test123',
            const UpdateCredentialParams(displayName: 'Updated Credential'),
          );

      expect(credential.id, 'cred_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/vaults/vault_test123/credentials/cred_test123',
      );
      expect(request.method, 'POST');
      expect(request.headers['anthropic-beta'], 'managed-agents-2026-04-01');

      final body =
          jsonDecode((request as dynamic).body) as Map<String, dynamic>;
      expect(body['display_name'], 'Updated Credential');
    });

    test('delete sends correct request', () async {
      mockHttpClient.queueJsonResponse({
        'id': 'cred_test123',
        'type': 'vault_credential_deleted',
      });

      final deleted = await client.vaults
          .credentials('vault_test123')
          .delete('cred_test123');

      expect(deleted.id, 'cred_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/vaults/vault_test123/credentials/cred_test123',
      );
      expect(request.method, 'DELETE');
    });

    test('archive sends correct request', () async {
      mockHttpClient.queueJsonResponse(ManagedAgentsFixtures.credential());

      await client.vaults.credentials('vault_test123').archive('cred_test123');

      final request = mockHttpClient.lastRequest!;
      expect(
        request.url.path,
        '/v1/vaults/vault_test123/credentials/cred_test123/archive',
      );
      expect(request.method, 'POST');
    });
  });
}
