/// Reason for the model to stop generating content.
enum StopReason {
  /// The model reached a natural stopping point.
  endTurn('end_turn'),

  /// The model reached the maximum number of tokens.
  maxTokens('max_tokens'),

  /// The model encountered a stop sequence.
  stopSequence('stop_sequence'),

  /// The model is invoking a tool.
  toolUse('tool_use'),

  /// The model paused mid-turn for continuation.
  pauseTurn('pause_turn'),

  /// The model refused to generate content.
  refusal('refusal');

  const StopReason(this.value);

  /// JSON value for the stop reason.
  final String value;

  /// Converts a string to [StopReason].
  static StopReason fromJson(String value) => switch (value) {
    'end_turn' => StopReason.endTurn,
    'max_tokens' => StopReason.maxTokens,
    'stop_sequence' => StopReason.stopSequence,
    'tool_use' => StopReason.toolUse,
    'pause_turn' => StopReason.pauseTurn,
    'refusal' => StopReason.refusal,
    _ => throw FormatException('Unknown StopReason: $value'),
  };

  /// Converts to JSON string.
  String toJson() => value;
}
