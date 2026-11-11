// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Starts a beta Messages thread and streams a continuation.
///
/// Run with ANTHROPIC_API_KEY set on a platform that supports message threads.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  const betas = ['message-threads-2026-08-12'];
  try {
    final request = MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 256,
      system: SystemPrompt.text('Answer in two sentences.'),
      messages: [InputMessage.user('Describe three common backyard birds.')],
      thread: const MessageThreadParam.create(),
    );
    final first = await client.messages.create(request, betas: betas);
    print(first.text);

    if (first.stopReason != StopReason.endTurn) return;
    final second = await client.messages
        .createStream(
          request.copyWith(
            messages: [InputMessage.user('How can I identify the first bird?')],
            system: null,
            thread: MessageThreadParam.continueFrom(first.id),
          ),
          betas: betas,
        )
        .finalMessage();
    print(second.text);
  } finally {
    client.close();
  }
}
