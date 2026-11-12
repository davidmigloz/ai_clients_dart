import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists enabled and disabled organization webhook endpoints.
///
/// Set ANTHROPIC_ADMIN_API_KEY to a key for an organization with webhook access.
Future<void> main() async {
  final key = Platform.environment['ANTHROPIC_ADMIN_API_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln('Set ANTHROPIC_ADMIN_API_KEY.');
    exitCode = 64;
    return;
  }
  final client = AnthropicClient.withApiKey(key);
  try {
    String? afterId;
    do {
      final page = await client.organization.webhooks.list(afterId: afterId);
      for (final endpoint in page.data) {
        stdout.writeln(
          '${endpoint.id} ${endpoint.state} ${endpoint.enabledEvents}',
        );
      }
      afterId = page.hasMore ? page.lastId : null;
    } while (afterId != null);
  } finally {
    client.close();
  }
}
