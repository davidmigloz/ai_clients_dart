import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists Activity Feed records without printing record contents.
///
/// Set ANTHROPIC_COMPLIANCE_ACCESS_KEY with Activity Feed read access, or
/// use an ANTHROPIC_ADMIN_KEY created while Compliance was enabled.
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
