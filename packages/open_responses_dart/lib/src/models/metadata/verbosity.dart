/// Verbosity level for output.
enum Verbosity {
  /// Unknown verbosity level (fallback for unrecognized values).
  unknown('unknown'),

  /// Low verbosity.
  low('low'),

  /// Medium verbosity.
  medium('medium'),

  /// High verbosity.
  high('high');

  /// The JSON value for this verbosity level.
  final String value;

  const Verbosity(this.value);

  /// Creates a [Verbosity] from a JSON value.
  factory Verbosity.fromJson(String json) {
    return Verbosity.values.firstWhere(
      (e) => e.value == json,
      orElse: () => Verbosity.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
