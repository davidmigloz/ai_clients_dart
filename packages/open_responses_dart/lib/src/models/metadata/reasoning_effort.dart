/// Reasoning effort level for reasoning models.
enum ReasoningEffort {
  /// Unknown effort level (fallback for unrecognized values).
  unknown('unknown'),

  /// No reasoning.
  none('none'),

  /// Low reasoning effort.
  low('low'),

  /// Medium reasoning effort.
  medium('medium'),

  /// High reasoning effort.
  high('high'),

  /// Extra high reasoning effort.
  xhigh('xhigh');

  /// The JSON value for this effort level.
  final String value;

  const ReasoningEffort(this.value);

  /// Creates a [ReasoningEffort] from a JSON value.
  factory ReasoningEffort.fromJson(String json) {
    return ReasoningEffort.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ReasoningEffort.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
