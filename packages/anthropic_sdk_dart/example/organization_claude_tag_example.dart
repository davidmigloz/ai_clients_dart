import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists effective Claude Tag settings and their source on Slack channels.
///
/// Set ANTHROPIC_ADMIN_API_KEY to a Claude Enterprise key with `read:claude_tag`.
/// Pass Slack's own workspace ID, beginning with `T`, or a Grid ID beginning with `E`.
Future<void> main(List<String> args) async {
  final key = Platform.environment['ANTHROPIC_ADMIN_API_KEY'];
  if (key == null || key.isEmpty || args.length != 1) {
    stderr.writeln(
      'Set ANTHROPIC_ADMIN_API_KEY and pass a Slack workspace ID.',
    );
    exitCode = 64;
    return;
  }
  final client = AnthropicClient.withApiKey(
    key,
    baseUrl: Platform.environment['ANTHROPIC_BASE_URL'],
  );
  try {
    final channels = client.organization.claudeTag.slackChannels;
    String? cursor;
    do {
      final page = await channels.list(
        slackWorkspaceId: args.single,
        includeInherited: true,
        page: cursor,
      );
      for (final channel in page.data) {
        stdout.writeln(
          '${channel.id}: enabled=${channel.settings.enabled} '
          '(${channel.sources.enabled?.type ?? 'unset'})',
        );
      }
      cursor = page.hasMore ? page.nextPage : null;
    } while (cursor != null);
  } finally {
    client.close();
  }
}
