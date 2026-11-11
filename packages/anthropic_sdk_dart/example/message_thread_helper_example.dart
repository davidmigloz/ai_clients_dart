// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Uses the local thread helper and opts into bounded history replay.
///
/// Run with ANTHROPIC_API_KEY set on a platform that supports message threads.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  try {
    final thread = client.messages.createThread(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 256,
        messages: [InputMessage.user('Suggest a short route for a city walk.')],
      ),
      replayOnThreadError: true,
    );
    final first = await thread.send();
    print(first.text);
    if (first.stopReason != StopReason.endTurn) return;

    final second = await thread
        .stream(messages: [InputMessage.user('Add one indoor stop.')])
        .finalMessage();
    print(second.text);
  } finally {
    client.close();
  }
}
