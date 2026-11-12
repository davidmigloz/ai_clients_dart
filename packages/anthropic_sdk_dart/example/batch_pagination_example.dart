// ignore_for_file: avoid_print
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists recent Message Batches using lazy pagination.
///
/// Set ANTHROPIC_API_KEY or ANTHROPIC_AUTH_TOKEN. Optionally set
/// ANTHROPIC_WORKSPACE_ID and comma-separated ANTHROPIC_BETAS.
/// Pass an after_id to resume a listing.
Future<void> main(List<String> args) async {
  if (args.contains('--help')) {
    print('Usage: dart run example/batch_pagination_example.dart [after_id]');
    return;
  }

  final client = AnthropicClient.fromEnvironment();
  final workspaceId = Platform.environment['ANTHROPIC_WORKSPACE_ID'];
  final betas = [
    for (final flag in (Platform.environment['ANTHROPIC_BETAS'] ?? '').split(
      ',',
    ))
      if (flag.trim().isNotEmpty) flag.trim(),
  ];

  try {
    final history = CursorPagination<MessageBatchListResponse, MessageBatch>(
      initialCursor: args.firstOrNull,
      fetchPage: (afterId, abortTrigger) => client.messages.batches.list(
        afterId: afterId,
        limit: 10,
        workspaceId: workspaceId,
        betas: betas,
        abortTrigger: abortTrigger,
      ),
      nextCursor: (page) {
        if (!page.hasMore) return null;
        return page.lastId ??
            (throw const FormatException(
              'Continuing batch page needs last_id',
            ));
      },
      selectItems: (page) => page.data,
    );

    // Use history.pages() to work with complete responses and their cursors.
    await for (final batch in history.items().take(20)) {
      print('${batch.id}: ${batch.processingStatus}');
    }
  } finally {
    client.close();
  }
}
