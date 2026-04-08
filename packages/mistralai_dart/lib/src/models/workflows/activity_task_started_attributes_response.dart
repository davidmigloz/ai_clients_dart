import 'package:meta/meta.dart';

import 'json_payload_response.dart';

/// Attributes for an activity task started event.
@immutable
class ActivityTaskStartedAttributesResponse {
  /// The task identifier.
  final String taskId;

  /// The activity name.
  final String activityName;

  /// The input payload.
  final JSONPayloadResponse input;

  /// Creates a [ActivityTaskStartedAttributesResponse].
  const ActivityTaskStartedAttributesResponse({
    required this.taskId,
    required this.activityName,
    required this.input,
  });

  /// Creates a [ActivityTaskStartedAttributesResponse] from JSON.
  factory ActivityTaskStartedAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => ActivityTaskStartedAttributesResponse(
    taskId: json['task_id'] as String? ?? '',
    activityName: json['activity_name'] as String? ?? '',
    input: JSONPayloadResponse.fromJson(json['input'] as Map<String, dynamic>),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'task_id': taskId,
    'activity_name': activityName,
    'input': input.toJson(),
  };

  /// Creates a copy with replaced values.
  ActivityTaskStartedAttributesResponse copyWith({
    String? taskId,
    String? activityName,
    JSONPayloadResponse? input,
  }) {
    return ActivityTaskStartedAttributesResponse(
      taskId: taskId ?? this.taskId,
      activityName: activityName ?? this.activityName,
      input: input ?? this.input,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! ActivityTaskStartedAttributesResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return taskId == other.taskId &&
        activityName == other.activityName &&
        input == other.input;
  }

  @override
  int get hashCode => Object.hash(taskId, activityName, input);

  @override
  String toString() =>
      'ActivityTaskStartedAttributesResponse(taskId: $taskId, activityName: $activityName, input: $input)';
}
