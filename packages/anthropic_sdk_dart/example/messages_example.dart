// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Basic message creation example.
///
/// This example demonstrates:
/// - Basic message creation
/// - System prompts
/// - Multi-turn conversations
/// - Message role usage
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Simple message
    print('=== Simple Message ===');
    final simpleResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [InputMessage.user('What is the capital of France?')],
      ),
    );
    print('Response: ${simpleResponse.text}');
    print(
      'Usage: ${simpleResponse.usage.inputTokens} input, '
      '${simpleResponse.usage.outputTokens} output tokens',
    );

    // Example 2: With system prompt
    print('\n=== With System Prompt ===');
    final systemResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        system: SystemPrompt.text(
          'You are a helpful assistant that speaks like a pirate. '
          'Use nautical terms and say "Arrr" occasionally.',
        ),
        messages: [InputMessage.user('Tell me about the weather')],
      ),
    );
    print('Response: ${systemResponse.text}');

    // Example 3: Multi-turn conversation
    print('\n=== Multi-turn Conversation ===');
    final conversationResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [
          InputMessage.user('My name is Alice.'),
          InputMessage.assistant('Hello Alice! Nice to meet you.'),
          InputMessage.user('What is my name?'),
        ],
      ),
    );
    print('Response: ${conversationResponse.text}');

    // Example 4: Using content blocks with text
    print('\n=== Content Blocks ===');
    final contentBlockResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [
          InputMessage.userBlocks([
            InputContentBlock.text('Please analyze this text:'),
            InputContentBlock.text(
              'The quick brown fox jumps over the lazy dog.',
            ),
          ]),
        ],
      ),
    );
    print('Response: ${contentBlockResponse.text}');

    // Example 5: Stop sequences
    print('\n=== Stop Sequences ===');
    final stopResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        stopSequences: const ['END'],
        messages: [InputMessage.user('Count from 1 to 10, say END after 5')],
      ),
    );
    print('Response: ${stopResponse.text}');
    print('Stop reason: ${stopResponse.stopReason}');

    // Example 6: Temperature and metadata
    print('\n=== Temperature and Metadata ===');
    final tempResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        temperature: 0.0, // Deterministic
        metadata: const Metadata(userId: 'example-user-123'),
        messages: [InputMessage.user('What is 2 + 2?')],
      ),
    );
    print('Response: ${tempResponse.text}');
    print('Model: ${tempResponse.model}');
  } finally {
    client.close();
  }
}
