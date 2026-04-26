import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../common/managed_agent_actor.dart';

/// Operation that produced a [MemoryVersion].
enum MemoryVersionOperation {
  /// The memory was created in this version.
  created('created'),

  /// The memory was modified in this version.
  modified('modified'),

  /// The memory was deleted in this version.
  deleted('deleted'),

  /// Unknown operation — fallback for unrecognized values.
  unknown('unknown');

  const MemoryVersionOperation(this.value);

  /// JSON value for this operation.
  final String value;

  /// Parses a [MemoryVersionOperation] from JSON.
  static MemoryVersionOperation fromJson(String value) => switch (value) {
    'created' => MemoryVersionOperation.created,
    'modified' => MemoryVersionOperation.modified,
    'deleted' => MemoryVersionOperation.deleted,
    _ => MemoryVersionOperation.unknown,
  };

  /// Converts this operation to JSON.
  String toJson() => value;
}

/// An immutable, append-only version of a [Memory] capturing a single
/// `created`/`modified`/`deleted` operation.
@immutable
class MemoryVersion {
  /// Object type. Always `memory_version`.
  final String type;

  /// Unique identifier for this version (`memver_...`).
  final String id;

  /// The memory store this version belongs to.
  final String memoryStoreId;

  /// The memory this version belongs to.
  final String memoryId;

  /// Path the memory had at this version, if applicable.
  final String? path;

  /// Snapshot of memory content at this version. May be `null` for delete
  /// operations or when redacted.
  final String? content;

  /// Size of [content] in bytes at this version, if applicable.
  final int? contentSizeBytes;

  /// SHA-256 of [content] at this version, hex-encoded, if applicable.
  final String? contentSha256;

  /// Operation that produced this version.
  final MemoryVersionOperation operation;

  /// Actor that created this version.
  final ManagedAgentActor? createdBy;

  /// Actor that redacted this version, if redacted.
  final ManagedAgentActor? redactedBy;

  /// ISO 8601 timestamp of when this version was created.
  final DateTime createdAt;

  /// ISO 8601 timestamp of when this version was redacted, if applicable.
  final DateTime? redactedAt;

  /// Creates a [MemoryVersion].
  const MemoryVersion({
    this.type = 'memory_version',
    required this.id,
    required this.memoryStoreId,
    required this.memoryId,
    this.path,
    this.content,
    this.contentSizeBytes,
    this.contentSha256,
    required this.operation,
    this.createdBy,
    this.redactedBy,
    required this.createdAt,
    this.redactedAt,
  });

  /// Creates a [MemoryVersion] from JSON.
  factory MemoryVersion.fromJson(Map<String, dynamic> json) {
    return MemoryVersion(
      type: json['type'] as String? ?? 'memory_version',
      id: json['id'] as String,
      memoryStoreId: json['memory_store_id'] as String,
      memoryId: json['memory_id'] as String,
      path: json['path'] as String?,
      content: json['content'] as String?,
      contentSizeBytes: json['content_size_bytes'] as int?,
      contentSha256: json['content_sha256'] as String?,
      operation: MemoryVersionOperation.fromJson(json['operation'] as String),
      createdBy: json['created_by'] != null
          ? ManagedAgentActor.fromJson(
              json['created_by'] as Map<String, dynamic>,
            )
          : null,
      redactedBy: json['redacted_by'] != null
          ? ManagedAgentActor.fromJson(
              json['redacted_by'] as Map<String, dynamic>,
            )
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      redactedAt: json['redacted_at'] != null
          ? DateTime.parse(json['redacted_at'] as String)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'type': type,
    'id': id,
    'memory_store_id': memoryStoreId,
    'memory_id': memoryId,
    if (path != null) 'path': path,
    if (content != null) 'content': content,
    if (contentSizeBytes != null) 'content_size_bytes': contentSizeBytes,
    if (contentSha256 != null) 'content_sha256': contentSha256,
    'operation': operation.toJson(),
    if (createdBy != null) 'created_by': createdBy!.toJson(),
    if (redactedBy != null) 'redacted_by': redactedBy!.toJson(),
    'created_at': createdAt.toUtc().toIso8601String(),
    if (redactedAt != null)
      'redacted_at': redactedAt!.toUtc().toIso8601String(),
  };

  /// Creates a copy with replaced values.
  MemoryVersion copyWith({
    String? type,
    String? id,
    String? memoryStoreId,
    String? memoryId,
    Object? path = unsetCopyWithValue,
    Object? content = unsetCopyWithValue,
    Object? contentSizeBytes = unsetCopyWithValue,
    Object? contentSha256 = unsetCopyWithValue,
    MemoryVersionOperation? operation,
    Object? createdBy = unsetCopyWithValue,
    Object? redactedBy = unsetCopyWithValue,
    DateTime? createdAt,
    Object? redactedAt = unsetCopyWithValue,
  }) {
    return MemoryVersion(
      type: type ?? this.type,
      id: id ?? this.id,
      memoryStoreId: memoryStoreId ?? this.memoryStoreId,
      memoryId: memoryId ?? this.memoryId,
      path: path == unsetCopyWithValue ? this.path : path as String?,
      content: content == unsetCopyWithValue
          ? this.content
          : content as String?,
      contentSizeBytes: contentSizeBytes == unsetCopyWithValue
          ? this.contentSizeBytes
          : contentSizeBytes as int?,
      contentSha256: contentSha256 == unsetCopyWithValue
          ? this.contentSha256
          : contentSha256 as String?,
      operation: operation ?? this.operation,
      createdBy: createdBy == unsetCopyWithValue
          ? this.createdBy
          : createdBy as ManagedAgentActor?,
      redactedBy: redactedBy == unsetCopyWithValue
          ? this.redactedBy
          : redactedBy as ManagedAgentActor?,
      createdAt: createdAt ?? this.createdAt,
      redactedAt: redactedAt == unsetCopyWithValue
          ? this.redactedAt
          : redactedAt as DateTime?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryVersion &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          id == other.id &&
          memoryStoreId == other.memoryStoreId &&
          memoryId == other.memoryId &&
          path == other.path &&
          content == other.content &&
          contentSizeBytes == other.contentSizeBytes &&
          contentSha256 == other.contentSha256 &&
          operation == other.operation &&
          createdBy == other.createdBy &&
          redactedBy == other.redactedBy &&
          createdAt == other.createdAt &&
          redactedAt == other.redactedAt;

  @override
  int get hashCode => Object.hash(
    type,
    id,
    memoryStoreId,
    memoryId,
    path,
    content,
    contentSizeBytes,
    contentSha256,
    operation,
    createdBy,
    redactedBy,
    createdAt,
    redactedAt,
  );

  @override
  String toString() =>
      'MemoryVersion('
      'type: $type, '
      'id: $id, '
      'memoryStoreId: $memoryStoreId, '
      'memoryId: $memoryId, '
      'path: $path, '
      'content: ${content == null ? null : '${content!.length} chars'}, '
      'contentSizeBytes: $contentSizeBytes, '
      'contentSha256: $contentSha256, '
      'operation: $operation, '
      'createdBy: $createdBy, '
      'redactedBy: $redactedBy, '
      'createdAt: $createdAt, '
      'redactedAt: $redactedAt)';
}
