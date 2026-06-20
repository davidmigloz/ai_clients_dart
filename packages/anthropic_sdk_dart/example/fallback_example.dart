// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Server-side fallback example (Beta).
///
/// On Claude Fable 5 a safety classifier may decline a request with
/// `stop_reason: "refusal"`. Opt into the `fallbacks` chain to automatically
/// re-run a refused request on another model (billed at the fallback model's
/// rates). Requires the `server-side-fallback-2026-06-01` beta header; add
/// `fallback-credit-2026-06-01` to reuse the cache-miss credit on manual retries.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: server-side fallback chain
    print('=== Server-side fallback ===');
    final response = await client.messages.create(
      MessageCreateRequest(
        model: 'claude-fable-5',
        maxTokens: 1024,
        messages: [InputMessage.user('Summarize the plot of Hamlet.')],
        // If claude-fable-5 declines, re-run this turn on claude-opus-4-8.
        // Per-attempt overrides (max_tokens, thinking, output_config, speed)
        // replace the top-level field for that hop only.
        fallbacks: const [FallbackConfigV2(model: 'claude-opus-4-8')],
      ),
      betas: const ['server-side-fallback-2026-06-01'],
    );

    // A fallback hop is marked in `content` by a FallbackBlock; the model that
    // actually served the response appears as a `fallback_message` usage
    // iteration.
    for (final block in response.content) {
      if (block is FallbackBlock) {
        // `trigger` explains why `from` handed over — e.g. a policy refusal in
        // a named category (or `null` when uncategorized).
        print(
          'Fallback hop: ${block.from.model} -> ${block.to.model} '
          '(trigger: ${block.trigger.category?.value ?? 'uncategorized'})',
        );
      }
      if (block is TextBlock) {
        print('Response: ${block.text}');
      }
    }
    if (response.usage.iterations != null) {
      for (final iter in response.usage.iterations!) {
        if (iter.type == 'fallback_message') {
          print('Served by fallback model: ${iter.model}');
        }
      }
    }

    // Example 2: manual fallback using a refusal credit token
    print('\n=== Manual fallback with a credit token ===');
    print('''
When you handle refusals yourself, opt into `fallback-credit-2026-06-01` and
reuse the one-time `fallback_credit_token` to refund the cache-miss cost of the
retry (the token expires 5 minutes after the refusal):

final first = await client.messages.create(
  request,
  betas: const ['fallback-credit-2026-06-01'],
);

if (first.stopReason == StopReason.refusal) {
  final details = first.stopDetails; // RefusalStopDetails
  final retry = await client.messages.create(
    request.copyWith(
      model: details?.recommendedModel ?? 'claude-opus-4-8',
      fallbackCreditToken: details?.fallbackCreditToken,
    ),
    betas: const ['fallback-credit-2026-06-01'],
  );
  // ... use `retry`
}
''');
  } finally {
    client.close();
  }
}
