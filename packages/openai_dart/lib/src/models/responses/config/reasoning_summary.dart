/// Reasoning summary generation mode.
enum ReasoningSummary {
  /// Unknown mode (fallback for unrecognized values).
  unknown('unknown'),

  /// Automatically generate summaries.
  auto('auto'),

  /// Generate concise summaries.
  concise('concise'),

  /// Generate detailed summaries.
  detailed('detailed');

  /// The JSON value for this mode.
  final String value;

  const ReasoningSummary(this.value);

  /// Creates a [ReasoningSummary] from a JSON value.
  factory ReasoningSummary.fromJson(String json) {
    return ReasoningSummary.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ReasoningSummary.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
