import 'package:meta/meta.dart';

import 'failure.dart';

/// Attributes for a workflow execution failed event.
@immutable
class WorkflowExecutionFailedAttributes {
  /// The task identifier.
  final String taskId;

  /// The failure details.
  final Failure failure;

  /// Attempt number for this execution.
  final int attempt;

  /// Creates a [WorkflowExecutionFailedAttributes].
  const WorkflowExecutionFailedAttributes({
    this.attempt = 1,
    required this.taskId,
    required this.failure,
  });

  /// Creates a [WorkflowExecutionFailedAttributes] from JSON.
  factory WorkflowExecutionFailedAttributes.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionFailedAttributes(
    attempt: json['attempt'] as int? ?? 1,
    taskId: json['task_id'] as String? ?? '',
    failure: Failure.fromJson(json['failure'] as Map<String, dynamic>),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'attempt': attempt,
    'task_id': taskId,
    'failure': failure.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionFailedAttributes copyWith({
    int? attempt,
    String? taskId,
    Failure? failure,
  }) {
    return WorkflowExecutionFailedAttributes(
      attempt: attempt ?? this.attempt,
      taskId: taskId ?? this.taskId,
      failure: failure ?? this.failure,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionFailedAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return attempt == other.attempt &&
        taskId == other.taskId &&
        failure == other.failure;
  }

  @override
  int get hashCode => Object.hashAll([taskId, failure, attempt]);

  @override
  String toString() =>
      'WorkflowExecutionFailedAttributes(attempt: $attempt, taskId: $taskId, failure: $failure)';
}
