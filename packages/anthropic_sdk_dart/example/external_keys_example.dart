import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists registered encryption keys without displaying their coordinates.
Future<void> main() async {
  final adminKey = Platform.environment['ANTHROPIC_ADMIN_KEY'];
  if (adminKey == null || adminKey.isEmpty) {
    stderr.writeln('Set ANTHROPIC_ADMIN_KEY.');
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withApiKey(adminKey);
  try {
    final keys = client.organization.externalKeys;
    final page = await keys.list(limit: 10);
    for (final key in page.data) {
      stdout.writeln('${key.providerConfig.type}: ${key.attachment.type}');
    }
    final cursor = page.nextPage;
    if (cursor != null) {
      final next = await keys.list(page: cursor, limit: 10);
      stdout.writeln('Keys on the next page: ${next.data.length}');
    }
  } finally {
    client.close();
  }
}
