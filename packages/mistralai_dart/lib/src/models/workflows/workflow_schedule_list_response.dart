import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'schedule_definition_output.dart';

/// Response containing a list of workflow schedules.
@immutable
class WorkflowScheduleListResponse {
  /// The list of schedules.
  final List<ScheduleDefinitionOutput> schedules;

  /// The token for the next page of results.
  final String? nextPageToken;

  /// Creates a [WorkflowScheduleListResponse].
  WorkflowScheduleListResponse({
    required List<ScheduleDefinitionOutput> schedules,
    this.nextPageToken,
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
        nextPageToken: json['next_page_token'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'schedules': schedules.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'next_page_token': nextPageToken,
  };

  /// Creates a copy with replaced values.
  WorkflowScheduleListResponse copyWith({
    List<ScheduleDefinitionOutput>? schedules,
    Object? nextPageToken = unsetCopyWithValue,
  }) {
    return WorkflowScheduleListResponse(
      schedules: schedules ?? this.schedules,
      nextPageToken: nextPageToken == unsetCopyWithValue
          ? this.nextPageToken
          : nextPageToken as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkflowScheduleListResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!listsEqual(schedules, other.schedules)) return false;
    return nextPageToken == other.nextPageToken;
  }

  @override
  int get hashCode => Object.hash(listHash(schedules), nextPageToken);

  @override
  String toString() =>
      'WorkflowScheduleListResponse(schedules: ${schedules.length}, nextPageToken: $nextPageToken)';
}
