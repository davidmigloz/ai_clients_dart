/// Policy for handling schedule overlaps.
enum ScheduleOverlapPolicy {
  /// Skip the overlapping execution.
  skip(1),

  /// Buffer one execution.
  bufferOne(2),

  /// Buffer all executions.
  bufferAll(3),

  /// Cancel the other execution.
  cancelOther(4),

  /// Terminate the other execution.
  terminateOther(5),

  /// Allow all overlapping executions.
  allowAll(6),

  /// Unknown policy (forward-compatibility fallback).
  unknown(0);

  const ScheduleOverlapPolicy(this.value);

  /// The int value of this enum member.
  final int value;

  /// Creates a [ScheduleOverlapPolicy] from a JSON integer value.
  static ScheduleOverlapPolicy fromJson(int? value) {
    if (value == null) return ScheduleOverlapPolicy.unknown;
    return ScheduleOverlapPolicy.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ScheduleOverlapPolicy.unknown,
    );
  }

  /// Returns the integer value for JSON serialization.
  int toJson() => value;
}
