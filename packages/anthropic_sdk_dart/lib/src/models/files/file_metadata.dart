import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// The scope of a file, indicating the context in which it was created.
@immutable
class FileScope {
  /// The ID of the scoping resource (e.g., the session ID).
  final String id;

  /// The type of scope. Currently always "session".
  final String type;

  /// Creates a [FileScope].
  const FileScope({required this.id, this.type = 'session'});

  /// Creates a [FileScope] from JSON.
  factory FileScope.fromJson(Map<String, dynamic> json) {
    return FileScope(
      id: json['id'] as String,
      type: json['type'] as String? ?? 'session',
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'type': type};

  /// Creates a copy with replaced values.
  FileScope copyWith({String? id, String? type}) {
    return FileScope(id: id ?? this.id, type: type ?? this.type);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileScope &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type;

  @override
  int get hashCode => Object.hash(id, type);

  @override
  String toString() => 'FileScope(id: $id, type: $type)';
}

/// Metadata for a file uploaded to Anthropic.
@immutable
class FileMetadata {
  /// Unique object identifier.
  ///
  /// The format and length of IDs may change over time.
  final String id;

  /// Original filename of the uploaded file.
  final String filename;

  /// MIME type of the file.
  final String mimeType;

  /// Size of the file in bytes.
  final int sizeBytes;

  /// RFC 3339 datetime string representing when the file was created.
  final DateTime createdAt;

  /// Object type. Always "file".
  final String type;

  /// Whether the file can be downloaded.
  final bool downloadable;

  /// The scope of this file, indicating the context in which it was created.
  final FileScope? scope;

  /// Creates a [FileMetadata].
  const FileMetadata({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
    this.type = 'file',
    this.downloadable = false,
    this.scope,
  });

  /// Creates a [FileMetadata] from JSON.
  factory FileMetadata.fromJson(Map<String, dynamic> json) {
    return FileMetadata(
      id: json['id'] as String,
      filename: json['filename'] as String,
      mimeType: json['mime_type'] as String,
      sizeBytes: json['size_bytes'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      type: json['type'] as String? ?? 'file',
      downloadable: json['downloadable'] as bool? ?? false,
      scope: json['scope'] != null
          ? FileScope.fromJson(json['scope'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'filename': filename,
    'mime_type': mimeType,
    'size_bytes': sizeBytes,
    'created_at': createdAt.toUtc().toIso8601String(),
    'type': type,
    'downloadable': downloadable,
    if (scope != null) 'scope': scope!.toJson(),
  };

  /// Creates a copy with replaced values.
  FileMetadata copyWith({
    String? id,
    String? filename,
    String? mimeType,
    int? sizeBytes,
    DateTime? createdAt,
    String? type,
    bool? downloadable,
    Object? scope = unsetCopyWithValue,
  }) {
    return FileMetadata(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      downloadable: downloadable ?? this.downloadable,
      scope: scope == unsetCopyWithValue ? this.scope : scope as FileScope?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileMetadata &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          filename == other.filename &&
          mimeType == other.mimeType &&
          sizeBytes == other.sizeBytes &&
          createdAt == other.createdAt &&
          type == other.type &&
          downloadable == other.downloadable &&
          scope == other.scope;

  @override
  int get hashCode => Object.hash(
    id,
    filename,
    mimeType,
    sizeBytes,
    createdAt,
    type,
    downloadable,
    scope,
  );

  @override
  String toString() =>
      'FileMetadata('
      'id: $id, '
      'filename: $filename, '
      'mimeType: $mimeType, '
      'sizeBytes: $sizeBytes, '
      'createdAt: $createdAt, '
      'type: $type, '
      'downloadable: $downloadable, '
      'scope: $scope)';
}
