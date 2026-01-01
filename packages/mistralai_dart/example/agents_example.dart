// ignore_for_file: avoid_print, unreachable_from_main
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Agents API (Beta).
///
/// This example shows how to:
/// - Create a new agent with instructions and tools
/// - List all agents with pagination
/// - Retrieve an agent by ID
/// - Update an agent's configuration
/// - Chat with an agent
/// - Stream agent responses
/// - Delete an agent
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  // Initialize client
  final client = MistralClient();

  try {
    // Example: Create a new agent
    await createAgentExample(client);

    // Example: List all agents
    await listAgentsExample(client);

    // Example: Chat with an agent
    await chatWithAgentExample(client);

    // Example: Stream agent responses
    await streamAgentResponseExample(client);
  } finally {
    client.close();
  }
}

/// Creates a new agent with custom instructions and tools.
Future<Agent> createAgentExample(MistralClient client) async {
  print('=== Creating Agent ===\n');

  const request = CreateAgentRequest(
    name: 'Research Assistant',
    description: 'An agent that helps with research tasks',
    model: 'mistral-large-latest',
    instructions: r'''
You are a helpful research assistant. Your role is to:
1. Help users find and synthesize information
2. Provide accurate, well-sourced answers
3. Ask clarifying questions when needed
4. Present information in a clear, structured format

Always cite your sources when using web search results.
''',
    tools: [Tool.webSearch()],
    metadata: {'team': 'research', 'version': '1.0'},
  );

  final agent = await client.agents.create(request: request);

  print('Created agent:');
  print('  ID: ${agent.id}');
  print('  Name: ${agent.name}');
  print('  Model: ${agent.model}');
  print('  Description: ${agent.description}');
  print('  Version: ${agent.version}');
  print('');

  return agent;
}

/// Lists all agents with pagination.
Future<void> listAgentsExample(MistralClient client) async {
  print('=== Listing Agents ===\n');

  // Get first page
  final page1 = await client.agents.list(page: 0, pageSize: 10);

  print('Found ${page1.total ?? page1.length} agents');
  print('Page 1 (${page1.length} agents):');

  for (final agent in page1.data) {
    print('  - ${agent.name} (${agent.id})');
    print('    Model: ${agent.model}');
    if (agent.description != null) {
      print('    Description: ${agent.description}');
    }
  }

  // Check if there are more pages
  if (page1.hasMore ?? false) {
    print('\nMore agents available...');
  }

  print('');
}

/// Retrieves and updates an agent.
Future<void> retrieveAndUpdateAgentExample(
  MistralClient client,
  String agentId,
) async {
  print('=== Retrieve and Update Agent ===\n');

  // Retrieve the agent
  final agent = await client.agents.retrieve(agentId: agentId);
  print('Retrieved agent: ${agent.name}');
  print('Current model: ${agent.model}');
  print('Current version: ${agent.version}');

  // Update the agent
  const updateRequest = UpdateAgentRequest(
    name: 'Research Assistant Pro',
    description: 'An enhanced research assistant',
    tools: [Tool.webSearch(), Tool.codeInterpreter()],
  );

  final updated = await client.agents.update(
    agentId: agentId,
    request: updateRequest,
  );

  print('\nUpdated agent:');
  print('  Name: ${updated.name}');
  print('  Description: ${updated.description}');
  print('  Version: ${updated.version}');
  print('');
}

/// Chats with an agent using the completion API.
Future<void> chatWithAgentExample(MistralClient client) async {
  print('=== Chat with Agent ===\n');

  // Note: Replace with an actual agent ID
  const agentId = 'your-agent-id';

  final request = AgentCompletionRequest(
    agentId: agentId,
    messages: [
      ChatMessage.user(
        'What are the latest developments in quantum computing?',
      ),
    ],
    maxTokens: 1024,
    temperature: 0.7,
  );

  print('Sending message to agent...');

  try {
    final response = await client.agents.complete(request: request);

    print('Agent response:');
    print('  Model: ${response.model}');
    print('  Content: ${response.text}');

    if (response.usage != null) {
      print('\nUsage:');
      print('  Prompt tokens: ${response.usage!.promptTokens}');
      print('  Completion tokens: ${response.usage!.completionTokens}');
      print('  Total tokens: ${response.usage!.totalTokens}');
    }
  } on ApiException catch (e) {
    print('API error: ${e.message}');
    print('(Make sure to use a valid agent ID)');
  }

  print('');
}

/// Streams agent responses for real-time output.
Future<void> streamAgentResponseExample(MistralClient client) async {
  print('=== Stream Agent Response ===\n');

  // Note: Replace with an actual agent ID
  const agentId = 'your-agent-id';

  final request = AgentCompletionRequest(
    agentId: agentId,
    messages: [
      ChatMessage.user('Write a haiku about artificial intelligence.'),
    ],
    maxTokens: 256,
  );

  print('Streaming response from agent:');

  try {
    final stream = client.agents.completeStream(request: request);

    await for (final event in stream) {
      if (event.choices.isNotEmpty) {
        final delta = event.choices.first.delta;
        if (delta.content != null) {
          // Print content without newline to show streaming
          stdout.write(delta.content);
        }
      }
    }
    print('\n');
  } on ApiException catch (e) {
    print('API error: ${e.message}');
    print('(Make sure to use a valid agent ID)');
  }
}

/// Demonstrates agent versioning.
Future<void> agentVersioningExample(
  MistralClient client,
  String agentId,
) async {
  print('=== Agent Versioning ===\n');

  // Retrieve a specific version of an agent
  final v1 = await client.agents.retrieve(agentId: agentId, version: 1);
  print('Version 1: ${v1.name}');

  // Get the latest version
  final latest = await client.agents.retrieve(agentId: agentId);
  print('Latest version (${latest.version}): ${latest.name}');

  // Update to a specific version
  final reverted = await client.agents.updateVersion(
    agentId: agentId,
    version: 1,
  );
  print('Reverted to version 1: ${reverted.name}');

  print('');
}

/// Deletes an agent.
Future<void> deleteAgentExample(MistralClient client, String agentId) async {
  print('=== Delete Agent ===\n');

  await client.agents.delete(agentId: agentId);
  print('Agent $agentId deleted successfully');

  print('');
}
