/// Finish reason for a completion.
enum FinishReason {
  /// Stop sequence reached.
  stop,

  /// Max tokens reached.
  length,

  /// Model decided to call tools.
  toolCalls,

  /// Model generated content that was filtered.
  modelLength,

  /// Error occurred during generation.
  error,

  /// Unknown finish reason (for forward compatibility).
  unknown,
}

/// Converts string to [FinishReason] enum.
///
/// Returns [FinishReason.unknown] for unrecognized values.
/// Returns `null` if [value] is `null`.
FinishReason? finishReasonFromString(String? value) {
  if (value == null) return null;
  return switch (value) {
    'stop' => FinishReason.stop,
    'length' => FinishReason.length,
    'tool_calls' => FinishReason.toolCalls,
    'model_length' => FinishReason.modelLength,
    'error' => FinishReason.error,
    _ => FinishReason.unknown,
  };
}

/// Converts [FinishReason] enum to string.
String finishReasonToString(FinishReason value) {
  return switch (value) {
    FinishReason.stop => 'stop',
    FinishReason.length => 'length',
    FinishReason.toolCalls => 'tool_calls',
    FinishReason.modelLength => 'model_length',
    FinishReason.error => 'error',
    FinishReason.unknown => 'unknown',
  };
}
