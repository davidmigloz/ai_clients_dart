// ignore_for_file: avoid_print
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Read dimensioned usage and costs with a scoped organization credential.
///
/// Set ANTHROPIC_ADMIN_API_KEY and provide two UTC timestamps, for example:
/// `dart run example/organization_analytics_example.dart 2026-10-01T00:00:00Z 2026-10-02T00:00:00Z`.
Future<void> main(List<String> args) async {
  final key = Platform.environment['ANTHROPIC_ADMIN_API_KEY'];
  if (key == null || key.isEmpty || args.length != 2) {
    print('Set ANTHROPIC_ADMIN_API_KEY and pass two RFC 3339 timestamps.');
    return;
  }

  final client = AnthropicClient.withApiKey(key);
  try {
    final analytics = client.organization.analytics;
    final query = UsageCostAnalyticsQuery(
      startingAt: DateTime.parse(args.first),
      endingAt: DateTime.parse(args.last),
      timeBucketWidth: AnalyticsBucketWidth.day,
      groupBy: const ['model'],
      orderBy: 'time',
      order: 'asc',
    );

    String? page;
    do {
      final usage = await analytics.usage(query.withPage(page));
      for (final row in usage.data) {
        print(
          '${row.startingAt} ${row.group.model}: ${row.usage.totalTokens} tokens',
        );
      }
      page = usage.nextPage;
    } while (page != null);

    page = null;
    do {
      final costs = await analytics.cost(query.withPage(page));
      for (final row in costs.data) {
        print(
          '${row.group.model}: ${row.cost.amount} minor units (${row.cost.currency})',
        );
      }
      page = costs.nextPage;
    } while (page != null);
  } finally {
    client.close();
  }
}
