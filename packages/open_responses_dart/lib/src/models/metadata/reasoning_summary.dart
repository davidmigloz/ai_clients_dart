/// Reasoning summary verbosity level.
enum ReasoningSummary {
  /// Unknown summary level (fallback for unrecognized values).
  unknown('unknown'),

  /// Concise summary.
  concise('concise'),

  /// Detailed summary.
  detailed('detailed'),

  /// Automatic selection.
  auto('auto');

  /// The JSON value for this summary level.
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
