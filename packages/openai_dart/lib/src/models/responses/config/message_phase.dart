/// The phase of a message in a response.
enum MessagePhase {
  /// Unknown phase (fallback for unrecognized values).
  unknown('unknown'),

  /// Commentary phase (intermediate thinking).
  commentary('commentary'),

  /// Final answer phase.
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
