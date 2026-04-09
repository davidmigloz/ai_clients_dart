import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'schedule_calendar.dart';
import 'schedule_interval.dart';
import 'schedule_policy.dart';

/// Definition of a workflow schedule.
@immutable
class ScheduleDefinition {
  /// The input for scheduled executions.
  final Object input;

  /// Optional schedule identifier.
  final String? scheduleId;

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

  /// Creates a [ScheduleDefinition].
  ScheduleDefinition({
    required this.input,
    this.scheduleId,
    List<ScheduleCalendar>? calendars,
    List<ScheduleInterval>? intervals,
    List<String>? cronExpressions,
    this.startAt,
    this.endAt,
    this.jitter,
    this.timeZoneName,
    this.policy,
    List<ScheduleCalendar>? skip,
  }) : calendars = calendars != null ? List.unmodifiable(calendars) : null,
       intervals = intervals != null ? List.unmodifiable(intervals) : null,
       cronExpressions = cronExpressions != null
           ? List.unmodifiable(cronExpressions)
           : null,
       skip = skip != null ? List.unmodifiable(skip) : null;

  /// Creates a [ScheduleDefinition] from JSON.
  factory ScheduleDefinition.fromJson(Map<String, dynamic> json) =>
      ScheduleDefinition(
        input: json['input'] ?? const <String, dynamic>{},
        scheduleId: json['schedule_id'] as String?,
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
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'input': input,
    if (scheduleId != null) 'schedule_id': scheduleId,
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
  };

  /// Creates a copy with replaced values.
  ScheduleDefinition copyWith({
    Object? input,
    Object? scheduleId = unsetCopyWithValue,
    Object? calendars = unsetCopyWithValue,
    Object? intervals = unsetCopyWithValue,
    Object? cronExpressions = unsetCopyWithValue,
    Object? startAt = unsetCopyWithValue,
    Object? endAt = unsetCopyWithValue,
    Object? jitter = unsetCopyWithValue,
    Object? timeZoneName = unsetCopyWithValue,
    Object? policy = unsetCopyWithValue,
    Object? skip = unsetCopyWithValue,
  }) {
    return ScheduleDefinition(
      input: input ?? this.input,
      scheduleId: scheduleId == unsetCopyWithValue
          ? this.scheduleId
          : scheduleId as String?,
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
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleDefinition) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(calendars, other.calendars)) return false;
    if (!listsEqual(intervals, other.intervals)) return false;
    if (!listsEqual(cronExpressions, other.cronExpressions)) return false;
    if (!listsEqual(skip, other.skip)) return false;
    return valuesDeepEqual(input, other.input) &&
        scheduleId == other.scheduleId &&
        startAt == other.startAt &&
        endAt == other.endAt &&
        jitter == other.jitter &&
        timeZoneName == other.timeZoneName &&
        policy == other.policy;
  }

  @override
  int get hashCode => Object.hash(
    valueDeepHashCode(input),
    scheduleId,
    listHash(calendars),
    listHash(intervals),
    listHash(cronExpressions),
    startAt,
    endAt,
    jitter,
    timeZoneName,
    policy,
    listHash(skip),
  );

  @override
  String toString() =>
      'ScheduleDefinition('
      'input: $input, '
      'scheduleId: $scheduleId, '
      'calendars: ${calendars?.length ?? 'null'}, '
      'intervals: ${intervals?.length ?? 'null'}, '
      'cronExpressions: ${cronExpressions?.length ?? 'null'}, '
      'startAt: $startAt, '
      'endAt: $endAt, '
      'jitter: $jitter, '
      'timeZoneName: $timeZoneName, '
      'policy: $policy, '
      'skip: ${skip?.length ?? 'null'}'
      ')';
}
