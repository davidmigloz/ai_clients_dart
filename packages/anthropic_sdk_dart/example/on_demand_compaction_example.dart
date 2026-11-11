// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Summarizes a completed turn and resumes with the signed compaction block.
///
/// Run with ANTHROPIC_API_KEY set on a platform that supports compaction.
Future<void> main() async {
  final client = AnthropicClient.fromEnvironment();
  const betas = ['compact-2026-09-04'];
  try {
    final opening = InputMessage.user(
      'Suggest three steps to plan a neighborhood book exchange.',
    );
    final request = MessageCreateRequest(
      model: 'claude-sonnet-5-5',
      maxTokens: 512,
      messages: [opening],
    );
    final first = await client.messages.create(request, betas: betas);
    if (first.stopReason != StopReason.endTurn) return;

    final history = [opening, first.toInputMessage()];
    final summary = await client.messages
        .createStream(
          request.copyWith(
            messages: history,
            compaction: const CompactionConfig.summarize(),
          ),
          betas: betas,
        )
        .finalMessage();
    final blocks = summary.content.whereType<CompactionBlock>();
    final signed =
        summary.stopReason == StopReason.compaction &&
        blocks.length == 1 &&
        blocks.single.content != null &&
        blocks.single.signature != null;

    final next = await client.messages.create(
      request.copyWith(
        messages: [
          if (signed) summary.toInputMessage() else ...history,
          InputMessage.user('Turn the plan into a checklist.'),
        ],
      ),
      betas: betas,
    );
    print(next.text);
  } finally {
    client.close();
  }
}
