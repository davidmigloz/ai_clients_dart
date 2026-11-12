import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists OIDC issuers registered with Claude Workload Identity Federation.
///
/// Set ANTHROPIC_AUTH_TOKEN to an OAuth access token with org:admin.
Future<void> main() async {
  final token = Platform.environment['ANTHROPIC_AUTH_TOKEN'];
  if (token == null || token.isEmpty) {
    stderr.writeln('Set ANTHROPIC_AUTH_TOKEN to an org:admin OAuth token.');
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withAuthToken(token);
  try {
    final issuers = client.organization.federation.issuers;
    final first = await issuers.list(limit: 10, includeArchived: false);
    stdout.writeln('Fetched ${first.data.length} issuers.');
    if (first.nextPage case final cursor?) {
      final next = await issuers.list(
        page: cursor,
        limit: 10,
        includeArchived: false,
      );
      stdout.writeln('Fetched ${next.data.length} more issuers.');
    }
  } finally {
    client.close();
  }
}
