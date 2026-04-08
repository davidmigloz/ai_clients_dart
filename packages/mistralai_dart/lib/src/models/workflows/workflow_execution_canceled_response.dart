import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'workflow_execution_canceled_attributes.dart';

/// Workflow execution canceled event.
@immutable
class WorkflowExecutionCanceledResponse {
  /// The event identifier.
  final String eventId;

  /// The event timestamp.
  final int eventTimestamp;

  /// The event type.
  final String eventType;

  /// The root workflow execution ID.
  final String rootWorkflowExecId;

  /// The parent workflow execution ID.
  final String? parentWorkflowExecId;

  /// The workflow execution ID.
  final String workflowExecId;

  /// The workflow run ID.
  final String workflowRunId;

  /// The workflow name.
  final String workflowName;

  /// The event attributes.
  final WorkflowExecutionCanceledAttributes attributes;

  /// Creates a [WorkflowExecutionCanceledResponse].
  const WorkflowExecutionCanceledResponse({
    required this.eventId,
    required this.eventTimestamp,
    this.eventType = 'WORKFLOW_EXECUTION_CANCELED',
    required this.rootWorkflowExecId,
    required this.parentWorkflowExecId,
    required this.workflowExecId,
    required this.workflowRunId,
    required this.workflowName,
    required this.attributes,
  });

  /// Creates a [WorkflowExecutionCanceledResponse] from JSON.
  factory WorkflowExecutionCanceledResponse.fromJson(
    Map<String, dynamic> json,
  ) => WorkflowExecutionCanceledResponse(
    eventId: json['event_id'] as String? ?? '',
    eventTimestamp: json['event_timestamp'] as int? ?? 0,
    eventType: json['event_type'] as String? ?? 'WORKFLOW_EXECUTION_CANCELED',
    rootWorkflowExecId: json['root_workflow_exec_id'] as String? ?? '',
    parentWorkflowExecId: json['parent_workflow_exec_id'] as String?,
    workflowExecId: json['workflow_exec_id'] as String? ?? '',
    workflowRunId: json['workflow_run_id'] as String? ?? '',
    workflowName: json['workflow_name'] as String? ?? '',
    attributes: WorkflowExecutionCanceledAttributes.fromJson(
      json['attributes'] as Map<String, dynamic>,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'event_id': eventId,
    'event_timestamp': eventTimestamp,
    'event_type': eventType,
    'root_workflow_exec_id': rootWorkflowExecId,
    'parent_workflow_exec_id': parentWorkflowExecId,
    'workflow_exec_id': workflowExecId,
    'workflow_run_id': workflowRunId,
    'workflow_name': workflowName,
    'attributes': attributes.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowExecutionCanceledResponse copyWith({
    String? eventId,
    int? eventTimestamp,
    String? eventType,
    String? rootWorkflowExecId,
    Object? parentWorkflowExecId = unsetCopyWithValue,
    String? workflowExecId,
    String? workflowRunId,
    String? workflowName,
    WorkflowExecutionCanceledAttributes? attributes,
  }) {
    return WorkflowExecutionCanceledResponse(
      eventId: eventId ?? this.eventId,
      eventTimestamp: eventTimestamp ?? this.eventTimestamp,
      eventType: eventType ?? this.eventType,
      rootWorkflowExecId: rootWorkflowExecId ?? this.rootWorkflowExecId,
      parentWorkflowExecId: parentWorkflowExecId == unsetCopyWithValue
          ? this.parentWorkflowExecId
          : parentWorkflowExecId as String?,
      workflowExecId: workflowExecId ?? this.workflowExecId,
      workflowRunId: workflowRunId ?? this.workflowRunId,
      workflowName: workflowName ?? this.workflowName,
      attributes: attributes ?? this.attributes,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowExecutionCanceledResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return eventId == other.eventId &&
        eventTimestamp == other.eventTimestamp &&
        eventType == other.eventType &&
        rootWorkflowExecId == other.rootWorkflowExecId &&
        parentWorkflowExecId == other.parentWorkflowExecId &&
        workflowExecId == other.workflowExecId &&
        workflowRunId == other.workflowRunId &&
        workflowName == other.workflowName &&
        attributes == other.attributes;
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    eventTimestamp,
    eventType,
    rootWorkflowExecId,
    parentWorkflowExecId,
    workflowExecId,
    workflowRunId,
    workflowName,
    attributes,
  );

  @override
  String toString() =>
      'WorkflowExecutionCanceledResponse('
      'eventId: $eventId, '
      'eventTimestamp: $eventTimestamp, '
      'eventType: $eventType, '
      'rootWorkflowExecId: $rootWorkflowExecId, '
      'parentWorkflowExecId: $parentWorkflowExecId, '
      'workflowExecId: $workflowExecId, '
      'workflowRunId: $workflowRunId, '
      'workflowName: $workflowName, '
      'attributes: $attributes'
      ')';
}
