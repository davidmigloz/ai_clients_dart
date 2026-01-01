// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Streaming example demonstrating SSE streaming.
///
/// This example demonstrates:
/// - Basic streaming with createStream
/// - Event handling for different message events
/// - Accumulating text from content block deltas
/// - Usage information from stream events
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Basic streaming
    print('=== Basic Streaming ===');
    final stream = client.messages.createStream(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [InputMessage.user('Write a haiku about programming')],
      ),
    );

    print('Streaming response:');
    await for (final event in stream) {
      switch (event) {
        case MessageStartEvent(:final message):
          print('[Start] Model: ${message.model}');
        case ContentBlockStartEvent(:final contentBlock):
          if (contentBlock is TextBlock) {
            print('[Block Start] Type: text');
          } else if (contentBlock is ThinkingBlock) {
            print('[Block Start] Type: thinking');
          } else if (contentBlock is ToolUseBlock) {
            print('[Block Start] Type: tool_use');
          }
        case ContentBlockDeltaEvent(:final delta):
          if (delta is TextDelta) {
            // Print text as it arrives without newline
            print(delta.text);
          }
        case ContentBlockStopEvent():
          print('[Block Stop]');
        case MessageDeltaEvent(:final delta, :final usage):
          print('\n[Delta] Stop reason: ${delta.stopReason}');
          print('[Delta] Output tokens: ${usage.outputTokens}');
        case MessageStopEvent():
          print('[Stop] Stream complete');
        case PingEvent():
          // Heartbeat, ignore
          break;
        case ErrorEvent(:final errorType, :final message):
          print('[Error] $errorType: $message');
      }
    }

    // Example 2: Accumulating text
    print('\n=== Accumulating Text ===');
    final textBuffer = StringBuffer();
    final accStream = client.messages.createStream(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [
          InputMessage.user('What is the meaning of life in one sentence?'),
        ],
      ),
    );

    await for (final event in accStream) {
      if (event case ContentBlockDeltaEvent(:final delta)) {
        if (delta is TextDelta) {
          textBuffer.write(delta.text);
        }
      }
    }
    print('Complete response: $textBuffer');

    // Example 3: Multi-turn streaming conversation
    print('\n=== Multi-turn Streaming ===');
    final conversationStream = client.messages.createStream(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [
          InputMessage.user('Hello!'),
          InputMessage.assistant('Hello! How can I help you today?'),
          InputMessage.user('Tell me a short joke.'),
        ],
      ),
    );

    print('Joke: ');
    await for (final event in conversationStream) {
      if (event case ContentBlockDeltaEvent(:final delta)) {
        if (delta is TextDelta) {
          print(delta.text);
        }
      }
    }

    // Example 4: Streaming with usage tracking
    print('\n=== Streaming with Usage Tracking ===');
    int? inputTokens;
    int? outputTokens;

    final usageStream = client.messages.createStream(
      MessageCreateRequest(
        model: 'claude-sonnet-4-20250514',
        maxTokens: 1024,
        messages: [InputMessage.user('Say "Hello, World!"')],
      ),
    );

    await for (final event in usageStream) {
      switch (event) {
        case MessageStartEvent(:final message):
          inputTokens = message.usage.inputTokens;
        case MessageDeltaEvent(:final usage):
          outputTokens = usage.outputTokens;
        default:
          break;
      }
    }

    print('Token usage - Input: $inputTokens, Output: $outputTokens');
  } finally {
    client.close();
  }
}
