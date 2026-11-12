import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Inventories organization-owned Claude Enterprise plugins.
///
/// Set ANTHROPIC_ADMIN_API_KEY to a key with `read:plugins`. To validate a
/// marketplace as well, pass its public GitHub repository URL.
Future<void> main(List<String> args) async {
  final key = Platform.environment['ANTHROPIC_ADMIN_API_KEY'];
  if (key == null || key.isEmpty || args.length > 1) {
    stderr.writeln(
      'Set ANTHROPIC_ADMIN_API_KEY. Optionally pass a marketplace URL.',
    );
    exitCode = 64;
    return;
  }
  final client = AnthropicClient.withApiKey(
    key,
    baseUrl: Platform.environment['ANTHROPIC_BASE_URL'],
  );
  try {
    String? cursor;
    do {
      final page = await client.organization.plugins.list(
        ownerType: 'organization',
        page: cursor,
      );
      for (final plugin in page.data) {
        stdout.writeln(
          '${plugin.id}: ${plugin.name} serves ${plugin.servedVersionId}',
        );
      }
      cursor = page.hasMore ? page.nextPage : null;
    } while (cursor != null);

    if (args.isNotEmpty) {
      final report = await client.organization.pluginMarketplaces
          .validateRepository(repositoryUrl: args.single);
      stdout.writeln('Marketplace valid: ${report.valid}');
      for (final pluginError in report.pluginErrors) {
        stdout.writeln('${pluginError.name}: ${pluginError.errorCode}');
      }
    }
  } finally {
    client.close();
  }
}
