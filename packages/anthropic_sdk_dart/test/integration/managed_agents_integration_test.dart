// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  String? environmentId;
  AnthropicClient? client;

  setUpAll(() {
    final key = Platform.environment['ANTHROPIC_API_KEY'];
    final envId = Platform.environment['ANTHROPIC_ENVIRONMENT_ID'];
    apiKey = (key != null && key.isNotEmpty) ? key : null;
    environmentId = (envId != null && envId.isNotEmpty) ? envId : null;
    if (apiKey == null) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Managed Agents API - Integration', () {
    test(
      'full agent lifecycle',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // 1. Create an agent
        final agent = await client!.agents.create(
          const CreateAgentParams(
            name: 'Test Agent - Dart SDK',
            model: ModelParamsId(id: 'claude-sonnet-4-5'),
          ),
        );
        expect(agent.id, isNotEmpty);
        expect(agent.name, equals('Test Agent - Dart SDK'));
        expect(agent.version, equals(1));

        try {
          // 2. Retrieve the agent
          final retrieved = await client!.agents.retrieve(agent.id);
          expect(retrieved.id, equals(agent.id));
          expect(retrieved.name, equals('Test Agent - Dart SDK'));

          // 3. List agents
          final agents = await client!.agents.list(limit: 5);
          expect(agents.data, isNotEmpty);

          // 4. Update the agent
          final updated = await client!.agents.update(
            agent.id,
            UpdateAgentParams(
              version: agent.version,
              name: 'Updated Test Agent - Dart SDK',
            ),
          );
          expect(updated.name, equals('Updated Test Agent - Dart SDK'));
          expect(updated.version, equals(2));

          // 5. List versions
          final versions = await client!.agents.listVersions(agent.id);
          expect(versions.data.length, greaterThanOrEqualTo(2));

          // 6. Retrieve specific version
          final v1 = await client!.agents.retrieve(agent.id, version: 1);
          expect(v1.name, equals('Test Agent - Dart SDK'));
        } finally {
          // 7. Archive the agent (cleanup)
          final archived = await client!.agents.archive(agent.id);
          expect(archived.archivedAt, isNotNull);
        }
      },
    );

    test(
      'session lifecycle with events',
      timeout: const Timeout(Duration(minutes: 5)),
      () async {
        if (apiKey == null || environmentId == null) {
          markTestSkipped('API key or environment ID not available');
          return;
        }

        // 1. Create an agent for the session
        final agent = await client!.agents.create(
          const CreateAgentParams(
            name: 'Session Test Agent - Dart SDK',
            model: ModelParamsId(id: 'claude-sonnet-4-5'),
            system: 'You are a helpful assistant. Keep responses very brief.',
          ),
        );

        try {
          // 2. Create a session
          final session = await client!.sessions.create(
            CreateSessionParams(
              agent: AgentParamsId(id: agent.id),
              environmentId: environmentId!,
            ),
          );
          expect(session.id, isNotEmpty);

          // 3. Send a message event
          final sendResponse = await client!.sessions
              .events(session.id)
              .send(
                const SendSessionEventsParams(
                  events: [
                    UserMessageEventParams(
                      content: [
                        {'type': 'text', 'text': 'Say "Hi" and nothing else.'},
                      ],
                    ),
                  ],
                ),
              );
          expect(sendResponse.data, isNotEmpty);

          // 4. Wait for the agent to respond
          await Future<void>.delayed(const Duration(seconds: 10));

          // 5. List events to see the response
          final events = await client!.sessions.events(session.id).list();
          expect(events.data, isNotEmpty);

          // 6. List sessions
          final sessions = await client!.sessions.list(
            agentId: agent.id,
            limit: 5,
          );
          expect(sessions.data, isNotEmpty);

          // 7. Retrieve session
          final retrieved = await client!.sessions.retrieve(session.id);
          expect(retrieved.id, equals(session.id));

          // 8. Delete session
          final deleted = await client!.sessions.delete(session.id);
          expect(deleted.id, equals(session.id));
        } finally {
          // Cleanup: archive the agent
          await client!.agents.archive(agent.id);
        }
      },
    );

    test(
      'vault lifecycle with credentials',
      timeout: const Timeout(Duration(minutes: 3)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // 1. Create a vault
        final vault = await client!.vaults.create(
          const CreateVaultParams(displayName: 'Test Vault - Dart SDK'),
        );
        expect(vault.id, isNotEmpty);
        expect(vault.displayName, equals('Test Vault - Dart SDK'));

        try {
          // 2. Retrieve the vault
          final retrieved = await client!.vaults.retrieve(vault.id);
          expect(retrieved.id, equals(vault.id));

          // 3. List vaults
          final vaults = await client!.vaults.list(limit: 5);
          expect(vaults.data, isNotEmpty);

          // 4. Update the vault
          final updated = await client!.vaults.update(
            vault.id,
            const UpdateVaultParams(
              displayName: 'Updated Test Vault - Dart SDK',
            ),
          );
          expect(updated.displayName, equals('Updated Test Vault - Dart SDK'));

          // 5. Create a credential
          final credential = await client!.vaults
              .credentials(vault.id)
              .create(
                const CreateCredentialParams(
                  auth: StaticBearerCreateParams(
                    token: 'test-token-value',
                    mcpServerUrl: 'https://mcp.example.com',
                  ),
                  displayName: 'Test Credential',
                ),
              );
          expect(credential.id, isNotEmpty);
          expect(credential.vaultId, equals(vault.id));

          // 6. List credentials
          final credentials = await client!.vaults.credentials(vault.id).list();
          expect(credentials.data, isNotEmpty);

          // 7. Retrieve credential
          final retrievedCred = await client!.vaults
              .credentials(vault.id)
              .retrieve(credential.id);
          expect(retrievedCred.id, equals(credential.id));

          // 8. Archive credential
          final archivedCred = await client!.vaults
              .credentials(vault.id)
              .archive(credential.id);
          expect(archivedCred.id, equals(credential.id));
        } finally {
          // Cleanup: delete the vault
          final deleted = await client!.vaults.delete(vault.id);
          expect(deleted.id, equals(vault.id));
        }
      },
    );
  });
}
