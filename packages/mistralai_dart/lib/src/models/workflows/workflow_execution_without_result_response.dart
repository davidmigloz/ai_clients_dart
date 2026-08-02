import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'workflow_execution_status.dart';

/// Response for a workflow execution without result data.
@immutable
class WorkflowExecutionWithoutResultResponse {
  /// The workflow name.
  final String workflowName;

  /// The execution identifier.
  final String executionId;

  /// The root execution identifier.
  final String rootExecutionId;

  /// The execution status.
  final WorkflowExecutionStatus? status;

  /// The start timestamp.
  final String startTime;

  /// The end timestamp.
  final String? endTime;

  /// The parent execution identifier.
  final String? parentExecutionId;

  /// Total duration in milliseconds.
  final int? totalDurationMs;

  /// The run identifier.
  final String? runId;

  /// The name of the deployment that ran this execution.
  final String? deploymentName;

  /// The ID of the user who triggered the execution.
  final String? userId;

  /// The ID of the workflow.
  final String? workflowId;

  /// Creates a [WorkflowExecutionWithoutResultResponse].
  const WorkflowExecutionWithoutResultResponse({
    required this.workflowName,
    required this.executionId,
    required this.rootExecutionId,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.parentExecutionId,
    this.totalDurationMs,
    this.runId,
    this.deploymentName,
    this.userId,
    this.workflowId,
  });

  /// Creates a [WorkflowExecutionWithoutResultResponse] from JSON.
  ///
  /// Throws a [FormatException] if a required field is missing.
  factory WorkflowExecutionWithoutResultResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final workflowName = json['workflow_name'] as String?;
    if (workflowName == null) {
      throw const FormatException(
        'WorkflowExecutionWithoutResultResponse: missing required field '
        '"workflow_name"',
      );
    }
    final executionId = json['execution_id'] as String?;
    if (executionId == null) {
      throw const FormatException(
        'WorkflowExecutionWithoutResultResponse: missing required field '
        '"execution_id"',
      );
    }
    final rootExecutionId = json['root_execution_id'] as String?;
    if (rootExecutionId == null) {
      throw const FormatException(
        'WorkflowExecutionWithoutResultResponse: missing required field '
        '"root_execution_id"',
      );
    }
    final startTime = json['start_time'] as String?;
    if (startTime == null) {
      throw const FormatException(
        'WorkflowExecutionWithoutResultResponse: missing required field '
        '"start_time"',
      );
    }
    if (!json.containsKey('status')) {
      throw const FormatException(
        'WorkflowExecutionWithoutResultResponse: missing required field '
        '"status"',
      );
    }
    if (!json.containsKey('end_time')) {
      throw const FormatException(
        'WorkflowExecutionWithoutResultResponse: missing required field '
        '"end_time"',
      );
    }
    return WorkflowExecutionWithoutResultResponse(
      workflowName: workflowName,
      executionId: executionId,
      rootExecutionId: rootExecutionId,
      status: json['status'] != null
          ? WorkflowExecutionStatus.fromJson(json['status'] as String)
          : null,
      startTime: startTime,
      endTime: json['end_time'] as String?,
      parentExecutionId: json['parent_execution_id'] as String?,
      totalDurationMs: json['total_duration_ms'] as int?,
      runId: json['run_id'] as String?,
      deploymentName: json['deployment_name'] as String?,
      userId: json['user_id'] as String?,
      workflowId: json['workflow_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'workflow_name': workflowName,
    'execution_id': executionId,
    'root_execution_id': rootExecutionId,
    'status': status?.toJson(),
    'start_time': startTime,
    'end_time': endTime,
    if (parentExecutionId != null) 'parent_execution_id': parentExecutionId,
    if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
    if (runId != null) 'run_id': runId,
    if (deploymentName != null) 'deployment_name': deploymentName,
    if (userId != null) 'user_id': userId,
    if (workflowId != null) 'workflow_id': workflowId,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionWithoutResultResponse copyWith({
    String? workflowName,
    String? executionId,
    String? rootExecutionId,
    Object? status = unsetCopyWithValue,
    String? startTime,
    Object? endTime = unsetCopyWithValue,
    Object? parentExecutionId = unsetCopyWithValue,
    Object? totalDurationMs = unsetCopyWithValue,
    Object? runId = unsetCopyWithValue,
    Object? deploymentName = unsetCopyWithValue,
    Object? userId = unsetCopyWithValue,
    Object? workflowId = unsetCopyWithValue,
  }) {
    return WorkflowExecutionWithoutResultResponse(
      workflowName: workflowName ?? this.workflowName,
      executionId: executionId ?? this.executionId,
      rootExecutionId: rootExecutionId ?? this.rootExecutionId,
      status: status == unsetCopyWithValue
          ? this.status
          : status as WorkflowExecutionStatus?,
      startTime: startTime ?? this.startTime,
      endTime: endTime == unsetCopyWithValue
          ? this.endTime
          : endTime as String?,
      parentExecutionId: parentExecutionId == unsetCopyWithValue
          ? this.parentExecutionId
          : parentExecutionId as String?,
      totalDurationMs: totalDurationMs == unsetCopyWithValue
          ? this.totalDurationMs
          : totalDurationMs as int?,
      runId: runId == unsetCopyWithValue ? this.runId : runId as String?,
      deploymentName: deploymentName == unsetCopyWithValue
          ? this.deploymentName
          : deploymentName as String?,
      userId: userId == unsetCopyWithValue ? this.userId : userId as String?,
      workflowId: workflowId == unsetCopyWithValue
          ? this.workflowId
          : workflowId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionWithoutResultResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflowName == other.workflowName &&
        executionId == other.executionId &&
        rootExecutionId == other.rootExecutionId &&
        status == other.status &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        parentExecutionId == other.parentExecutionId &&
        totalDurationMs == other.totalDurationMs &&
        runId == other.runId &&
        deploymentName == other.deploymentName &&
        userId == other.userId &&
        workflowId == other.workflowId;
  }

  @override
  int get hashCode => Object.hash(
    workflowName,
    executionId,
    rootExecutionId,
    status,
    startTime,
    endTime,
    parentExecutionId,
    totalDurationMs,
    runId,
    deploymentName,
    userId,
    workflowId,
  );

  @override
  String toString() =>
      'WorkflowExecutionWithoutResultResponse('
      'workflowName: $workflowName, '
      'executionId: $executionId, '
      'rootExecutionId: $rootExecutionId, '
      'status: $status, '
      'startTime: $startTime, '
      'endTime: $endTime, '
      'parentExecutionId: $parentExecutionId, '
      'totalDurationMs: $totalDurationMs, '
      'runId: $runId, '
      'deploymentName: $deploymentName, '
      'userId: $userId, '
      'workflowId: $workflowId'
      ')';
}
