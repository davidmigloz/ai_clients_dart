import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Attributes for a workflow task timed out event.
@immutable
class WorkflowTaskTimedOutAttributes {
  /// The task identifier.
  final String taskId;

  /// The type of timeout.
  final String? timeoutType;

  /// Creates a [WorkflowTaskTimedOutAttributes].
  const WorkflowTaskTimedOutAttributes({
    required this.taskId,
    this.timeoutType,
  });

  /// Creates a [WorkflowTaskTimedOutAttributes] from JSON.
  factory WorkflowTaskTimedOutAttributes.fromJson(Map<String, dynamic> json) =>
      WorkflowTaskTimedOutAttributes(
        taskId: json['task_id'] as String? ?? '',
        timeoutType: json['timeout_type'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    if (timeoutType != null) 'timeout_type': timeoutType,
  };

  /// Creates a copy with replaced values.
  WorkflowTaskTimedOutAttributes copyWith({
    String? taskId,
    Object? timeoutType = unsetCopyWithValue,
  }) {
    return WorkflowTaskTimedOutAttributes(
      taskId: taskId ?? this.taskId,
      timeoutType: timeoutType == unsetCopyWithValue
          ? this.timeoutType
          : timeoutType as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowTaskTimedOutAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId && timeoutType == other.timeoutType;
  }

  @override
  int get hashCode => Object.hash(taskId, timeoutType);

  @override
  String toString() =>
      'WorkflowTaskTimedOutAttributes(taskId: $taskId, timeoutType: $timeoutType)';
}
