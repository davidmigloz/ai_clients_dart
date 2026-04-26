import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';

/// An item in a paginated list of memories.
///
/// Variants:
/// - [Memory] — a memory entry (type: `memory`)
/// - [MemoryPrefix] — a directory-like path prefix (type: `memory_prefix`)
/// - [UnknownMemoryListItem] — Unrecognized type (preserves raw JSON)
sealed class MemoryListItem {
  const MemoryListItem();

  /// Creates a [MemoryListItem] from JSON.
  factory MemoryListItem.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    return switch (type) {
      'memory' => Memory.fromJson(json),
      'memory_prefix' => MemoryPrefix.fromJson(json),
      _ => UnknownMemoryListItem.fromJson(json),
    };
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}

/// A memory stored within a [MemoryStore].
///
/// `Memory` is the canonical representation returned by single-item endpoints
/// (get/create/update) and as a `memory`-typed entry within
/// [MemoryListItem] lists.
@immutable
class Memory extends MemoryListItem {
  /// Object type. Always `memory`.
  final String type;

  /// Unique identifier for the memory (`mem_...`).
  final String id;

  /// The memory store this memory belongs to.
  final String memoryStoreId;

  /// Memory path within the store, e.g. `/notes/foo.md`.
  final String path;

  /// Memory content. Returned only when `view=full`.
  final String? content;

  /// Size of [content] in bytes.
  final int contentSizeBytes;

  /// SHA-256 of [content], hex-encoded.
  final String contentSha256;

  /// ID of the latest [MemoryVersion] for this memory.
  final String memoryVersionId;

  /// ISO 8601 timestamp of when the memory was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when the memory was last updated.
  final DateTime updatedAt;

  /// Creates a [Memory].
  const Memory({
    this.type = 'memory',
    required this.id,
    required this.memoryStoreId,
    required this.path,
    this.content,
    required this.contentSizeBytes,
    required this.contentSha256,
    required this.memoryVersionId,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [Memory] from JSON.
  factory Memory.fromJson(Map<String, dynamic> json) {
    return Memory(
      type: json['type'] as String? ?? 'memory',
      id: json['id'] as String,
      memoryStoreId: json['memory_store_id'] as String,
      path: json['path'] as String,
      content: json['content'] as String?,
      contentSizeBytes: json['content_size_bytes'] as int,
      contentSha256: json['content_sha256'] as String,
      memoryVersionId: json['memory_version_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'memory_store_id': memoryStoreId,
    'path': path,
    if (content != null) 'content': content,
    'content_size_bytes': contentSizeBytes,
    'content_sha256': contentSha256,
    'memory_version_id': memoryVersionId,
    'created_at': createdAt.toUtc().toIso8601String(),
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  Memory copyWith({
    String? type,
    String? id,
    String? memoryStoreId,
    String? path,
    Object? content = unsetCopyWithValue,
    int? contentSizeBytes,
    String? contentSha256,
    String? memoryVersionId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Memory(
      type: type ?? this.type,
      id: id ?? this.id,
      memoryStoreId: memoryStoreId ?? this.memoryStoreId,
      path: path ?? this.path,
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      contentSizeBytes: contentSizeBytes ?? this.contentSizeBytes,
      contentSha256: contentSha256 ?? this.contentSha256,
      memoryVersionId: memoryVersionId ?? this.memoryVersionId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Memory &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          memoryStoreId == other.memoryStoreId &&
          path == other.path &&
          content == other.content &&
          contentSizeBytes == other.contentSizeBytes &&
          contentSha256 == other.contentSha256 &&
          memoryVersionId == other.memoryVersionId &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(
    type,
    id,
    memoryStoreId,
    path,
    content,
    contentSizeBytes,
    contentSha256,
    memoryVersionId,
    createdAt,
    updatedAt,
  );

  @override
  String toString() =>
      'Memory('
      'type: $type, '
      'id: $id, '
      'memoryStoreId: $memoryStoreId, '
      'path: $path, '
      'content: ${content == null ? null : '${content!.length} chars'}, '
      'contentSizeBytes: $contentSizeBytes, '
      'contentSha256: $contentSha256, '
      'memoryVersionId: $memoryVersionId, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt)';
}

/// A directory-like path prefix returned by `list memories` to summarize
/// nested paths beyond the requested `depth`.
@immutable
class MemoryPrefix extends MemoryListItem {
  /// Object type. Always `memory_prefix`.
  final String type;

  /// The shared path prefix.
  final String path;

  /// Creates a [MemoryPrefix].
  const MemoryPrefix({this.type = 'memory_prefix', required this.path});

  /// Creates a [MemoryPrefix] from JSON.
  factory MemoryPrefix.fromJson(Map<String, dynamic> json) {
    return MemoryPrefix(
      type: json['type'] as String? ?? 'memory_prefix',
      path: json['path'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'path': path};

  /// Creates a copy with replaced values.
  MemoryPrefix copyWith({String? type, String? path}) {
    return MemoryPrefix(type: type ?? this.type, path: path ?? this.path);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryPrefix &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          path == other.path;

  @override
  int get hashCode => Object.hash(type, path);

  @override
  String toString() => 'MemoryPrefix(type: $type, path: $path)';
}

/// Unrecognized [MemoryListItem] — preserves raw JSON for forward
/// compatibility.
@immutable
class UnknownMemoryListItem extends MemoryListItem {
  /// The raw JSON data.
  final Map<String, dynamic> rawJson;

  /// Creates an [UnknownMemoryListItem].
  const UnknownMemoryListItem({required this.rawJson});

  /// Creates an [UnknownMemoryListItem] from JSON.
  factory UnknownMemoryListItem.fromJson(Map<String, dynamic> json) {
    return UnknownMemoryListItem(rawJson: json);
  }

  @override
  Map<String, dynamic> toJson() => rawJson;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UnknownMemoryListItem &&
          runtimeType == other.runtimeType &&
          mapsDeepEqual(rawJson, other.rawJson);

  @override
  int get hashCode => mapDeepHashCode(rawJson);

  @override
  String toString() => 'UnknownMemoryListItem(rawJson: $rawJson)';
}

/// Confirmation that a [Memory] has been deleted.
@immutable
class DeletedMemory {
  /// Object type. Always `memory_deleted`.
  final String type;

  /// Unique identifier of the deleted memory.
  final String id;

  /// Creates a [DeletedMemory].
  const DeletedMemory({this.type = 'memory_deleted', required this.id});

  /// Creates a [DeletedMemory] from JSON.
  factory DeletedMemory.fromJson(Map<String, dynamic> json) {
    return DeletedMemory(
      type: json['type'] as String? ?? 'memory_deleted',
      id: json['id'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'type': type, 'id': id};

  /// Creates a copy with replaced values.
  DeletedMemory copyWith({String? type, String? id}) {
    return DeletedMemory(type: type ?? this.type, id: id ?? this.id);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeletedMemory &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id;

  @override
  int get hashCode => Object.hash(type, id);

  @override
  String toString() => 'DeletedMemory(type: $type, id: $id)';
}
