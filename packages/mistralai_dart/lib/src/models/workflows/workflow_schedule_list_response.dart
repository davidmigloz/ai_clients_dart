import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'schedule_definition_output.dart';

/// Response containing a list of workflow schedules.
@immutable
class WorkflowScheduleListResponse {
  /// The list of schedules.
  final List<ScheduleDefinitionOutput> schedules;

  /// Creates a [WorkflowScheduleListResponse].
  WorkflowScheduleListResponse({
    required List<ScheduleDefinitionOutput> schedules,
  }) : schedules = List.unmodifiable(schedules);

  /// Creates a [WorkflowScheduleListResponse] from JSON.
  factory WorkflowScheduleListResponse.fromJson(Map<String, dynamic> json) =>
      WorkflowScheduleListResponse(
        schedules:
            (json['schedules'] as List?)
                ?.map(
                  (e) => ScheduleDefinitionOutput.fromJson(
                    e as Map<String, dynamic>,
                  ),
                )
                .toList() ??
            [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'schedules': schedules.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  WorkflowScheduleListResponse copyWith({
    List<ScheduleDefinitionOutput>? schedules,
  }) {
    return WorkflowScheduleListResponse(schedules: schedules ?? this.schedules);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowScheduleListResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(schedules, other.schedules)) return false;
    return true;
  }

  @override
  int get hashCode => listHash(schedules);

  @override
  String toString() =>
      'WorkflowScheduleListResponse(schedules: ${schedules.length})';
}
