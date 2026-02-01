// ignore_for_file: avoid_print, deprecated_member_use_from_same_package
/// Example demonstrating the Assistants API with OpenAI.
///
/// This example shows how to create assistants, threads, and runs.
/// Run with: dart run example/assistants_example.dart
///
/// Note: The Assistants API is deprecated. Use the Responses API instead.
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart'
    hide CodeInterpreterTool, FileSearchTool, FunctionTool;
import 'package:openai_dart/openai_dart_assistants.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  String? assistantId;
  String? threadId;

  try {
    // Create an assistant
    print('=== Creating Assistant ===\n');

    final assistant = await client.beta.assistants.create(
      const CreateAssistantRequest(
        model: 'gpt-4.1',
        name: 'Math Tutor',
        instructions:
            'You are a helpful math tutor. '
            'Answer questions clearly and concisely. '
            'Show your work when solving problems.',
        tools: [CodeInterpreterTool()],
        metadata: {'type': 'tutor', 'subject': 'math'},
      ),
    );

    assistantId = assistant.id;
    print('Created assistant: ${assistant.name} (${assistant.id})');
    print('Model: ${assistant.model}');
    print(
      'Tools: ${assistant.tools.map((t) => switch (t) {
        CodeInterpreterTool() => 'code_interpreter',
        FileSearchTool() => 'file_search',
        FunctionTool() => 'function',
      }).join(", ")}\n',
    );

    // Create a thread
    print('=== Creating Thread ===\n');

    final thread = await client.beta.threads.create(
      CreateThreadRequest(
        messages: [ThreadMessage.user('Hello! I need help with math.')],
        metadata: const {'topic': 'math help'},
      ),
    );

    threadId = thread.id;
    print('Created thread: ${thread.id}\n');

    // Add a message to the thread
    print('=== Adding Message ===\n');

    await client.beta.threads.messages.create(
      thread.id,
      CreateMessageRequest.user('What is 25 * 4?'),
    );

    print('Added user message\n');

    // Create and run the assistant
    print('=== Running Assistant ===\n');

    var run = await client.beta.threads.runs.create(
      thread.id,
      CreateRunRequest(assistantId: assistant.id),
    );

    print('Created run: ${run.id}');
    print('Status: ${run.status}\n');

    // Poll until complete
    print('Waiting for completion...');
    var attempts = 0;
    while (!_isTerminalStatus(run.status) && attempts < 30) {
      await Future<void>.delayed(const Duration(seconds: 1));
      run = await client.beta.threads.runs.retrieve(thread.id, run.id);
      stdout.write('.');
      attempts++;
    }
    print('\n');

    print('Final status: ${run.status}');
    if (run.usage != null) {
      print('Tokens used: ${run.usage!.totalTokens}\n');
    }

    // Get messages
    print('=== Conversation ===\n');

    final messages = await client.beta.threads.messages.list(
      thread.id,
      order: 'asc',
    );

    for (final message in messages.data) {
      final role = message.role.toUpperCase();
      final text = message.text;
      print('$role: $text\n');
    }

    // Continue the conversation
    print('=== Continuing Conversation ===\n');

    await client.beta.threads.messages.create(
      thread.id,
      CreateMessageRequest.user('Now divide that result by 5.'),
    );

    run = await client.beta.threads.runs.create(
      thread.id,
      CreateRunRequest(assistantId: assistant.id),
    );

    print('Waiting for completion...');
    attempts = 0;
    while (!_isTerminalStatus(run.status) && attempts < 30) {
      await Future<void>.delayed(const Duration(seconds: 1));
      run = await client.beta.threads.runs.retrieve(thread.id, run.id);
      stdout.write('.');
      attempts++;
    }
    print('\n');

    // Get latest messages
    final updatedMessages = await client.beta.threads.messages.list(
      thread.id,
      order: 'asc',
    );

    print('Latest response:');
    final lastMessage = updatedMessages.data.last;
    print('ASSISTANT: ${lastMessage.text}\n');

    // List assistants
    print('=== List Assistants ===\n');

    final assistants = await client.beta.assistants.list(limit: 5);
    print('Found ${assistants.data.length} assistant(s):');
    for (final a in assistants.data) {
      print('  - ${a.name ?? "Unnamed"} (${a.id})');
    }
    print('');

    // Update assistant
    print('=== Updating Assistant ===\n');

    final updated = await client.beta.assistants.update(
      assistant.id,
      const ModifyAssistantRequest(
        name: 'Advanced Math Tutor',
        instructions:
            'You are an advanced math tutor. '
            'Provide detailed explanations with examples.',
      ),
    );

    print('Updated assistant name: ${updated.name}\n');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    // Clean up
    print('=== Cleanup ===\n');

    if (threadId != null) {
      await client.beta.threads.delete(threadId);
      print('Deleted thread: $threadId');
    }

    if (assistantId != null) {
      await client.beta.assistants.delete(assistantId);
      print('Deleted assistant: $assistantId');
    }

    client.close();
    print('\nDone!');
  }
}

/// Helper to check if a run status is terminal.
bool _isTerminalStatus(RunStatus status) {
  return status == RunStatus.completed ||
      status == RunStatus.failed ||
      status == RunStatus.cancelled ||
      status == RunStatus.expired ||
      status == RunStatus.incomplete;
}
