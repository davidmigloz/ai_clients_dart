// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Managed Agents API example (Beta).
///
/// This example demonstrates:
/// - Creating and managing agents
/// - Starting sessions and sending messages
/// - Polling session events
/// - Managing vaults and credentials
/// - Multiagent coordinator rosters and outcome evaluations
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
    // 4. Multiagent orchestration & outcome evaluations
    // =========================================================================
    print('\n=== Multiagent & Outcomes ===');

    // Create a leaf "worker" agent the coordinator can spawn (depth limit 1).
    final worker = await client.agents.create(
      const CreateAgentParams(
        name: 'Worker',
        model: ModelParamsId(id: 'claude-sonnet-4-5'),
      ),
    );

    // Create a coordinator agent with a roster: the worker plus `self`.
    final coordinator = await client.agents.create(
      CreateAgentParams(
        name: 'Coordinator',
        model: const ModelParamsId(id: 'claude-sonnet-4-5'),
        multiagent: MultiagentCoordinatorParams(
          agents: [
            MultiagentRosterEntryAgent(agent: AgentParamsId(id: worker.id)),
            const MultiagentSelfParams(),
          ],
        ),
      ),
    );
    final resolved = coordinator.multiagent;
    if (resolved is MultiagentCoordinator) {
      print(
        'Coordinator roster: ${resolved.agents.map((a) => a.id).join(', ')}',
      );
    }

    // Define an outcome the agent should work toward, graded by a rubric.
    await client.sessions
        .events(session.id)
        .send(
          const SendSessionEventsParams(
            events: [
              UserDefineOutcomeEventParams(
                description: 'Produce a one-paragraph summary.',
                rubric: TextRubricParams(
                  content: 'Must be a single paragraph with no bullet points.',
                ),
                maxIterations: 3,
              ),
            ],
          ),
        );
    print('Defined an outcome for the session');

    // =========================================================================
    // 5. Webhooks & credential validation
    // =========================================================================
    print('\n=== Webhooks & Credential Validation ===');

    // Parse an inbound webhook payload (e.g. the body of your HTTP handler)
    // into a typed event, then switch over the discriminated `data` union.
    final samplePayload = <String, dynamic>{
      'type': 'event',
      'id': 'evt_123',
      'created_at': '2026-04-01T00:00:00Z',
      'data': <String, dynamic>{
        'type': 'session.created',
        'id': 'sesn_123',
        'organization_id': 'org_123',
        'workspace_id': 'wrkspc_123',
      },
    };
    final webhookEvent = WebhookEvent.fromJson(samplePayload);
    switch (webhookEvent.data) {
      case WebhookSessionCreatedEventData(:final id):
        print('Webhook: session $id created');
      case WebhookVaultCredentialRefreshFailedEventData(:final id):
        print('Webhook: credential $id refresh failed');
      default:
        print('Webhook: ${webhookEvent.data.runtimeType}');
    }

    // Validate a vault credential's MCP-OAuth setup. The mcp_oauth_validate
    // endpoint only accepts MCP-OAuth credentials (a static-bearer credential
    // is rejected with a 400), so create one of those.
    final credential = await client.vaults
        .credentials(vault.id)
        .create(
          const CreateCredentialParams(
            auth: McpOauthCreateParams(
              accessToken: 'access-token',
              mcpServerUrl: 'https://mcp.example.com',
            ),
          ),
        );
    final validation = await client.vaults
        .credentials(vault.id)
        .validateCredential(credential.id);
    print('Credential validation status: ${validation.status.value}');

    // =========================================================================
    // 6. Cleanup
    // =========================================================================
    print('\n=== Cleanup ===');

    await client.sessions.delete(session.id);
    print('Deleted session');

    await client.agents.archive(agent.id);
    await client.agents.archive(coordinator.id);
    await client.agents.archive(worker.id);
    print('Archived agents');

    await client.vaults.delete(vault.id);
    print('Deleted vault');
  } finally {
    client.close();
  }
}
