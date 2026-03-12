import '../copy_with_sentinel.dart';

/// Represents a time interval.
class Interval {
  /// Optional. Inclusive start of the interval.
  final DateTime? startTime;

  /// Optional. Exclusive end of the interval.
  final DateTime? endTime;

  /// Creates an [Interval].
  const Interval({this.startTime, this.endTime});

  /// Creates an [Interval] from JSON.
  factory Interval.fromJson(Map<String, dynamic> json) => Interval(
    startTime: json['startTime'] != null
        ? DateTime.parse(json['startTime'] as String)
        : null,
    endTime: json['endTime'] != null
        ? DateTime.parse(json['endTime'] as String)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (startTime != null) 'startTime': startTime!.toIso8601String(),
    if (endTime != null) 'endTime': endTime!.toIso8601String(),
  };

  /// Creates a copy with replaced values.
  Interval copyWith({
    Object? startTime = unsetCopyWithValue,
    Object? endTime = unsetCopyWithValue,
  }) {
    return Interval(
      startTime: startTime == unsetCopyWithValue
          ? this.startTime
          : startTime as DateTime?,
      endTime: endTime == unsetCopyWithValue
          ? this.endTime
          : endTime as DateTime?,
    );
  }

  @override
  String toString() => 'Interval(startTime: $startTime, endTime: $endTime)';
}
