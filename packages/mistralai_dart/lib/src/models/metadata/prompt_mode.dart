/// Prompt mode for reasoning models.
///
/// Used with `ChatCompletionRequest.promptMode` to enable special
/// reasoning behaviors in compatible models.
enum MistralPromptMode {
  /// Enable reasoning mode with system prompt.
  ///
  /// When set, the model will engage in extended reasoning
  /// before providing a final response.
  reasoning('reasoning');

  const MistralPromptMode(this.value);

  /// The string value used in the API.
  final String value;

  /// Creates from a JSON string value.
  ///
  /// Returns null if [value] is null.
  static MistralPromptMode? fromString(String? value) {
    if (value == null) return null;
    return MistralPromptMode.values.firstWhere(
      (e) => e.value == value,
      orElse: () => MistralPromptMode.reasoning,
    );
  }
}
