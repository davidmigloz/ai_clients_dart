import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'workflow_execution_status.dart';
import 'workflow_execution_trace_summary_span.dart';

/// Response for workflow execution trace summary.
@immutable
class WorkflowExecutionTraceSummaryResponse {
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

  /// The execution result.
  final Object? result;

  /// The span tree.
  final WorkflowExecutionTraceSummarySpan? spanTree;

  /// The parent execution identifier.
  final String? parentExecutionId;

  /// Total duration in milliseconds.
  final int? totalDurationMs;

  /// Creates a [WorkflowExecutionTraceSummaryResponse].
  const WorkflowExecutionTraceSummaryResponse({
    required this.workflowName,
    required this.executionId,
    required this.rootExecutionId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.result,
    this.spanTree,
    this.parentExecutionId,
    this.totalDurationMs,
  });

  /// Creates a [WorkflowExecutionTraceSummaryResponse] from JSON.
  factory WorkflowExecutionTraceSummaryResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionTraceSummaryResponse(
    workflowName: json['workflow_name'] as String? ?? '',
    executionId: json['execution_id'] as String? ?? '',
    rootExecutionId: json['root_execution_id'] as String? ?? '',
    status: json['status'] != null
        ? WorkflowExecutionStatus.fromJson(json['status'] as String)
        : null,
    startTime: json['start_time'] as String? ?? '',
    endTime: json['end_time'] as String?,
    result: json['result'],
    spanTree: json['span_tree'] != null
        ? WorkflowExecutionTraceSummarySpan.fromJson(
            json['span_tree'] as Map<String, dynamic>,
          )
        : null,
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
    'result': result,
    if (spanTree != null) 'span_tree': spanTree?.toJson(),
    if (parentExecutionId != null) 'parent_execution_id': parentExecutionId,
    if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionTraceSummaryResponse copyWith({
    String? workflowName,
    String? executionId,
    String? rootExecutionId,
    Object? status = unsetCopyWithValue,
    String? startTime,
    Object? endTime = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    Object? spanTree = unsetCopyWithValue,
    Object? parentExecutionId = unsetCopyWithValue,
    Object? totalDurationMs = unsetCopyWithValue,
  }) {
    return WorkflowExecutionTraceSummaryResponse(
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
      result: result == unsetCopyWithValue ? this.result : result,
      spanTree: spanTree == unsetCopyWithValue
          ? this.spanTree
          : spanTree as WorkflowExecutionTraceSummarySpan?,
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
    if (other is! WorkflowExecutionTraceSummaryResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflowName == other.workflowName &&
        executionId == other.executionId &&
        rootExecutionId == other.rootExecutionId &&
        status == other.status &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        valuesDeepEqual(result, other.result) &&
        spanTree == other.spanTree &&
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
    valueDeepHashCode(result),
    spanTree,
    parentExecutionId,
    totalDurationMs,
  );

  @override
  String toString() =>
      'WorkflowExecutionTraceSummaryResponse('
      'workflowName: $workflowName, '
      'executionId: $executionId, '
      'rootExecutionId: $rootExecutionId, '
      'status: $status, '
      'startTime: $startTime, '
      'endTime: $endTime, '
      'result: $result, '
      'spanTree: $spanTree, '
      'parentExecutionId: $parentExecutionId, '
      'totalDurationMs: $totalDurationMs'
      ')';
}
