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

  /// The run identifier.
  final String? runId;

  /// The name of the deployment that ran this execution.
  final String? deploymentName;

  /// The ID of the user who triggered the execution.
  final String? userId;

  /// The ID of the workflow.
  final String? workflowId;

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
    this.runId,
    this.deploymentName,
    this.userId,
    this.workflowId,
  });

  /// Creates a [WorkflowExecutionTraceOTelResponse] from JSON.
  ///
  /// Throws a [FormatException] if a required field is missing.
  factory WorkflowExecutionTraceOTelResponse.fromJson(
    Map<String, dynamic> json,
  ) {
    final workflowName = json['workflow_name'] as String?;
    if (workflowName == null) {
      throw const FormatException(
        'WorkflowExecutionTraceOTelResponse: missing required field '
        '"workflow_name"',
      );
    }
    final executionId = json['execution_id'] as String?;
    if (executionId == null) {
      throw const FormatException(
        'WorkflowExecutionTraceOTelResponse: missing required field '
        '"execution_id"',
      );
    }
    final rootExecutionId = json['root_execution_id'] as String?;
    if (rootExecutionId == null) {
      throw const FormatException(
        'WorkflowExecutionTraceOTelResponse: missing required field '
        '"root_execution_id"',
      );
    }
    final startTime = json['start_time'] as String?;
    if (startTime == null) {
      throw const FormatException(
        'WorkflowExecutionTraceOTelResponse: missing required field '
        '"start_time"',
      );
    }
    final dataSource = json['data_source'] as String?;
    if (dataSource == null) {
      throw const FormatException(
        'WorkflowExecutionTraceOTelResponse: missing required field '
        '"data_source"',
      );
    }
    return WorkflowExecutionTraceOTelResponse(
      workflowName: workflowName,
      executionId: executionId,
      rootExecutionId: rootExecutionId,
      status: json['status'] != null
          ? WorkflowExecutionStatus.fromJson(json['status'] as String)
          : null,
      startTime: startTime,
      endTime: json['end_time'] as String?,
      result: json['result'],
      dataSource: dataSource,
      otelTraceData: json['otel_trace_data'] != null
          ? TempoGetTraceResponse.fromJson(
              json['otel_trace_data'] as Map<String, dynamic>,
            )
          : null,
      otelTraceId: json['otel_trace_id'] as String?,
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
    'result': result,
    'data_source': dataSource,
    if (otelTraceData != null) 'otel_trace_data': otelTraceData?.toJson(),
    if (otelTraceId != null) 'otel_trace_id': otelTraceId,
    if (parentExecutionId != null) 'parent_execution_id': parentExecutionId,
    if (totalDurationMs != null) 'total_duration_ms': totalDurationMs,
    if (runId != null) 'run_id': runId,
    if (deploymentName != null) 'deployment_name': deploymentName,
    if (userId != null) 'user_id': userId,
    if (workflowId != null) 'workflow_id': workflowId,
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
    Object? runId = unsetCopyWithValue,
    Object? deploymentName = unsetCopyWithValue,
    Object? userId = unsetCopyWithValue,
    Object? workflowId = unsetCopyWithValue,
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
    valueDeepHashCode(result),
    dataSource,
    otelTraceData,
    otelTraceId,
    parentExecutionId,
    totalDurationMs,
    runId,
    deploymentName,
    userId,
    workflowId,
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
      'totalDurationMs: $totalDurationMs, '
      'runId: $runId, '
      'deploymentName: $deploymentName, '
      'userId: $userId, '
      'workflowId: $workflowId'
      ')';
}
