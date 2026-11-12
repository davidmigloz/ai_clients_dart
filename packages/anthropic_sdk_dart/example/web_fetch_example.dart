import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Fetches a URL supplied by the user, with tool-result URL sources excluded.
///
/// Set ANTHROPIC_API_KEY and pass the HTTPS URL to read.
Future<void> main(List<String> args) async {
  if (args.length != 1) {
    stderr.writeln('Pass one HTTPS URL.');
    exitCode = 64;
    return;
  }
  final client = AnthropicClient.fromEnvironment();
  try {
    final message = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 512,
        messages: [InputMessage.user('Summarize ${args.single}.')],
        tools: [
          ToolDefinition.builtIn(
            BuiltInTool.webFetch(
              type: 'web_fetch_20260318',
              urlSources: const WebFetchUrlSources(
                clientToolResults: WebFetchUrlToolFilter.none(),
                serverToolResults: WebFetchUrlToolFilter.none(),
              ),
            ),
          ),
        ],
      ),
    );
    for (final result in message.content.whereType<WebFetchToolResultBlock>()) {
      if (result.rawErrorCode case final code?) {
        stderr.writeln('Web fetch failed ($code).');
      }
    }
    stdout.writeln(message.text);
  } finally {
    client.close();
  }
}
