import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Lists destinations and displays their delivery status.
///
/// Set ANTHROPIC_ADMIN_API_KEY to an authorized organization credential.
Future<void> main() async {
  final key = Platform.environment['ANTHROPIC_ADMIN_API_KEY'];
  if (key == null || key.isEmpty) {
    stderr.writeln('Set ANTHROPIC_ADMIN_API_KEY.');
    exitCode = 64;
    return;
  }
  final client = AnthropicClient.withApiKey(
    key,
    baseUrl: Platform.environment['ANTHROPIC_BASE_URL'],
  );
  try {
    String? page;
    do {
      final destinations = await client.organization.telemetryDestinations.list(
        page: page,
      );
      for (final destination in destinations.data) {
        stdout.writeln('${destination.id} ${destination.state.type}');
        if (destination.deliveryHealth.lastError case final lastError?) {
          stdout.writeln('  Latest delivery error: $lastError');
        }
      }
      page = destinations.hasMore ? destinations.nextPage : null;
    } while (page != null);
  } finally {
    client.close();
  }
}
