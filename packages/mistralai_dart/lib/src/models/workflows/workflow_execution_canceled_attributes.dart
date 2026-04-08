import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Attributes for a workflow execution canceled event.
@immutable
class WorkflowExecutionCanceledAttributes {
  /// The task identifier.
  final String taskId;

  /// The cancellation reason.
  final String? reason;

  /// Creates a [WorkflowExecutionCanceledAttributes].
  const WorkflowExecutionCanceledAttributes({
    required this.taskId,
    this.reason,
  });

  /// Creates a [WorkflowExecutionCanceledAttributes] from JSON.
  factory WorkflowExecutionCanceledAttributes.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionCanceledAttributes(
    taskId: json['task_id'] as String? ?? '',
    reason: json['reason'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    if (reason != null) 'reason': reason,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionCanceledAttributes copyWith({
    String? taskId,
    Object? reason = unsetCopyWithValue,
  }) {
    return WorkflowExecutionCanceledAttributes(
      taskId: taskId ?? this.taskId,
      reason: reason == unsetCopyWithValue ? this.reason : reason as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionCanceledAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId && reason == other.reason;
  }

  @override
  int get hashCode => Object.hash(taskId, reason);

  @override
  String toString() =>
      'WorkflowExecutionCanceledAttributes(taskId: $taskId, reason: $reason)';
}
