/// Labels an `assistant` message as intermediate commentary or the final
/// answer.
///
/// For models like `gpt-5.3-codex` and beyond, when sending follow-up
/// requests, preserve and resend [phase] on all assistant messages. Omitting
/// it can degrade performance. Not used for user messages.
enum MessagePhase {
  /// Unknown phase (fallback for unrecognized values).
  unknown('unknown'),

  /// Intermediate commentary from the assistant.
  commentary('commentary'),

  /// The final answer from the assistant.
  finalAnswer('final_answer');

  /// The JSON value for this phase.
  final String value;

  const MessagePhase(this.value);

  /// Creates a [MessagePhase] from a JSON value.
  factory MessagePhase.fromJson(String json) {
    return MessagePhase.values.firstWhere(
      (e) => e.value == json,
      orElse: () => MessagePhase.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
