/// The terminal status of a programmatic tool calling execution.
///
/// Unifies the `ProgramOutputStatus` and `ProgramOutputItemStatus` schemas,
/// which are identical enums.
enum ProgramOutputStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// The program execution completed.
  completed('completed'),

  /// The program execution did not complete (e.g. truncated).
  incomplete('incomplete');

  /// The JSON value for this status.
  final String value;

  const ProgramOutputStatus(this.value);

  /// Creates a [ProgramOutputStatus] from a JSON value.
  factory ProgramOutputStatus.fromJson(String json) {
    return ProgramOutputStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ProgramOutputStatus.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
