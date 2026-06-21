import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Response returned when a batch job is deleted.
@immutable
class DeleteBatchJobResponse {
  /// Unique identifier of the deleted job.
  final String id;

  /// Whether the job was deleted.
  final bool? deleted;

  /// Object type.
  final String? object;

  /// Creates a [DeleteBatchJobResponse].
  const DeleteBatchJobResponse({required this.id, this.deleted, this.object});

  /// Creates a [DeleteBatchJobResponse] from JSON.
  factory DeleteBatchJobResponse.fromJson(Map<String, dynamic> json) =>
      DeleteBatchJobResponse(
        id: json['id'] as String? ?? '',
        deleted: json['deleted'] as bool?,
        object: json['object'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    if (deleted != null) 'deleted': deleted,
    if (object != null) 'object': object,
  };

  /// Creates a copy with replaced values.
  DeleteBatchJobResponse copyWith({
    String? id,
    Object? deleted = unsetCopyWithValue,
    Object? object = unsetCopyWithValue,
  }) {
    return DeleteBatchJobResponse(
      id: id ?? this.id,
      deleted: deleted == unsetCopyWithValue ? this.deleted : deleted as bool?,
      object: object == unsetCopyWithValue ? this.object : object as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DeleteBatchJobResponse) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id && deleted == other.deleted && object == other.object;
  }

  @override
  int get hashCode => Object.hash(id, deleted, object);

  @override
  String toString() =>
      'DeleteBatchJobResponse(id: $id, deleted: $deleted, object: $object)';
}
