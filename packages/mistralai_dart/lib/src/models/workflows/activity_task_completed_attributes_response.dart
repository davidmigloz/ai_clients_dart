import 'package:meta/meta.dart';

import 'json_payload_response.dart';

/// Attributes for an activity task completed event.
@immutable
class ActivityTaskCompletedAttributesResponse {
  /// The task identifier.
  final String taskId;

  /// The activity name.
  final String activityName;

  /// The result payload.
  final JSONPayloadResponse result;

  /// Creates a [ActivityTaskCompletedAttributesResponse].
  const ActivityTaskCompletedAttributesResponse({
    required this.taskId,
    required this.activityName,
    required this.result,
  });

  /// Creates a [ActivityTaskCompletedAttributesResponse] from JSON.
  factory ActivityTaskCompletedAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => ActivityTaskCompletedAttributesResponse(
    taskId: json['task_id'] as String? ?? '',
    activityName: json['activity_name'] as String? ?? '',
    result: JSONPayloadResponse.fromJson(
      json['result'] as Map<String, dynamic>,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'activity_name': activityName,
    'result': result.toJson(),
  };

  /// Creates a copy with replaced values.
  ActivityTaskCompletedAttributesResponse copyWith({
    String? taskId,
    String? activityName,
    JSONPayloadResponse? result,
  }) {
    return ActivityTaskCompletedAttributesResponse(
      taskId: taskId ?? this.taskId,
      activityName: activityName ?? this.activityName,
      result: result ?? this.result,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActivityTaskCompletedAttributesResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId &&
        activityName == other.activityName &&
        result == other.result;
  }

  @override
  int get hashCode => Object.hash(taskId, activityName, result);

  @override
  String toString() =>
      'ActivityTaskCompletedAttributesResponse(taskId: $taskId, activityName: $activityName, result: $result)';
}
