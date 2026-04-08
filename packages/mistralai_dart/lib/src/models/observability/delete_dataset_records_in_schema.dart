import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Request to bulk-delete dataset records.
@immutable
class DeleteDatasetRecordsInSchema {
  /// The IDs of records to delete (1-500 items).
  final List<String> datasetRecordIds;

  /// Creates a [DeleteDatasetRecordsInSchema].
  DeleteDatasetRecordsInSchema({required List<String> datasetRecordIds})
    : datasetRecordIds = List.unmodifiable(datasetRecordIds);

  /// Creates a [DeleteDatasetRecordsInSchema] from JSON.
  factory DeleteDatasetRecordsInSchema.fromJson(Map<String, dynamic> json) =>
      DeleteDatasetRecordsInSchema(
        datasetRecordIds:
            (json['dataset_record_ids'] as List?)?.cast<String>() ?? [],
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'dataset_record_ids': datasetRecordIds};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeleteDatasetRecordsInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(datasetRecordIds, other.datasetRecordIds);
  }

  @override
  int get hashCode => listHash(datasetRecordIds);

  @override
  String toString() =>
      'DeleteDatasetRecordsInSchema(${datasetRecordIds.length} records)';
}
