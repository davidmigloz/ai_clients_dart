// ignore_for_file: avoid_print, unreachable_from_main
import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Connectors API (Beta).
///
/// Connectors expose external Model Context Protocol (MCP) servers to agents
/// and conversations, with configurable authentication and tool execution.
///
/// This example shows how to:
/// - Create, list, update, and delete connectors
/// - Manage connector credentials
/// - Activate and deactivate connectors
/// - List and call connector tools
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  final client = MistralClient.fromEnvironment();

  try {
    await connectorManagementExample(client);
    await connectorCredentialsExample(client);
    await connectorToolsExample(client);
  } finally {
    client.close();
  }
}

/// Demonstrates basic connector CRUD and activation operations.
Future<void> connectorManagementExample(MistralClient client) async {
  print('=== Connector Management Example ===\n');

  // Create an MCP connector.
  final connector = await client.connectors.create(
    request: const CreateConnectorRequest(
      name: 'my_connector',
      description: 'My MCP connector',
      server: 'https://mcp.example.com',
      visibility: ResourceVisibility.sharedOrg,
    ),
  );
  print('Created connector: ${connector.id} (${connector.name})');

  // List connectors with pagination + filters.
  final page = await client.connectors.list(
    queryFilters: const ConnectorsQueryFilters(active: true),
    pageSize: 50,
  );
  print('Found ${page.length} connector(s)');

  // Retrieve a connector by id or name.
  final fetched = await client.connectors.get(connectorIdOrName: connector.id);
  print('Fetched: ${fetched.name}');

  // Update the connector.
  await client.connectors.update(
    connectorId: connector.id,
    request: const UpdateConnectorRequest(description: 'Updated description'),
  );

  // Activate the connector for the whole organization.
  final activated = await client.connectors.activateForOrganization(
    connectorId: connector.id,
    toolConfiguration: const ToolExecutionConfiguration(include: ['search']),
  );
  print('Activate: ${activated.message}');

  // Deactivate it again.
  await client.connectors.deactivateForOrganization(connectorId: connector.id);

  // Delete the connector.
  final deleted = await client.connectors.delete(connectorId: connector.id);
  print('Delete: ${deleted.message}\n');
}

/// Demonstrates credential management for a connector.
Future<void> connectorCredentialsExample(MistralClient client) async {
  print('=== Connector Credentials Example ===\n');

  const connectorIdOrName = 'my_connector';

  // Create or update user-level credentials.
  final created = await client.connectors.createOrUpdateUserCredentials(
    connectorIdOrName: connectorIdOrName,
    request: const CredentialsCreateOrUpdate(
      name: 'my-cred',
      isDefault: true,
      credentials: ConnectionCredentials(bearerToken: 'secret-token'),
    ),
  );
  print('Create credentials: ${created.message}');

  // List user-level credentials.
  final credentials = await client.connectors.listUserCredentials(
    connectorIdOrName: connectorIdOrName,
  );
  print('User credentials: ${credentials.credentials.length}');

  // Inspect the supported authentication methods.
  final methods = await client.connectors.getAuthenticationMethods(
    connectorIdOrName: connectorIdOrName,
  );
  for (final method in methods) {
    print('  - ${method.methodType.value}');
  }

  // Fetch an OAuth2 authorization URL.
  final authUrl = await client.connectors.getAuthUrl(
    connectorIdOrName: connectorIdOrName,
    methodType: OutboundAuthenticationType.oauth2,
  );
  print('Auth URL (ttl ${authUrl.ttl}s): ${authUrl.authUrl}');

  // Delete the credentials.
  await client.connectors.deleteUserCredentials(
    connectorIdOrName: connectorIdOrName,
    credentialsName: 'my-cred',
  );
  print('');
}

/// Demonstrates listing and calling connector tools.
Future<void> connectorToolsExample(MistralClient client) async {
  print('=== Connector Tools Example ===\n');

  const connectorIdOrName = 'my_connector';

  // List the tools exposed by the connector.
  final tools = await client.connectors.listTools(
    connectorIdOrName: connectorIdOrName,
  );
  print('Connector exposes ${tools.length} tool(s)');

  // Call a tool with arguments.
  final result = await client.connectors.callTool(
    connectorIdOrName: connectorIdOrName,
    toolName: 'search',
    request: const ConnectorCallToolRequest(arguments: {'query': 'mistral'}),
  );
  print('Tool returned ${result.content.length} content block(s)');
  if (result.metadata?.mcpMeta?.isError ?? false) {
    print('Tool reported an error');
  }
}
