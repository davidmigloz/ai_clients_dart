import 'package:meta/meta.dart';

import 'partial_schedule_definition.dart';

/// Request to update a workflow schedule.
@immutable
class WorkflowScheduleUpdateRequest {
  /// The partial schedule definition to apply.
  final PartialScheduleDefinition schedule;

  /// Creates a [WorkflowScheduleUpdateRequest].
  const WorkflowScheduleUpdateRequest({required this.schedule});

  /// Creates a [WorkflowScheduleUpdateRequest] from JSON.
  factory WorkflowScheduleUpdateRequest.fromJson(Map<String, dynamic> json) =>
      WorkflowScheduleUpdateRequest(
        schedule: PartialScheduleDefinition.fromJson(
          json['schedule'] as Map<String, dynamic>? ?? const {},
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'schedule': schedule.toJson()};

  /// Creates a copy with replaced values.
  WorkflowScheduleUpdateRequest copyWith({
    PartialScheduleDefinition? schedule,
  }) {
    return WorkflowScheduleUpdateRequest(schedule: schedule ?? this.schedule);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowScheduleUpdateRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return schedule == other.schedule;
  }

  @override
  int get hashCode => schedule.hashCode;

  @override
  String toString() => 'WorkflowScheduleUpdateRequest(schedule: $schedule)';
}
