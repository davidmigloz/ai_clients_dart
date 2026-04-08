import 'package:meta/meta.dart';

import 'failure.dart';

/// Attributes for a workflow execution failed event.
@immutable
class WorkflowExecutionFailedAttributes {
  /// The task identifier.
  final String taskId;

  /// The failure details.
  final Failure failure;

  /// Creates a [WorkflowExecutionFailedAttributes].
  const WorkflowExecutionFailedAttributes({
    required this.taskId,
    required this.failure,
  });

  /// Creates a [WorkflowExecutionFailedAttributes] from JSON.
  factory WorkflowExecutionFailedAttributes.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionFailedAttributes(
    taskId: json['task_id'] as String? ?? '',
    failure: Failure.fromJson(json['failure'] as Map<String, dynamic>),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'failure': failure.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionFailedAttributes copyWith({
    String? taskId,
    Failure? failure,
  }) {
    return WorkflowExecutionFailedAttributes(
      taskId: taskId ?? this.taskId,
      failure: failure ?? this.failure,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionFailedAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId && failure == other.failure;
  }

  @override
  int get hashCode => Object.hash(taskId, failure);

  @override
  String toString() =>
      'WorkflowExecutionFailedAttributes(taskId: $taskId, failure: $failure)';
}
