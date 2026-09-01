// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Extended thinking example.
///
/// This example demonstrates:
/// - Enabling extended thinking mode
/// - Accessing thinking blocks from responses
/// - Streaming with thinking blocks
/// - Budget tokens configuration
/// - Multi-turn conversation with thinking replay (tool use)
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
        model: 'claude-sonnet-4-6',
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
        model: 'claude-sonnet-4-6',
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
        model: 'claude-sonnet-4-6',
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

    // Example 4: Multi-turn conversation with thinking replay
    print('\n=== Multi-Turn Conversation with Thinking Replay ===');

    // Define a simple client tool
    const exchangeRateTool = Tool(
      name: 'get_exchange_rate',
      description: 'Get the current exchange rate between two currencies.',
      inputSchema: InputSchema(
        properties: {
          'from': {
            'type': 'string',
            'description': 'Source currency code, e.g. "USD"',
          },
          'to': {
            'type': 'string',
            'description': 'Target currency code, e.g. "EUR"',
          },
        },
        required: ['from', 'to'],
        extra: {'additionalProperties': false},
      ),
    );

    final userMessage = InputMessage.user(
      'Convert 250 USD to EUR and tell me if that is enough to buy a '
      '€200 item.',
    );

    final toolResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 16000,
        thinking: const ThinkingEnabled(budgetTokens: 10000),
        tools: [ToolDefinition.custom(exchangeRateTool)],
        messages: [userMessage],
      ),
    );

    for (final block in toolResponse.content) {
      switch (block) {
        case ThinkingBlock(:final thinking):
          print('Thinking process:');
          print(thinking);
          print('');
        case ToolUseBlock(:final name, :final input):
          print('Claude wants to use tool: $name');
          print('With input: ${jsonEncode(input)}');
        default:
          break;
      }
    }

    if (toolResponse.hasToolUse) {
      final toolUse = toolResponse.toolUseBlocks.first;

      // Simulate tool execution
      final toolResult = jsonEncode({'rate': 0.92});

      final finalResponse = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-6',
          maxTokens: 16000,
          thinking: const ThinkingEnabled(budgetTokens: 10000),
          tools: [ToolDefinition.custom(exchangeRateTool)],
          messages: [
            userMessage,
            // Preserves block order, which is load-bearing here: the API
            // requires thinking blocks to be replayed unmodified and in
            // their original position when continuing a turn that used
            // extended thinking together with tool use.
            toolResponse.toInputMessage(),
            InputMessage(
              role: MessageRole.user,
              content: MessageContent.blocks([
                InputContentBlock.toolResult(
                  toolUseId: toolUse.id,
                  content: [ToolResultContent.text(toolResult)],
                ),
              ]),
            ),
          ],
        ),
      );

      print('\nFinal answer:');
      print(finalResponse.text);
    }
  } finally {
    client.close();
  }
}
