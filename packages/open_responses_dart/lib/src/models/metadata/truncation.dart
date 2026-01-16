/// Truncation strategy for long inputs.
enum Truncation {
  /// Unknown truncation strategy (fallback for unrecognized values).
  unknown('unknown'),

  /// Automatically truncate input if too long.
  auto('auto'),

  /// Disable truncation (fail if too long).
  disabled('disabled');

  /// The JSON value for this truncation strategy.
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
