import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Attributes for a custom task in-progress event.
@immutable
class CustomTaskInProgressAttributesResponse {
  /// The custom task identifier.
  final String customTaskId;

  /// The custom task type.
  final String customTaskType;

  /// The progress payload.
  final Map<String, dynamic> payload;

  /// Creates a [CustomTaskInProgressAttributesResponse].
  const CustomTaskInProgressAttributesResponse({
    required this.customTaskId,
    required this.customTaskType,
    required this.payload,
  });

  /// Creates a [CustomTaskInProgressAttributesResponse] from JSON.
  factory CustomTaskInProgressAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => CustomTaskInProgressAttributesResponse(
    customTaskId: json['custom_task_id'] as String? ?? '',
    customTaskType: json['custom_task_type'] as String? ?? '',
    payload: json['payload'] as Map<String, dynamic>? ?? {},
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'custom_task_id': customTaskId,
    'custom_task_type': customTaskType,
    'payload': payload,
  };

  /// Creates a copy with replaced values.
  CustomTaskInProgressAttributesResponse copyWith({
    String? customTaskId,
    String? customTaskType,
    Map<String, dynamic>? payload,
  }) {
    return CustomTaskInProgressAttributesResponse(
      customTaskId: customTaskId ?? this.customTaskId,
      customTaskType: customTaskType ?? this.customTaskType,
      payload: payload ?? this.payload,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomTaskInProgressAttributesResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    if (!mapsDeepEqual(payload, other.payload)) return false;
    return customTaskId == other.customTaskId &&
        customTaskType == other.customTaskType;
  }

  @override
  int get hashCode =>
      Object.hash(customTaskId, customTaskType, mapDeepHashCode(payload));

  @override
  String toString() =>
      'CustomTaskInProgressAttributesResponse(customTaskId: $customTaskId, customTaskType: $customTaskType, payload: ${payload.length})';
}
