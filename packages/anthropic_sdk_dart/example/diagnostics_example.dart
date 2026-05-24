// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Prompt-cache diagnostics example (Beta).
///
/// Cache diagnostics let you find out *why* the prompt cache prefix could not
/// be fully reused between two consecutive requests. Pass the previous
/// response's `id` via [DiagnosticsParam.previousMessageId] and the API reports
/// a [Diagnostics.cacheMissReason] on the response explaining where the prompt
/// diverged.
///
/// Requires the `cache-diagnosis-2026-04-07` beta header — pass it via the
/// `betas` parameter of `messages.create`.
Future<void> main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // First turn — opt in to diagnostics without a prior message to compare
    // against by passing `previousMessageId: null`.
    final first = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 1024,
        diagnostics: const DiagnosticsParam(),
        messages: [InputMessage.user('Summarize the rules of chess.')],
      ),
      betas: ['cache-diagnosis-2026-04-07'],
    );
    print('First message id: ${first.id}');

    // Second turn — reference the previous response id. The response's
    // `diagnostics.cacheMissReason` explains any prompt-cache divergence.
    final second = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-sonnet-4-6',
        maxTokens: 1024,
        diagnostics: DiagnosticsParam(previousMessageId: first.id),
        messages: [InputMessage.user('Now explain en passant.')],
      ),
      betas: ['cache-diagnosis-2026-04-07'],
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
