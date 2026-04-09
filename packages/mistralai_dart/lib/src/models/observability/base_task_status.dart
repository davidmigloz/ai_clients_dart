/// Status of an observability task.
enum BaseTaskStatus {
  /// Task is currently running.
  running('RUNNING'),

  /// Task completed successfully.
  completed('COMPLETED'),

  /// Task failed with an error.
  failed('FAILED'),

  /// Task was canceled.
  canceled('CANCELED'),

  /// Task was terminated.
  terminated('TERMINATED'),

  /// Task continued as a new execution.
  continuedAsNew('CONTINUED_AS_NEW'),

  /// Task timed out.
  timedOut('TIMED_OUT'),

  /// Task status is unknown (forward-compatible fallback).
  unknown('UNKNOWN');

  const BaseTaskStatus(this.value);

  /// The string value of this status.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [BaseTaskStatus] from a JSON value.
  static BaseTaskStatus fromJson(String? value) => fromString(value);

  /// Creates a [BaseTaskStatus] from a string value.
  static BaseTaskStatus fromString(String? value) {
    if (value == null) return BaseTaskStatus.unknown;
    return BaseTaskStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => BaseTaskStatus.unknown,
    );
  }
}
