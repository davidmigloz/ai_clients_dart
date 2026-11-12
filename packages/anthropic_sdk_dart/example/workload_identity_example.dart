import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Calls Messages with a workload identity configured in Claude Console.
///
/// Set ANTHROPIC_FEDERATION_RULE_ID, ANTHROPIC_ORGANIZATION_ID and
/// ANTHROPIC_SERVICE_ACCOUNT_ID. Set ANTHROPIC_WORKSPACE_ID when the rule
/// covers multiple workspaces. Provide a rotating identity token file via
/// ANTHROPIC_IDENTITY_TOKEN_FILE or supply ANTHROPIC_IDENTITY_TOKEN.
Future<void> main() async {
  final client = AnthropicClient.withWorkloadIdentity(
    identityTokenProvider: () async {
      final file = Platform.environment['ANTHROPIC_IDENTITY_TOKEN_FILE'];
      if (file != null && file.isNotEmpty) {
        return (await File(file).readAsString()).trim();
      }
      return _environment('ANTHROPIC_IDENTITY_TOKEN');
    },
    federationRuleId: _environment('ANTHROPIC_FEDERATION_RULE_ID'),
    organizationId: _environment('ANTHROPIC_ORGANIZATION_ID'),
    serviceAccountId: _environment('ANTHROPIC_SERVICE_ACCOUNT_ID'),
    workspaceId: Platform.environment['ANTHROPIC_WORKSPACE_ID'],
  );
  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 128,
        messages: [InputMessage.user('Explain workload identity briefly.')],
      ),
    );
    stdout.writeln(response.text);
  } finally {
    client.close();
  }
}

String _environment(String name) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) throw StateError('Set $name.');
  return value;
}
