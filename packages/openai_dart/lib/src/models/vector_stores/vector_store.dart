import 'package:meta/meta.dart';

import '../assistants/tool_resources.dart';

/// A vector store for semantic file search.
///
/// Vector stores process and index files for efficient semantic search
/// within the Assistants API.
@immutable
class VectorStore {
  /// Creates a [VectorStore].
  const VectorStore({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.name,
    required this.usageBytes,
    required this.fileCounts,
    required this.status,
    this.expiresAfter,
    this.expiresAt,
    this.lastActiveAt,
    required this.metadata,
  });

  /// Creates a [VectorStore] from JSON.
  factory VectorStore.fromJson(Map<String, dynamic> json) {
    return VectorStore(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      name: json['name'] as String?,
      usageBytes: json['usage_bytes'] as int,
      fileCounts: VectorStoreFileCounts.fromJson(
        json['file_counts'] as Map<String, dynamic>,
      ),
      status: VectorStoreStatus.fromJson(json['status'] as String),
      expiresAfter: json['expires_after'] != null
          ? ExpirationPolicy.fromJson(
              json['expires_after'] as Map<String, dynamic>,
            )
          : null,
      expiresAt: json['expires_at'] as int?,
      lastActiveAt: json['last_active_at'] as int?,
      metadata:
          (json['metadata'] as Map<String, dynamic>?)?.cast<String, String>() ??
          {},
    );
  }

  /// The vector store identifier.
  final String id;

  /// The object type (always "vector_store").
  final String object;

  /// The Unix timestamp when the vector store was created.
  final int createdAt;

  /// The name of the vector store.
  final String? name;

  /// The total size of files in bytes.
  final int usageBytes;

  /// File counts by status.
  final VectorStoreFileCounts fileCounts;

  /// The status of the vector store.
  final VectorStoreStatus status;

  /// The expiration policy.
  final ExpirationPolicy? expiresAfter;

  /// The Unix timestamp when the vector store expires.
  final int? expiresAt;

  /// The Unix timestamp of last activity.
  final int? lastActiveAt;

  /// Custom metadata.
  final Map<String, String> metadata;

  /// Whether the vector store is ready for use.
  bool get isReady => status == VectorStoreStatus.completed;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    if (name != null) 'name': name,
    'usage_bytes': usageBytes,
    'file_counts': fileCounts.toJson(),
    'status': status.toJson(),
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
    if (expiresAt != null) 'expires_at': expiresAt,
    if (lastActiveAt != null) 'last_active_at': lastActiveAt,
    'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorStore &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VectorStore(id: $id, name: $name)';
}

/// A list of vector stores.
@immutable
class VectorStoreList {
  /// Creates a [VectorStoreList].
  const VectorStoreList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [VectorStoreList] from JSON.
  factory VectorStoreList.fromJson(Map<String, dynamic> json) {
    return VectorStoreList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => VectorStore.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of vector stores.
  final List<VectorStore> data;

  /// The ID of the first vector store.
  final String? firstId;

  /// The ID of the last vector store.
  final String? lastId;

  /// Whether there are more vector stores.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((v) => v.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorStoreList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'VectorStoreList(${data.length} stores)';
}

/// A request to create a vector store.
@immutable
class CreateVectorStoreRequest {
  /// Creates a [CreateVectorStoreRequest].
  const CreateVectorStoreRequest({
    this.fileIds,
    this.name,
    this.expiresAfter,
    this.chunkingStrategy,
    this.metadata,
  });

  /// Creates a [CreateVectorStoreRequest] from JSON.
  factory CreateVectorStoreRequest.fromJson(Map<String, dynamic> json) {
    return CreateVectorStoreRequest(
      fileIds: (json['file_ids'] as List<dynamic>?)?.cast<String>(),
      name: json['name'] as String?,
      expiresAfter: json['expires_after'] != null
          ? ExpirationPolicy.fromJson(
              json['expires_after'] as Map<String, dynamic>,
            )
          : null,
      chunkingStrategy: json['chunking_strategy'] != null
          ? ChunkingStrategy.fromJson(
              json['chunking_strategy'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// File IDs to add to the vector store.
  final List<String>? fileIds;

  /// The name of the vector store.
  final String? name;

  /// The expiration policy.
  final ExpirationPolicy? expiresAfter;

  /// The chunking strategy.
  final ChunkingStrategy? chunkingStrategy;

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (fileIds != null) 'file_ids': fileIds,
    if (name != null) 'name': name,
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
    if (chunkingStrategy != null)
      'chunking_strategy': chunkingStrategy!.toJson(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVectorStoreRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => Object.hash(name, fileIds);

  @override
  String toString() => 'CreateVectorStoreRequest(name: $name)';
}

/// A request to modify a vector store.
@immutable
class ModifyVectorStoreRequest {
  /// Creates a [ModifyVectorStoreRequest].
  const ModifyVectorStoreRequest({this.name, this.expiresAfter, this.metadata});

  /// Creates a [ModifyVectorStoreRequest] from JSON.
  factory ModifyVectorStoreRequest.fromJson(Map<String, dynamic> json) {
    return ModifyVectorStoreRequest(
      name: json['name'] as String?,
      expiresAfter: json['expires_after'] != null
          ? ExpirationPolicy.fromJson(
              json['expires_after'] as Map<String, dynamic>,
            )
          : null,
      metadata: (json['metadata'] as Map<String, dynamic>?)
          ?.cast<String, String>(),
    );
  }

  /// The name of the vector store.
  final String? name;

  /// The expiration policy.
  final ExpirationPolicy? expiresAfter;

  /// Custom metadata.
  final Map<String, String>? metadata;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (name != null) 'name': name,
    if (expiresAfter != null) 'expires_after': expiresAfter!.toJson(),
    if (metadata != null) 'metadata': metadata,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ModifyVectorStoreRequest && runtimeType == other.runtimeType;

  @override
  int get hashCode => name.hashCode;

  @override
  String toString() => 'ModifyVectorStoreRequest(name: $name)';
}

/// The response from deleting a vector store.
@immutable
class DeleteVectorStoreResponse {
  /// Creates a [DeleteVectorStoreResponse].
  const DeleteVectorStoreResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteVectorStoreResponse] from JSON.
  factory DeleteVectorStoreResponse.fromJson(Map<String, dynamic> json) {
    return DeleteVectorStoreResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted vector store.
  final String id;

  /// The object type.
  final String object;

  /// Whether the vector store was deleted.
  final bool deleted;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteVectorStoreResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'DeleteVectorStoreResponse(id: $id, deleted: $deleted)';
}

/// File counts by status in a vector store.
@immutable
class VectorStoreFileCounts {
  /// Creates a [VectorStoreFileCounts].
  const VectorStoreFileCounts({
    required this.inProgress,
    required this.completed,
    required this.failed,
    required this.cancelled,
    required this.total,
  });

  /// Creates a [VectorStoreFileCounts] from JSON.
  factory VectorStoreFileCounts.fromJson(Map<String, dynamic> json) {
    return VectorStoreFileCounts(
      inProgress: json['in_progress'] as int,
      completed: json['completed'] as int,
      failed: json['failed'] as int,
      cancelled: json['cancelled'] as int,
      total: json['total'] as int,
    );
  }

  /// Files in progress.
  final int inProgress;

  /// Completed files.
  final int completed;

  /// Failed files.
  final int failed;

  /// Cancelled files.
  final int cancelled;

  /// Total files.
  final int total;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'in_progress': inProgress,
    'completed': completed,
    'failed': failed,
    'cancelled': cancelled,
    'total': total,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorStoreFileCounts &&
          runtimeType == other.runtimeType &&
          total == other.total;

  @override
  int get hashCode => total.hashCode;

  @override
  String toString() => 'VectorStoreFileCounts(completed: $completed/$total)';
}

/// Vector store status values.
enum VectorStoreStatus {
  /// Files are being processed.
  inProgress._('in_progress'),

  /// Processing completed.
  completed._('completed'),

  /// The vector store expired.
  expired._('expired');

  const VectorStoreStatus._(this._value);

  /// Creates from JSON string.
  factory VectorStoreStatus.fromJson(String json) {
    return values.firstWhere(
      (e) => e._value == json,
      orElse: () => throw FormatException('Unknown status: $json'),
    );
  }

  final String _value;

  /// Converts to JSON string.
  String toJson() => _value;

  @override
  String toString() => _value;
}

/// An expiration policy for a vector store.
@immutable
class ExpirationPolicy {
  /// Creates an [ExpirationPolicy].
  const ExpirationPolicy({required this.anchor, required this.days});

  /// Creates an [ExpirationPolicy] from JSON.
  factory ExpirationPolicy.fromJson(Map<String, dynamic> json) {
    return ExpirationPolicy(
      anchor: json['anchor'] as String,
      days: json['days'] as int,
    );
  }

  /// The anchor for expiration ("last_active_at").
  final String anchor;

  /// The number of days until expiration.
  final int days;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'anchor': anchor, 'days': days};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExpirationPolicy &&
          runtimeType == other.runtimeType &&
          anchor == other.anchor &&
          days == other.days;

  @override
  int get hashCode => Object.hash(anchor, days);

  @override
  String toString() => 'ExpirationPolicy(anchor: $anchor, days: $days)';
}
