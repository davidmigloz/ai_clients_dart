import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import '../workflows/principal_type.dart';

/// Preview of an observability dataset.
@immutable
class DatasetPreview {
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

  /// Workspace-local slug.
  final String slug;

  /// Additional JSON metadata supplied by the caller.
  final Map<String, dynamic>? metadata;

  /// Kind of account that owns the dataset.
  final PrincipalType? ownerType;

  /// Creates a [DatasetPreview].
  const DatasetPreview({
    this.slug = '',
    this.metadata,
    this.ownerType,
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.description,
    required this.ownerId,
    required this.workspaceId,
  });

  /// Creates a [DatasetPreview] from JSON.
  factory DatasetPreview.fromJson(Map<String, dynamic> json) => DatasetPreview(
    slug: json['slug'] as String? ?? '',
    metadata: json['metadata'] as Map<String, dynamic>?,
    ownerType: PrincipalType.fromJson(json['owner_type'] as String?),
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
    if (slug.isNotEmpty) 'slug': slug,
    if (metadata != null) 'metadata': metadata,
    if (ownerType != null) 'owner_type': ownerType!.value,
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
  DatasetPreview copyWith({
    String? slug,
    Object? metadata = unsetCopyWithValue,
    Object? ownerType = unsetCopyWithValue,
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = unsetCopyWithValue,
    String? name,
    String? description,
    String? ownerId,
    String? workspaceId,
  }) {
    return DatasetPreview(
      slug: slug ?? this.slug,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : (metadata as Map<Object?, Object?>?)?.cast<String, dynamic>(),
      ownerType: ownerType == unsetCopyWithValue
          ? this.ownerType
          : ownerType as PrincipalType?,
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
    if (other is! DatasetPreview) return false;
    if (runtimeType != other.runtimeType) return false;
    return slug == other.slug &&
        mapsDeepEqual(metadata, other.metadata) &&
        ownerType == other.ownerType &&
        id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        name == other.name &&
        description == other.description &&
        ownerId == other.ownerId &&
        workspaceId == other.workspaceId;
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    description,
    ownerId,
    workspaceId,
    slug,
    mapDeepHashCode(metadata),
    ownerType,
  ]);

  @override
  String toString() =>
      'DatasetPreview(slug: $slug, metadata: ${metadata?.length}, ownerType: $ownerType, id: $id, name: $name)';
}
