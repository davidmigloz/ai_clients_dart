import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'dataset_record_payload.dart';

/// Request to create a new dataset record.
@immutable
class CreateDatasetRecordRequest {
  /// The record's payload.
  final DatasetRecordPayload payload;

  /// Additional properties (free-form).
  final Map<String, dynamic>? properties;

  /// Creates a [CreateDatasetRecordRequest].
  CreateDatasetRecordRequest({
    required this.payload,
    Map<String, dynamic>? properties,
  }) : properties = properties != null ? Map.unmodifiable(properties) : null;

  /// Creates a [CreateDatasetRecordRequest] from JSON.
  factory CreateDatasetRecordRequest.fromJson(Map<String, dynamic> json) =>
      CreateDatasetRecordRequest(
        payload: DatasetRecordPayload.fromJson(
          json['payload'] as Map<String, dynamic>? ?? {},
        ),
        properties: json['properties'] != null
            ? Map<String, dynamic>.from(json['properties'] as Map)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'payload': payload.toJson(),
    if (properties != null)
      'properties': Map<String, dynamic>.from(properties!),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateDatasetRecordRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return payload == other.payload &&
        mapsDeepEqual(properties, other.properties);
  }

  @override
  int get hashCode => Object.hash(payload, mapDeepHashCode(properties));

  @override
  String toString() => 'CreateDatasetRecordRequest(payload: $payload)';
}
