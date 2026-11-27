/// Controls the depth of reasoning before generating responses.
enum ThinkingLevel {
  /// Default value.
  unspecified,

  /// Constrains the model to use minimal tokens for thinking on supported models.
  /// Best for low-complexity tasks.
  minimal,

  /// Minimizes latency and cost.
  /// Best for simple instruction following or high-throughput apps.
  low,

  /// Balances reasoning depth and latency for moderately complex tasks.
  medium,

  /// Allows deep reasoning with more tokens.
  high,

  /// Highest reasoning depth on Gemini 4 Neon and Gemini 4 Hydrogen.
  xhigh,
}

/// Converts string to ThinkingLevel enum.
ThinkingLevel thinkingLevelFromString(String? value) {
  return switch (value?.toUpperCase()) {
    'MINIMAL' => ThinkingLevel.minimal,
    'LOW' => ThinkingLevel.low,
    'MEDIUM' => ThinkingLevel.medium,
    'HIGH' => ThinkingLevel.high,
    'XHIGH' => ThinkingLevel.xhigh,
    _ => ThinkingLevel.unspecified,
  };
}

/// Converts ThinkingLevel enum to string.
String thinkingLevelToString(ThinkingLevel level) {
  return switch (level) {
    ThinkingLevel.minimal => 'MINIMAL',
    ThinkingLevel.low => 'LOW',
    ThinkingLevel.medium => 'MEDIUM',
    ThinkingLevel.high => 'HIGH',
    ThinkingLevel.xhigh => 'XHIGH',
    ThinkingLevel.unspecified => 'THINKING_LEVEL_UNSPECIFIED',
  };
}
