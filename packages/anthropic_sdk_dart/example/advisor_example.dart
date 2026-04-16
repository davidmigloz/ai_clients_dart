// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Advisor tool example (Beta).
///
/// The advisor tool pairs a faster executor model (Sonnet/Haiku) with a
/// stronger advisor model (Opus) for mid-generation strategic guidance.
/// The advisor runs server-side within a single Messages API request.
///
/// Requires the `advisor-tool-2026-03-01` beta header.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Basic advisor tool usage
    print('=== Basic Advisor Tool ===');
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 4096,
        tools: [
          ToolDefinition.builtIn(const AdvisorTool(model: 'claude-opus-4-7')),
        ],
        messages: [
          InputMessage.user(
            'Build a concurrent worker pool in Go with graceful shutdown.',
          ),
        ],
      ),
      betas: ['advisor-tool-2026-03-01'],
    );

    // The response contains ServerToolUseBlock + AdvisorToolResultBlock
    for (final block in response.content) {
      if (block is ServerToolUseBlock && block.name == 'advisor') {
        print('Advisor was consulted (tool_use_id: ${block.id})');
      }
      if (block is AdvisorToolResultBlock) {
        switch (block.content) {
          case AdvisorResult(:final text):
            print(
              'Advisor advice: ${text.length > 100 ? '${text.substring(0, 100)}...' : text}',
            );
          case AdvisorRedactedResult():
            print('Advisor returned encrypted advice (for round-tripping)');
          case AdvisorToolResultError(:final errorCode):
            print('Advisor error: $errorCode');
          case AdvisorToolResultUnknown():
            print('Unknown advisor result type');
        }
      }
      if (block is TextBlock) {
        print(
          'Executor response: ${block.text.length > 100 ? '${block.text.substring(0, 100)}...' : block.text}',
        );
      }
    }

    // Check advisor usage in iterations
    if (response.usage.iterations != null) {
      for (final iter in response.usage.iterations!) {
        if (iter.type == 'advisor_message') {
          print(
            'Advisor usage — model: ${iter.model}, '
            'input: ${iter.inputTokens}, output: ${iter.outputTokens}',
          );
        }
      }
    }

    // Example 2: Advisor with caching and max_uses
    print('\n=== Advisor with Caching ===');
    print('''
For long agent loops, enable advisor-side caching to reduce costs:

final tools = [
  ToolDefinition.builtIn(
    AdvisorTool(
      model: 'claude-opus-4-7',
      maxUses: 3,
      caching: CacheControlEphemeral(ttl: CacheTtl.ttl5m),
    ),
  ),
];

- maxUses: limits advisor calls per request (prevents runaway costs)
- caching: enables prompt caching across advisor calls in a conversation
  (breaks even at ~3 calls, improves from there)
''');

    // Example 3: Multi-turn conversation with advisor
    print('\n=== Multi-Turn Conversation ===');
    print('''
Pass advisor_tool_result blocks back verbatim on subsequent turns:

// First turn
final response1 = await client.messages.create(request, betas: [...]);

// Build next turn — include full assistant content (with advisor blocks)
final messages = [
  InputMessage.user('Build a Go worker pool.'),
  InputMessage(
    role: MessageRole.assistant,
    content: response1.content
        .map((b) => InputContentBlock.fromJson(b.toJson()))
        .toList(),
  ),
  InputMessage.user('Now add a max-in-flight limit of 10.'),
];

// The advisor sees the full conversation history
final response2 = await client.messages.create(
  MessageCreateRequest(
    model: 'claude-sonnet-4-6',
    maxTokens: 4096,
    tools: [ToolDefinition.builtIn(AdvisorTool(model: 'claude-opus-4-7'))],
    messages: messages,
  ),
  betas: ['advisor-tool-2026-03-01'],
);
''');
  } finally {
    client.close();
  }
}
