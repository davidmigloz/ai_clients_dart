// ignore_for_file: avoid_print
import 'dart:async';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Dreams API example (Beta, research preview).
///
/// A dream is an asynchronous memory-consolidation job that reads a memory
/// store plus a set of session transcripts and writes consolidated memories
/// into a new output memory store. This example demonstrates:
///
/// 1. Create a dream from a memory store and session transcripts
/// 2. Poll until the dream finishes
/// 3. List dreams filtered by status
/// 4. Archive a finished dream
///
/// Note: the Dreams API is in research preview — request and response shapes
/// are volatile and may change without the deprecation period that applies
/// to generally-available endpoints. This is a beta feature and requires the
/// `anthropic-beta: dreaming-2026-04-21` header (sent automatically by the
/// SDK).
/// Request research-preview access on the Claude API and set
/// ANTHROPIC_API_KEY. Pass an existing memory store ID followed by session IDs:
/// `dart run example/dreams_example.dart memstore_... sesn_...`.
Future<void> main(List<String> args) async {
  if (args.length < 2 || args.length > 101) {
    print(
      'Usage: dart run example/dreams_example.dart STORE_ID SESSION_ID [...]',
    );
    return;
  }
  final client = AnthropicClient.fromEnvironment();

  try {
    // 1. Create a dream that reads an existing memory store plus a couple of
    //    session transcripts, and writes consolidated memories into a new
    //    output memory store.
    print('=== Create Dream ===');
    var dream = await client.dreams.create(
      CreateDreamRequest(
        inputs: [
          DreamMemoryStoreInput(memoryStoreId: args.first),
          DreamSessionsInput(sessionIds: args.sublist(1)),
        ],
        instructions: 'Consolidate notes about user preferences.',
        model: const DreamModelParamsId(id: 'claude-sonnet-5'),
        // Defaults to creating a new output memory store; pass
        // `OutputBehavior.updateExisting(memoryStoreId)` to consolidate an
        // existing store in place instead.
        outputBehavior: const OutputBehaviorCreateNew(),
      ),
    );
    print(
      'Created dream: ${dream.id} (status: ${dream.status}, '
      'outputBehavior: ${dream.outputBehavior.runtimeType})',
    );

    // 2. Poll until the dream finishes.
    print('\n=== Poll Dream ===');
    while (dream.status == DreamStatus.pending ||
        dream.status == DreamStatus.running) {
      await Future<void>.delayed(const Duration(seconds: 2));
      dream = await client.dreams.retrieve(dream.id);
      print('  status: ${dream.status}');
    }

    switch (dream.status) {
      case DreamStatus.completed:
        for (final output in dream.outputs) {
          if (output is DreamMemoryStoreOutput) {
            print('Consolidated memories written to: ${output.memoryStoreId}');
          }
        }
      case DreamStatus.failed:
        print('Dream failed: ${dream.error?.message}');
      case DreamStatus.canceled:
      case DreamStatus.pending:
      case DreamStatus.running:
      case DreamStatus.unknown:
        print('Dream ended with status: ${dream.status}');
    }
    print(
      'Usage: ${dream.usage.inputTokens} input, '
      '${dream.usage.outputTokens} output tokens',
    );

    // 3. List dreams, filtering by status.
    print('\n=== List Dreams ===');
    final dreamList = await client.dreams.list(
      statuses: [DreamStatus.completed, DreamStatus.failed],
      limit: 10,
    );
    for (final d in dreamList.data) {
      print('  ${d.id}: ${d.status}');
    }

    // 4. Archive the finished dream (or cancel it, if it were still running).
    print('\n=== Archive Dream ===');
    final archived = await client.dreams.archive(dream.id);
    print('Archived at: ${archived.archivedAt}');
  } finally {
    client.close();
  }
}
