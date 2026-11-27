import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'dataset_record.dart';
import 'dataset_record_payload.dart';

/// The CreateDatasetRecordsItem wire payload.
@immutable
class CreateDatasetRecordsItem {
  /// Creates a [CreateDatasetRecordsItem].
  const CreateDatasetRecordsItem({
    this.id,
    required this.payload,
    this.properties,
    this.source,
  });

  /// Optional client-generated record ID, to retry safely: a record with this ID that already exists in the dataset is returned as is instead of being created again.
  final String? id;

  /// The payload field.
  final DatasetRecordPayload payload;

  /// The properties field.
  final Map<String, dynamic>? properties;

  /// Caller-declared channel that initiated record creation. This value does not certify that the payload is an unmodified copy of its source.
  final DatasetRecordInputSource? source;

  /// Parses a [CreateDatasetRecordsItem] from JSON.
  factory CreateDatasetRecordsItem.fromJson(Map<String, dynamic> json) {
    if (json['payload'] == null) {
      throw const FormatException('CreateDatasetRecordsItem: missing payload');
    }
    return CreateDatasetRecordsItem(
      id: json['id'] == null ? null : json['id'] as String,
      payload: DatasetRecordPayload.fromJson(
        json['payload'] as Map<String, dynamic>,
      ),
      properties: json['properties'] == null
          ? null
          : json['properties'] as Map<String, dynamic>,
      source: json['source'] == null
          ? null
          : DatasetRecordInputSource.fromJson(json['source'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'id': ?id,
    'payload': payload.toJson(),
    'properties': ?properties,
    if (source != null) 'source': source!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  CreateDatasetRecordsItem copyWith({
    Object? id = unsetCopyWithValue,
    DatasetRecordPayload? payload,
    Object? properties = unsetCopyWithValue,
    Object? source = unsetCopyWithValue,
  }) => CreateDatasetRecordsItem(
    id: id == unsetCopyWithValue ? this.id : id as String?,
    payload: payload ?? this.payload,
    properties: properties == unsetCopyWithValue
        ? this.properties
        : (properties as Map?)?.cast<String, dynamic>(),
    source: source == unsetCopyWithValue
        ? this.source
        : source as DatasetRecordInputSource?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDatasetRecordsItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          payload == other.payload &&
          valuesDeepEqual(properties, other.properties) &&
          source == other.source;

  @override
  int get hashCode =>
      Object.hashAll([id, payload, valueDeepHashCode(properties), source]);

  @override
  String toString() =>
      'CreateDatasetRecordsItem('
      'id: $id, '
      'payload: $payload, '
      'properties: ${properties?.length}, '
      'source: $source)';
}

/// The CreateDatasetRecordsRequest wire payload.
@immutable
class CreateDatasetRecordsRequest {
  /// Creates a [CreateDatasetRecordsRequest].
  const CreateDatasetRecordsRequest({required this.records});

  /// Records to add. They are created together: if one is invalid, none is created.
  final List<CreateDatasetRecordsItem> records;

  /// Parses a [CreateDatasetRecordsRequest] from JSON.
  factory CreateDatasetRecordsRequest.fromJson(Map<String, dynamic> json) {
    if (json['records'] == null) {
      throw const FormatException(
        'CreateDatasetRecordsRequest: missing records',
      );
    }
    return CreateDatasetRecordsRequest(
      records: (json['records'] as List<Object?>)
          .map(
            (item) => CreateDatasetRecordsItem.fromJson(
              item! as Map<String, dynamic>,
            ),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'records': records.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  CreateDatasetRecordsRequest copyWith({
    List<CreateDatasetRecordsItem>? records,
  }) => CreateDatasetRecordsRequest(records: records ?? this.records);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDatasetRecordsRequest &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(records, other.records);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(records)]);

  @override
  String toString() =>
      'CreateDatasetRecordsRequest('
      'records: ${records.length})';
}

/// The CreateDatasetRecordsResponse wire payload.
@immutable
class CreateDatasetRecordsResponse {
  /// Creates a [CreateDatasetRecordsResponse].
  const CreateDatasetRecordsResponse({required this.records});

  /// The created records, in the request order.
  final List<DatasetRecord> records;

  /// Parses a [CreateDatasetRecordsResponse] from JSON.
  factory CreateDatasetRecordsResponse.fromJson(Map<String, dynamic> json) {
    if (json['records'] == null) {
      throw const FormatException(
        'CreateDatasetRecordsResponse: missing records',
      );
    }
    return CreateDatasetRecordsResponse(
      records: (json['records'] as List<Object?>)
          .map((item) => DatasetRecord.fromJson(item! as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'records': records.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  CreateDatasetRecordsResponse copyWith({List<DatasetRecord>? records}) =>
      CreateDatasetRecordsResponse(records: records ?? this.records);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDatasetRecordsResponse &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(records, other.records);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(records)]);

  @override
  String toString() =>
      'CreateDatasetRecordsResponse('
      'records: ${records.length})';
}

/// Source-agnostic counts for a completed dataset import.
@immutable
class DatasetImportResult {
  /// Creates a [DatasetImportResult].
  const DatasetImportResult({
    required this.importedRecordCount,
    required this.requestedRecordCount,
    required this.skippedRecordCount,
  });

  /// The imported_record_count field.
  final int importedRecordCount;

  /// The requested_record_count field.
  final int requestedRecordCount;

  /// The skipped_record_count field.
  final int skippedRecordCount;

  /// Parses a [DatasetImportResult] from JSON.
  factory DatasetImportResult.fromJson(Map<String, dynamic> json) {
    if (json['imported_record_count'] == null) {
      throw const FormatException(
        'DatasetImportResult: missing imported_record_count',
      );
    }
    if (json['requested_record_count'] == null) {
      throw const FormatException(
        'DatasetImportResult: missing requested_record_count',
      );
    }
    if (json['skipped_record_count'] == null) {
      throw const FormatException(
        'DatasetImportResult: missing skipped_record_count',
      );
    }
    return DatasetImportResult(
      importedRecordCount: json['imported_record_count'] as int,
      requestedRecordCount: json['requested_record_count'] as int,
      skippedRecordCount: json['skipped_record_count'] as int,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'imported_record_count': importedRecordCount,
    'requested_record_count': requestedRecordCount,
    'skipped_record_count': skippedRecordCount,
  };

  /// Creates a copy with the given fields replaced.
  DatasetImportResult copyWith({
    int? importedRecordCount,
    int? requestedRecordCount,
    int? skippedRecordCount,
  }) => DatasetImportResult(
    importedRecordCount: importedRecordCount ?? this.importedRecordCount,
    requestedRecordCount: requestedRecordCount ?? this.requestedRecordCount,
    skippedRecordCount: skippedRecordCount ?? this.skippedRecordCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DatasetImportResult &&
          runtimeType == other.runtimeType &&
          importedRecordCount == other.importedRecordCount &&
          requestedRecordCount == other.requestedRecordCount &&
          skippedRecordCount == other.skippedRecordCount;

  @override
  int get hashCode => Object.hashAll([
    importedRecordCount,
    requestedRecordCount,
    skippedRecordCount,
  ]);

  @override
  String toString() =>
      'DatasetImportResult('
      'importedRecordCount: $importedRecordCount, '
      'requestedRecordCount: $requestedRecordCount, '
      'skippedRecordCount: $skippedRecordCount)';
}

/// Values for DatasetRecordInputSource.
enum DatasetRecordInputSource {
  /// Represents DIRECT_INPUT.
  directInput('DIRECT_INPUT'),

  /// Represents TELEMETRY_SPAN.
  telemetrySpan('TELEMETRY_SPAN'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const DatasetRecordInputSource(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static DatasetRecordInputSource fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}
