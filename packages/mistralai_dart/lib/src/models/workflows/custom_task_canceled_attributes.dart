import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Attributes for a custom task canceled event.
@immutable
class CustomTaskCanceledAttributes {
  /// The custom task identifier.
  final String customTaskId;

  /// The custom task type.
  final String customTaskType;

  /// The cancellation reason.
  final String? reason;

  /// Creates a [CustomTaskCanceledAttributes].
  const CustomTaskCanceledAttributes({
    required this.customTaskId,
    required this.customTaskType,
    this.reason,
  });

  /// Creates a [CustomTaskCanceledAttributes] from JSON.
  factory CustomTaskCanceledAttributes.fromJson(Map<String, dynamic> json) =>
      CustomTaskCanceledAttributes(
        customTaskId: json['custom_task_id'] as String? ?? '',
        customTaskType: json['custom_task_type'] as String? ?? '',
        reason: json['reason'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'custom_task_id': customTaskId,
    'custom_task_type': customTaskType,
    if (reason != null) 'reason': reason,
  };

  /// Creates a copy with replaced values.
  CustomTaskCanceledAttributes copyWith({
    String? customTaskId,
    String? customTaskType,
    Object? reason = unsetCopyWithValue,
  }) {
    return CustomTaskCanceledAttributes(
      customTaskId: customTaskId ?? this.customTaskId,
      customTaskType: customTaskType ?? this.customTaskType,
      reason: reason == unsetCopyWithValue ? this.reason : reason as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomTaskCanceledAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return customTaskId == other.customTaskId &&
        customTaskType == other.customTaskType &&
        reason == other.reason;
  }

  @override
  int get hashCode => Object.hash(customTaskId, customTaskType, reason);

  @override
  String toString() =>
      'CustomTaskCanceledAttributes(customTaskId: $customTaskId, customTaskType: $customTaskType, reason: $reason)';
}
