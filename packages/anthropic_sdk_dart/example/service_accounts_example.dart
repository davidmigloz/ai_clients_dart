import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists service accounts and, optionally, a service account's memberships.
///
/// Set ANTHROPIC_AUTH_TOKEN to an OAuth token with org:admin.
/// Pass an svac_ ID as the first argument to list its workspace memberships.
Future<void> main(List<String> args) async {
  final token = Platform.environment['ANTHROPIC_AUTH_TOKEN'];
  if (token == null || token.isEmpty) {
    stderr.writeln('Set ANTHROPIC_AUTH_TOKEN to an org:admin OAuth token.');
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withAuthToken(token);
  try {
    final accounts = client.organization.serviceAccounts;
    if (args.isEmpty) {
      final page = await accounts.list(limit: 20);
      stdout.writeln('Fetched ${page.data.length} service accounts.');
    } else {
      final page = await accounts.workspaces.list(args.first, limit: 20);
      stdout.writeln('Fetched ${page.data.length} workspace memberships.');
    }
  } finally {
    client.close();
  }
}
