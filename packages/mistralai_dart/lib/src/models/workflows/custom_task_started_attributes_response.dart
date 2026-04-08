import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'json_payload_response.dart';

/// Attributes for a custom task started event.
@immutable
class CustomTaskStartedAttributesResponse {
  /// The custom task identifier.
  final String customTaskId;

  /// The custom task type.
  final String customTaskType;

  /// The start payload.
  final JSONPayloadResponse? payload;

  /// Creates a [CustomTaskStartedAttributesResponse].
  const CustomTaskStartedAttributesResponse({
    required this.customTaskId,
    required this.customTaskType,
    this.payload,
  });

  /// Creates a [CustomTaskStartedAttributesResponse] from JSON.
  factory CustomTaskStartedAttributesResponse.fromJson(
    Map<String, dynamic> json,
  ) => CustomTaskStartedAttributesResponse(
    customTaskId: json['custom_task_id'] as String? ?? '',
    customTaskType: json['custom_task_type'] as String? ?? '',
    payload: json['payload'] != null
        ? JSONPayloadResponse.fromJson(json['payload'] as Map<String, dynamic>)
        : null,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'custom_task_id': customTaskId,
    'custom_task_type': customTaskType,
    if (payload != null) 'payload': payload?.toJson(),
  };

  /// Creates a copy with replaced values.
  CustomTaskStartedAttributesResponse copyWith({
    String? customTaskId,
    String? customTaskType,
    Object? payload = unsetCopyWithValue,
  }) {
    return CustomTaskStartedAttributesResponse(
      customTaskId: customTaskId ?? this.customTaskId,
      customTaskType: customTaskType ?? this.customTaskType,
      payload: payload == unsetCopyWithValue
          ? this.payload
          : payload as JSONPayloadResponse?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CustomTaskStartedAttributesResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return customTaskId == other.customTaskId &&
        customTaskType == other.customTaskType &&
        payload == other.payload;
  }

  @override
  int get hashCode => Object.hash(customTaskId, customTaskType, payload);

  @override
  String toString() =>
      'CustomTaskStartedAttributesResponse(customTaskId: $customTaskId, customTaskType: $customTaskType, payload: $payload)';
}
