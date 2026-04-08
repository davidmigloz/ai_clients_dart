import 'package:meta/meta.dart';

import 'json_payload_response.dart';

/// Attributes for a custom task completed event.
@immutable
class CustomTaskCompletedAttributesResponse {
  /// The custom task identifier.
  final String customTaskId;

  /// The custom task type.
  final String customTaskType;

  /// The result payload.
  final JSONPayloadResponse payload;

  /// Creates a [CustomTaskCompletedAttributesResponse].
  const CustomTaskCompletedAttributesResponse({
    required this.customTaskId,
    required this.customTaskType,
    required this.payload,
  });

  /// Creates a [CustomTaskCompletedAttributesResponse] from JSON.
  factory CustomTaskCompletedAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => CustomTaskCompletedAttributesResponse(
    customTaskId: json['custom_task_id'] as String? ?? '',
    customTaskType: json['custom_task_type'] as String? ?? '',
    payload: JSONPayloadResponse.fromJson(
      json['payload'] as Map<String, dynamic>,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'custom_task_id': customTaskId,
    'custom_task_type': customTaskType,
    'payload': payload.toJson(),
  };

  /// Creates a copy with replaced values.
  CustomTaskCompletedAttributesResponse copyWith({
    String? customTaskId,
    String? customTaskType,
    JSONPayloadResponse? payload,
  }) {
    return CustomTaskCompletedAttributesResponse(
      customTaskId: customTaskId ?? this.customTaskId,
      customTaskType: customTaskType ?? this.customTaskType,
      payload: payload ?? this.payload,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomTaskCompletedAttributesResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return customTaskId == other.customTaskId &&
        customTaskType == other.customTaskType &&
        payload == other.payload;
  }

  @override
  int get hashCode => Object.hash(customTaskId, customTaskType, payload);

  @override
  String toString() =>
      'CustomTaskCompletedAttributesResponse(customTaskId: $customTaskId, customTaskType: $customTaskType, payload: $payload)';
}
