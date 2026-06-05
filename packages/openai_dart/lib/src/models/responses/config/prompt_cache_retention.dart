/// The retention policy for prompt cache entries.
enum PromptCacheRetention {
  /// Unknown retention (fallback for unrecognized values).
  unknown('unknown'),

  /// In-memory cache (cleared when the server restarts).
  inMemory('in-memory'),

  /// 24-hour cache retention.
  ///
  /// As of 2026-05-29 this is the default for organizations without Zero Data
  /// Retention (ZDR) enabled; previously the default was [inMemory].
  h24('24h');

  /// The JSON value for this retention policy.
  final String value;

  const PromptCacheRetention(this.value);

  /// Creates a [PromptCacheRetention] from a JSON value.
  factory PromptCacheRetention.fromJson(String json) {
    return PromptCacheRetention.values.firstWhere(
      (e) => e.value == json,
      orElse: () => PromptCacheRetention.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
