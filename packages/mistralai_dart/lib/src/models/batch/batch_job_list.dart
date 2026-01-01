import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import 'batch_job.dart';

/// Response from listing batch jobs.
@immutable
class BatchJobList {
  /// Object type (always "list").
  final String object;

  /// The list of batch jobs.
  final List<BatchJob> data;

  /// Total number of jobs.
  final int? total;

  /// Creates a [BatchJobList].
  const BatchJobList({this.object = 'list', required this.data, this.total});

  /// Creates a [BatchJobList] from JSON.
  factory BatchJobList.fromJson(Map<String, dynamic> json) => BatchJobList(
    object: json['object'] as String? ?? 'list',
    data:
        (json['data'] as List?)
            ?.map((e) => BatchJob.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    total: json['total'] as int?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
    if (total != null) 'total': total,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BatchJobList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listEquals(data, other.data) &&
          total == other.total;

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data), total);

  @override
  String toString() => 'BatchJobList(count: ${data.length}, total: $total)';
}
