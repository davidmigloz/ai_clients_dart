/// Controls the reasoning effort level for reasoning models.
///
/// Used with `ChatCompletionRequest.reasoningEffort` and
/// `AgentCompletionRequest.reasoningEffort` to control how much
/// reasoning the model performs before responding.
enum ReasoningEffort {
  /// Disable reasoning effort.
  none('none'),

  /// Minimal reasoning effort.
  minimal('minimal'),

  /// Low reasoning effort.
  low('low'),

  /// Medium reasoning effort.
  medium('medium'),

  /// Enable comprehensive reasoning traces.
  high('high'),

  /// Maximum reasoning effort.
  xhigh('xhigh'),

  /// Unknown reasoning effort (forward compatibility).
  unknown('unknown');

  const ReasoningEffort(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a string value.
  ///
  /// Returns null if [value] is null.
  /// Returns [unknown] if [value] does not match any known value.
  static ReasoningEffort? fromString(String? value) => switch (value) {
    'none' => none,
    'minimal' => minimal,
    'low' => low,
    'medium' => medium,
    'high' => high,
    'xhigh' => xhigh,
    null => null,
    _ => unknown,
  };
}
