// ignore_for_file: avoid_print, unreachable_from_main

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';

/// Example demonstrating the ChatKit API for building chat interfaces.
///
/// The ChatKit API (Beta) provides:
/// - Session management with client secrets for frontend authentication
/// - Thread management for conversation histories
/// - Thread items for messages and other content
///
/// **Note**: ChatKit requires a workflow ID from the OpenAI dashboard.
/// Sessions provide ephemeral access tokens for secure client-side usage.
///
/// To run this example, set the following environment variables:
/// ```bash
/// export OPENAI_API_KEY=your-api-key
/// export OPENAI_CHATKIT_WORKFLOW_ID=your-workflow-id  # Required for sessions
/// export OPENAI_CHATKIT_THREAD_ID=your-thread-id      # Optional for thread tests
/// dart run example/chatkit_example.dart
/// ```
Future<void> main() async {
  // Create client from environment variables
  final client = OpenAIClient.fromEnvironment();

  try {
    await listThreadsExample(client);
    // Uncomment if you have a workflow ID configured
    // await sessionExample(client);
  } finally {
    client.close();
  }
}

/// Example: List ChatKit threads.
Future<void> listThreadsExample(OpenAIClient client) async {
  print('=== List ChatKit Threads Example ===\n');

  // List all threads
  final threads = await client.chatkit.threads.list();

  print('Total threads found: ${threads.data.length}');
  print('Has more: ${threads.hasMore}');
  print('');

  // Display each thread
  for (final thread in threads.data) {
    print('Thread: ${thread.id}');
    print('  Title: ${thread.title ?? "(untitled)"}');
    print('  User: ${thread.user}');
    print('  Status: ${thread.status.type}');
    print('  Created: ${thread.createdAtDateTime}');

    // Show status details
    if (thread.status.isActive) {
      print('  State: Active');
    } else if (thread.status.isLocked) {
      print('  State: Locked');
    } else if (thread.status.isClosed) {
      print('  State: Closed');
    }
    print('');
  }

  // Example with pagination
  if (threads.hasMore && threads.lastId != null) {
    print('Fetching next page...');
    final nextPage = await client.chatkit.threads.list(
      limit: 5,
      after: threads.lastId,
    );
    print('Next page has ${nextPage.data.length} threads');
  }
  print('');

  // If there are threads, show items from the first one
  if (threads.data.isNotEmpty) {
    final firstThread = threads.data.first;
    await listThreadItemsExample(client, firstThread.id);
  }
}

/// Example: List items in a ChatKit thread.
Future<void> listThreadItemsExample(
  OpenAIClient client,
  String threadId,
) async {
  print('=== Thread Items Example ===\n');

  // List items in the thread
  final items = await client.chatkit.threads.items.list(
    threadId,
    limit: 20,
    order: 'asc',
  );

  print('Thread $threadId has ${items.data.length} items');
  print('Has more: ${items.hasMore}');
  print('');

  // Display each item
  for (final item in items.data) {
    print('Item: ${item.id}');
    print('  Type: ${item.type}');

    // Use type helper methods
    if (item.isUserMessage) {
      print('  Category: User message');
    } else if (item.isAssistantMessage) {
      print('  Category: Assistant message');
    } else if (item.isWidgetMessage) {
      print('  Category: Widget message');
    } else if (item.isClientToolCall) {
      print('  Category: Client tool call');
    } else if (item.isTask) {
      print('  Category: Task');
    } else if (item.isTaskGroup) {
      print('  Category: Task group');
    }
    print('');
  }
}

/// Example: Create and manage a ChatKit session.
///
/// **Note**: Requires OPENAI_CHATKIT_WORKFLOW_ID environment variable.
Future<void> sessionExample(OpenAIClient client) async {
  print('=== ChatKit Session Example ===\n');

  // Get workflow ID from environment
  final workflowId = Platform.environment['OPENAI_CHATKIT_WORKFLOW_ID'] ?? '';

  if (workflowId.isEmpty) {
    print('OPENAI_CHATKIT_WORKFLOW_ID not set. Skipping session example.');
    print('');
    return;
  }

  // Create a session with minimal configuration
  final userId = 'example-user-${DateTime.now().millisecondsSinceEpoch}';
  final session = await client.chatkit.sessions.create(
    CreateChatSessionRequest(
      workflow: WorkflowParam(id: workflowId),
      user: userId,
    ),
  );

  print('Created session: ${session.id}');
  print('Status: ${session.status}');
  print('User: ${session.user}');
  print('Workflow: ${session.workflow.id}');
  print('Expires at: ${session.expiresAtDateTime}');
  print('');

  // The client secret is used for frontend authentication
  print(
    'Client secret (for frontend): ${session.clientSecret.substring(0, 20)}...',
  );
  print('');

  // Check session state using helper methods
  print('Session state:');
  print('  Is active: ${session.isActive}');
  print('  Is expired: ${session.isExpired}');
  print('  Is cancelled: ${session.isCancelled}');
  print('');

  // Show rate limits
  print('Rate limits:');
  print('  Max requests/minute: ${session.maxRequestsPer1Minute}');
  print('');

  // Show chatkit configuration
  print('ChatKit configuration:');
  print(
    '  Auto titling: ${session.chatkitConfiguration.automaticThreadTitling.enabled}',
  );
  print('  File upload: ${session.chatkitConfiguration.fileUpload.enabled}');
  print('  History: ${session.chatkitConfiguration.history.enabled}');
  print('');

  // Cancel the session when done
  final cancelled = await client.chatkit.sessions.cancel(session.id);
  print('Cancelled session: ${cancelled.id}');
  print('New status: ${cancelled.status}');
  print('Is cancelled: ${cancelled.isCancelled}');
  print('');
}

/// Example: Create a session with full configuration options.
Future<void> fullSessionExample(OpenAIClient client) async {
  print('=== Full Session Configuration Example ===\n');

  // Get workflow ID from environment
  final workflowId = Platform.environment['OPENAI_CHATKIT_WORKFLOW_ID'] ?? '';

  if (workflowId.isEmpty) {
    print('OPENAI_CHATKIT_WORKFLOW_ID not set. Skipping example.');
    print('');
    return;
  }

  // Create a session with all configuration options
  final session = await client.chatkit.sessions.create(
    CreateChatSessionRequest(
      workflow: WorkflowParam(
        id: workflowId,
        // Enable tracing for debugging
        tracing: const TracingParam(enabled: true),
      ),
      user: 'full-example-user',
      // Session expires in 10 minutes
      expiresAfter: 600,
      // Custom rate limits
      rateLimits: const RateLimitsParam(maxRequestsPer1Minute: 30),
      // ChatKit-specific features
      chatkitConfiguration: const ChatkitConfigurationParam(
        // Auto-generate thread titles
        automaticThreadTitling: AutomaticThreadTitlingParam(enabled: true),
        // Allow file uploads
        fileUpload: FileUploadParam(
          enabled: true,
          maxFileSize: 5, // 5MB
          maxFiles: 10,
        ),
        // Show conversation history
        history: HistoryParam(enabled: true, recentThreads: 20),
      ),
    ),
  );

  print('Created fully configured session: ${session.id}');
  print('');

  try {
    // Show all configuration details
    print('Configuration applied:');
    print('  Workflow: ${session.workflow.id}');
    print('  Rate limit: ${session.rateLimits.maxRequestsPer1Minute} req/min');
    print(
      '  Auto titling: ${session.chatkitConfiguration.automaticThreadTitling.enabled}',
    );
    print(
      '  File upload enabled: ${session.chatkitConfiguration.fileUpload.enabled}',
    );
    print(
      '  Max file size: ${session.chatkitConfiguration.fileUpload.maxFileSize}MB',
    );
    print('  Max files: ${session.chatkitConfiguration.fileUpload.maxFiles}');
    print('  History enabled: ${session.chatkitConfiguration.history.enabled}');
    print(
      '  Recent threads: ${session.chatkitConfiguration.history.recentThreads}',
    );
    print('');
  } finally {
    // Always clean up
    await client.chatkit.sessions.cancel(session.id);
    print('Session cleaned up');
    print('');
  }
}
