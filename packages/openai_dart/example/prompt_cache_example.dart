// ignore_for_file: avoid_print
import 'package:openai_dart/openai_dart.dart';

/// Prewarms a stable prefix, compares the next response, and reads diagnostics.
///
/// Run with OPENAI_API_KEY set. This makes two small paid requests, disables
/// retries, limits output, and deletes both stored responses afterward.
Future<void> main() async {
  final client = OpenAIClient(
    config: OpenAIConfig.fromEnvironment().copyWith(
      retryPolicy: const RetryPolicy(maxRetries: 0),
      timeout: const Duration(seconds: 60),
    ),
  );
  final responseIds = <String>[];
  // GPT-5.6 and later require at least 1,024 tokens in the reusable prefix.
  // Replace these sample entries with your application's stable context.
  final prefix = List.generate(
    80,
    (i) =>
        'Reference entry $i: Keep the model, tools, settings, and prefix '
        'unchanged for cache reuse.',
  ).join('\n');
  final request = CreateResponseRequest(
    model: 'gpt-6-luna',
    input: ResponseInput.text('$prefix\nReply with only OK.'),
    reasoning: const ReasoningConfig(effort: ReasoningEffort.none),
    serviceTier: ServiceTier.defaultTier,
    maxOutputTokens: 16,
    store: true,
    promptCacheOptions: const ResponsePromptCacheOptionsParam(
      mode: PromptCacheMode.implicit,
      ttl: PromptCacheTtl.minutes30,
      prewarm: true,
    ),
  );

  try {
    final baseline = await client.responses.create(request);
    responseIds.add(baseline.id);
    print('Prewarm status: ${baseline.status}');

    // The comparison ID requests diagnostics; it does not load history.
    final response = await client.responses.create(
      request.copyWith(
        promptCacheOptions: ResponsePromptCacheOptionsParam(
          mode: PromptCacheMode.implicit,
          ttl: PromptCacheTtl.minutes30,
          comparisonResponseId: baseline.id,
          prewarm: false,
        ),
      ),
    );
    responseIds.add(response.id);
    print('Output: ${response.outputText}');
    print(
      'Cached input tokens: ${response.usage?.inputTokensDetails?.cachedTokens}',
    );
    switch (response.promptCacheDiagnostics) {
      case PromptCacheMissDiagnostics(:final reason, :final cacheMissedTokens):
        print(
          'Miss: ${reason.value}; estimated affected tokens: $cacheMissedTokens',
        );
      case PromptCacheHitDiagnostics():
        print('No cache miss detected; check usage for actual reuse.');
      case PromptCacheComparisonResponseNotFoundDiagnostics():
        print('Comparison record was missing or expired.');
      case PromptCacheUnavailableDiagnostics():
        print('Diagnostics were inconclusive or unsupported.');
      case UnknownPromptCacheDiagnostics(:final type):
        print('Future diagnostic type: $type');
      case null:
        print('No cache diagnostics returned.');
    }

    // Chat and compaction use the narrower mode/TTL options type.
    const chatOptions = PromptCacheOptionsParam(
      mode: PromptCacheMode.implicit,
      ttl: PromptCacheTtl.minutes30,
    );
    print('Chat cache options: ${chatOptions.toJson()}');
  } finally {
    try {
      // Attempt every cleanup even if one deletion fails.
      await Future.wait(responseIds.map(client.responses.delete));
    } finally {
      client.close();
    }
  }
}
