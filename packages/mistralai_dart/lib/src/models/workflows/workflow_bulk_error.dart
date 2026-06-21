import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'workflow.dart';

/// An error encountered while bulk archiving or unarchiving a workflow.
@immutable
class WorkflowBulkError {
  /// The requested workflow ID.
  final String workflowId;

  /// Error message describing why the operation failed.
  final String message;

  /// The workflow, if found.
  final Workflow? workflow;

  /// Creates a [WorkflowBulkError].
  const WorkflowBulkError({
    required this.workflowId,
    required this.message,
    this.workflow,
  });

  /// Creates a [WorkflowBulkError] from JSON.
  factory WorkflowBulkError.fromJson(Map<String, dynamic> json) =>
      WorkflowBulkError(
        workflowId: json['workflow_id'] as String? ?? '',
        message: json['message'] as String? ?? '',
        workflow: json['workflow'] != null
            ? Workflow.fromJson(json['workflow'] as Map<String, dynamic>)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'workflow_id': workflowId,
    'message': message,
    if (workflow != null) 'workflow': workflow?.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowBulkError copyWith({
    String? workflowId,
    String? message,
    Object? workflow = unsetCopyWithValue,
  }) {
    return WorkflowBulkError(
      workflowId: workflowId ?? this.workflowId,
      message: message ?? this.message,
      workflow: workflow == unsetCopyWithValue
          ? this.workflow
          : workflow as Workflow?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowBulkError) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflowId == other.workflowId &&
        message == other.message &&
        workflow == other.workflow;
  }

  @override
  int get hashCode => Object.hash(workflowId, message, workflow);

  @override
  String toString() =>
      'WorkflowBulkError('
      'workflowId: $workflowId, '
      'message: $message, '
      'workflow: $workflow'
      ')';
}
