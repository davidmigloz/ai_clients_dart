import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Attributes for a workflow execution canceled event.
@immutable
class WorkflowExecutionCanceledAttributes {
  /// The task identifier.
  final String taskId;

  /// The cancellation reason.
  final String? reason;

  /// Attempt number for this execution.
  final int attempt;

  /// Creates a [WorkflowExecutionCanceledAttributes].
  const WorkflowExecutionCanceledAttributes({
    this.attempt = 1,
    required this.taskId,
    this.reason,
  });

  /// Creates a [WorkflowExecutionCanceledAttributes] from JSON.
  factory WorkflowExecutionCanceledAttributes.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionCanceledAttributes(
    attempt: json['attempt'] as int? ?? 1,
    taskId: json['task_id'] as String? ?? '',
    reason: json['reason'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'attempt': attempt,
    'task_id': taskId,
    if (reason != null) 'reason': reason,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionCanceledAttributes copyWith({
    int? attempt,
    String? taskId,
    Object? reason = unsetCopyWithValue,
  }) {
    return WorkflowExecutionCanceledAttributes(
      attempt: attempt ?? this.attempt,
      taskId: taskId ?? this.taskId,
      reason: reason == unsetCopyWithValue ? this.reason : reason as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionCanceledAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return attempt == other.attempt &&
        taskId == other.taskId &&
        reason == other.reason;
  }

  @override
  int get hashCode => Object.hashAll([taskId, reason, attempt]);

  @override
  String toString() =>
      'WorkflowExecutionCanceledAttributes(attempt: $attempt, taskId: $taskId, reason: $reason)';
}
