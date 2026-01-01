import 'package:meta/meta.dart';

import 'fine_tuning_job.dart';

/// Response containing a list of fine-tuning jobs.
@immutable
class FineTuningJobList {
  /// Object type (always "list").
  final String object;

  /// List of fine-tuning jobs.
  final List<FineTuningJob> data;

  /// Total count of jobs.
  final int? total;

  /// Creates a [FineTuningJobList].
  const FineTuningJobList({
    this.object = 'list',
    required this.data,
    this.total,
  });

  /// Creates a [FineTuningJobList] from JSON.
  factory FineTuningJobList.fromJson(Map<String, dynamic> json) =>
      FineTuningJobList(
        object: json['object'] as String? ?? 'list',
        data:
            (json['data'] as List?)
                ?.map((e) => FineTuningJob.fromJson(e as Map<String, dynamic>))
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
      other is FineTuningJobList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          data == other.data;

  @override
  int get hashCode => Object.hash(object, data);

  @override
  String toString() => 'FineTuningJobList(count: ${data.length})';
}
