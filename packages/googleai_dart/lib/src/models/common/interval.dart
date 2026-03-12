import '../copy_with_sentinel.dart';

/// Represents a time interval.
class Interval {
  /// Optional. Inclusive start of the interval.
  final String? startTime;

  /// Optional. Exclusive end of the interval.
  final String? endTime;

  /// Creates an [Interval].
  const Interval({this.startTime, this.endTime});

  /// Creates an [Interval] from JSON.
  factory Interval.fromJson(Map<String, dynamic> json) => Interval(
    startTime: json['startTime'] as String?,
    endTime: json['endTime'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (startTime != null) 'startTime': startTime,
    if (endTime != null) 'endTime': endTime,
  };

  /// Creates a copy with replaced values.
  Interval copyWith({
    Object? startTime = unsetCopyWithValue,
    Object? endTime = unsetCopyWithValue,
  }) {
    return Interval(
      startTime: startTime == unsetCopyWithValue
          ? this.startTime
          : startTime as String?,
      endTime: endTime == unsetCopyWithValue
          ? this.endTime
          : endTime as String?,
    );
  }

  @override
  String toString() => 'Interval(startTime: $startTime, endTime: $endTime)';
}
