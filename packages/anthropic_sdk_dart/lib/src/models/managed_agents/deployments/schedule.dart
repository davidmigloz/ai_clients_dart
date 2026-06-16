import 'package:meta/meta.dart';

import '../../beta_timestamp.dart';
import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// A recurring schedule with computed runtime timestamps.
///
/// Discriminated union — only cron is supported currently.
///
/// Variants:
/// - [CronSchedule] — 5-field POSIX cron schedule (type: "cron")
/// - [UnknownSchedule] — Unrecognized type (preserves raw JSON)
sealed class Schedule {
  const Schedule();

  /// Creates a [Schedule] from JSON.
  factory Schedule.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'cron' => CronSchedule.fromJson(json),
      _ => UnknownSchedule.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// 5-field POSIX cron schedule with computed runtime timestamps.
@immutable
class CronSchedule extends Schedule {
  /// The type discriminator. Always `cron`.
  final String type;

  /// 5-field POSIX cron expression: minute hour day-of-month month day-of-week
  /// (e.g., "0 9 * * 1-5" for weekdays at 9am).
  ///
  /// Day-of-week is 0-7 where 0 and 7 both mean Sunday. Extended cron syntax —
  /// seconds or year fields, and the special characters L, W, #, and ? — is not
  /// supported, nor are predefined shortcuts (`@daily`).
  ///
  /// Length must be between 1 and 256 characters.
  final String expression;

  /// IANA timezone identifier (e.g., "America/Los_Angeles", "UTC").
  final String timezone;

  /// Time the most recent scheduled run actually started.
  ///
  /// Null until one completes; preserved after the deployment is archived.
  /// Manual runs do not update this.
  final BetaTimestamp? lastRunAt;

  /// Up to 5 timestamps of upcoming cron occurrences.
  ///
  /// Non-empty for active and paused deployments (reflects what the schedule
  /// would do if unpaused); empty once the deployment is archived
  /// (`archived_at` set). Each fire is offset by a small per-schedule jitter, so
  /// a run will actually start at or shortly after its listed time.
  final List<BetaTimestamp>? upcomingRunsAt;

  /// Creates a [CronSchedule].
  const CronSchedule({
    this.type = 'cron',
    required this.expression,
    required this.timezone,
    this.lastRunAt,
    this.upcomingRunsAt,
  });

  /// Creates a [CronSchedule] from JSON.
  factory CronSchedule.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'cron';
    if (type != 'cron') {
      throw FormatException('CronSchedule: expected type "cron", got "$type"');
    }
    final rawUpcoming = json['upcoming_runs_at'] as List?;
    return CronSchedule(
      type: type,
      expression: json['expression'] as String,
      timezone: json['timezone'] as String,
      lastRunAt: json['last_run_at'] != null
          ? DateTime.parse(json['last_run_at'] as String)
          : null,
      upcomingRunsAt: rawUpcoming
          ?.map((e) => DateTime.parse(e as String))
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'expression': expression,
    'timezone': timezone,
    if (lastRunAt != null) 'last_run_at': lastRunAt!.toUtc().toIso8601String(),
    if (upcomingRunsAt != null)
      'upcoming_runs_at': upcomingRunsAt!
          .map((e) => e.toUtc().toIso8601String())
          .toList(),
  };

  /// Creates a copy with replaced values.
  CronSchedule copyWith({
    String? type,
    String? expression,
    String? timezone,
    Object? lastRunAt = unsetCopyWithValue,
    Object? upcomingRunsAt = unsetCopyWithValue,
  }) {
    return CronSchedule(
      type: type ?? this.type,
      expression: expression ?? this.expression,
      timezone: timezone ?? this.timezone,
      lastRunAt: lastRunAt == unsetCopyWithValue
          ? this.lastRunAt
          : lastRunAt as BetaTimestamp?,
      upcomingRunsAt: upcomingRunsAt == unsetCopyWithValue
          ? this.upcomingRunsAt
          : upcomingRunsAt as List<BetaTimestamp>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CronSchedule &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          expression == other.expression &&
          timezone == other.timezone &&
          lastRunAt == other.lastRunAt &&
          listsEqual(upcomingRunsAt, other.upcomingRunsAt);

  @override
  int get hashCode => Object.hash(
    type,
    expression,
    timezone,
    lastRunAt,
    listHash(upcomingRunsAt),
  );

  @override
  String toString() =>
      'CronSchedule('
      'type: $type, '
      'expression: $expression, '
      'timezone: $timezone, '
      'lastRunAt: $lastRunAt, '
      'upcomingRunsAt: ${upcomingRunsAt == null ? null : '${upcomingRunsAt!.length} items'})';
}

/// Unrecognized schedule type (preserves raw JSON).
@immutable
class UnknownSchedule extends Schedule {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownSchedule].
  const UnknownSchedule({required this.rawJson});

  /// Creates an [UnknownSchedule] from JSON.
  factory UnknownSchedule.fromJson(Map<String, dynamic> json) {
    return UnknownSchedule(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownSchedule &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownSchedule(rawJson: $rawJson)';
}
