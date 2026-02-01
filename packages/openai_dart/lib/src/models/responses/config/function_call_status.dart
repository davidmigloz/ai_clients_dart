/// The status of a function call.
enum FunctionCallStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// Function call completed successfully.
  completed('completed'),

  /// Function call failed.
  failed('failed');

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
