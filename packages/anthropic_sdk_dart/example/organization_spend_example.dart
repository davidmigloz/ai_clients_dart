import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Reads effective limits and pending increase requests.
///
/// Set ANTHROPIC_ADMIN_KEY to an Enterprise key with read:spend_limits.
Future<void> main() async {
  final adminKey = Platform.environment['ANTHROPIC_ADMIN_KEY'];
  if (adminKey == null || adminKey.isEmpty) {
    stderr.writeln('Set ANTHROPIC_ADMIN_KEY.');
    exitCode = 64;
    return;
  }

  final client = AnthropicClient.withApiKey(adminKey);
  try {
    final limits = await client.organization.spendLimits.listEffective(
      periods: [OrganizationSpendPeriod.monthly],
      limit: 10,
    );
    stdout.writeln('${limits.data.length} monthly limits on the first page');

    final requests = await client.organization.spendLimits.increaseRequests
        .list(statuses: ['pending'], limit: 10);
    stdout.writeln(
      '${requests.data.length} pending requests on the first page',
    );
  } finally {
    client.close();
  }
}
