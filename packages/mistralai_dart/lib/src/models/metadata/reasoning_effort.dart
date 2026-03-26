/// Controls the reasoning effort level for reasoning models.
///
/// Used with `ChatCompletionRequest.reasoningEffort` and
/// `AgentCompletionRequest.reasoningEffort` to control how much
/// reasoning the model performs before responding.
enum ReasoningEffort {
  /// Enable comprehensive reasoning traces.
  high('high'),

  /// Disable reasoning effort.
  none('none');

  const ReasoningEffort(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  ///
  /// Returns null if [value] is null or does not match any known value.
  static ReasoningEffort? fromString(String? value) {
    if (value == null) return null;
    for (final effort in ReasoningEffort.values) {
      if (effort.value == value) return effort;
    }
    return null;
  }
}
