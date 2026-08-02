part of 'triggers.dart';

/// Parameters for creating a [Trigger].
class TriggerCreateParams {
  /// Required. The interaction request template to be executed.
  final CreateInteractionParams interaction;

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

  /// Creates a [TriggerCreateParams].
  const TriggerCreateParams({
    required this.interaction,
    required this.schedule,
    required this.timeZone,
    this.displayName,
    this.environmentId,
    this.executionTimeoutSeconds,
    this.maxConsecutiveFailures,
  });

  /// Creates a [TriggerCreateParams] from JSON.
  factory TriggerCreateParams.fromJson(Map<String, dynamic> json) =>
      TriggerCreateParams(
        interaction: CreateInteractionParams.fromJson(
          json['interaction'] as Map<String, dynamic>,
        ),
        schedule: json['schedule'] as String,
        timeZone: json['time_zone'] as String,
        displayName: json['display_name'] as String?,
        environmentId: json['environment_id'] as String?,
        executionTimeoutSeconds: json['execution_timeout_seconds'] as int?,
        maxConsecutiveFailures: json['max_consecutive_failures'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'interaction': interaction.toJson(),
    'schedule': schedule,
    'time_zone': timeZone,
    if (displayName != null) 'display_name': displayName,
    if (environmentId != null) 'environment_id': environmentId,
    if (executionTimeoutSeconds != null)
      'execution_timeout_seconds': executionTimeoutSeconds,
    if (maxConsecutiveFailures != null)
      'max_consecutive_failures': maxConsecutiveFailures,
  };

  /// Creates a copy with replaced values.
  TriggerCreateParams copyWith({
    Object? interaction = unsetCopyWithValue,
    Object? schedule = unsetCopyWithValue,
    Object? timeZone = unsetCopyWithValue,
    Object? displayName = unsetCopyWithValue,
    Object? environmentId = unsetCopyWithValue,
    Object? executionTimeoutSeconds = unsetCopyWithValue,
    Object? maxConsecutiveFailures = unsetCopyWithValue,
  }) {
    return TriggerCreateParams(
      interaction: interaction == unsetCopyWithValue
          ? this.interaction
          : interaction! as CreateInteractionParams,
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
    );
  }
}
