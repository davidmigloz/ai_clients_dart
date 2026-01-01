// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Web Search tool example (Beta).
///
/// This example demonstrates how to configure and use the Web Search tool.
/// Note: This is a beta feature.
///
/// Web Search allows Claude to:
/// - Search the web for current information
/// - Access up-to-date content
/// - Verify facts with external sources
void main() {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Configure Web Search tool
    print('=== Web Search Tool Configuration ===');
    print('''
The Web Search tool is configured as part of the tools array:

final tools = [
  const WebSearchTool(
    allowedDomains: ['wikipedia.org', 'github.com'],
    blockedDomains: ['example.com'],
    maxUses: 5,
    userLocation: UserLocation(
      city: 'San Francisco',
      region: 'California',
      country: 'US',
      timezone: 'America/Los_Angeles',
    ),
  ).toJson(),
];

final response = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-20250514',
    maxTokens: 4096,
    tools: tools,
    messages: [
      InputMessage.user('What are the latest news about AI?'),
    ],
  ),
);

Claude will automatically use web search when needed and include
the search results in the response.
''');

    // Example 2: Minimal configuration
    print('\n=== Minimal Configuration ===');
    print('''
For basic web search, you can use minimal configuration:

final tools = [
  const WebSearchTool().toJson(),
];

This allows Claude to search any domain without restrictions.
''');

    // Example 3: Using web search with allowed domains
    print('\n=== Domain Filtering ===');
    const tool = WebSearchTool(
      allowedDomains: ['wikipedia.org', 'bbc.com', 'reuters.com'],
      maxUses: 3,
    );
    print('WebSearchTool JSON:');
    print(tool.toJson());
    print('''

With this configuration, Claude can only search these trusted domains.
This is useful for:
- Ensuring reliable sources
- Limiting to specific knowledge bases
- Compliance with content policies
''');

    // Example 4: Simulated web search flow
    print('\n=== Web Search Response ===');
    print('''
When Claude uses web search, you might see responses like:

{
  "type": "text",
  "text": "Based on my web search, I found that..."
}

Or with thinking enabled, Claude will explain its search strategy:

{
  "type": "thinking",
  "thinking": "I need to search for recent information about AI.
               Let me query for 'artificial intelligence news 2024'..."
}

The web search results are automatically integrated into
Claude's response - you don't need to handle them separately.
''');

    // Example 5: Location-aware search
    print('\n=== Location-Aware Search ===');
    const locationTool = WebSearchTool(
      userLocation: UserLocation(
        city: 'Tokyo',
        region: 'Tokyo',
        country: 'JP',
        timezone: 'Asia/Tokyo',
      ),
    );
    print('Location-aware WebSearchTool:');
    print(locationTool.toJson());
    print('''

With location configured, searches for local content
(weather, news, events) will be localized appropriately.
''');
  } finally {
    client.close();
  }
}
