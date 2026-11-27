import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'dataset_record_batch.dart';
import 'dataset_record_payload.dart';

/// Request to create a new dataset record.
@immutable
class CreateDatasetRecordRequest {
  /// The record's payload.
  final DatasetRecordPayload payload;

  /// Additional properties (free-form).
  final Map<String, dynamic>? properties;

  /// Channel that initiated record creation.
  final DatasetRecordInputSource? source;

  /// Creates a [CreateDatasetRecordRequest].
  CreateDatasetRecordRequest({
    required this.payload,
    this.source,
    Map<String, dynamic>? properties,
  }) : properties = properties != null ? Map.unmodifiable(properties) : null;

  /// Creates a [CreateDatasetRecordRequest] from JSON.
  factory CreateDatasetRecordRequest.fromJson(Map<String, dynamic> json) =>
      CreateDatasetRecordRequest(
        payload: DatasetRecordPayload.fromJson(
          json['payload'] as Map<String, dynamic>? ?? {},
        ),
        source: json['source'] == null
            ? null
            : DatasetRecordInputSource.fromJson(json['source'] as String),
        properties: json['properties'] != null
            ? Map<String, dynamic>.from(json['properties'] as Map)
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'payload': payload.toJson(),
    if (source != null) 'source': source!.toJson(),
    if (properties != null)
      'properties': Map<String, dynamic>.from(properties!),
  };

  /// Creates a copy with replaced values.
  CreateDatasetRecordRequest copyWith({
    DatasetRecordPayload? payload,
    Object? properties = unsetCopyWithValue,
    Object? source = unsetCopyWithValue,
  }) => CreateDatasetRecordRequest(
    payload: payload ?? this.payload,
    properties: properties == unsetCopyWithValue
        ? this.properties
        : (properties as Map<Object?, Object?>?)?.cast<String, dynamic>(),
    source: source == unsetCopyWithValue
        ? this.source
        : source as DatasetRecordInputSource?,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CreateDatasetRecordRequest) return false;
    if (runtimeType != other.runtimeType) return false;
    return payload == other.payload &&
        source == other.source &&
        mapsDeepEqual(properties, other.properties);
  }

  @override
  int get hashCode => Object.hash(payload, mapDeepHashCode(properties), source);

  @override
  String toString() =>
      'CreateDatasetRecordRequest(payload: $payload, properties: ${properties?.length}, source: $source)';
}
