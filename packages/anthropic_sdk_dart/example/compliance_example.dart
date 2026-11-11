// Query the Activity Feed with a scoped key. This example makes a live API call.
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

Future<void> main() async {
  final key =
      Platform.environment['ANTHROPIC_COMPLIANCE_ACCESS_KEY'] ??
      Platform.environment['ANTHROPIC_ADMIN_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln(
      'Set ANTHROPIC_COMPLIANCE_ACCESS_KEY or a scoped ANTHROPIC_ADMIN_KEY.',
    );
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withApiKey(key);
  try {
    final page = await client.compliance.listActivities(limit: 10);
    // Avoid printing sensitive activity records.
    stdout
      ..writeln('Fetched ${page.data.length} activities.')
      ..writeln('More results: ${page.hasMore}');
  } finally {
    client.close();
  }
}
