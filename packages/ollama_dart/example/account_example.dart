// ignore_for_file: avoid_print
import 'dart:io';

import 'package:ollama_dart/ollama_dart.dart';

/// Reads account balances and recent cloud usage without changing the account.
Future<void> main() async {
  final client = OllamaClient.withApiKey(
    Platform.environment['OLLAMA_API_KEY']!,
    baseUrl: 'https://ollama.com',
  );
  // To use the account signed into a local Ollama server, use OllamaClient().
  try {
    final balance = await client.balance.get();
    print('Purchased credits: USD ${balance.purchased.balanceUsd}');
    switch (balance.included) {
      case IncludedBalance(:final balanceUsd, :final allowanceUsd):
        print('Included credits: USD $balanceUsd of $allowanceUsd');
      case LegacyIncludedBalance(:final session, :final weekly):
        print('Session: ${session.remainingPercent}% remaining');
        print('Weekly: ${weekly.remainingPercent}% remaining');
      case UnknownIncludedBalance():
        print('Included balance format is newer than this client.');
    }
    final usage = await client.usage.get(
      range: UsageRange.days7,
      groupBy: UsageGroupBy.model,
    );
    print('Requests: ${usage.totals.requestCount}');
    print('Usage: USD ${usage.totals.usageUsd}');
    for (final group in usage.totals.groups ?? <UsageGroup>[]) {
      print('${group.model}: ${group.requestCount} requests');
    }
  } finally {
    client.close();
  }
}
