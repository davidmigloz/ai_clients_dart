import 'package:meta/meta.dart';

import 'failure.dart';

/// Attributes for an activity task retrying event.
@immutable
class ActivityTaskRetryingAttributes {
  /// The task identifier.
  final String taskId;

  /// The activity name.
  final String activityName;

  /// The attempt number.
  final int attempt;

  /// The failure details.
  final Failure failure;

  /// Creates a [ActivityTaskRetryingAttributes].
  const ActivityTaskRetryingAttributes({
    required this.taskId,
    required this.activityName,
    required this.attempt,
    required this.failure,
  });

  /// Creates a [ActivityTaskRetryingAttributes] from JSON.
  factory ActivityTaskRetryingAttributes.fromJson(Map<String, dynamic> json) =>
      ActivityTaskRetryingAttributes(
        taskId: json['task_id'] as String? ?? '',
        activityName: json['activity_name'] as String? ?? '',
        attempt: json['attempt'] as int? ?? 0,
        failure: Failure.fromJson(json['failure'] as Map<String, dynamic>),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'activity_name': activityName,
    'attempt': attempt,
    'failure': failure.toJson(),
  };

  /// Creates a copy with replaced values.
  ActivityTaskRetryingAttributes copyWith({
    String? taskId,
    String? activityName,
    int? attempt,
    Failure? failure,
  }) {
    return ActivityTaskRetryingAttributes(
      taskId: taskId ?? this.taskId,
      activityName: activityName ?? this.activityName,
      attempt: attempt ?? this.attempt,
      failure: failure ?? this.failure,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActivityTaskRetryingAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId &&
        activityName == other.activityName &&
        attempt == other.attempt &&
        failure == other.failure;
  }

  @override
  int get hashCode => Object.hash(taskId, activityName, attempt, failure);

  @override
  String toString() =>
      'ActivityTaskRetryingAttributes('
      'taskId: $taskId, '
      'activityName: $activityName, '
      'attempt: $attempt, '
      'failure: $failure'
      ')';
}
