import 'package:meta/meta.dart';

import 'failure.dart';

/// Attributes for an activity task failed event.
@immutable
class ActivityTaskFailedAttributes {
  /// The task identifier.
  final String taskId;

  /// The activity name.
  final String activityName;

  /// The attempt number.
  final int attempt;

  /// The failure details.
  final Failure failure;

  /// Creates a [ActivityTaskFailedAttributes].
  const ActivityTaskFailedAttributes({
    required this.taskId,
    required this.activityName,
    required this.attempt,
    required this.failure,
  });

  /// Creates a [ActivityTaskFailedAttributes] from JSON.
  factory ActivityTaskFailedAttributes.fromJson(Map<String, dynamic> json) =>
      ActivityTaskFailedAttributes(
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
  ActivityTaskFailedAttributes copyWith({
    String? taskId,
    String? activityName,
    int? attempt,
    Failure? failure,
  }) {
    return ActivityTaskFailedAttributes(
      taskId: taskId ?? this.taskId,
      activityName: activityName ?? this.activityName,
      attempt: attempt ?? this.attempt,
      failure: failure ?? this.failure,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActivityTaskFailedAttributes) return false;
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
      'ActivityTaskFailedAttributes('
      'taskId: $taskId, '
      'activityName: $activityName, '
      'attempt: $attempt, '
      'failure: $failure'
      ')';
}
