// ignore_for_file: avoid_print
import 'dart:async';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Session Threads example (Beta).
///
/// Sessions can be segmented into threads — useful for multi-agent setups
/// where a parent orchestrator agent spawns sub-agent threads. Each thread
/// carries its own status, usage, and stats independent of the parent
/// session.
///
/// This example demonstrates:
/// - Listing threads under a session
/// - Retrieving a single thread
/// - Streaming live thread events with sealed-variant dispatch
/// - Archiving a thread
///
/// Note: The Managed Agents API is a beta feature.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  // Replace with a real session id from `client.sessions.create(...)` or
  // `client.sessions.list()`.
  const sessionId = 'sesn_REPLACE_ME';

  try {
    // =========================================================================
    // 1. List threads under the session
    // =========================================================================
    print('=== List threads ===');
    final threads = await client.sessions.threads(sessionId).list(limit: 10);
    print('Found ${threads.data.length} threads.');
    for (final thread in threads.data) {
      print(
        '  ${thread.id}: status=${thread.status.value}, '
        'parent=${thread.parentThreadId ?? "(root)"}',
      );
    }
    if (threads.data.isEmpty) {
      print('No threads yet — create a session that spawns threads first.');
      return;
    }

    // =========================================================================
    // 2. Retrieve a single thread
    // =========================================================================
    final firstThread = threads.data.first;
    print('\n=== Retrieve ${firstThread.id} ===');
    final thread = await client.sessions
        .threads(sessionId)
        .retrieve(firstThread.id);
    print(
      'Thread ${thread.id} (agent: ${thread.agent.name}, '
      'status: ${thread.status.value})',
    );

    // =========================================================================
    // 3. Stream live thread events
    // =========================================================================
    print('\n=== Stream events for ${thread.id} (up to 5s) ===');
    final stream = client.sessions
        .threads(sessionId)
        .events(thread.id)
        .stream();

    final subscription = stream.listen((event) {
      switch (event) {
        case SessionThreadCreatedEvent():
          print('  thread created: ${event.sessionThreadId}');
        case SessionThreadStatusRunningEvent():
          print('  thread running');
        case SessionThreadStatusIdleEvent():
          print('  thread idle (${event.stopReason})');
        case SessionThreadStatusRescheduledEvent():
          print('  thread rescheduled');
        case SessionThreadStatusTerminatedEvent():
          print('  thread terminated');
        case AgentThreadMessageReceivedEvent():
          print(
            '  message from ${event.fromAgentName ?? event.fromSessionThreadId}',
          );
        case AgentThreadMessageSentEvent():
          print(
            '  message sent to ${event.toAgentName ?? event.toSessionThreadId}',
          );
        case AgentMessageEvent():
          print('  agent message in thread');
        case UnknownSessionEvent():
          print('  (unrecognized event type)');
        default:
          // Other SessionEvent variants are still possible inside a thread.
          break;
      }
    });

    await Future<void>.delayed(const Duration(seconds: 5));
    await subscription.cancel();

    // =========================================================================
    // 4. Archive the thread
    // =========================================================================
    print('\n=== Archive ${thread.id} ===');
    final archived = await client.sessions
        .threads(sessionId)
        .archive(thread.id);
    print('Archived at: ${archived.archivedAt}');
  } finally {
    client.close();
  }
}
