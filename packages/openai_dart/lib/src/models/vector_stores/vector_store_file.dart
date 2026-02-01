import 'package:meta/meta.dart';

import '../assistants/tool_resources.dart';

/// A file in a vector store.
///
/// Files are processed and indexed for semantic search.
@immutable
class VectorStoreFile {
  /// Creates a [VectorStoreFile].
  const VectorStoreFile({
    required this.id,
    required this.object,
    required this.usageBytes,
    required this.createdAt,
    required this.vectorStoreId,
    required this.status,
    this.lastError,
    this.chunkingStrategy,
  });

  /// Creates a [VectorStoreFile] from JSON.
  factory VectorStoreFile.fromJson(Map<String, dynamic> json) {
    return VectorStoreFile(
      id: json['id'] as String,
      object: json['object'] as String,
      usageBytes: json['usage_bytes'] as int,
      createdAt: json['created_at'] as int,
      vectorStoreId: json['vector_store_id'] as String,
      status: VectorStoreFileStatus.fromJson(json['status'] as String),
      lastError: json['last_error'] != null
          ? VectorStoreFileError.fromJson(
              json['last_error'] as Map<String, dynamic>,
            )
          : null,
      chunkingStrategy: json['chunking_strategy'] != null
          ? ChunkingStrategy.fromJson(
              json['chunking_strategy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The file identifier.
  final String id;

  /// The object type (always "vector_store.file").
  final String object;

  /// The size of the file in bytes.
  final int usageBytes;

  /// The Unix timestamp when the file was added.
  final int createdAt;

  /// The vector store ID this file belongs to.
  final String vectorStoreId;

  /// The processing status.
  final VectorStoreFileStatus status;

  /// The last error if processing failed.
  final VectorStoreFileError? lastError;

  /// The chunking strategy used.
  final ChunkingStrategy? chunkingStrategy;

  /// Whether the file is ready.
  bool get isReady => status == VectorStoreFileStatus.completed;

  /// Whether the file failed processing.
  bool get isFailed => status == VectorStoreFileStatus.failed;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'usage_bytes': usageBytes,
    'created_at': createdAt,
    'vector_store_id': vectorStoreId,
    'status': status.toJson(),
    if (lastError != null) 'last_error': lastError!.toJson(),
    if (chunkingStrategy != null)
      'chunking_strategy': chunkingStrategy!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorStoreFile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'VectorStoreFile(id: $id, status: $status)';
}

/// A list of vector store files.
@immutable
class VectorStoreFileList {
  /// Creates a [VectorStoreFileList].
  const VectorStoreFileList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [VectorStoreFileList] from JSON.
  factory VectorStoreFileList.fromJson(Map<String, dynamic> json) {
    return VectorStoreFileList(
      object: json['object'] as String,
      data: (json['data'] as List<dynamic>)
          .map((e) => VectorStoreFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool,
    );
  }

  /// The object type (always "list").
  final String object;

  /// The list of files.
  final List<VectorStoreFile> data;

  /// The ID of the first file.
  final String? firstId;

  /// The ID of the last file.
  final String? lastId;

  /// Whether there are more files.
  final bool hasMore;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((f) => f.toJson()).toList(),
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorStoreFileList &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'VectorStoreFileList(${data.length} files)';
}

/// A request to create a vector store file.
@immutable
class CreateVectorStoreFileRequest {
  /// Creates a [CreateVectorStoreFileRequest].
  const CreateVectorStoreFileRequest({
    required this.fileId,
    this.chunkingStrategy,
  });

  /// Creates a [CreateVectorStoreFileRequest] from JSON.
  factory CreateVectorStoreFileRequest.fromJson(Map<String, dynamic> json) {
    return CreateVectorStoreFileRequest(
      fileId: json['file_id'] as String,
      chunkingStrategy: json['chunking_strategy'] != null
          ? ChunkingStrategy.fromJson(
              json['chunking_strategy'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// The file ID to add.
  final String fileId;

  /// The chunking strategy.
  final ChunkingStrategy? chunkingStrategy;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'file_id': fileId,
    if (chunkingStrategy != null)
      'chunking_strategy': chunkingStrategy!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVectorStoreFileRequest &&
          runtimeType == other.runtimeType &&
          fileId == other.fileId;

  @override
  int get hashCode => fileId.hashCode;

  @override
  String toString() => 'CreateVectorStoreFileRequest(fileId: $fileId)';
}

/// The response from deleting a vector store file.
@immutable
class DeleteVectorStoreFileResponse {
  /// Creates a [DeleteVectorStoreFileResponse].
  const DeleteVectorStoreFileResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteVectorStoreFileResponse] from JSON.
  factory DeleteVectorStoreFileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteVectorStoreFileResponse(
      id: json['id'] as String,
      object: json['object'] as String,
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted file.
  final String id;

  /// The object type.
  final String object;

  /// Whether the file was deleted.
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
      other is DeleteVectorStoreFileResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'DeleteVectorStoreFileResponse(id: $id, deleted: $deleted)';
}

/// Vector store file status values.
enum VectorStoreFileStatus {
  /// File is in progress.
  inProgress._('in_progress'),

  /// File processing completed.
  completed._('completed'),

  /// File processing was cancelled.
  cancelled._('cancelled'),

  /// File processing failed.
  failed._('failed');

  const VectorStoreFileStatus._(this._value);

  /// Creates from JSON string.
  factory VectorStoreFileStatus.fromJson(String json) {
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

/// An error from vector store file processing.
@immutable
class VectorStoreFileError {
  /// Creates a [VectorStoreFileError].
  const VectorStoreFileError({required this.code, required this.message});

  /// Creates a [VectorStoreFileError] from JSON.
  factory VectorStoreFileError.fromJson(Map<String, dynamic> json) {
    return VectorStoreFileError(
      code: json['code'] as String,
      message: json['message'] as String,
    );
  }

  /// The error code.
  final String code;

  /// The error message.
  final String message;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'code': code, 'message': message};

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VectorStoreFileError &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'VectorStoreFileError(code: $code)';
}
