import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Reads an organization usage summary without printing credentials.
Future<void> main(List<String> args) async {
  if (args.contains('--help')) {
    stdout
      ..writeln('Usage: dart run example/admin_usage_example.dart [--vibe]')
      ..writeln('Set MISTRAL_ADMIN_API_KEY to an organization Admin key.');
    return;
  }
  final key = Platform.environment['MISTRAL_ADMIN_API_KEY'];
  if (key == null || key.trim().isEmpty) {
    stderr.writeln('Set MISTRAL_ADMIN_API_KEY to an organization Admin key.');
    exitCode = 64;
    return;
  }

  final admin = MistralAdminClient.withApiKey(key);
  try {
    final monthly = await admin.usage.getMonthly();
    final limits = await admin.usage.getRateLimits();
    final auditLogs = await admin.auditLogs.list(limit: 5);
    final keyPage = await admin.apiKeys.list(limit: 5);
    stdout
      ..writeln('Usage window: ${monthly.startDate} to ${monthly.endDate}')
      ..writeln('Requests per second: ${limits.requestsPerSecond}')
      ..writeln('Audit events returned: ${auditLogs.length}')
      ..writeln('Workspace keys returned: ${keyPage.keys.length}');

    if (args.contains('--vibe')) {
      final end = DateTime.now().toUtc();
      final start = end.subtract(const Duration(days: 7));
      final activity = await admin.vibeAnalytics.getWorkByTime(
        startTime: start.millisecondsSinceEpoch ~/ 1000,
        endTime: end.millisecondsSinceEpoch ~/ 1000,
        granularity: VibeUsageGranularity.day,
      );
      stdout.writeln('Vibe Work usage buckets: ${activity.data.length}');
    }
  } finally {
    admin.close();
  }
}
