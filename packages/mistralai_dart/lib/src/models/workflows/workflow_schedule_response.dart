import 'package:meta/meta.dart';

/// Response for scheduling a workflow.
@immutable
class WorkflowScheduleResponse {
  /// The schedule identifier.
  final String scheduleId;

  /// Creates a [WorkflowScheduleResponse].
  const WorkflowScheduleResponse({required this.scheduleId});

  /// Creates a [WorkflowScheduleResponse] from JSON.
  factory WorkflowScheduleResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowScheduleResponse(
        scheduleId: json['schedule_id'] as String? ?? '',
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'schedule_id': scheduleId};

  /// Creates a copy with replaced values.
  WorkflowScheduleResponse copyWith({String? scheduleId}) {
    return WorkflowScheduleResponse(scheduleId: scheduleId ?? this.scheduleId);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowScheduleResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return scheduleId == other.scheduleId;
  }

  @override
  int get hashCode => scheduleId.hashCode;

  @override
  String toString() => 'WorkflowScheduleResponse(scheduleId: $scheduleId)';
}
