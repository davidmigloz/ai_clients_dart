/// How a web tool's result blocks appear in the API response when the result
/// was consumed by a completed `code_execution` call in the same turn.
///
/// Only supported for the `web_search_20260318` and `web_fetch_20260318` tool
/// versions. Results from direct calls, or from `code_execution` calls that
/// paused before completing, are always returned in full.
enum ResponseInclusion {
  /// Return the complete content (default).
  full('full'),

  /// Drop the nested `server_tool_use` and result block pair entirely.
  excluded('excluded');

  const ResponseInclusion(this.value);

  /// JSON value for this response-inclusion mode.
  final String value;

  /// Parses a [ResponseInclusion] from JSON.
  static ResponseInclusion fromJson(String value) => switch (value) {
    'full' => ResponseInclusion.full,
    'excluded' => ResponseInclusion.excluded,
    _ => throw FormatException('Unknown ResponseInclusion: $value'),
  };

  /// Converts this response-inclusion mode to JSON.
  String toJson() => value;
}
