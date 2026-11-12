import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Reports a UTC day's Claude Enterprise activity using a `read:analytics` key.
///
/// Set ANTHROPIC_ADMIN_API_KEY and pass a report day in YYYY-MM-DD format.
Future<void> main(List<String> args) async {
  final key = Platform.environment['ANTHROPIC_ADMIN_API_KEY'];
  if (key == null || key.isEmpty || args.length != 1) {
    stderr.writeln(
      'Set ANTHROPIC_ADMIN_API_KEY and pass a UTC YYYY-MM-DD day.',
    );
    exitCode = 64;
    return;
  }

  final date = args.single;
  final followingDay = DateTime.parse(
    '${date}T00:00:00Z',
  ).add(const Duration(days: 1)).toIso8601String().split('T').first;
  final client = AnthropicClient.withApiKey(
    key,
    baseUrl: Platform.environment['ANTHROPIC_BASE_URL'],
  );
  try {
    final analytics = client.organization.analytics;
    final summaries = await analytics.summaries(
      startingDate: date,
      endingDate: followingDay,
    );
    for (final day in summaries.data) {
      stdout.writeln('${day.dailyActiveUserCount} active users');
      if (day.claudeTagDailyActiveUserCount case final count?) {
        stdout.writeln('$count active Claude Tag users');
      }
    }

    final query = AnalyticsActivityQuery(date: date, limit: 100);
    String? cursor;
    var rows = 0;
    do {
      final users = await analytics.users(query.withPage(cursor));
      rows += users.data.length;
      cursor = users.nextPage;
    } while (cursor != null);
    stdout.writeln('Received $rows user activity rows.');
  } finally {
    client.close();
  }
}
