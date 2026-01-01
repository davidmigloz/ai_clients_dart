// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Extended thinking example.
///
/// This example demonstrates:
/// - Enabling extended thinking mode
/// - Accessing thinking blocks from responses
/// - Streaming with thinking blocks
/// - Budget tokens configuration
///
/// Note: Extended thinking requires compatible models like claude-sonnet-4.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Basic extended thinking
    print('=== Extended Thinking ===');
    final thinkingResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 16000,
        thinking: const ThinkingEnabled(budgetTokens: 10000),
        messages: [
          InputMessage.user(
            'Solve this step by step: If a train travels 120 km in 2 hours, '
            'and another train travels 180 km in 3 hours, which train is faster?',
          ),
        ],
      ),
    );

    // Access thinking blocks
    for (final block in thinkingResponse.content) {
      switch (block) {
        case ThinkingBlock(:final thinking):
          print('Thinking process:');
          print(thinking);
          print('');
        case TextBlock(:final text):
          print('Final answer:');
          print(text);
        default:
          break;
      }
    }

    // Print usage information
    print('\nUsage:');
    print('  Input tokens: ${thinkingResponse.usage.inputTokens}');
    print('  Output tokens: ${thinkingResponse.usage.outputTokens}');

    // Example 2: Streaming with thinking
    print('\n=== Streaming with Thinking ===');
    final thinkingStream = client.messages.createStream(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 16000,
        thinking: const ThinkingEnabled(budgetTokens: 5000),
        messages: [InputMessage.user('What is 15% of 240? Show your work.')],
      ),
    );

    var currentBlockType = '';
    await for (final event in thinkingStream) {
      switch (event) {
        case ContentBlockStartEvent(:final contentBlock):
          if (contentBlock is ThinkingBlock) {
            currentBlockType = 'thinking';
            print('[Thinking starts]');
          } else if (contentBlock is TextBlock) {
            currentBlockType = 'text';
            print('\n[Response starts]');
          }
        case ContentBlockDeltaEvent(:final delta):
          switch (delta) {
            case ThinkingDelta(:final thinking):
              // Stream thinking content
              print(thinking);
            case TextDelta(:final text):
              // Stream response text
              print(text);
            default:
              break;
          }
        case ContentBlockStopEvent():
          if (currentBlockType == 'thinking') {
            print('[Thinking ends]');
          } else {
            print('\n[Response ends]');
          }
        default:
          break;
      }
    }

    // Example 3: Complex reasoning task
    print('\n=== Complex Reasoning ===');
    final complexResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 16000,
        thinking: const ThinkingEnabled(budgetTokens: 8000),
        messages: [
          InputMessage.user(
            'A farmer has chickens and cows. '
            'If there are 20 heads and 56 legs in total, '
            'how many chickens and how many cows does the farmer have?',
          ),
        ],
      ),
    );

    // Extract thinking and response
    final thinkingBlocks = complexResponse.content
        .whereType<ThinkingBlock>()
        .toList();
    final textBlocks = complexResponse.content.whereType<TextBlock>().toList();

    if (thinkingBlocks.isNotEmpty) {
      print("Claude's reasoning process:");
      print('-' * 40);
      for (final block in thinkingBlocks) {
        print(block.thinking);
      }
      print('-' * 40);
    }

    if (textBlocks.isNotEmpty) {
      print('\nFinal answer:');
      print(textBlocks.map((b) => b.text).join('\n'));
    }
  } finally {
    client.close();
  }
}
