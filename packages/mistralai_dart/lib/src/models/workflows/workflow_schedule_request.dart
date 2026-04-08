import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'schedule_definition.dart';

/// Request to schedule a workflow.
@immutable
class WorkflowScheduleRequest {
  /// The schedule definition.
  final ScheduleDefinition schedule;

  /// Optional schedule identifier.
  final String? scheduleId;

  /// The deployment name.
  final String? deploymentName;

  /// The workflow identifier.
  final String? workflowIdentifier;

  /// The registration identifier.
  final String? workflowRegistrationId;

  /// The task queue name.
  final String? workflowTaskQueue;

  /// The workflow version identifier.
  final String? workflowVersionId;

  /// Creates a [WorkflowScheduleRequest].
  const WorkflowScheduleRequest({
    required this.schedule,
    this.scheduleId,
    this.deploymentName,
    this.workflowIdentifier,
    this.workflowRegistrationId,
    this.workflowTaskQueue,
    this.workflowVersionId,
  });

  /// Creates a [WorkflowScheduleRequest] from JSON.
  factory WorkflowScheduleRequest.fromJson(Map<String, dynamic> json) =>
      WorkflowScheduleRequest(
        schedule: ScheduleDefinition.fromJson(
          json['schedule'] as Map<String, dynamic>,
        ),
        scheduleId: json['schedule_id'] as String?,
        deploymentName: json['deployment_name'] as String?,
        workflowIdentifier: json['workflow_identifier'] as String?,
        workflowRegistrationId: json['workflow_registration_id'] as String?,
        workflowTaskQueue: json['workflow_task_queue'] as String?,
        workflowVersionId: json['workflow_version_id'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'schedule': schedule.toJson(),
    if (scheduleId != null) 'schedule_id': scheduleId,
    if (deploymentName != null) 'deployment_name': deploymentName,
    if (workflowIdentifier != null) 'workflow_identifier': workflowIdentifier,
    if (workflowRegistrationId != null)
      'workflow_registration_id': workflowRegistrationId,
    if (workflowTaskQueue != null) 'workflow_task_queue': workflowTaskQueue,
    if (workflowVersionId != null) 'workflow_version_id': workflowVersionId,
  };

  /// Creates a copy with replaced values.
  WorkflowScheduleRequest copyWith({
    ScheduleDefinition? schedule,
    Object? scheduleId = unsetCopyWithValue,
    Object? deploymentName = unsetCopyWithValue,
    Object? workflowIdentifier = unsetCopyWithValue,
    Object? workflowRegistrationId = unsetCopyWithValue,
    Object? workflowTaskQueue = unsetCopyWithValue,
    Object? workflowVersionId = unsetCopyWithValue,
  }) {
    return WorkflowScheduleRequest(
      schedule: schedule ?? this.schedule,
      scheduleId: scheduleId == unsetCopyWithValue
          ? this.scheduleId
          : scheduleId as String?,
      deploymentName: deploymentName == unsetCopyWithValue
          ? this.deploymentName
          : deploymentName as String?,
      workflowIdentifier: workflowIdentifier == unsetCopyWithValue
          ? this.workflowIdentifier
          : workflowIdentifier as String?,
      workflowRegistrationId: workflowRegistrationId == unsetCopyWithValue
          ? this.workflowRegistrationId
          : workflowRegistrationId as String?,
      workflowTaskQueue: workflowTaskQueue == unsetCopyWithValue
          ? this.workflowTaskQueue
          : workflowTaskQueue as String?,
      workflowVersionId: workflowVersionId == unsetCopyWithValue
          ? this.workflowVersionId
          : workflowVersionId as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowScheduleRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return schedule == other.schedule &&
        scheduleId == other.scheduleId &&
        deploymentName == other.deploymentName &&
        workflowIdentifier == other.workflowIdentifier &&
        workflowRegistrationId == other.workflowRegistrationId &&
        workflowTaskQueue == other.workflowTaskQueue &&
        workflowVersionId == other.workflowVersionId;
  }

  @override
  int get hashCode => Object.hash(
    schedule,
    scheduleId,
    deploymentName,
    workflowIdentifier,
    workflowRegistrationId,
    workflowTaskQueue,
    workflowVersionId,
  );

  @override
  String toString() =>
      'WorkflowScheduleRequest('
      'schedule: $schedule, '
      'scheduleId: $scheduleId, '
      'deploymentName: $deploymentName, '
      'workflowIdentifier: $workflowIdentifier, '
      'workflowRegistrationId: $workflowRegistrationId, '
      'workflowTaskQueue: $workflowTaskQueue, '
      'workflowVersionId: $workflowVersionId'
      ')';
}
