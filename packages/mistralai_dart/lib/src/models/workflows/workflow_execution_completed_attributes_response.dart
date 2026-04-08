import 'package:meta/meta.dart';

import 'json_payload_response.dart';

/// Attributes for a workflow execution completed event.
@immutable
class WorkflowExecutionCompletedAttributesResponse {
  /// The task identifier.
  final String taskId;

  /// The result payload.
  final JSONPayloadResponse result;

  /// Creates a [WorkflowExecutionCompletedAttributesResponse].
  const WorkflowExecutionCompletedAttributesResponse({
    required this.taskId,
    required this.result,
  });

  /// Creates a [WorkflowExecutionCompletedAttributesResponse] from JSON.
  factory WorkflowExecutionCompletedAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionCompletedAttributesResponse(
    taskId: json['task_id'] as String? ?? '',
    result: JSONPayloadResponse.fromJson(
      json['result'] as Map<String, dynamic>,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'result': result.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionCompletedAttributesResponse copyWith({
    String? taskId,
    JSONPayloadResponse? result,
  }) {
    return WorkflowExecutionCompletedAttributesResponse(
      taskId: taskId ?? this.taskId,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionCompletedAttributesResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId && result == other.result;
  }

  @override
  int get hashCode => Object.hash(taskId, result);

  @override
  String toString() =>
      'WorkflowExecutionCompletedAttributesResponse(taskId: $taskId, result: $result)';
}
