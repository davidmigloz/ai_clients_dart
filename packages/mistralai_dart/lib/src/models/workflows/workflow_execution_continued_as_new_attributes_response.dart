import 'package:meta/meta.dart';

import 'json_payload_response.dart';

/// Attributes for a workflow execution continued-as-new event.
@immutable
class WorkflowExecutionContinuedAsNewAttributesResponse {
  /// The task identifier.
  final String taskId;

  /// The new execution run ID.
  final String newExecutionRunId;

  /// The workflow name.
  final String workflowName;

  /// The input payload.
  final JSONPayloadResponse input;

  /// Creates a [WorkflowExecutionContinuedAsNewAttributesResponse].
  const WorkflowExecutionContinuedAsNewAttributesResponse({
    required this.taskId,
    required this.newExecutionRunId,
    required this.workflowName,
    required this.input,
  });

  /// Creates a [WorkflowExecutionContinuedAsNewAttributesResponse] from JSON.
  factory WorkflowExecutionContinuedAsNewAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionContinuedAsNewAttributesResponse(
    taskId: json['task_id'] as String? ?? '',
    newExecutionRunId: json['new_execution_run_id'] as String? ?? '',
    workflowName: json['workflow_name'] as String? ?? '',
    input: JSONPayloadResponse.fromJson(json['input'] as Map<String, dynamic>),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'new_execution_run_id': newExecutionRunId,
    'workflow_name': workflowName,
    'input': input.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionContinuedAsNewAttributesResponse copyWith({
    String? taskId,
    String? newExecutionRunId,
    String? workflowName,
    JSONPayloadResponse? input,
  }) {
    return WorkflowExecutionContinuedAsNewAttributesResponse(
      taskId: taskId ?? this.taskId,
      newExecutionRunId: newExecutionRunId ?? this.newExecutionRunId,
      workflowName: workflowName ?? this.workflowName,
      input: input ?? this.input,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionContinuedAsNewAttributesResponse) {
      return false;
    }
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId &&
        newExecutionRunId == other.newExecutionRunId &&
        workflowName == other.workflowName &&
        input == other.input;
  }

  @override
  int get hashCode =>
      Object.hash(taskId, newExecutionRunId, workflowName, input);

  @override
  String toString() =>
      'WorkflowExecutionContinuedAsNewAttributesResponse('
      'taskId: $taskId, '
      'newExecutionRunId: $newExecutionRunId, '
      'workflowName: $workflowName, '
      'input: $input'
      ')';
}
