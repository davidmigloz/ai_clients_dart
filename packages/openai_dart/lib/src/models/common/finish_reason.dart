/// Reason why the model stopped generating tokens.
///
/// This enum indicates why the model finished generating a completion.
/// Understanding the finish reason helps in handling edge cases like
/// truncated responses or content filtering.
enum FinishReason {
  /// The model reached a natural stopping point or stop sequence.
  stop('stop'),

  /// The model reached the maximum number of tokens specified in the request.
  length('length'),

  /// The model called a function/tool and is waiting for a response.
  toolCalls('tool_calls'),

  /// The content was flagged by content filters.
  contentFilter('content_filter'),

  /// (Deprecated) The model called a function.
  ///
  /// Use [toolCalls] instead for newer API versions.
  functionCall('function_call');

  const FinishReason(this.value);

  /// The JSON value for this finish reason.
  final String value;

  /// Creates a [FinishReason] from a JSON string.
  static FinishReason fromJson(String value) => switch (value) {
    'stop' => FinishReason.stop,
    'length' => FinishReason.length,
    'tool_calls' => FinishReason.toolCalls,
    'content_filter' => FinishReason.contentFilter,
    'function_call' => FinishReason.functionCall,
    _ => throw FormatException('Unknown FinishReason: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;

  /// Whether the response was truncated due to length limits.
  bool get isTruncated => this == FinishReason.length;

  /// Whether the model wants to call a tool/function.
  bool get isToolCall =>
      this == FinishReason.toolCalls || this == FinishReason.functionCall;

  /// Whether the content was filtered.
  bool get isFiltered => this == FinishReason.contentFilter;

  /// Whether the response completed normally.
  bool get isComplete => this == FinishReason.stop;
}
