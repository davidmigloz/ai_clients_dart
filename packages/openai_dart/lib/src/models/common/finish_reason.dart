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
  functionCall('function_call'),

  /// An unrecognized finish reason from a third-party provider.
  ///
  /// Returned instead of throwing when [fromJson] encounters a value not
  /// in the OpenAI spec. For example, OpenRouter may return "error".
  unknown('unknown');

  const FinishReason(this.value);

  /// The JSON value for this finish reason.
  final String value;

  /// Creates a [FinishReason] from a JSON string.
  ///
  /// In addition to standard OpenAI values, this handles non-standard
  /// values returned by OpenAI-compatible providers:
  ///
  /// | Value            | Mapped to       | Provider                    |
  /// |------------------|-----------------|-----------------------------|
  /// | `end_turn`       | [stop]          | AWS Bedrock Converse API    |
  /// | `tool_use`       | [toolCalls]     | AWS Bedrock Converse API    |
  /// | `max_tokens`     | [length]        | AWS Bedrock Converse API    |
  /// | `stop_sequence`  | [stop]          | AWS Bedrock Converse API    |
  /// | `eos`            | [stop]          | TogetherAI                  |
  /// | (unrecognized)   | [unknown]       | Any non-standard provider   |
  static FinishReason fromJson(String value) => switch (value) {
    'stop' => FinishReason.stop,
    'length' => FinishReason.length,
    'tool_calls' => FinishReason.toolCalls,
    'content_filter' => FinishReason.contentFilter,
    'function_call' => FinishReason.functionCall,
    // AWS Bedrock Converse API native values
    'end_turn' => FinishReason.stop,
    'stop_sequence' => FinishReason.stop,
    'tool_use' => FinishReason.toolCalls,
    'max_tokens' => FinishReason.length,
    // TogetherAI end-of-sequence
    'eos' => FinishReason.stop,
    _ => FinishReason.unknown,
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
