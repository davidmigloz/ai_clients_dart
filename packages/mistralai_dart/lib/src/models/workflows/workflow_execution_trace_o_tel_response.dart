import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'tempo_get_trace_response.dart';
import 'workflow_execution_status.dart';

/// Response for workflow execution OpenTelemetry trace.
@immutable
class WorkflowExecutionTraceOTelResponse {
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

  /// The data source.
  final String dataSource;

  /// OpenTelemetry trace data.
  final TempoGetTraceResponse? otelTraceData;

  /// OpenTelemetry trace identifier.
  final String? otelTraceId;

  /// The parent execution identifier.
  final String? parentExecutionId;

  /// Total duration in milliseconds.
  final int? totalDurationMs;

  /// Creates a [WorkflowExecutionTraceOTelResponse].
  const WorkflowExecutionTraceOTelResponse({
    required this.workflowName,
    required this.executionId,
    required this.rootExecutionId,
    required this.status,
    required this.startTime,
    required this.endTime,
    required this.result,
    required this.dataSource,
    this.otelTraceData,
    this.otelTraceId,
    this.parentExecutionId,
    this.totalDurationMs,
  });

  /// Creates a [WorkflowExecutionTraceOTelResponse] from JSON.
  factory WorkflowExecutionTraceOTelResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionTraceOTelResponse(
    workflowName: json['workflow_name'] as String? ?? '',
    executionId: json['execution_id'] as String? ?? '',
    rootExecutionId: json['root_execution_id'] as String? ?? '',
    status: json['status'] != null
        ? WorkflowExecutionStatus.fromJson(json['status'] as String)
        : null,
    startTime: json['start_time'] as String? ?? '',
    endTime: json['end_time'] as String?,
    result: json['result'],
    dataSource: json['data_source'] as String? ?? '',
    otelTraceData: json['otel_trace_data'] != null
        ? TempoGetTraceResponse.fromJson(
            json['otel_trace_data'] as Map<String, dynamic>,
          )
        : null,
    otelTraceId: json['otel_trace_id'] as String?,
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
    'data_source': dataSource,
    if (otelTraceData != null) 'otel_trace_data': otelTraceData?.toJson(),
    if (otelTraceId != null) 'otel_trace_id': otelTraceId,
    if (parentExecutionId != null) 'parent_execution_id': parentExecutionId,
    if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionTraceOTelResponse copyWith({
    String? workflowName,
    String? executionId,
    String? rootExecutionId,
    Object? status = unsetCopyWithValue,
    String? startTime,
    Object? endTime = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    String? dataSource,
    Object? otelTraceData = unsetCopyWithValue,
    Object? otelTraceId = unsetCopyWithValue,
    Object? parentExecutionId = unsetCopyWithValue,
    Object? totalDurationMs = unsetCopyWithValue,
  }) {
    return WorkflowExecutionTraceOTelResponse(
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
      dataSource: dataSource ?? this.dataSource,
      otelTraceData: otelTraceData == unsetCopyWithValue
          ? this.otelTraceData
          : otelTraceData as TempoGetTraceResponse?,
      otelTraceId: otelTraceId == unsetCopyWithValue
          ? this.otelTraceId
          : otelTraceId as String?,
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
    if (other is! WorkflowExecutionTraceOTelResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return workflowName == other.workflowName &&
        executionId == other.executionId &&
        rootExecutionId == other.rootExecutionId &&
        status == other.status &&
        startTime == other.startTime &&
        endTime == other.endTime &&
        valuesDeepEqual(result, other.result) &&
        dataSource == other.dataSource &&
        otelTraceData == other.otelTraceData &&
        otelTraceId == other.otelTraceId &&
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
    dataSource,
    otelTraceData,
    otelTraceId,
    parentExecutionId,
    totalDurationMs,
  );

  @override
  String toString() =>
      'WorkflowExecutionTraceOTelResponse('
      'workflowName: $workflowName, '
      'executionId: $executionId, '
      'rootExecutionId: $rootExecutionId, '
      'status: $status, '
      'startTime: $startTime, '
      'endTime: $endTime, '
      'result: $result, '
      'dataSource: $dataSource, '
      'otelTraceData: $otelTraceData, '
      'otelTraceId: $otelTraceId, '
      'parentExecutionId: $parentExecutionId, '
      'totalDurationMs: $totalDurationMs'
      ')';
}
