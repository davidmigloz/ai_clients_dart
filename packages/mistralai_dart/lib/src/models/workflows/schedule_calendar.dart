import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'schedule_range.dart';

/// Calendar specification for a schedule.
@immutable
class ScheduleCalendar {
  /// Optional comment.
  final String? comment;

  /// Day of month ranges.
  final List<ScheduleRange>? dayOfMonth;

  /// Day of week ranges.
  final List<ScheduleRange>? dayOfWeek;

  /// Hour ranges.
  final List<ScheduleRange>? hour;

  /// Minute ranges.
  final List<ScheduleRange>? minute;

  /// Month ranges.
  final List<ScheduleRange>? month;

  /// Second ranges.
  final List<ScheduleRange>? second;

  /// Year ranges.
  final List<ScheduleRange>? year;

  /// Creates a [ScheduleCalendar].
  ScheduleCalendar({
    this.comment,
    List<ScheduleRange>? dayOfMonth,
    List<ScheduleRange>? dayOfWeek,
    List<ScheduleRange>? hour,
    List<ScheduleRange>? minute,
    List<ScheduleRange>? month,
    List<ScheduleRange>? second,
    List<ScheduleRange>? year,
  }) : dayOfMonth = dayOfMonth != null ? List.unmodifiable(dayOfMonth) : null,
       dayOfWeek = dayOfWeek != null ? List.unmodifiable(dayOfWeek) : null,
       hour = hour != null ? List.unmodifiable(hour) : null,
       minute = minute != null ? List.unmodifiable(minute) : null,
       month = month != null ? List.unmodifiable(month) : null,
       second = second != null ? List.unmodifiable(second) : null,
       year = year != null ? List.unmodifiable(year) : null;

  /// Creates a [ScheduleCalendar] from JSON.
  factory ScheduleCalendar.fromJson(Map<String, dynamic> json) =>
      ScheduleCalendar(
        comment: json['comment'] as String?,
        dayOfMonth: (json['day_of_month'] as List?)
            ?.map((e) => ScheduleRange.fromJson(e as Map<String, dynamic>))
            .toList(),
        dayOfWeek: (json['day_of_week'] as List?)
            ?.map((e) => ScheduleRange.fromJson(e as Map<String, dynamic>))
            .toList(),
        hour: (json['hour'] as List?)
            ?.map((e) => ScheduleRange.fromJson(e as Map<String, dynamic>))
            .toList(),
        minute: (json['minute'] as List?)
            ?.map((e) => ScheduleRange.fromJson(e as Map<String, dynamic>))
            .toList(),
        month: (json['month'] as List?)
            ?.map((e) => ScheduleRange.fromJson(e as Map<String, dynamic>))
            .toList(),
        second: (json['second'] as List?)
            ?.map((e) => ScheduleRange.fromJson(e as Map<String, dynamic>))
            .toList(),
        year: (json['year'] as List?)
            ?.map((e) => ScheduleRange.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (comment != null) 'comment': comment,
    if (dayOfMonth != null)
      'day_of_month': dayOfMonth?.map((e) => e.toJson()).toList(),
    if (dayOfWeek != null)
      'day_of_week': dayOfWeek?.map((e) => e.toJson()).toList(),
    if (hour != null) 'hour': hour?.map((e) => e.toJson()).toList(),
    if (minute != null) 'minute': minute?.map((e) => e.toJson()).toList(),
    if (month != null) 'month': month?.map((e) => e.toJson()).toList(),
    if (second != null) 'second': second?.map((e) => e.toJson()).toList(),
    if (year != null) 'year': year?.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  ScheduleCalendar copyWith({
    Object? comment = unsetCopyWithValue,
    Object? dayOfMonth = unsetCopyWithValue,
    Object? dayOfWeek = unsetCopyWithValue,
    Object? hour = unsetCopyWithValue,
    Object? minute = unsetCopyWithValue,
    Object? month = unsetCopyWithValue,
    Object? second = unsetCopyWithValue,
    Object? year = unsetCopyWithValue,
  }) {
    return ScheduleCalendar(
      comment: comment == unsetCopyWithValue
          ? this.comment
          : comment as String?,
      dayOfMonth: dayOfMonth == unsetCopyWithValue
          ? this.dayOfMonth
          : dayOfMonth as List<ScheduleRange>?,
      dayOfWeek: dayOfWeek == unsetCopyWithValue
          ? this.dayOfWeek
          : dayOfWeek as List<ScheduleRange>?,
      hour: hour == unsetCopyWithValue
          ? this.hour
          : hour as List<ScheduleRange>?,
      minute: minute == unsetCopyWithValue
          ? this.minute
          : minute as List<ScheduleRange>?,
      month: month == unsetCopyWithValue
          ? this.month
          : month as List<ScheduleRange>?,
      second: second == unsetCopyWithValue
          ? this.second
          : second as List<ScheduleRange>?,
      year: year == unsetCopyWithValue
          ? this.year
          : year as List<ScheduleRange>?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleCalendar) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(dayOfMonth, other.dayOfMonth)) return false;
    if (!listsEqual(dayOfWeek, other.dayOfWeek)) return false;
    if (!listsEqual(hour, other.hour)) return false;
    if (!listsEqual(minute, other.minute)) return false;
    if (!listsEqual(month, other.month)) return false;
    if (!listsEqual(second, other.second)) return false;
    if (!listsEqual(year, other.year)) return false;
    return comment == other.comment;
  }

  @override
  int get hashCode => Object.hash(
    comment,
    listHash(dayOfMonth),
    listHash(dayOfWeek),
    listHash(hour),
    listHash(minute),
    listHash(month),
    listHash(second),
    listHash(year),
  );

  @override
  String toString() =>
      'ScheduleCalendar('
      'comment: $comment, '
      'dayOfMonth: ${dayOfMonth?.length ?? 'null'}, '
      'dayOfWeek: ${dayOfWeek?.length ?? 'null'}, '
      'hour: ${hour?.length ?? 'null'}, '
      'minute: ${minute?.length ?? 'null'}, '
      'month: ${month?.length ?? 'null'}, '
      'second: ${second?.length ?? 'null'}, '
      'year: ${year?.length ?? 'null'}'
      ')';
}
