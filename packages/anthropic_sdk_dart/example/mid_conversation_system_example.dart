// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Mid-conversation system message example.
///
/// This example demonstrates:
/// - Injecting updated system instructions partway through a conversation
///   using a `mid_conv_system` content block (via
///   [InputContentBlock.midConversationSystem]), without a separate user turn
///   or disrupting prompt caching.
/// - Reading the new `outputTokensDetails` breakdown from usage.
///
/// Mid-conversation system messages are supported by Claude Opus 4.8.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-opus-4-8',
        maxTokens: 1024,
        system: SystemPrompt.text(
          'You are a helpful assistant. Answer concisely.',
        ),
        messages: [
          InputMessage.user('What is the capital of France?'),
          InputMessage.assistant('The capital of France is Paris.'),
          // Update the system instructions mid-conversation, then ask a
          // follow-up — all within the messages array.
          InputMessage.userBlocks([
            InputContentBlock.midConversationSystem(
              content: const [
                TextInputBlock('From now on, always answer in French.'),
              ],
            ),
            InputContentBlock.text('What is its population?'),
          ]),
        ],
      ),
    );

    for (final block in response.content) {
      if (block case TextBlock(:final text)) {
        print(text);
      }
    }

    // Output token breakdown (e.g. reasoning tokens) is available via the new
    // `outputTokensDetails` field on usage.
    final details = response.usage.outputTokensDetails;
    print('\nUsage:');
    print('  Output tokens: ${response.usage.outputTokens}');
    if (details != null) {
      print('  Thinking tokens: ${details.thinkingTokens}');
    }
  } finally {
    client.close();
  }
}
