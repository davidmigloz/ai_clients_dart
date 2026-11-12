import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists federation rules, optionally filtered by an issuer.
///
/// Set ANTHROPIC_AUTH_TOKEN to an OAuth token with org:admin.
/// Pass an fdis_ issuer ID to filter the list.
Future<void> main(List<String> args) async {
  final token = Platform.environment['ANTHROPIC_AUTH_TOKEN'];
  if (token == null || token.isEmpty) {
    stderr.writeln('Set ANTHROPIC_AUTH_TOKEN to an org:admin OAuth token.');
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withAuthToken(token);
  try {
    final rules = client.organization.federation.rules;
    final page = await rules.list(
      issuerId: args.isEmpty ? null : args.first,
      limit: 20,
      includeArchived: false,
    );
    stdout.writeln('Fetched ${page.data.length} federation rules.');
  } finally {
    client.close();
  }
}
