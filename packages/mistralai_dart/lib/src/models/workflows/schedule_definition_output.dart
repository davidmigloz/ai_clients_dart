import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'schedule_calendar.dart';
import 'schedule_future_execution.dart';
import 'schedule_interval.dart';
import 'schedule_policy.dart';
import 'schedule_recent_execution.dart';

/// Output definition of a workflow schedule.
@immutable
class ScheduleDefinitionOutput {
  /// The input for scheduled executions.
  final Object input;

  /// The schedule identifier.
  final String scheduleId;

  /// The name of the scheduled workflow.
  final String workflowName;

  /// Whether the schedule is paused.
  final bool paused;

  /// Calendar-based schedules.
  final List<ScheduleCalendar>? calendars;

  /// Interval-based schedules.
  final List<ScheduleInterval>? intervals;

  /// Cron expression schedules.
  final List<String>? cronExpressions;

  /// Schedule start time.
  final String? startAt;

  /// Schedule end time.
  final String? endAt;

  /// Jitter duration.
  final String? jitter;

  /// Time zone name.
  final String? timeZoneName;

  /// Schedule policy.
  final SchedulePolicy? policy;

  /// Calendars to skip.
  final List<ScheduleCalendar>? skip;

  /// The deployment the schedule targets.
  final String? deploymentName;

  /// A note describing the schedule.
  final String? note;

  /// Remaining number of executions, if limited.
  final int? remainingExecutions;

  /// Upcoming scheduled executions.
  final List<ScheduleFutureExecution>? futureExecutions;

  /// Recently started executions.
  final List<ScheduleRecentExecution>? recentExecutions;

  /// Creates a [ScheduleDefinitionOutput].
  ScheduleDefinitionOutput({
    required this.input,
    required this.scheduleId,
    required this.workflowName,
    required this.paused,
    List<ScheduleCalendar>? calendars,
    List<ScheduleInterval>? intervals,
    List<String>? cronExpressions,
    this.startAt,
    this.endAt,
    this.jitter,
    this.timeZoneName,
    this.policy,
    List<ScheduleCalendar>? skip,
    this.deploymentName,
    this.note,
    this.remainingExecutions,
    List<ScheduleFutureExecution>? futureExecutions,
    List<ScheduleRecentExecution>? recentExecutions,
  }) : calendars = calendars != null ? List.unmodifiable(calendars) : null,
       intervals = intervals != null ? List.unmodifiable(intervals) : null,
       cronExpressions = cronExpressions != null
           ? List.unmodifiable(cronExpressions)
           : null,
       skip = skip != null ? List.unmodifiable(skip) : null,
       futureExecutions = futureExecutions != null
           ? List.unmodifiable(futureExecutions)
           : null,
       recentExecutions = recentExecutions != null
           ? List.unmodifiable(recentExecutions)
           : null;

  /// Creates a [ScheduleDefinitionOutput] from JSON.
  factory ScheduleDefinitionOutput.fromJson(Map<String, dynamic> json) =>
      ScheduleDefinitionOutput(
        input: json['input'] ?? const <String, dynamic>{},
        scheduleId: json['schedule_id'] as String? ?? '',
        workflowName: json['workflow_name'] as String? ?? '',
        paused: json['paused'] as bool? ?? false,
        calendars: (json['calendars'] as List?)
            ?.map((e) => ScheduleCalendar.fromJson(e as Map<String, dynamic>))
            .toList(),
        intervals: (json['intervals'] as List?)
            ?.map((e) => ScheduleInterval.fromJson(e as Map<String, dynamic>))
            .toList(),
        cronExpressions: (json['cron_expressions'] as List?)?.cast<String>(),
        startAt: json['start_at'] as String?,
        endAt: json['end_at'] as String?,
        jitter: json['jitter'] as String?,
        timeZoneName: json['time_zone_name'] as String?,
        policy: json['policy'] != null
            ? SchedulePolicy.fromJson(json['policy'] as Map<String, dynamic>)
            : null,
        skip: (json['skip'] as List?)
            ?.map((e) => ScheduleCalendar.fromJson(e as Map<String, dynamic>))
            .toList(),
        deploymentName: json['deployment_name'] as String?,
        note: json['note'] as String?,
        remainingExecutions: json['remaining_executions'] as int?,
        futureExecutions: (json['future_executions'] as List?)
            ?.map(
              (e) =>
                  ScheduleFutureExecution.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
        recentExecutions: (json['recent_executions'] as List?)
            ?.map(
              (e) =>
                  ScheduleRecentExecution.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input': input,
    'schedule_id': scheduleId,
    'workflow_name': workflowName,
    'paused': paused,
    if (calendars != null)
      'calendars': calendars?.map((e) => e.toJson()).toList(),
    if (intervals != null)
      'intervals': intervals?.map((e) => e.toJson()).toList(),
    if (cronExpressions != null) 'cron_expressions': cronExpressions,
    if (startAt != null) 'start_at': startAt,
    if (endAt != null) 'end_at': endAt,
    if (jitter != null) 'jitter': jitter,
    if (timeZoneName != null) 'time_zone_name': timeZoneName,
    if (policy != null) 'policy': policy?.toJson(),
    if (skip != null) 'skip': skip?.map((e) => e.toJson()).toList(),
    if (deploymentName != null) 'deployment_name': deploymentName,
    if (note != null) 'note': note,
    if (remainingExecutions != null)
      'remaining_executions': remainingExecutions,
    if (futureExecutions != null)
      'future_executions': futureExecutions?.map((e) => e.toJson()).toList(),
    if (recentExecutions != null)
      'recent_executions': recentExecutions?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ScheduleDefinitionOutput copyWith({
    Object? input,
    String? scheduleId,
    String? workflowName,
    bool? paused,
    Object? calendars = unsetCopyWithValue,
    Object? intervals = unsetCopyWithValue,
    Object? cronExpressions = unsetCopyWithValue,
    Object? startAt = unsetCopyWithValue,
    Object? endAt = unsetCopyWithValue,
    Object? jitter = unsetCopyWithValue,
    Object? timeZoneName = unsetCopyWithValue,
    Object? policy = unsetCopyWithValue,
    Object? skip = unsetCopyWithValue,
    Object? deploymentName = unsetCopyWithValue,
    Object? note = unsetCopyWithValue,
    Object? remainingExecutions = unsetCopyWithValue,
    Object? futureExecutions = unsetCopyWithValue,
    Object? recentExecutions = unsetCopyWithValue,
  }) {
    return ScheduleDefinitionOutput(
      input: input ?? this.input,
      scheduleId: scheduleId ?? this.scheduleId,
      workflowName: workflowName ?? this.workflowName,
      paused: paused ?? this.paused,
      calendars: calendars == unsetCopyWithValue
          ? this.calendars
          : calendars as List<ScheduleCalendar>?,
      intervals: intervals == unsetCopyWithValue
          ? this.intervals
          : intervals as List<ScheduleInterval>?,
      cronExpressions: cronExpressions == unsetCopyWithValue
          ? this.cronExpressions
          : cronExpressions as List<String>?,
      startAt: startAt == unsetCopyWithValue
          ? this.startAt
          : startAt as String?,
      endAt: endAt == unsetCopyWithValue ? this.endAt : endAt as String?,
      jitter: jitter == unsetCopyWithValue ? this.jitter : jitter as String?,
      timeZoneName: timeZoneName == unsetCopyWithValue
          ? this.timeZoneName
          : timeZoneName as String?,
      policy: policy == unsetCopyWithValue
          ? this.policy
          : policy as SchedulePolicy?,
      skip: skip == unsetCopyWithValue
          ? this.skip
          : skip as List<ScheduleCalendar>?,
      deploymentName: deploymentName == unsetCopyWithValue
          ? this.deploymentName
          : deploymentName as String?,
      note: note == unsetCopyWithValue ? this.note : note as String?,
      remainingExecutions: remainingExecutions == unsetCopyWithValue
          ? this.remainingExecutions
          : remainingExecutions as int?,
      futureExecutions: futureExecutions == unsetCopyWithValue
          ? this.futureExecutions
          : futureExecutions as List<ScheduleFutureExecution>?,
      recentExecutions: recentExecutions == unsetCopyWithValue
          ? this.recentExecutions
          : recentExecutions as List<ScheduleRecentExecution>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleDefinitionOutput) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(calendars, other.calendars)) return false;
    if (!listsEqual(intervals, other.intervals)) return false;
    if (!listsEqual(cronExpressions, other.cronExpressions)) return false;
    if (!listsEqual(skip, other.skip)) return false;
    if (!listsEqual(futureExecutions, other.futureExecutions)) return false;
    if (!listsEqual(recentExecutions, other.recentExecutions)) return false;
    return valuesDeepEqual(input, other.input) &&
        scheduleId == other.scheduleId &&
        workflowName == other.workflowName &&
        paused == other.paused &&
        startAt == other.startAt &&
        endAt == other.endAt &&
        jitter == other.jitter &&
        timeZoneName == other.timeZoneName &&
        policy == other.policy &&
        deploymentName == other.deploymentName &&
        note == other.note &&
        remainingExecutions == other.remainingExecutions;
  }

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(input),
    scheduleId,
    workflowName,
    paused,
    listHash(calendars),
    listHash(intervals),
    listHash(cronExpressions),
    startAt,
    endAt,
    jitter,
    timeZoneName,
    policy,
    listHash(skip),
    deploymentName,
    note,
    remainingExecutions,
    listHash(futureExecutions),
    listHash(recentExecutions),
  ]);

  @override
  String toString() =>
      'ScheduleDefinitionOutput('
      'input: $input, '
      'scheduleId: $scheduleId, '
      'workflowName: $workflowName, '
      'paused: $paused, '
      'calendars: ${calendars?.length ?? 'null'}, '
      'intervals: ${intervals?.length ?? 'null'}, '
      'cronExpressions: ${cronExpressions?.length ?? 'null'}, '
      'startAt: $startAt, '
      'endAt: $endAt, '
      'jitter: $jitter, '
      'timeZoneName: $timeZoneName, '
      'policy: $policy, '
      'skip: ${skip?.length ?? 'null'}, '
      'deploymentName: $deploymentName, '
      'note: $note, '
      'remainingExecutions: $remainingExecutions, '
      'futureExecutions: ${futureExecutions?.length ?? 'null'}, '
      'recentExecutions: ${recentExecutions?.length ?? 'null'}'
      ')';
}
