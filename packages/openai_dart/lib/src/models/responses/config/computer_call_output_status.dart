/// Status of a computer call output returned by the input-items resource.
enum ComputerCallOutputStatus {
  /// Unknown status (fallback for unrecognized values).
  unknown('unknown'),

  /// The output is in progress.
  inProgress('in_progress'),

  /// The output completed.
  completed('completed'),

  /// The output is incomplete.
  incomplete('incomplete'),

  /// The output failed.
  failed('failed');

  /// The JSON value for this status.
  final String value;
  const ComputerCallOutputStatus(this.value);

  /// Creates a status from JSON.
  factory ComputerCallOutputStatus.fromJson(String json) =>
      ComputerCallOutputStatus.values.firstWhere(
        (e) => e.value == json,
        orElse: () => ComputerCallOutputStatus.unknown,
      );

  /// Converts to JSON.
  String toJson() => value;
}
