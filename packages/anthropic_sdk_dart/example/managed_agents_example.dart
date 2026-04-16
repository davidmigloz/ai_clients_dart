// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Managed Agents API example (Beta).
///
/// This example demonstrates:
/// - Creating and managing agents
/// - Starting sessions and sending messages
/// - Polling session events
/// - Managing vaults and credentials
///
/// Note: The Managed Agents API is a beta feature.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // =========================================================================
    // 1. Agents — create, list, retrieve
    // =========================================================================
    print('=== Agents ===');

    // Create an agent with a model and system prompt
    final agent = await client.agents.create(
      const CreateAgentParams(
        name: 'Helper Agent',
        model: ModelParamsId(id: 'claude-sonnet-4-6'),
        system: 'You are a helpful assistant.',
      ),
    );
    print('Created agent: ${agent.id} (v${agent.version})');

    // List agents
    final agents = await client.agents.list(limit: 5);
    print('Total agents: ${agents.data.length}');

    // Retrieve a specific agent
    final retrieved = await client.agents.retrieve(agent.id);
    print('Retrieved: ${retrieved.name}');

    // =========================================================================
    // 2. Sessions — create, send messages, poll events
    // =========================================================================
    print('\n=== Sessions ===');

    // Create a session from the agent
    final session = await client.sessions.create(
      CreateSessionParams(
        agent: AgentParamsId(id: agent.id),
        environmentId: 'default',
      ),
    );
    print('Created session: ${session.id} (status: ${session.status.value})');

    // Send a user message
    final eventsResource = client.sessions.events(session.id);
    await eventsResource.send(
      const SendSessionEventsParams(
        events: [
          UserMessageEventParams(
            content: [
              {'type': 'text', 'text': 'What is 2 + 2?'},
            ],
          ),
        ],
      ),
    );
    print('Sent message to session');

    // Poll for events
    final events = await eventsResource.list();
    for (final event in events.data) {
      print('Event: ${event.runtimeType}');
    }

    // List sessions
    final sessions = await client.sessions.list(agentId: agent.id, limit: 5);
    print('Total sessions: ${sessions.data.length}');

    // =========================================================================
    // 3. Vaults — create, list credentials
    // =========================================================================
    print('\n=== Vaults ===');

    // Create a vault
    final vault = await client.vaults.create(
      const CreateVaultParams(displayName: 'My Vault'),
    );
    print('Created vault: ${vault.id}');

    // List vaults
    final vaults = await client.vaults.list(limit: 5);
    print('Total vaults: ${vaults.data.length}');

    // List credentials in the vault
    final credentials = await client.vaults.credentials(vault.id).list();
    print('Credentials in vault: ${credentials.data.length}');

    // =========================================================================
    // 4. Cleanup
    // =========================================================================
    print('\n=== Cleanup ===');

    await client.sessions.delete(session.id);
    print('Deleted session');

    await client.agents.archive(agent.id);
    print('Archived agent');

    await client.vaults.delete(vault.id);
    print('Deleted vault');
  } finally {
    client.close();
  }
}
