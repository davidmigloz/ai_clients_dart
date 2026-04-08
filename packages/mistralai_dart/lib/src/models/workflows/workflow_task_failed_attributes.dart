import 'package:meta/meta.dart';

import 'failure.dart';

/// Attributes for a workflow task failed event.
@immutable
class WorkflowTaskFailedAttributes {
  /// The task identifier.
  final String taskId;

  /// The failure details.
  final Failure failure;

  /// Creates a [WorkflowTaskFailedAttributes].
  const WorkflowTaskFailedAttributes({
    required this.taskId,
    required this.failure,
  });

  /// Creates a [WorkflowTaskFailedAttributes] from JSON.
  factory WorkflowTaskFailedAttributes.fromJson(Map<String, dynamic> json) =>
      WorkflowTaskFailedAttributes(
        taskId: json['task_id'] as String? ?? '',
        failure: Failure.fromJson(json['failure'] as Map<String, dynamic>),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'failure': failure.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowTaskFailedAttributes copyWith({String? taskId, Failure? failure}) {
    return WorkflowTaskFailedAttributes(
      taskId: taskId ?? this.taskId,
      failure: failure ?? this.failure,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowTaskFailedAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId && failure == other.failure;
  }

  @override
  int get hashCode => Object.hash(taskId, failure);

  @override
  String toString() =>
      'WorkflowTaskFailedAttributes(taskId: $taskId, failure: $failure)';
}
