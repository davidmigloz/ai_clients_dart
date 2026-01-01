// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Token counting example.
///
/// This example demonstrates:
/// - Counting tokens in messages
/// - Estimating token usage before sending
/// - Understanding token limits
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Count tokens in a simple message
    print('=== Simple Token Count ===');
    final simpleCount = await client.messages.countTokens(
      TokenCountRequest(
        model: 'claude-sonnet-4-20250514',
        messages: [InputMessage.user('Hello, how are you today?')],
      ),
    );

    print('Simple message token count: ${simpleCount.inputTokens}');

    // Example 2: Count tokens with system prompt
    print('\n=== With System Prompt ===');
    final systemCount = await client.messages.countTokens(
      TokenCountRequest(
        model: 'claude-sonnet-4-20250514',
        system: SystemPrompt.text(
          'You are a helpful assistant that specializes in explaining '
          'complex topics in simple terms.',
        ),
        messages: [InputMessage.user('Explain quantum computing to me.')],
      ),
    );

    print('With system prompt: ${systemCount.inputTokens} tokens');

    // Example 3: Multi-turn conversation token count
    print('\n=== Multi-turn Conversation ===');
    final conversationCount = await client.messages.countTokens(
      TokenCountRequest(
        model: 'claude-sonnet-4-20250514',
        messages: [
          InputMessage.user('What is machine learning?'),
          InputMessage.assistant(
            'Machine learning is a subset of artificial intelligence that '
            'enables systems to learn and improve from experience without '
            'being explicitly programmed. It focuses on developing computer '
            'programs that can access data and use it to learn for themselves.',
          ),
          InputMessage.user('What are some common applications?'),
          InputMessage.assistant(
            'Common applications include image recognition, speech recognition, '
            'recommendation systems, fraud detection, and autonomous vehicles.',
          ),
          InputMessage.user('Tell me more about recommendation systems.'),
        ],
      ),
    );

    print('Multi-turn conversation: ${conversationCount.inputTokens} tokens');

    // Example 4: Compare token counts for different content
    print('\n=== Content Comparison ===');

    final shortMessage = await client.messages.countTokens(
      TokenCountRequest(
        model: 'claude-sonnet-4-20250514',
        messages: [InputMessage.user('Hi!')],
      ),
    );

    final longMessage = await client.messages.countTokens(
      TokenCountRequest(
        model: 'claude-sonnet-4-20250514',
        messages: [
          InputMessage.user(
            'Please provide a comprehensive analysis of the impact of '
            'artificial intelligence on modern healthcare systems, including '
            'discussion of diagnostic tools, treatment planning, drug discovery, '
            'patient monitoring, and administrative efficiency improvements.',
          ),
        ],
      ),
    );

    print('Short message: ${shortMessage.inputTokens} tokens');
    print('Long message: ${longMessage.inputTokens} tokens');

    // Example 5: Token budget planning
    print('\n=== Token Budget Planning ===');
    const maxContextWindow = 200000; // Claude Sonnet context window
    const desiredOutputTokens = 4096;

    final currentInputTokens = conversationCount.inputTokens;
    const availableForInput = maxContextWindow - desiredOutputTokens;
    final remainingBudget = availableForInput - currentInputTokens;

    print('Context window: $maxContextWindow tokens');
    print('Current input: $currentInputTokens tokens');
    print('Reserved for output: $desiredOutputTokens tokens');
    print('Remaining budget: $remainingBudget tokens');
    print(
      'Usage: ${(currentInputTokens / availableForInput * 100).toStringAsFixed(1)}%',
    );

    // Example 6: Count tokens with tools
    print('\n=== With Tools ===');
    final toolsCount = await client.messages.countTokens(
      TokenCountRequest(
        model: 'claude-sonnet-4-20250514',
        tools: const [
          {
            'name': 'get_weather',
            'description': 'Get the current weather for a location',
            'input_schema': {
              'type': 'object',
              'properties': {
                'location': {
                  'type': 'string',
                  'description': 'City and state, e.g. San Francisco, CA',
                },
              },
              'required': ['location'],
            },
          },
        ],
        messages: [InputMessage.user("What's the weather in New York?")],
      ),
    );

    print('With tools defined: ${toolsCount.inputTokens} tokens');
  } finally {
    client.close();
  }
}
