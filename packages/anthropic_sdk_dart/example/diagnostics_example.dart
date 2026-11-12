// ignore_for_file: avoid_print
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Prompt-cache diagnostics example.
///
/// Cache diagnostics let you find out *why* the prompt cache prefix could not
/// be fully reused between two consecutive requests. Pass the previous
/// response's `id` via [DiagnosticsParam.previousMessageId] and the API reports
/// a [Diagnostics.cacheMissReason] on the response explaining where the prompt
/// diverged.
///
/// Set ANTHROPIC_API_KEY for the Claude API and pass a local text file that
/// meets your model’s minimum cacheable prompt length.
Future<void> main(List<String> arguments) async {
  if (arguments.length != 1) {
    throw ArgumentError('Usage: diagnostics_example.dart context.txt');
  }
  final context = await File(arguments.single).readAsString();
  final firstTurn = InputMessage.userBlocks([
    TextInputBlock(context, cacheControl: const CacheControlEphemeral()),
    const TextInputBlock('Summarize this text.'),
  ]);
  final client = AnthropicClient.fromEnvironment();

  try {
    // First turn — opt in to diagnostics without a prior message to compare
    // against by passing `previousMessageId: null`.
    final first = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 1024,
        diagnostics: const DiagnosticsParam(),
        messages: [firstTurn],
      ),
    );
    print('First message id: ${first.id}');

    // Second turn — reference the previous response id. The response's
    // `diagnostics.cacheMissReason` explains any prompt-cache divergence.
    final second = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-5-5',
        maxTokens: 1024,
        diagnostics: DiagnosticsParam(previousMessageId: first.id),
        messages: [
          firstTurn,
          first.toInputMessage(),
          InputMessage.user('What is the main conclusion?'),
        ],
      ),
    );

    final reason = second.diagnostics?.cacheMissReason;
    print('Cache miss reason: ${_describe(reason)}');
  } finally {
    client.close();
  }
}

/// Renders a human-readable explanation for a [CacheMissReason].
String _describe(CacheMissReason? reason) => switch (reason) {
  null => 'diagnosis pending or no divergence detected',
  CacheMissModelChanged(:final cacheMissedInputTokens) =>
    'the model changed ($cacheMissedInputTokens tokens not cached)',
  CacheMissSystemChanged(:final cacheMissedInputTokens) =>
    'the system prompt changed ($cacheMissedInputTokens tokens not cached)',
  CacheMissToolsChanged(:final cacheMissedInputTokens) =>
    'the tools changed ($cacheMissedInputTokens tokens not cached)',
  CacheMissMessagesChanged(:final cacheMissedInputTokens) =>
    'the messages changed ($cacheMissedInputTokens tokens not cached)',
  CacheMissPreviousMessageNotFound() =>
    'the previous message could not be found',
  CacheMissUnavailable() => 'diagnostics are unavailable for this request',
  UnknownCacheMissReason() => 'an unrecognized reason (forward-compatible)',
};
