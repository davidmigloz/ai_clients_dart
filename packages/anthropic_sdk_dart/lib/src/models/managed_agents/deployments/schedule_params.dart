import 'package:meta/meta.dart';

import '../../common/equality_helpers.dart';

/// A recurring schedule.
///
/// Discriminated union — only cron is supported currently.
///
/// Variants:
/// - [CronScheduleParams] — 5-field POSIX cron schedule (type: "cron")
/// - [UnknownScheduleParams] — Unrecognized type (preserves raw JSON)
sealed class ScheduleParams {
  const ScheduleParams();

  /// Creates a [ScheduleParams] from JSON.
  factory ScheduleParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'cron' => CronScheduleParams.fromJson(json),
      _ => UnknownScheduleParams.fromJson(json),
    };
  }

  /// Creates parameters for a cron schedule.
  ///
  /// The `type` discriminator is fixed to `cron` by [CronScheduleParams].
  const factory ScheduleParams.cron({
    required String expression,
    required String timezone,
  }) = CronScheduleParams;

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// 5-field POSIX cron schedule.
///
/// Literal wall-clock matching in the configured timezone.
@immutable
class CronScheduleParams extends ScheduleParams {
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
  ///
  /// Validated against the IANA timezone database.
  final String timezone;

  /// Creates a [CronScheduleParams].
  const CronScheduleParams({
    this.type = 'cron',
    required this.expression,
    required this.timezone,
  });

  /// Creates a [CronScheduleParams] from JSON.
  factory CronScheduleParams.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? 'cron';
    if (type != 'cron') {
      throw FormatException(
        'CronScheduleParams: expected type "cron", got "$type"',
      );
    }
    return CronScheduleParams(
      type: type,
      expression: json['expression'] as String,
      timezone: json['timezone'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'expression': expression,
    'timezone': timezone,
  };

  /// Creates a copy with replaced values.
  CronScheduleParams copyWith({
    String? type,
    String? expression,
    String? timezone,
  }) {
    return CronScheduleParams(
      type: type ?? this.type,
      expression: expression ?? this.expression,
      timezone: timezone ?? this.timezone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CronScheduleParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          expression == other.expression &&
          timezone == other.timezone;

  @override
  int get hashCode => Object.hash(type, expression, timezone);

  @override
  String toString() =>
      'CronScheduleParams('
      'type: $type, '
      'expression: $expression, '
      'timezone: $timezone)';
}

/// Unrecognized schedule params type (preserves raw JSON).
@immutable
class UnknownScheduleParams extends ScheduleParams {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownScheduleParams].
  const UnknownScheduleParams({required this.rawJson});

  /// Creates an [UnknownScheduleParams] from JSON.
  factory UnknownScheduleParams.fromJson(Map<String, dynamic> json) {
    return UnknownScheduleParams(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownScheduleParams &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownScheduleParams(rawJson: $rawJson)';
}
