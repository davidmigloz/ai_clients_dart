/// The retention policy for prompt cache entries.
///
/// Used by the existing `prompt_cache_retention` API control, which is deprecated
/// in favor of `prompt_cache_options.ttl`.
enum PromptCacheRetention {
  /// Unknown retention (fallback for unrecognized values).
  unknown('unknown'),

  /// Standard in-memory cache retention.
  inMemory('in_memory'),

  /// 24-hour cache retention.
  ///
  /// As of 2026-05-29 this is the default for organizations without Zero Data
  /// Retention (ZDR) enabled; previously the default was [inMemory].
  h24('24h');

  /// The JSON value for this retention policy.
  final String value;

  const PromptCacheRetention(this.value);

  /// Creates a [PromptCacheRetention] from a JSON value.
  ///
  /// Accepts the legacy `in-memory` spelling for saved/provider payloads;
  /// serialization always emits the canonical `in_memory` spelling.
  factory PromptCacheRetention.fromJson(String json) {
    if (json == 'in-memory') return PromptCacheRetention.inMemory;
    return PromptCacheRetention.values.firstWhere(
      (e) => e.value == json,
      orElse: () => PromptCacheRetention.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
