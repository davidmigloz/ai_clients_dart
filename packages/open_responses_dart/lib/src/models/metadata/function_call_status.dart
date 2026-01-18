/// The status of a function call output.
enum FunctionCallStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// Function call is being processed.
  inProgress('in_progress'),

  /// Function call completed.
  completed('completed'),

  /// Function call incomplete.
  incomplete('incomplete');

  /// The JSON value for this status.
  final String value;

  const FunctionCallStatus(this.value);

  /// Creates a [FunctionCallStatus] from a JSON value.
  factory FunctionCallStatus.fromJson(String json) {
    return FunctionCallStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => FunctionCallStatus.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
