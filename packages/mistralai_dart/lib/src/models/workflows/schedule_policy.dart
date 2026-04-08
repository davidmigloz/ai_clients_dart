import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'schedule_overlap_policy.dart';

/// Policy settings for a schedule.
@immutable
class SchedulePolicy {
  /// The catchup window in seconds.
  final int? catchupWindowSeconds;

  /// The overlap policy.
  final ScheduleOverlapPolicy? overlap;

  /// Whether to pause on failure.
  final bool? pauseOnFailure;

  /// Creates a [SchedulePolicy].
  const SchedulePolicy({
    this.catchupWindowSeconds,
    this.overlap,
    this.pauseOnFailure,
  });

  /// Creates a [SchedulePolicy] from JSON.
  factory SchedulePolicy.fromJson(Map<String, dynamic> json) => SchedulePolicy(
    catchupWindowSeconds: json['catchup_window_seconds'] as int?,
    overlap: json['overlap'] != null
        ? ScheduleOverlapPolicy.fromJson(json['overlap'] as int)
        : null,
    pauseOnFailure: json['pause_on_failure'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (catchupWindowSeconds != null)
      'catchup_window_seconds': catchupWindowSeconds,
    if (overlap != null) 'overlap': overlap?.toJson(),
    if (pauseOnFailure != null) 'pause_on_failure': pauseOnFailure,
  };

  /// Creates a copy with replaced values.
  SchedulePolicy copyWith({
    Object? catchupWindowSeconds = unsetCopyWithValue,
    Object? overlap = unsetCopyWithValue,
    Object? pauseOnFailure = unsetCopyWithValue,
  }) {
    return SchedulePolicy(
      catchupWindowSeconds: catchupWindowSeconds == unsetCopyWithValue
          ? this.catchupWindowSeconds
          : catchupWindowSeconds as int?,
      overlap: overlap == unsetCopyWithValue
          ? this.overlap
          : overlap as ScheduleOverlapPolicy?,
      pauseOnFailure: pauseOnFailure == unsetCopyWithValue
          ? this.pauseOnFailure
          : pauseOnFailure as bool?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! SchedulePolicy) return false;
    if (runtimeType != other.runtimeType) return false;
    return catchupWindowSeconds == other.catchupWindowSeconds &&
        overlap == other.overlap &&
        pauseOnFailure == other.pauseOnFailure;
  }

  @override
  int get hashCode =>
      Object.hash(catchupWindowSeconds, overlap, pauseOnFailure);

  @override
  String toString() =>
      'SchedulePolicy(catchupWindowSeconds: $catchupWindowSeconds, overlap: $overlap, pauseOnFailure: $pauseOnFailure)';
}
