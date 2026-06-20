import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'json_payload_response.dart';

/// Attributes for a workflow execution started event.
@immutable
class WorkflowExecutionStartedAttributesResponse {
  /// The task identifier.
  final String taskId;

  /// The workflow name.
  final String workflowName;

  /// The input payload.
  final JSONPayloadResponse input;

  /// The display name.
  final String? displayName;

  /// Creates a [WorkflowExecutionStartedAttributesResponse].
  const WorkflowExecutionStartedAttributesResponse({
    required this.taskId,
    required this.workflowName,
    required this.input,
    this.displayName,
  });

  /// Creates a [WorkflowExecutionStartedAttributesResponse] from JSON.
  factory WorkflowExecutionStartedAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionStartedAttributesResponse(
    taskId: json['task_id'] as String? ?? '',
    workflowName: json['workflow_name'] as String? ?? '',
    input: JSONPayloadResponse.fromJson(json['input'] as Map<String, dynamic>),
    displayName: json['display_name'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'workflow_name': workflowName,
    'input': input.toJson(),
    if (displayName != null) 'display_name': displayName,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionStartedAttributesResponse copyWith({
    String? taskId,
    String? workflowName,
    JSONPayloadResponse? input,
    Object? displayName = unsetCopyWithValue,
  }) {
    return WorkflowExecutionStartedAttributesResponse(
      taskId: taskId ?? this.taskId,
      workflowName: workflowName ?? this.workflowName,
      input: input ?? this.input,
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionStartedAttributesResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId &&
        workflowName == other.workflowName &&
        input == other.input &&
        displayName == other.displayName;
  }

  @override
  int get hashCode => Object.hash(taskId, workflowName, input, displayName);

  @override
  String toString() =>
      'WorkflowExecutionStartedAttributesResponse(taskId: $taskId, workflowName: $workflowName, input: $input, displayName: $displayName)';
}
