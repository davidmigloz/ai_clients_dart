import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// Request to import dataset records from another dataset.
@immutable
class PostDatasetImportFromDatasetInSchema {
  /// The record IDs to import (1-10000 items).
  final List<String> datasetRecordIds;

  /// Creates a [PostDatasetImportFromDatasetInSchema].
  PostDatasetImportFromDatasetInSchema({required List<String> datasetRecordIds})
    : datasetRecordIds = List.unmodifiable(datasetRecordIds);

  /// Creates a [PostDatasetImportFromDatasetInSchema] from JSON.
  factory PostDatasetImportFromDatasetInSchema.fromJson(
    Map<String, dynamic> json,
  ) => PostDatasetImportFromDatasetInSchema(
    datasetRecordIds:
        (json['dataset_record_ids'] as List?)?.cast<String>() ?? [],
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'dataset_record_ids': datasetRecordIds};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDatasetImportFromDatasetInSchema) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(datasetRecordIds, other.datasetRecordIds);
  }

  @override
  int get hashCode => listHash(datasetRecordIds);

  @override
  String toString() =>
      'PostDatasetImportFromDatasetInSchema('
      '${datasetRecordIds.length} records)';
}
