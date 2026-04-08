import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Synchronous response for a workflow execution.
@immutable
class WorkflowExecutionSyncResponse {
  /// The workflow name.
  final String workflowName;

  /// The execution identifier.
  final String executionId;

  /// The execution result.
  final Object result;

  /// Creates a [WorkflowExecutionSyncResponse].
  const WorkflowExecutionSyncResponse({
    required this.workflowName,
    required this.executionId,
    required this.result,
  });

  /// Creates a [WorkflowExecutionSyncResponse] from JSON.
  factory WorkflowExecutionSyncResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowExecutionSyncResponse(
        workflowName: json['workflow_name'] as String? ?? '',
        executionId: json['execution_id'] as String? ?? '',
        result: json['result'] ?? const <String, dynamic>{},
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'workflow_name': workflowName,
    'execution_id': executionId,
    'result': result,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionSyncResponse copyWith({
    String? workflowName,
    String? executionId,
    Object? result,
  }) {
    return WorkflowExecutionSyncResponse(
      workflowName: workflowName ?? this.workflowName,
      executionId: executionId ?? this.executionId,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionSyncResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflowName == other.workflowName &&
        executionId == other.executionId &&
        valuesDeepEqual(result, other.result);
  }

  @override
  int get hashCode =>
      Object.hash(workflowName, executionId, valueDeepHashCode(result));

  @override
  String toString() =>
      'WorkflowExecutionSyncResponse(workflowName: $workflowName, executionId: $executionId, result: $result)';
}
