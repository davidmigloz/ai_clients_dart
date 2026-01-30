/// The status of a response.
enum ResponseStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// Response is queued for processing.
  queued('queued'),

  /// Response is being generated.
  inProgress('in_progress'),

  /// Response generation completed.
  completed('completed'),

  /// Response generation failed.
  failed('failed'),

  /// Response generation incomplete.
  incomplete('incomplete'),

  /// Response was cancelled.
  cancelled('cancelled');

  /// The JSON value for this status.
  final String value;

  const ResponseStatus(this.value);

  /// Creates a [ResponseStatus] from a JSON value.
  factory ResponseStatus.fromJson(String json) {
    return ResponseStatus.values.firstWhere(
      (e) => e.value == json,
      orElse: () => ResponseStatus.unknown,
    );
  }

  /// Converts to JSON value.
  String toJson() => value;
}
