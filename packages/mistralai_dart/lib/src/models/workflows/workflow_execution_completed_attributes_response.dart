import 'package:meta/meta.dart';

import 'json_payload_response.dart';

/// Attributes for a workflow execution completed event.
@immutable
class WorkflowExecutionCompletedAttributesResponse {
  /// The task identifier.
  final String taskId;

  /// The result payload.
  final JSONPayloadResponse result;

  /// Attempt number for this execution.
  final int attempt;

  /// Creates a [WorkflowExecutionCompletedAttributesResponse].
  const WorkflowExecutionCompletedAttributesResponse({
    this.attempt = 1,
    required this.taskId,
    required this.result,
  });

  /// Creates a [WorkflowExecutionCompletedAttributesResponse] from JSON.
  factory WorkflowExecutionCompletedAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionCompletedAttributesResponse(
    attempt: json['attempt'] as int? ?? 1,
    taskId: json['task_id'] as String? ?? '',
    result: JSONPayloadResponse.fromJson(
      json['result'] as Map<String, dynamic>,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'attempt': attempt,
    'task_id': taskId,
    'result': result.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionCompletedAttributesResponse copyWith({
    int? attempt,
    String? taskId,
    JSONPayloadResponse? result,
  }) {
    return WorkflowExecutionCompletedAttributesResponse(
      attempt: attempt ?? this.attempt,
      taskId: taskId ?? this.taskId,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionCompletedAttributesResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return attempt == other.attempt &&
        taskId == other.taskId &&
        result == other.result;
  }

  @override
  int get hashCode => Object.hashAll([taskId, result, attempt]);

  @override
  String toString() =>
      'WorkflowExecutionCompletedAttributesResponse(attempt: $attempt, taskId: $taskId, result: $result)';
}
