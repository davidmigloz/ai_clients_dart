import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// An observability dataset.
@immutable
class Dataset {
  /// Unique identifier.
  final String id;

  /// When the dataset was created.
  final DateTime createdAt;

  /// When the dataset was last updated.
  final DateTime updatedAt;

  /// When the dataset was deleted (null if active).
  final DateTime? deletedAt;

  /// Dataset name.
  final String name;

  /// Dataset description.
  final String description;

  /// Owner user ID.
  final String ownerId;

  /// Workspace ID.
  final String workspaceId;

  /// Creates a [Dataset].
  const Dataset({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.workspaceId,
  });

  /// Creates a [Dataset] from JSON.
  factory Dataset.fromJson(Map<String, dynamic> json) => Dataset(
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
    name: json['name'] as String? ?? '',
    description: json['description'] as String? ?? '',
    ownerId: json['owner_id'] as String? ?? '',
    workspaceId: json['workspace_id'] as String? ?? '',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'name': name,
    'description': description,
    'owner_id': ownerId,
    'workspace_id': workspaceId,
  };

  /// Creates a copy with replaced values.
  Dataset copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = unsetCopyWithValue,
    String? name,
    String? description,
    String? ownerId,
    String? workspaceId,
  }) {
    return Dataset(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == unsetCopyWithValue
          ? this.deletedAt
          : deletedAt as DateTime?,
      name: name ?? this.name,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      workspaceId: workspaceId ?? this.workspaceId,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! Dataset) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        name == other.name &&
        description == other.description &&
        ownerId == other.ownerId &&
        workspaceId == other.workspaceId;
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    description,
    ownerId,
    workspaceId,
  );

  @override
  String toString() => 'Dataset(id: $id, name: $name)';
}
