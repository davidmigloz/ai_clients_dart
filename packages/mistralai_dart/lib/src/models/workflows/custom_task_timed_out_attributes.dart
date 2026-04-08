import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Attributes for a custom task timed-out event.
@immutable
class CustomTaskTimedOutAttributes {
  /// The custom task identifier.
  final String customTaskId;

  /// The custom task type.
  final String customTaskType;

  /// The type of timeout.
  final String? timeoutType;

  /// Creates a [CustomTaskTimedOutAttributes].
  const CustomTaskTimedOutAttributes({
    required this.customTaskId,
    required this.customTaskType,
    this.timeoutType,
  });

  /// Creates a [CustomTaskTimedOutAttributes] from JSON.
  factory CustomTaskTimedOutAttributes.fromJson(Map<String, dynamic> json) =>
      CustomTaskTimedOutAttributes(
        customTaskId: json['custom_task_id'] as String? ?? '',
        customTaskType: json['custom_task_type'] as String? ?? '',
        timeoutType: json['timeout_type'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'custom_task_id': customTaskId,
    'custom_task_type': customTaskType,
    if (timeoutType != null) 'timeout_type': timeoutType,
  };

  /// Creates a copy with replaced values.
  CustomTaskTimedOutAttributes copyWith({
    String? customTaskId,
    String? customTaskType,
    Object? timeoutType = unsetCopyWithValue,
  }) {
    return CustomTaskTimedOutAttributes(
      customTaskId: customTaskId ?? this.customTaskId,
      customTaskType: customTaskType ?? this.customTaskType,
      timeoutType: timeoutType == unsetCopyWithValue
          ? this.timeoutType
          : timeoutType as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomTaskTimedOutAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return customTaskId == other.customTaskId &&
        customTaskType == other.customTaskType &&
        timeoutType == other.timeoutType;
  }

  @override
  int get hashCode => Object.hash(customTaskId, customTaskType, timeoutType);

  @override
  String toString() =>
      'CustomTaskTimedOutAttributes(customTaskId: $customTaskId, customTaskType: $customTaskType, timeoutType: $timeoutType)';
}
