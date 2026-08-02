part of 'triggers.dart';

/// The status of a [Trigger].
enum TriggerStatus {
  /// The trigger is active and will fire on schedule.
  active,

  /// The trigger is paused and will not fire.
  paused,

  /// The trigger has entered an error state due to consecutive failures.
  error,
}

/// Converts a JSON string to a [TriggerStatus], or `null` if unrecognized
/// (forward-compatible).
TriggerStatus? triggerStatusFromString(String? value) {
  return switch (value) {
    'active' => TriggerStatus.active,
    'paused' => TriggerStatus.paused,
    'error' => TriggerStatus.error,
    _ => null,
  };
}

/// Converts a [TriggerStatus] to its JSON string.
String triggerStatusToString(TriggerStatus value) {
  return switch (value) {
    TriggerStatus.active => 'active',
    TriggerStatus.paused => 'paused',
    TriggerStatus.error => 'error',
  };
}

/// A trigger configuration that is scheduled to run an agent.
class Trigger {
  /// Required. Output only. Identifier. The ID of the trigger.
  final String id;

  /// Required. The interaction request template to be executed.
  final Interaction interaction;

  /// Required. The cron schedule on which the trigger should run. Standard
  /// cron format.
  final String schedule;

  /// Required. Time zone in which the schedule should be interpreted.
  final String timeZone;

  /// Optional. The display name of the trigger.
  final String? displayName;

  /// Optional. The environment ID for the trigger execution.
  final String? environmentId;

  /// Optional. The execution timeout for the triggered interaction.
  final int? executionTimeoutSeconds;

  /// Optional. The maximum number of consecutive failures allowed before the
  /// trigger is automatically paused (status becomes ERROR).
  final int? maxConsecutiveFailures;

  /// Output only. The number of consecutive failures that have occurred
  /// since the last successful execution.
  final int? consecutiveFailureCount;

  /// Output only. The ID of the last interaction created by this trigger.
  final String? previousInteractionId;

  /// Output only. The current status of the trigger.
  final TriggerStatus? status;

  /// Output only. The time when the trigger was created.
  final DateTime? createTime;

  /// Output only. The time when the trigger was last updated.
  final DateTime? updateTime;

  /// Output only. The time when the trigger was last run.
  final DateTime? lastRunTime;

  /// Output only. The time when the trigger is scheduled to run next.
  final DateTime? nextRunTime;

  /// Output only. The time when the trigger was last paused.
  final DateTime? lastPauseTime;

  /// Output only. The time when the trigger was last resumed.
  final DateTime? lastResumeTime;

  /// Creates a [Trigger].
  const Trigger({
    required this.id,
    required this.interaction,
    required this.schedule,
    required this.timeZone,
    this.displayName,
    this.environmentId,
    this.executionTimeoutSeconds,
    this.maxConsecutiveFailures,
    this.consecutiveFailureCount,
    this.previousInteractionId,
    this.status,
    this.createTime,
    this.updateTime,
    this.lastRunTime,
    this.nextRunTime,
    this.lastPauseTime,
    this.lastResumeTime,
  });

  /// Creates a [Trigger] from JSON.
  factory Trigger.fromJson(Map<String, dynamic> json) => Trigger(
    id: json['id'] as String,
    interaction: Interaction.fromJson(
      json['interaction'] as Map<String, dynamic>,
    ),
    schedule: json['schedule'] as String,
    timeZone: json['time_zone'] as String,
    displayName: json['display_name'] as String?,
    environmentId: json['environment_id'] as String?,
    executionTimeoutSeconds: json['execution_timeout_seconds'] as int?,
    maxConsecutiveFailures: json['max_consecutive_failures'] as int?,
    consecutiveFailureCount: json['consecutive_failure_count'] as int?,
    previousInteractionId: json['previous_interaction_id'] as String?,
    status: triggerStatusFromString(json['status'] as String?),
    createTime: json['create_time'] != null
        ? DateTime.parse(json['create_time'] as String)
        : null,
    updateTime: json['update_time'] != null
        ? DateTime.parse(json['update_time'] as String)
        : null,
    lastRunTime: json['last_run_time'] != null
        ? DateTime.parse(json['last_run_time'] as String)
        : null,
    nextRunTime: json['next_run_time'] != null
        ? DateTime.parse(json['next_run_time'] as String)
        : null,
    lastPauseTime: json['last_pause_time'] != null
        ? DateTime.parse(json['last_pause_time'] as String)
        : null,
    lastResumeTime: json['last_resume_time'] != null
        ? DateTime.parse(json['last_resume_time'] as String)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'interaction': interaction.toJson(),
    'schedule': schedule,
    'time_zone': timeZone,
    if (displayName != null) 'display_name': displayName,
    if (environmentId != null) 'environment_id': environmentId,
    if (executionTimeoutSeconds != null)
      'execution_timeout_seconds': executionTimeoutSeconds,
    if (maxConsecutiveFailures != null)
      'max_consecutive_failures': maxConsecutiveFailures,
    if (consecutiveFailureCount != null)
      'consecutive_failure_count': consecutiveFailureCount,
    if (previousInteractionId != null)
      'previous_interaction_id': previousInteractionId,
    if (status != null) 'status': triggerStatusToString(status!),
    if (createTime != null) 'create_time': createTime!.toIso8601String(),
    if (updateTime != null) 'update_time': updateTime!.toIso8601String(),
    if (lastRunTime != null) 'last_run_time': lastRunTime!.toIso8601String(),
    if (nextRunTime != null) 'next_run_time': nextRunTime!.toIso8601String(),
    if (lastPauseTime != null)
      'last_pause_time': lastPauseTime!.toIso8601String(),
    if (lastResumeTime != null)
      'last_resume_time': lastResumeTime!.toIso8601String(),
  };

  /// Creates a copy with replaced values.
  Trigger copyWith({
    Object? id = unsetCopyWithValue,
    Object? interaction = unsetCopyWithValue,
    Object? schedule = unsetCopyWithValue,
    Object? timeZone = unsetCopyWithValue,
    Object? displayName = unsetCopyWithValue,
    Object? environmentId = unsetCopyWithValue,
    Object? executionTimeoutSeconds = unsetCopyWithValue,
    Object? maxConsecutiveFailures = unsetCopyWithValue,
    Object? consecutiveFailureCount = unsetCopyWithValue,
    Object? previousInteractionId = unsetCopyWithValue,
    Object? status = unsetCopyWithValue,
    Object? createTime = unsetCopyWithValue,
    Object? updateTime = unsetCopyWithValue,
    Object? lastRunTime = unsetCopyWithValue,
    Object? nextRunTime = unsetCopyWithValue,
    Object? lastPauseTime = unsetCopyWithValue,
    Object? lastResumeTime = unsetCopyWithValue,
  }) {
    return Trigger(
      id: id == unsetCopyWithValue ? this.id : id! as String,
      interaction: interaction == unsetCopyWithValue
          ? this.interaction
          : interaction! as Interaction,
      schedule: schedule == unsetCopyWithValue
          ? this.schedule
          : schedule! as String,
      timeZone: timeZone == unsetCopyWithValue
          ? this.timeZone
          : timeZone! as String,
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
      environmentId: environmentId == unsetCopyWithValue
          ? this.environmentId
          : environmentId as String?,
      executionTimeoutSeconds: executionTimeoutSeconds == unsetCopyWithValue
          ? this.executionTimeoutSeconds
          : executionTimeoutSeconds as int?,
      maxConsecutiveFailures: maxConsecutiveFailures == unsetCopyWithValue
          ? this.maxConsecutiveFailures
          : maxConsecutiveFailures as int?,
      consecutiveFailureCount: consecutiveFailureCount == unsetCopyWithValue
          ? this.consecutiveFailureCount
          : consecutiveFailureCount as int?,
      previousInteractionId: previousInteractionId == unsetCopyWithValue
          ? this.previousInteractionId
          : previousInteractionId as String?,
      status: status == unsetCopyWithValue
          ? this.status
          : status as TriggerStatus?,
      createTime: createTime == unsetCopyWithValue
          ? this.createTime
          : createTime as DateTime?,
      updateTime: updateTime == unsetCopyWithValue
          ? this.updateTime
          : updateTime as DateTime?,
      lastRunTime: lastRunTime == unsetCopyWithValue
          ? this.lastRunTime
          : lastRunTime as DateTime?,
      nextRunTime: nextRunTime == unsetCopyWithValue
          ? this.nextRunTime
          : nextRunTime as DateTime?,
      lastPauseTime: lastPauseTime == unsetCopyWithValue
          ? this.lastPauseTime
          : lastPauseTime as DateTime?,
      lastResumeTime: lastResumeTime == unsetCopyWithValue
          ? this.lastResumeTime
          : lastResumeTime as DateTime?,
    );
  }
}
