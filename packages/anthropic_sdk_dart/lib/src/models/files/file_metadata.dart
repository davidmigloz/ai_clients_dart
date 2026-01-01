import 'package:meta/meta.dart';

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

  /// Creates a [FileMetadata].
  const FileMetadata({
    required this.id,
    required this.filename,
    required this.mimeType,
    required this.sizeBytes,
    required this.createdAt,
    this.type = 'file',
    this.downloadable = false,
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
  }) {
    return FileMetadata(
      id: id ?? this.id,
      filename: filename ?? this.filename,
      mimeType: mimeType ?? this.mimeType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      downloadable: downloadable ?? this.downloadable,
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
          downloadable == other.downloadable;

  @override
  int get hashCode => Object.hash(
    id,
    filename,
    mimeType,
    sizeBytes,
    createdAt,
    type,
    downloadable,
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
      'downloadable: $downloadable)';
}
