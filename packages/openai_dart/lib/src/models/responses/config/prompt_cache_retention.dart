/// The retention policy for prompt cache entries.
enum PromptCacheRetention {
  /// Unknown retention (fallback for unrecognized values).
  unknown('unknown'),

  /// In-memory cache (cleared when the server restarts).
  inMemory('in-memory'),

  /// 24-hour cache retention.
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
