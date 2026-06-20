import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'schedule_calendar.dart';
import 'schedule_interval.dart';
import 'schedule_policy.dart';

/// Partial definition of a workflow schedule used for updates.
///
/// All fields are optional; only the provided fields are applied.
@immutable
class PartialScheduleDefinition {
  /// The input for scheduled executions.
  final Object? input;

  /// Calendar-based schedules.
  final List<ScheduleCalendar>? calendars;

  /// Interval-based schedules.
  final List<ScheduleInterval>? intervals;

  /// Cron expression schedules.
  final List<String>? cronExpressions;

  /// Calendars to skip.
  final List<ScheduleCalendar>? skip;

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

  /// Maximum number of executions.
  final int? maxExecutions;

  /// Creates a [PartialScheduleDefinition].
  PartialScheduleDefinition({
    this.input,
    List<ScheduleCalendar>? calendars,
    List<ScheduleInterval>? intervals,
    List<String>? cronExpressions,
    List<ScheduleCalendar>? skip,
    this.startAt,
    this.endAt,
    this.jitter,
    this.timeZoneName,
    this.policy,
    this.maxExecutions,
  }) : calendars = calendars != null ? List.unmodifiable(calendars) : null,
       intervals = intervals != null ? List.unmodifiable(intervals) : null,
       cronExpressions = cronExpressions != null
           ? List.unmodifiable(cronExpressions)
           : null,
       skip = skip != null ? List.unmodifiable(skip) : null;

  /// Creates a [PartialScheduleDefinition] from JSON.
  factory PartialScheduleDefinition.fromJson(Map<String, dynamic> json) =>
      PartialScheduleDefinition(
        input: json['input'],
        calendars: (json['calendars'] as List?)
            ?.map((e) => ScheduleCalendar.fromJson(e as Map<String, dynamic>))
            .toList(),
        intervals: (json['intervals'] as List?)
            ?.map((e) => ScheduleInterval.fromJson(e as Map<String, dynamic>))
            .toList(),
        cronExpressions: (json['cron_expressions'] as List?)?.cast<String>(),
        skip: (json['skip'] as List?)
            ?.map((e) => ScheduleCalendar.fromJson(e as Map<String, dynamic>))
            .toList(),
        startAt: json['start_at'] as String?,
        endAt: json['end_at'] as String?,
        jitter: json['jitter'] as String?,
        timeZoneName: json['time_zone_name'] as String?,
        policy: json['policy'] != null
            ? SchedulePolicy.fromJson(json['policy'] as Map<String, dynamic>)
            : null,
        maxExecutions: json['max_executions'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (input != null) 'input': input,
    if (calendars != null)
      'calendars': calendars?.map((e) => e.toJson()).toList(),
    if (intervals != null)
      'intervals': intervals?.map((e) => e.toJson()).toList(),
    if (cronExpressions != null) 'cron_expressions': cronExpressions,
    if (skip != null) 'skip': skip?.map((e) => e.toJson()).toList(),
    if (startAt != null) 'start_at': startAt,
    if (endAt != null) 'end_at': endAt,
    if (jitter != null) 'jitter': jitter,
    if (timeZoneName != null) 'time_zone_name': timeZoneName,
    if (policy != null) 'policy': policy?.toJson(),
    if (maxExecutions != null) 'max_executions': maxExecutions,
  };

  /// Creates a copy with replaced values.
  PartialScheduleDefinition copyWith({
    Object? input = unsetCopyWithValue,
    Object? calendars = unsetCopyWithValue,
    Object? intervals = unsetCopyWithValue,
    Object? cronExpressions = unsetCopyWithValue,
    Object? skip = unsetCopyWithValue,
    Object? startAt = unsetCopyWithValue,
    Object? endAt = unsetCopyWithValue,
    Object? jitter = unsetCopyWithValue,
    Object? timeZoneName = unsetCopyWithValue,
    Object? policy = unsetCopyWithValue,
    Object? maxExecutions = unsetCopyWithValue,
  }) {
    return PartialScheduleDefinition(
      input: input == unsetCopyWithValue ? this.input : input,
      calendars: calendars == unsetCopyWithValue
          ? this.calendars
          : calendars as List<ScheduleCalendar>?,
      intervals: intervals == unsetCopyWithValue
          ? this.intervals
          : intervals as List<ScheduleInterval>?,
      cronExpressions: cronExpressions == unsetCopyWithValue
          ? this.cronExpressions
          : cronExpressions as List<String>?,
      skip: skip == unsetCopyWithValue
          ? this.skip
          : skip as List<ScheduleCalendar>?,
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
      maxExecutions: maxExecutions == unsetCopyWithValue
          ? this.maxExecutions
          : maxExecutions as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PartialScheduleDefinition) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(calendars, other.calendars)) return false;
    if (!listsEqual(intervals, other.intervals)) return false;
    if (!listsEqual(cronExpressions, other.cronExpressions)) return false;
    if (!listsEqual(skip, other.skip)) return false;
    return valuesDeepEqual(input, other.input) &&
        startAt == other.startAt &&
        endAt == other.endAt &&
        jitter == other.jitter &&
        timeZoneName == other.timeZoneName &&
        policy == other.policy &&
        maxExecutions == other.maxExecutions;
  }

  @override
  int get hashCode => Object.hash(
    valueDeepHashCode(input),
    listHash(calendars),
    listHash(intervals),
    listHash(cronExpressions),
    listHash(skip),
    startAt,
    endAt,
    jitter,
    timeZoneName,
    policy,
    maxExecutions,
  );

  @override
  String toString() =>
      'PartialScheduleDefinition('
      'input: $input, '
      'calendars: ${calendars?.length ?? 'null'}, '
      'intervals: ${intervals?.length ?? 'null'}, '
      'cronExpressions: ${cronExpressions?.length ?? 'null'}, '
      'skip: ${skip?.length ?? 'null'}, '
      'startAt: $startAt, '
      'endAt: $endAt, '
      'jitter: $jitter, '
      'timeZoneName: $timeZoneName, '
      'policy: $policy, '
      'maxExecutions: $maxExecutions'
      ')';
}
