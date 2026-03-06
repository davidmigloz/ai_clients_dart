import 'package:meta/meta.dart';

/// A file within a container.
///
/// Container files are files that have been added to a container
/// for use in isolated execution environments.
///
/// ## Example
///
/// ```dart
/// final files = await client.containers.files.list('container-abc123');
/// for (final file in files.data) {
///   print('${file.path}: ${file.bytes} bytes');
/// }
/// ```
@immutable
class ContainerFile {
  /// Creates a [ContainerFile].
  const ContainerFile({
    required this.id,
    required this.object,
    required this.containerId,
    required this.createdAt,
    this.bytes,
    required this.path,
    this.source,
  });

  /// Creates a [ContainerFile] from JSON.
  factory ContainerFile.fromJson(Map<String, dynamic> json) {
    return ContainerFile(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'container.file',
      containerId: json['container_id'] as String,
      createdAt: json['created_at'] as int,
      bytes: json['bytes'] as int?,
      path: json['path'] as String,
      source: json['source'] as String?,
    );
  }

  /// Unique identifier for the file.
  final String id;

  /// The type of this object (`container.file`).
  final String object;

  /// The container this file belongs to.
  final String containerId;

  /// Unix timestamp (in seconds) when the file was created.
  final int createdAt;

  /// Size of the file in bytes, or null if not yet available.
  final int? bytes;

  /// Path of the file in the container.
  final String path;

  /// Source of the file.
  final String? source;

  /// The creation time as a DateTime.
  DateTime get createdAtDateTime =>
      DateTime.fromMillisecondsSinceEpoch(createdAt * 1000);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'container_id': containerId,
    'created_at': createdAt,
    if (bytes != null) 'bytes': bytes,
    'path': path,
    if (source != null) 'source': source,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerFile &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'ContainerFile(id: $id, path: $path)';
}

/// A list of container files.
@immutable
class ContainerFileList {
  /// Creates a [ContainerFileList].
  const ContainerFileList({
    required this.object,
    required this.data,
    this.firstId,
    this.lastId,
    required this.hasMore,
  });

  /// Creates a [ContainerFileList] from JSON.
  factory ContainerFileList.fromJson(Map<String, dynamic> json) {
    return ContainerFileList(
      object: json['object'] as String? ?? 'list',
      data: (json['data'] as List<dynamic>)
          .map((e) => ContainerFile.fromJson(e as Map<String, dynamic>))
          .toList(),
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
      hasMore: json['has_more'] as bool? ?? false,
    );
  }

  /// The object type, which is always `list`.
  final String object;

  /// The list of container files.
  final List<ContainerFile> data;

  /// The ID of the first file in the list, or null if empty.
  final String? firstId;

  /// The ID of the last file in the list, or null if empty.
  final String? lastId;

  /// Whether there are more files available.
  final bool hasMore;

  /// Whether the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of files.
  int get length => data.length;

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
      other is ContainerFileList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          data.length == other.data.length;

  @override
  int get hashCode => Object.hash(object, data.length);

  @override
  String toString() => 'ContainerFileList(${data.length} files)';
}

/// The response from deleting a container file.
@immutable
class DeleteContainerFileResponse {
  /// Creates a [DeleteContainerFileResponse].
  const DeleteContainerFileResponse({
    required this.id,
    required this.object,
    required this.deleted,
  });

  /// Creates a [DeleteContainerFileResponse] from JSON.
  factory DeleteContainerFileResponse.fromJson(Map<String, dynamic> json) {
    return DeleteContainerFileResponse(
      id: json['id'] as String,
      object: json['object'] as String? ?? 'container.file.deleted',
      deleted: json['deleted'] as bool,
    );
  }

  /// The ID of the deleted file.
  final String id;

  /// The object type.
  final String object;

  /// Whether the file was successfully deleted.
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
      other is DeleteContainerFileResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          deleted == other.deleted;

  @override
  int get hashCode => Object.hash(id, deleted);

  @override
  String toString() =>
      'DeleteContainerFileResponse(id: $id, deleted: $deleted)';
}
