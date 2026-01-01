// ignore_for_file: avoid_print, unreachable_from_main
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating the Conversations API (Beta).
///
/// This example shows how to:
/// - Start a new conversation with a model or agent
/// - Continue a conversation with follow-up messages
/// - Retrieve conversation history
/// - Restart a conversation from a specific point
/// - Handle function calls within conversations
///
/// Before running:
/// 1. Get your API key from https://console.mistral.ai/
/// 2. Set environment variable: export MISTRAL_API_KEY=your_api_key
void main() async {
  // Initialize client
  final client = MistralClient();

  try {
    // Example: Start and continue a conversation
    await basicConversationExample(client);

    // Example: Conversation with function calls
    await functionCallConversationExample(client);
  } finally {
    client.close();
  }
}

/// Starts a new conversation and sends follow-up messages.
Future<void> basicConversationExample(MistralClient client) async {
  print('=== Basic Conversation Example ===\n');

  // Start a new conversation
  final startRequest = StartConversationRequest.withMessage(
    model: 'mistral-large-latest',
    message: 'Hello! Can you explain what machine learning is in simple terms?',
    maxTokens: 500,
    temperature: 0.7,
  );

  print('Starting conversation...');
  final startResponse = await client.conversations.start(request: startRequest);

  print('Conversation ID: ${startResponse.conversationId}');
  print('Assistant: ${startResponse.text}\n');

  if (startResponse.usage != null) {
    print('Usage: ${startResponse.usage!.totalTokens} tokens\n');
  }

  // Continue the conversation with a follow-up
  print('Sending follow-up question...');
  final followUpResponse = await client.conversations.sendMessage(
    conversationId: startResponse.conversationId,
    message: 'Can you give me a real-world example of that?',
    maxTokens: 500,
  );

  print('Assistant: ${followUpResponse.text}\n');

  // Retrieve the full conversation history
  print('Retrieving conversation history...');
  final entries = await client.conversations.getEntries(
    conversationId: startResponse.conversationId,
  );

  print('Conversation has ${entries.length} entries:');
  print('  - User messages: ${entries.userMessages.length}');
  print('  - Assistant messages: ${entries.assistantMessages.length}');
  print('');
}

/// Demonstrates a conversation with function calling.
Future<void> functionCallConversationExample(MistralClient client) async {
  print('=== Function Call Conversation Example ===\n');

  // Start a conversation with tools enabled
  final startRequest = StartConversationRequest(
    model: 'mistral-large-latest',
    inputs: const [MessageInputEntry(content: 'What is the weather in Paris?')],
    tools: [
      Tool.function(
        name: 'get_weather',
        description: 'Get the current weather for a location',
        parameters: const {
          'type': 'object',
          'properties': {
            'location': {'type': 'string', 'description': 'The city name'},
          },
          'required': ['location'],
        },
      ),
    ],
    maxTokens: 500,
  );

  print('Starting conversation with tools...');

  try {
    final response = await client.conversations.start(request: startRequest);

    print('Conversation ID: ${response.conversationId}');

    // Check if the model made a function call
    final functionCalls = response.functionCalls;
    if (functionCalls.isNotEmpty) {
      print('Model wants to call functions:');
      for (final call in functionCalls) {
        print('  - ${call.name}(${call.arguments})');
      }

      // Provide the function result
      print('\nProviding function result...');
      final resultResponse = await client.conversations.sendFunctionResult(
        conversationId: response.conversationId,
        callId: functionCalls.first.callId ?? 'call-1',
        result: '{"temperature": 22, "condition": "sunny", "humidity": 45}',
      );

      print('Assistant: ${resultResponse.text}');
    } else {
      print('Assistant: ${response.text}');
    }
  } on ApiException catch (e) {
    print('API error: ${e.message}');
  }

  print('');
}

/// Lists all conversations.
Future<void> listConversationsExample(MistralClient client) async {
  print('=== List Conversations ===\n');

  final conversations = await client.conversations.list(page: 0, pageSize: 10);

  print('Found ${conversations.total ?? conversations.length} conversations');

  for (final conv in conversations.data) {
    print('  - ${conv.id}');
    print('    Model: ${conv.model ?? conv.agentId ?? "unknown"}');
    print('    Entries: ${conv.entryCount}');
  }

  print('');
}

/// Retrieves a specific conversation.
Future<void> retrieveConversationExample(
  MistralClient client,
  String conversationId,
) async {
  print('=== Retrieve Conversation ===\n');

  final conversation = await client.conversations.retrieve(
    conversationId: conversationId,
  );

  print('Conversation: ${conversation.id}');
  print('Model: ${conversation.model}');
  print('Created: ${conversation.createdAt}');
  print('Entries: ${conversation.entryCount}');

  print('');
}

/// Restarts a conversation from a specific entry.
Future<void> restartConversationExample(
  MistralClient client,
  String conversationId,
  String entryId,
) async {
  print('=== Restart Conversation ===\n');

  final response = await client.conversations.restart(
    conversationId: conversationId,
    request: RestartConversationRequest(
      entryId: entryId,
      temperature: 0.9, // Try with different temperature
    ),
  );

  print('New conversation ID: ${response.conversationId}');
  print('New response: ${response.text}');

  print('');
}

/// Uses an agent in a conversation.
Future<void> agentConversationExample(
  MistralClient client,
  String agentId,
) async {
  print('=== Agent Conversation ===\n');

  final startRequest = StartConversationRequest.withMessage(
    agentId: agentId,
    message: 'Help me write a Python function to sort a list.',
    maxTokens: 1000,
  );

  final response = await client.conversations.start(request: startRequest);

  print('Conversation with agent started');
  print('Agent response: ${response.text}');

  print('');
}

/// Demonstrates streaming responses (when available).
Future<void> streamingConversationExample(MistralClient client) async {
  print('=== Streaming Conversation ===\n');

  // Note: Streaming for conversations may require the append endpoint
  // with streaming support. This example shows the concept.

  const request = StartConversationRequest(
    model: 'mistral-large-latest',
    inputs: [
      MessageInputEntry(content: 'Tell me a short story about a robot.'),
    ],
    maxTokens: 500,
  );

  print('Starting conversation...');

  try {
    final response = await client.conversations.start(request: request);

    print('Response:');
    for (final output in response.outputs) {
      if (output is MessageOutputEntry) {
        stdout.write(output.content);
      }
    }
    print('\n');
  } on ApiException catch (e) {
    print('API error: ${e.message}');
  }
}

/// Deletes a conversation.
Future<void> deleteConversationExample(
  MistralClient client,
  String conversationId,
) async {
  print('=== Delete Conversation ===\n');

  await client.conversations.delete(conversationId: conversationId);
  print('Conversation $conversationId deleted');

  print('');
}
