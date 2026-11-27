import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../workflows/principal_type.dart';
import 'base_task_status.dart';
import 'dataset_record_batch.dart';

/// A dataset import task tracking the progress of an import operation.
@immutable
class DatasetImportTask {
  /// Unique identifier.
  final String id;

  /// When the task was created.
  final DateTime createdAt;

  /// When the task was last updated.
  final DateTime updatedAt;

  /// When the task was deleted (null if active).
  final DateTime? deletedAt;

  /// ID of the user who created the task.
  final String creatorId;

  /// ID of the target dataset.
  final String datasetId;

  /// Workspace ID.
  final String workspaceId;

  /// Current task status.
  final BaseTaskStatus status;

  /// Status message.
  final String? message;

  /// Progress percentage (0-100).
  final int? progress;

  /// Kind of account that submitted the import.
  final PrincipalType? creatorType;

  /// Record counts when the import has finished.
  final DatasetImportResult? result;

  /// Creates a [DatasetImportTask].
  const DatasetImportTask({
    this.creatorType,
    this.result,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.creatorId,
    required this.datasetId,
    required this.workspaceId,
    required this.status,
    this.message,
    this.progress,
  });

  /// Creates a [DatasetImportTask] from JSON.
  factory DatasetImportTask.fromJson(Map<String, dynamic> json) =>
      DatasetImportTask(
        creatorType: PrincipalType.fromJson(json['creator_type'] as String?),
        result: json['result'] == null
            ? null
            : DatasetImportResult.fromJson(
                json['result'] as Map<String, dynamic>,
              ),
        id: json['id'] as String? ?? '',
        createdAt:
            DateTime.tryParse(json['created_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        updatedAt:
            DateTime.tryParse(json['updated_at'] as String? ?? '') ??
            DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
        deletedAt: json['deleted_at'] != null
            ? DateTime.tryParse(json['deleted_at'] as String)
            : null,
        creatorId: json['creator_id'] as String? ?? '',
        datasetId: json['dataset_id'] as String? ?? '',
        workspaceId: json['workspace_id'] as String? ?? '',
        status: BaseTaskStatus.fromJson(json['status'] as String?),
        message: json['message'] as String?,
        progress: json['progress'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (creatorType != null) 'creator_type': creatorType!.value,
    if (result != null) 'result': result!.toJson(),
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'creator_id': creatorId,
    'dataset_id': datasetId,
    'workspace_id': workspaceId,
    'status': status.value,
    if (message != null) 'message': message,
    if (progress != null) 'progress': progress,
  };

  /// Creates a copy with replaced values.
  DatasetImportTask copyWith({
    Object? creatorType = unsetCopyWithValue,
    Object? result = unsetCopyWithValue,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = unsetCopyWithValue,
    String? creatorId,
    String? datasetId,
    String? workspaceId,
    BaseTaskStatus? status,
    Object? message = unsetCopyWithValue,
    Object? progress = unsetCopyWithValue,
  }) {
    return DatasetImportTask(
      creatorType: creatorType == unsetCopyWithValue
          ? this.creatorType
          : creatorType as PrincipalType?,
      result: result == unsetCopyWithValue
          ? this.result
          : result as DatasetImportResult?,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == unsetCopyWithValue
          ? this.deletedAt
          : deletedAt as DateTime?,
      creatorId: creatorId ?? this.creatorId,
      datasetId: datasetId ?? this.datasetId,
      workspaceId: workspaceId ?? this.workspaceId,
      status: status ?? this.status,
      message: message == unsetCopyWithValue
          ? this.message
          : message as String?,
      progress: progress == unsetCopyWithValue
          ? this.progress
          : progress as int?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DatasetImportTask) return false;
    if (runtimeType != other.runtimeType) return false;
    return creatorType == other.creatorType &&
        result == other.result &&
        id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        creatorId == other.creatorId &&
        datasetId == other.datasetId &&
        workspaceId == other.workspaceId &&
        status == other.status &&
        message == other.message &&
        progress == other.progress;
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    creatorId,
    datasetId,
    workspaceId,
    status,
    message,
    progress,
    creatorType,
    result,
  ]);

  @override
  String toString() =>
      'DatasetImportTask(creatorType: $creatorType, result: $result, id: $id, datasetId: $datasetId, '
      'status: ${status.value}, progress: $progress)';
}
