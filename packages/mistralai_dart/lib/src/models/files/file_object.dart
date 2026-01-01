import 'package:meta/meta.dart';

import 'file_purpose.dart';

/// Represents a file uploaded to the Mistral API.
@immutable
class FileObject {
  /// Unique identifier for the file.
  final String id;

  /// The object type (always "file").
  final String object;

  /// Size of the file in bytes.
  final int bytes;

  /// Unix timestamp of when the file was created.
  final int createdAt;

  /// The name of the file.
  final String filename;

  /// The purpose of the file.
  final FilePurpose purpose;

  /// The sample type (for fine-tuning files).
  final String? sampleType;

  /// The number of lines in the file (for JSONL files).
  final int? numLines;

  /// Source information (e.g., "upload", "repository").
  final String? source;

  /// Whether the file has been deleted.
  final bool? deleted;

  /// Creates a [FileObject].
  const FileObject({
    required this.id,
    required this.object,
    required this.bytes,
    required this.createdAt,
    required this.filename,
    required this.purpose,
    this.sampleType,
    this.numLines,
    this.source,
    this.deleted,
  });

  /// Creates a [FileObject] from JSON.
  factory FileObject.fromJson(Map<String, dynamic> json) => FileObject(
    id: json['id'] as String? ?? '',
    object: json['object'] as String? ?? 'file',
    bytes: json['bytes'] as int? ?? 0,
    createdAt: json['created_at'] as int? ?? 0,
    filename: json['filename'] as String? ?? '',
    purpose: filePurposeFromString(json['purpose'] as String?),
    sampleType: json['sample_type'] as String?,
    numLines: json['num_lines'] as int?,
    source: json['source'] as String?,
    deleted: json['deleted'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'bytes': bytes,
    'created_at': createdAt,
    'filename': filename,
    'purpose': filePurposeToString(purpose),
    if (sampleType != null) 'sample_type': sampleType,
    if (numLines != null) 'num_lines': numLines,
    if (source != null) 'source': source,
    if (deleted != null) 'deleted': deleted,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileObject &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          object == other.object &&
          bytes == other.bytes &&
          createdAt == other.createdAt &&
          filename == other.filename &&
          purpose == other.purpose;

  @override
  int get hashCode =>
      Object.hash(id, object, bytes, createdAt, filename, purpose);

  @override
  String toString() =>
      'FileObject(id: $id, filename: $filename, '
      'purpose: $purpose, bytes: $bytes)';
}
