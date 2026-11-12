// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Searches an allowlist of domains using the Claude Messages web search tool.
///
/// Set ANTHROPIC_API_KEY before running. Enable web search for your Claude
/// organization. This example calls the current tool directly rather than
/// running searches through the code execution tool.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  try {
    final message = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 1024,
        messages: [
          InputMessage.user(
            'Search Wikipedia for monads in functional programming, then '
            'explain the concept in two sentences and cite the article.',
          ),
        ],
        tools: [
          ToolDefinition.builtIn(
            const WebSearchTool(
              type: 'web_search_20260318',
              allowedDomains: ['wikipedia.org'],
              allowedCallers: ['direct'],
              maxUses: 3,
            ),
          ),
        ],
      ),
    );
    print(message.text);
    for (final block in message.content.whereType<WebSearchToolResultBlock>()) {
      switch (block.content) {
        case WebSearchResultSuccess(:final results):
          for (final result in results) {
            print('${result.title} (${result.url})');
          }
        case WebSearchResultError(:final rawErrorCode):
          print('Web search failed: $rawErrorCode');
      }
    }
  } finally {
    client.close();
  }
}
