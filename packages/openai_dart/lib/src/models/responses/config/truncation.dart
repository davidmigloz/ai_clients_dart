/// Truncation strategy for long inputs.
enum Truncation {
  /// Unknown strategy (fallback for unrecognized values).
  unknown('unknown'),

  /// Automatically truncate input.
  auto('auto'),

  /// Disable truncation.
  disabled('disabled');

  /// The JSON value for this strategy.
  final String value;

  const Truncation(this.value);

  /// Creates a [Truncation] from a JSON value.
  factory Truncation.fromJson(String json) {
    return Truncation.values.firstWhere(
      (e) => e.value == json,
      orElse: () => Truncation.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
