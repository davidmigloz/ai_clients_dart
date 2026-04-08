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
  });

  /// Creates a [WorkflowExecutionWithoutResultResponse] from JSON.
  factory WorkflowExecutionWithoutResultResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionWithoutResultResponse(
    workflowName: json['workflow_name'] as String? ?? '',
    executionId: json['execution_id'] as String? ?? '',
    rootExecutionId: json['root_execution_id'] as String? ?? '',
    status: json['status'] != null
        ? WorkflowExecutionStatus.fromJson(json['status'] as String)
        : null,
    startTime: json['start_time'] as String? ?? '',
    endTime: json['end_time'] as String?,
    parentExecutionId: json['parent_execution_id'] as String?,
    totalDurationMs: json['total_duration_ms'] as int?,
  );

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
        totalDurationMs == other.totalDurationMs;
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
      'totalDurationMs: $totalDurationMs'
      ')';
}
