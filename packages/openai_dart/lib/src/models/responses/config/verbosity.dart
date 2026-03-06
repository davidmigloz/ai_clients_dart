/// Verbosity level for output.
///
/// Constrains the verbosity of the model's response. Lower values will result
/// in more concise responses, while higher values will result in more verbose
/// responses.
enum Verbosity {
  /// Unknown verbosity (fallback for unrecognized values).
  unknown('unknown'),

  /// Low verbosity — more concise responses.
  low('low'),

  /// Medium verbosity (default).
  medium('medium'),

  /// High verbosity — more detailed responses.
  high('high');

  /// The JSON value for this verbosity.
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
