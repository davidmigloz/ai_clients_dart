import 'package:meta/meta.dart';

import 'dataset_import_task.dart';
import 'paginated_result.dart';

/// Response containing a paginated list of dataset import tasks.
@immutable
class DatasetImportTasks {
  /// The paginated tasks.
  final PaginatedResult<DatasetImportTask> tasks;

  /// Creates a [DatasetImportTasks].
  const DatasetImportTasks({required this.tasks});

  /// Creates a [DatasetImportTasks] from JSON.
  factory DatasetImportTasks.fromJson(Map<String, dynamic> json) =>
      DatasetImportTasks(
        tasks: PaginatedResult.fromJson(
          json['tasks'] as Map<String, dynamic>? ?? {},
          DatasetImportTask.fromJson,
        ),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'tasks': tasks.toJson((e) => e.toJson())};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DatasetImportTasks) return false;
    if (runtimeType != other.runtimeType) return false;
    return tasks == other.tasks;
  }

  @override
  int get hashCode => tasks.hashCode;

  @override
  String toString() => 'DatasetImportTasks(tasks: $tasks)';
}
