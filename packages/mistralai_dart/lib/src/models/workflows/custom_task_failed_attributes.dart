import 'package:meta/meta.dart';

import 'failure.dart';

/// Attributes for a custom task failed event.
@immutable
class CustomTaskFailedAttributes {
  /// The custom task identifier.
  final String customTaskId;

  /// The custom task type.
  final String customTaskType;

  /// The failure details.
  final Failure failure;

  /// Creates a [CustomTaskFailedAttributes].
  const CustomTaskFailedAttributes({
    required this.customTaskId,
    required this.customTaskType,
    required this.failure,
  });

  /// Creates a [CustomTaskFailedAttributes] from JSON.
  factory CustomTaskFailedAttributes.fromJson(Map<String, dynamic> json) =>
      CustomTaskFailedAttributes(
        customTaskId: json['custom_task_id'] as String? ?? '',
        customTaskType: json['custom_task_type'] as String? ?? '',
        failure: Failure.fromJson(json['failure'] as Map<String, dynamic>),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'custom_task_id': customTaskId,
    'custom_task_type': customTaskType,
    'failure': failure.toJson(),
  };

  /// Creates a copy with replaced values.
  CustomTaskFailedAttributes copyWith({
    String? customTaskId,
    String? customTaskType,
    Failure? failure,
  }) {
    return CustomTaskFailedAttributes(
      customTaskId: customTaskId ?? this.customTaskId,
      customTaskType: customTaskType ?? this.customTaskType,
      failure: failure ?? this.failure,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomTaskFailedAttributes) return false;
    if (runtimeType != other.runtimeType) return false;
    return customTaskId == other.customTaskId &&
        customTaskType == other.customTaskType &&
        failure == other.failure;
  }

  @override
  int get hashCode => Object.hash(customTaskId, customTaskType, failure);

  @override
  String toString() =>
      'CustomTaskFailedAttributes(customTaskId: $customTaskId, customTaskType: $customTaskType, failure: $failure)';
}
