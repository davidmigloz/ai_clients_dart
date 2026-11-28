part of 'environments.dart';

/// File or directory entry type, including future wire values.
extension type const EnvironmentFileType(String value) {
  /// A regular file.
  static const file = EnvironmentFileType('FILE');

  /// A directory.
  static const directory = EnvironmentFileType('DIRECTORY');

  /// The service did not specify the type.
  static const unspecified = EnvironmentFileType('TYPE_UNSPECIFIED');

  /// Whether the entry is a regular file.
  bool get isFile => value.toUpperCase() == file.value;

  /// Whether the entry is a directory.
  bool get isDirectory => value.toUpperCase() == directory.value;
}

/// Metadata for a file or directory within an environment.
class EnvironmentFile {
  /// Entry name, such as `main.py` or `src`.
  final String? name;

  /// Full path relative to the workspace root.
  final String? path;

  /// The kind of entry.
  final EnvironmentFileType? type;

  /// Entry size in bytes, as an int64 string to preserve precision on the web.
  final String? sizeBytes;

  /// MIME type, when supplied for a file.
  final String? mimeType;

  /// When the entry was created.
  final DateTime? created;

  /// When the entry was last modified.
  final DateTime? modified;

  /// Creates metadata for an environment entry.
  const EnvironmentFile({
    this.name,
    this.path,
    this.type,
    this.sizeBytes,
    this.mimeType,
    this.created,
    this.modified,
  });

  /// Parses file or directory metadata.
  factory EnvironmentFile.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    final created = json['created'] as String?;
    final modified = json['modified'] as String?;
    return EnvironmentFile(
      name: json['name'] as String?,
      path: json['path'] as String?,
      type: type == null ? null : EnvironmentFileType(type),
      sizeBytes: json['size_bytes'] as String?,
      mimeType: json['mime_type'] as String?,
      created: created == null ? null : DateTime.parse(created),
      modified: modified == null ? null : DateTime.parse(modified),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'name': ?name,
    'path': ?path,
    'type': ?type?.value,
    'size_bytes': ?sizeBytes,
    'mime_type': ?mimeType,
    'created': ?created?.toIso8601String(),
    'modified': ?modified?.toIso8601String(),
  };

  /// Creates a copy with replaced values.
  EnvironmentFile copyWith({
    Object? name = unsetCopyWithValue,
    Object? path = unsetCopyWithValue,
    Object? type = unsetCopyWithValue,
    Object? sizeBytes = unsetCopyWithValue,
    Object? mimeType = unsetCopyWithValue,
    Object? created = unsetCopyWithValue,
    Object? modified = unsetCopyWithValue,
  }) => EnvironmentFile(
    name: name == unsetCopyWithValue ? this.name : name as String?,
    path: path == unsetCopyWithValue ? this.path : path as String?,
    type: type == unsetCopyWithValue ? this.type : type as EnvironmentFileType?,
    sizeBytes: sizeBytes == unsetCopyWithValue
        ? this.sizeBytes
        : sizeBytes as String?,
    mimeType: mimeType == unsetCopyWithValue
        ? this.mimeType
        : mimeType as String?,
    created: created == unsetCopyWithValue
        ? this.created
        : created as DateTime?,
    modified: modified == unsetCopyWithValue
        ? this.modified
        : modified as DateTime?,
  );
}
