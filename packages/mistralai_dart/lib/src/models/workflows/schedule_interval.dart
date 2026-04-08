import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Interval specification for a schedule.
@immutable
class ScheduleInterval {
  /// The interval duration.
  final String every;

  /// The offset duration.
  final String? offset;

  /// Creates a [ScheduleInterval].
  const ScheduleInterval({required this.every, this.offset});

  /// Creates a [ScheduleInterval] from JSON.
  factory ScheduleInterval.fromJson(Map<String, dynamic> json) =>
      ScheduleInterval(
        every: json['every'] as String? ?? '',
        offset: json['offset'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'every': every,
    if (offset != null) 'offset': offset,
  };

  /// Creates a copy with replaced values.
  ScheduleInterval copyWith({
    String? every,
    Object? offset = unsetCopyWithValue,
  }) {
    return ScheduleInterval(
      every: every ?? this.every,
      offset: offset == unsetCopyWithValue ? this.offset : offset as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ScheduleInterval) return false;
    if (runtimeType != other.runtimeType) return false;
    return every == other.every && offset == other.offset;
  }

  @override
  int get hashCode => Object.hash(every, offset);

  @override
  String toString() => 'ScheduleInterval(every: $every, offset: $offset)';
}
