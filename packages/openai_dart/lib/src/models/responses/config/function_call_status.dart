/// The status of a function call.
///
/// Mirrors the OpenAI `FunctionCallStatus` schema, which only accepts
/// `in_progress`, `completed`, and `incomplete`. The API rejects any other
/// value (including `failed`).
enum FunctionCallStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// Function call is in progress.
  inProgress('in_progress'),

  /// Function call completed successfully.
  completed('completed'),

  /// Function call did not complete (e.g. truncated, refused).
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
