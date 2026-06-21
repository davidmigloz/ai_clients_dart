import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'schedule_overlap_policy.dart';

/// Request to immediately trigger a workflow schedule.
@immutable
class WorkflowScheduleTriggerRequest {
  /// Optional overlap policy override to use for the immediate trigger.
  final ScheduleOverlapPolicy? overlap;

  /// Creates a [WorkflowScheduleTriggerRequest].
  const WorkflowScheduleTriggerRequest({this.overlap});

  /// Creates a [WorkflowScheduleTriggerRequest] from JSON.
  factory WorkflowScheduleTriggerRequest.fromJson(Map<String, dynamic> json) =>
      WorkflowScheduleTriggerRequest(
        overlap: json['overlap'] != null
            ? ScheduleOverlapPolicy.fromJson(json['overlap'] as int?)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (overlap != null) 'overlap': overlap?.toJson(),
  };

  /// Creates a copy with replaced values.
  WorkflowScheduleTriggerRequest copyWith({
    Object? overlap = unsetCopyWithValue,
  }) {
    return WorkflowScheduleTriggerRequest(
      overlap: overlap == unsetCopyWithValue
          ? this.overlap
          : overlap as ScheduleOverlapPolicy?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowScheduleTriggerRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return overlap == other.overlap;
  }

  @override
  int get hashCode => overlap.hashCode;

  @override
  String toString() => 'WorkflowScheduleTriggerRequest(overlap: $overlap)';
}
