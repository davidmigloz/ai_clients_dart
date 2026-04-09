import 'package:meta/meta.dart';

/// A range specification for schedule calendars.
@immutable
class ScheduleRange {
  /// The start of the range.
  final int start;

  /// The end of the range.
  final int end;

  /// The step increment.
  final int step;

  /// Creates a [ScheduleRange].
  const ScheduleRange({required this.start, this.end = 0, this.step = 0});

  /// Creates a [ScheduleRange] from JSON.
  factory ScheduleRange.fromJson(Map<String, dynamic> json) => ScheduleRange(
    start: json['start'] as int? ?? 0,
    end: json['end'] as int? ?? 0,
    step: json['step'] as int? ?? 0,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'start': start, 'end': end, 'step': step};

  /// Creates a copy with replaced values.
  ScheduleRange copyWith({int? start, int? end, int? step}) {
    return ScheduleRange(
      start: start ?? this.start,
      end: end ?? this.end,
      step: step ?? this.step,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleRange) return false;
    if (runtimeType != other.runtimeType) return false;
    return start == other.start && end == other.end && step == other.step;
  }

  @override
  int get hashCode => Object.hash(start, end, step);

  @override
  String toString() => 'ScheduleRange(start: $start, end: $end, step: $step)';
}
