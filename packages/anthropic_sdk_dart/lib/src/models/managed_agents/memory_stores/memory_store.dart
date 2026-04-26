import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// A managed agents memory store.
///
/// Memory stores are containers for [Memory] objects that can be mounted into
/// agent sessions. This is a beta feature and requires the `anthropic-beta`
/// header.
@immutable
class MemoryStore {
  /// Object type. Always `memory_store`.
  final String type;

  /// Unique identifier for the memory store (`memstore_...`).
  final String id;

  /// Display name of the memory store.
  final String name;

  /// Optional description.
  final String? description;

  /// Custom metadata. Limited to 16 keys (≤64 chars), values up to 512 chars.
  final Map<String, String>? metadata;

  /// ISO 8601 timestamp of when the store was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the store was last updated.
  final DateTime updatedAt;

  /// ISO 8601 timestamp of when the store was archived, if applicable.
  final DateTime? archivedAt;

  /// Creates a [MemoryStore].
  MemoryStore({
    this.type = 'memory_store',
    required this.id,
    required this.name,
    this.description,
    Map<String, String>? metadata,
    required this.createdAt,
    required this.updatedAt,
    this.archivedAt,
  }) : metadata = metadata != null ? Map.unmodifiable(metadata) : null;

  /// Creates a [MemoryStore] from JSON.
  factory MemoryStore.fromJson(Map<String, dynamic> json) {
    return MemoryStore(
      type: json['type'] as String? ?? 'memory_store',
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      metadata: (json['metadata'] as Map<String, dynamic>?)?.map(
        (k, v) => MapEntry(k, v as String),
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      archivedAt: json['archived_at'] != null
          ? DateTime.parse(json['archived_at'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'name': name,
    if (description != null) 'description': description,
    if (metadata != null) 'metadata': metadata,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
    if (archivedAt != null)
      'archived_at': archivedAt!.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  MemoryStore copyWith({
    String? type,
    String? id,
    String? name,
    Object? description = unsetCopyWithValue,
    Object? metadata = unsetCopyWithValue,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? archivedAt = unsetCopyWithValue,
  }) {
    return MemoryStore(
      type: type ?? this.type,
      id: id ?? this.id,
      name: name ?? this.name,
      description: description == unsetCopyWithValue
          ? this.description
          : description as String?,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, String>?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      archivedAt: archivedAt == unsetCopyWithValue
          ? this.archivedAt
          : archivedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryStore &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          name == other.name &&
          description == other.description &&
          mapsEqual(metadata, other.metadata) &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt &&
          archivedAt == other.archivedAt;

  @override
  int get hashCode => Object.hash(
    type,
    id,
    name,
    description,
    mapHash(metadata),
    createdAt,
    updatedAt,
    archivedAt,
  );

  @override
  String toString() =>
      'MemoryStore('
      'type: $type, '
      'id: $id, '
      'name: $name, '
      'description: $description, '
      'metadata: ${metadata?.length ?? 0} entries, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'archivedAt: $archivedAt)';
}

/// Confirmation that a [MemoryStore] has been deleted.
@immutable
class DeletedMemoryStore {
  /// Object type. Always `memory_store_deleted`.
  final String type;

  /// Unique identifier of the deleted memory store.
  final String id;

  /// Creates a [DeletedMemoryStore].
  const DeletedMemoryStore({
    this.type = 'memory_store_deleted',
    required this.id,
  });

  /// Creates a [DeletedMemoryStore] from JSON.
  factory DeletedMemoryStore.fromJson(Map<String, dynamic> json) {
    return DeletedMemoryStore(
      type: json['type'] as String? ?? 'memory_store_deleted',
      id: json['id'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Creates a copy with replaced values.
  DeletedMemoryStore copyWith({String? type, String? id}) {
    return DeletedMemoryStore(type: type ?? this.type, id: id ?? this.id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedMemoryStore &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => 'DeletedMemoryStore(type: $type, id: $id)';
}
