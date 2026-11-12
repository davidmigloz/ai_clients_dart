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
///
/// Set ANTHROPIC_API_KEY and pass the ID of an existing multiagent session.
/// Pass --archive to archive an idle child outside a workflow run.
Future<void> main(List<String> arguments) async {
  if (arguments.isEmpty ||
      arguments.length > 2 ||
      (arguments.length == 2 && arguments.last != '--archive')) {
    throw ArgumentError(
      'Usage: session_threads_example.dart session-id [--archive]',
    );
  }
  final sessionId = arguments.first;
  final client = AnthropicClient.fromEnvironment();

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
    final children = threads.data.where(
      (thread) => thread.parentThreadId != null,
    );
    final firstThread = children.firstOrNull ?? threads.data.first;
    print('\n=== Retrieve ${firstThread.id} ===');
    final thread = await client.sessions
        .threads(sessionId)
        .retrieve(firstThread.id);
    final agentLabel = switch (thread.agent) {
      SessionThreadAgent(:final name) => name,
      Advisor(:final model) => 'advisor:$model',
      _ => 'unknown',
    };
    print(
      'Thread ${thread.id} (agent: $agentLabel, '
      'status: ${thread.status.value})',
    );

    // =========================================================================
    // 3. Stream live thread events
    // =========================================================================
    print('\n=== Stream events for ${thread.id} (up to 5s) ===');
    final abort = Completer<void>();
    final timer = Timer(const Duration(seconds: 5), abort.complete);
    try {
      await for (final event
          in client.sessions
              .threads(sessionId)
              .events(thread.id)
              .stream(abortTrigger: abort.future)) {
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
      }
    } on AbortedException {
      print('Stopped reading thread events.');
    } finally {
      timer.cancel();
    }

    if (arguments.length == 2) {
      final threadResource = client.sessions.threads(sessionId);
      final latest = await threadResource.retrieve(thread.id);
      if (latest.parentThreadId != null &&
          latest.status == SessionStatus.idle) {
        final archived = await threadResource.archive(thread.id);
        print('Archived at: ${archived.archivedAt}');
      } else {
        print('Archiving requires an idle child outside a workflow run.');
      }
    }
  } finally {
    client.close();
  }
}
