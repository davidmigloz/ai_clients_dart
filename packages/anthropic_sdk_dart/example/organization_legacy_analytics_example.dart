// ignore_for_file: avoid_print
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Reads one page of a legacy usage report from Claude Console or Enterprise.
/// Set ANTHROPIC_ADMIN_API_KEY and pass `console` or `enterprise` followed by
/// two UTC RFC 3339 timestamps. Enterprise requires the read:analytics scope.
Future<void> main(List<String> args) async {
  final key = Platform.environment['ANTHROPIC_ADMIN_API_KEY'];
  if (key == null ||
      key.isEmpty ||
      args.length != 3 ||
      !const {'console', 'enterprise'}.contains(args.first)) {
    print(
      'Set ANTHROPIC_ADMIN_API_KEY and pass console or enterprise, start, end.',
    );
    return;
  }
  final start = DateTime.parse(args[1]);
  final end = DateTime.parse(args[2]);
  final client = AnthropicClient.withApiKey(
    key,
    baseUrl: Platform.environment['ANTHROPIC_BASE_URL'],
  );
  try {
    final analytics = client.organization.analytics;
    final report = args.first == 'console'
        ? await analytics.messagesUsageReport(
            startingAt: start,
            endingAt: end,
            bucketWidth: AnalyticsBucketWidth.day,
          )
        : await analytics.usageReport(
            LegacyEnterpriseAnalyticsQuery(
              startingAt: start,
              endingAt: end,
              bucketWidth: AnalyticsBucketWidth.day,
            ),
          );
    for (final bucket in report.data) {
      print('${bucket.startingAt}: ${bucket.results.length} usage rows');
    }
    if (report.hasMore) print('More rows are available.');
  } finally {
    client.close();
  }
}
