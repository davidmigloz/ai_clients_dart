import 'package:meta/meta.dart';

/// A recent execution that was started by a workflow schedule.
@immutable
class ScheduleRecentExecution {
  /// ID of the workflow execution that was started.
  final String executionId;

  /// Time the execution was scheduled to run.
  final String scheduledAt;

  /// Actual time the execution started.
  final String startedAt;

  /// Creates a [ScheduleRecentExecution].
  const ScheduleRecentExecution({
    required this.executionId,
    required this.scheduledAt,
    required this.startedAt,
  });

  /// Creates a [ScheduleRecentExecution] from JSON.
  factory ScheduleRecentExecution.fromJson(Map<String, dynamic> json) =>
      ScheduleRecentExecution(
        executionId: json['execution_id'] as String? ?? '',
        scheduledAt: json['scheduled_at'] as String? ?? '',
        startedAt: json['started_at'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'execution_id': executionId,
    'scheduled_at': scheduledAt,
    'started_at': startedAt,
  };

  /// Creates a copy with replaced values.
  ScheduleRecentExecution copyWith({
    String? executionId,
    String? scheduledAt,
    String? startedAt,
  }) => ScheduleRecentExecution(
    executionId: executionId ?? this.executionId,
    scheduledAt: scheduledAt ?? this.scheduledAt,
    startedAt: startedAt ?? this.startedAt,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleRecentExecution) return false;
    if (runtimeType != other.runtimeType) return false;
    return executionId == other.executionId &&
        scheduledAt == other.scheduledAt &&
        startedAt == other.startedAt;
  }

  @override
  int get hashCode => Object.hash(executionId, scheduledAt, startedAt);

  @override
  String toString() =>
      'ScheduleRecentExecution('
      'executionId: $executionId, '
      'scheduledAt: $scheduledAt, '
      'startedAt: $startedAt'
      ')';
}
