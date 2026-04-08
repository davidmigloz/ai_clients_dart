import 'package:meta/meta.dart';

import 'dataset_record.dart';
import 'paginated_result.dart';

/// Response containing a paginated list of dataset records.
@immutable
class DatasetRecords {
  /// The paginated records.
  final PaginatedResult<DatasetRecord> records;

  /// Creates a [DatasetRecords].
  const DatasetRecords({required this.records});

  /// Creates a [DatasetRecords] from JSON.
  factory DatasetRecords.fromJson(Map<String, dynamic> json) => DatasetRecords(
    records: PaginatedResult.fromJson(
      json['records'] as Map<String, dynamic>? ?? {},
      DatasetRecord.fromJson,
    ),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'records': records.toJson((e) => e.toJson()),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DatasetRecords) return false;
    if (runtimeType != other.runtimeType) return false;
    return records == other.records;
  }

  @override
  int get hashCode => records.hashCode;

  @override
  String toString() => 'DatasetRecords(records: $records)';
}
