part of 'triggers.dart';

/// The status of a [TriggerExecution].
enum TriggerExecutionStatus {
  /// The execution is currently in progress.
  inProgress,

  /// The execution completed successfully.
  completed,

  /// The execution failed.
  failed,

  /// The execution was skipped (e.g., previous execution still running).
  skipped,

  /// The execution timed out.
  timedOut,
}

/// Converts a JSON string to a [TriggerExecutionStatus], or `null` if
/// unrecognized (forward-compatible).
TriggerExecutionStatus? triggerExecutionStatusFromString(String? value) {
  return switch (value) {
    'in_progress' => TriggerExecutionStatus.inProgress,
    'completed' => TriggerExecutionStatus.completed,
    'failed' => TriggerExecutionStatus.failed,
    'skipped' => TriggerExecutionStatus.skipped,
    'timed_out' => TriggerExecutionStatus.timedOut,
    _ => null,
  };
}

/// Converts a [TriggerExecutionStatus] to its JSON string.
String triggerExecutionStatusToString(TriggerExecutionStatus value) {
  return switch (value) {
    TriggerExecutionStatus.inProgress => 'in_progress',
    TriggerExecutionStatus.completed => 'completed',
    TriggerExecutionStatus.failed => 'failed',
    TriggerExecutionStatus.skipped => 'skipped',
    TriggerExecutionStatus.timedOut => 'timed_out',
  };
}

/// An execution instance of a [Trigger].
class TriggerExecution {
  /// Required. Output only. Identifier. The ID of the trigger execution.
  final String id;

  /// Required. Output only. Identifier. The ID of the trigger that created
  /// this execution.
  final String triggerId;

  /// Output only. The ID of the interaction created by this execution, if
  /// any.
  final String? interactionId;

  /// Output only. The environment ID used for the execution.
  final String? environmentId;

  /// Output only. The error message if the execution failed.
  final String? error;

  /// Output only. The time when the execution was scheduled to run.
  final DateTime? scheduledTime;

  /// Output only. The time when the execution started.
  final DateTime? startTime;

  /// Output only. The time when the execution finished.
  final DateTime? endTime;

  /// Output only. The status of the execution.
  final TriggerExecutionStatus? status;

  /// Creates a [TriggerExecution].
  const TriggerExecution({
    required this.id,
    required this.triggerId,
    this.interactionId,
    this.environmentId,
    this.error,
    this.scheduledTime,
    this.startTime,
    this.endTime,
    this.status,
  });

  /// Creates a [TriggerExecution] from JSON.
  factory TriggerExecution.fromJson(Map<String, dynamic> json) =>
      TriggerExecution(
        id: json['id'] as String,
        triggerId: json['trigger_id'] as String,
        interactionId: json['interaction_id'] as String?,
        environmentId: json['environment_id'] as String?,
        error: json['error'] as String?,
        scheduledTime: json['scheduled_time'] != null
            ? DateTime.parse(json['scheduled_time'] as String)
            : null,
        startTime: json['start_time'] != null
            ? DateTime.parse(json['start_time'] as String)
            : null,
        endTime: json['end_time'] != null
            ? DateTime.parse(json['end_time'] as String)
            : null,
        status: triggerExecutionStatusFromString(json['status'] as String?),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'trigger_id': triggerId,
    if (interactionId != null) 'interaction_id': interactionId,
    if (environmentId != null) 'environment_id': environmentId,
    if (error != null) 'error': error,
    if (scheduledTime != null)
      'scheduled_time': scheduledTime!.toIso8601String(),
    if (startTime != null) 'start_time': startTime!.toIso8601String(),
    if (endTime != null) 'end_time': endTime!.toIso8601String(),
    if (status != null) 'status': triggerExecutionStatusToString(status!),
  };

  /// Creates a copy with replaced values.
  TriggerExecution copyWith({
    Object? id = unsetCopyWithValue,
    Object? triggerId = unsetCopyWithValue,
    Object? interactionId = unsetCopyWithValue,
    Object? environmentId = unsetCopyWithValue,
    Object? error = unsetCopyWithValue,
    Object? scheduledTime = unsetCopyWithValue,
    Object? startTime = unsetCopyWithValue,
    Object? endTime = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
  }) {
    return TriggerExecution(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      triggerId: triggerId == unsetCopyWithValue
          ? this.triggerId
          : triggerId! as String,
      interactionId: interactionId == unsetCopyWithValue
          ? this.interactionId
          : interactionId as String?,
      environmentId: environmentId == unsetCopyWithValue
          ? this.environmentId
          : environmentId as String?,
      error: error == unsetCopyWithValue ? this.error : error as String?,
      scheduledTime: scheduledTime == unsetCopyWithValue
          ? this.scheduledTime
          : scheduledTime as DateTime?,
      startTime: startTime == unsetCopyWithValue
          ? this.startTime
          : startTime as DateTime?,
      endTime: endTime == unsetCopyWithValue
          ? this.endTime
          : endTime as DateTime?,
      status: status == unsetCopyWithValue
          ? this.status
          : status as TriggerExecutionStatus?,
    );
  }
}
