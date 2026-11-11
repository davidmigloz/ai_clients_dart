import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Reads organization and workspace metadata with a Claude Console Admin key.
///
/// Set ANTHROPIC_ADMIN_KEY before running.
Future<void> main() async {
  final adminKey = Platform.environment['ANTHROPIC_ADMIN_KEY'];
  if (adminKey == null || adminKey.isEmpty) {
    stderr.writeln('Set ANTHROPIC_ADMIN_KEY.');
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withApiKey(adminKey);
  try {
    final organization = await client.organization.retrieve();
    stdout.writeln('Organization: ${organization.name}');

    final workspaces = client.organization.workspaces;
    final first = await workspaces.list(limit: 10, includeDefault: true);
    stdout.writeln('Workspaces on the first page: ${first.data.length}');
    final cursor = first.lastId;
    if (first.hasMore && cursor != null) {
      final next = await workspaces.list(
        limit: 10,
        includeDefault: true,
        afterId: cursor,
      );
      stdout.writeln('Workspaces on the next page: ${next.data.length}');
    }
  } finally {
    client.close();
  }
}
