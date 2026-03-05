/// The status of a function call output.
///
/// This is distinct from [FunctionCallStatus] which has different values
/// (`unknown`/`completed`/`failed`).
enum FunctionCallOutputStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// Function call is in progress.
  inProgress('in_progress'),

  /// Function call completed.
  completed('completed'),

  /// Function call is incomplete.
  incomplete('incomplete');

  /// The JSON value for this status.
  final String value;

  const FunctionCallOutputStatus(this.value);

  /// Creates a [FunctionCallOutputStatus] from a JSON value.
  factory FunctionCallOutputStatus.fromJson(String json) {
    return FunctionCallOutputStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => FunctionCallOutputStatus.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
