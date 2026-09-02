// ignore_for_file: avoid_print
import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Extended thinking example.
///
/// This example demonstrates:
/// - Enabling adaptive extended thinking mode
/// - Accessing thinking blocks from responses
/// - Streaming with thinking blocks
/// - Progress updates via [ThinkingDisplayMode.updates]
/// - Preserved thinking / block binding controls
/// - Multi-turn conversation with thinking replay (tool use)
///
/// Note: current-generation models (e.g. `claude-sonnet-5`) have adaptive
/// thinking always on and reject `enabled`/`disabled` thinking
/// configurations — use [ThinkingConfig.adaptive] instead.
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
        model: 'claude-sonnet-5',
        maxTokens: 16000,
        thinking: ThinkingConfig.adaptive(
          display: ThinkingDisplayMode.summarized,
        ),
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
        model: 'claude-sonnet-5',
        maxTokens: 16000,
        thinking: ThinkingConfig.adaptive(
          display: ThinkingDisplayMode.summarized,
        ),
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
        model: 'claude-sonnet-5',
        maxTokens: 16000,
        thinking: ThinkingConfig.adaptive(
          display: ThinkingDisplayMode.summarized,
        ),
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

    // Example 4: Progress updates
    //
    // With `display: ThinkingDisplayMode.updates`, reasoning blocks come
    // back with an empty `thinking` field, while the short progress updates
    // the model writes between tool calls come back as text: any `thinking`
    // block with non-empty text is a progress update you can show the user.
    print('\n=== Progress Updates ===');
    final updatesResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5',
        maxTokens: 16000,
        thinking: ThinkingConfig.adaptive(display: ThinkingDisplayMode.updates),
        messages: [
          InputMessage.user(
            'Plan a 3-day itinerary for a trip to Kyoto, Japan.',
          ),
        ],
      ),
      betas: ['thinking-display-updates-2026-08-18'],
    );

    for (final block in updatesResponse.content) {
      if (block case ThinkingBlock(:final thinking) when thinking.isNotEmpty) {
        print('[Status] $thinking');
      }
    }
    print('\nFinal answer:');
    print(updatesResponse.text);

    // Example 5: Preserved thinking / block binding
    //
    // `blockBinding` controls what happens when a replayed thinking block
    // fails the conversation check (e.g. it came from a different
    // conversation). `dropBlock` removes the failing block instead of
    // erroring, and reports each removal in `inputTransformations` — an
    // append-only history of changes the API made to the request's input.
    print('\n=== Preserved Thinking / Block Binding ===');
    final bindingResponse = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5',
        maxTokens: 16000,
        thinking: ThinkingConfig.adaptive(
          display: ThinkingDisplayMode.summarized,
          blockBinding: const ThinkingBlockBinding(
            prefixMismatchBehavior: ThinkingPrefixMismatchBehavior.dropBlock,
          ),
        ),
        messages: [InputMessage.user('What is the square root of 2025?')],
      ),
      betas: ['thinking-binding-controls-2026-08-01'],
    );

    print(bindingResponse.text);
    final transformations = bindingResponse.inputTransformations ?? const [];
    if (transformations.isEmpty) {
      print('No input transformations (nothing was dropped).');
    } else {
      for (final transformation in transformations) {
        if (transformation case ThinkingDroppedInputTransformation(
          :final path,
          :final reason,
        )) {
          print('Dropped thinking block at $path: ${reason.toJson()}');
        }
      }
    }

    // Example 6: Multi-turn conversation with thinking replay
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
        model: 'claude-sonnet-5',
        maxTokens: 16000,
        thinking: ThinkingConfig.adaptive(
          display: ThinkingDisplayMode.summarized,
        ),
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

    final toolUses = toolResponse.toolUseBlocks;
    if (toolUses.isNotEmpty) {
      // Every replayed tool_use block needs its own tool_result in the next
      // message — Claude can request several tools in a single turn, and the
      // API rejects the request if any of them goes unanswered.
      final toolResults = [
        for (final toolUse in toolUses)
          InputContentBlock.toolResult(
            toolUseId: toolUse.id,
            // Simulate tool execution
            content: [
              ToolResultContent.text(jsonEncode({'rate': 0.92})),
            ],
          ),
      ];

      final finalResponse = await client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-5',
          maxTokens: 16000,
          thinking: ThinkingConfig.adaptive(
            display: ThinkingDisplayMode.summarized,
          ),
          tools: [ToolDefinition.custom(exchangeRateTool)],
          messages: [
            userMessage,
            // Preserves block order, which is load-bearing here: the API
            // requires thinking blocks to be replayed unmodified and in
            // their original position when continuing a turn that used
            // extended thinking together with tool use.
            toolResponse.toInputMessage(),
            InputMessage.userBlocks(toolResults),
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
