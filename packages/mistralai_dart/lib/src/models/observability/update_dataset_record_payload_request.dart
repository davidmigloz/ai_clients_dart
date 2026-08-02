import 'package:meta/meta.dart';

import 'dataset_record_payload.dart';

/// Request to update a dataset record's payload.
@immutable
class UpdateDatasetRecordPayloadRequest {
  /// The new record payload.
  final DatasetRecordPayload payload;

  /// Creates an [UpdateDatasetRecordPayloadRequest].
  const UpdateDatasetRecordPayloadRequest({required this.payload});

  /// Creates an [UpdateDatasetRecordPayloadRequest] from JSON.
  factory UpdateDatasetRecordPayloadRequest.fromJson(
    Map<String, dynamic> json,
  ) => UpdateDatasetRecordPayloadRequest(
    payload: DatasetRecordPayload.fromJson(
      json['payload'] as Map<String, dynamic>? ?? {},
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'payload': payload.toJson()};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! UpdateDatasetRecordPayloadRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return payload == other.payload;
  }

  @override
  int get hashCode => payload.hashCode;

  @override
  String toString() => 'UpdateDatasetRecordPayloadRequest(payload: $payload)';
}
