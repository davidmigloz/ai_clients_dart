import 'dart:typed_data';

import 'package:meta/meta.dart';

import 'file_object.dart';

/// A request to create an upload.
///
/// Uploads allow you to send large files in parts.
///
/// ## Example
///
/// ```dart
/// final upload = await client.uploads.create(
///   CreateUploadRequest(
///     filename: 'large_file.jsonl',
///     purpose: FilePurpose.fineTune,
///     bytes: totalBytes,
///     mimeType: 'text/jsonl',
///   ),
/// );
/// ```
@immutable
class CreateUploadRequest {
  /// Creates a [CreateUploadRequest].
  const CreateUploadRequest({
    required this.filename,
    required this.purpose,
    required this.bytes,
    required this.mimeType,
  });

  /// Creates a [CreateUploadRequest] from JSON.
  factory CreateUploadRequest.fromJson(Map<String, dynamic> json) {
    return CreateUploadRequest(
      filename: json['filename'] as String,
      purpose: FilePurpose.fromJson(json['purpose'] as String),
      bytes: json['bytes'] as int,
      mimeType: json['mime_type'] as String,
    );
  }

  /// The name of the file to upload.
  final String filename;

  /// The intended purpose of the file.
  final FilePurpose purpose;

  /// The total size of the file in bytes.
  final int bytes;

  /// The MIME type of the file.
  ///
  /// Must be one of the supported types for the purpose.
  final String mimeType;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'filename': filename,
    'purpose': purpose.toJson(),
    'bytes': bytes,
    'mime_type': mimeType,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateUploadRequest &&
          runtimeType == other.runtimeType &&
          filename == other.filename &&
          bytes == other.bytes;

  @override
  int get hashCode => Object.hash(filename, bytes);

  @override
  String toString() => 'CreateUploadRequest(filename: $filename, $bytes bytes)';
}

/// An upload object.
///
/// Represents an in-progress or completed upload.
@immutable
class Upload {
  /// Creates an [Upload].
  const Upload({
    required this.id,
    required this.object,
    required this.bytes,
    required this.createdAt,
    required this.filename,
    required this.purpose,
    required this.status,
    this.expiresAt,
    this.file,
  });

  /// Creates an [Upload] from JSON.
  factory Upload.fromJson(Map<String, dynamic> json) {
    return Upload(
      id: json['id'] as String,
      object: json['object'] as String,
      bytes: json['bytes'] as int,
      createdAt: json['created_at'] as int,
      filename: json['filename'] as String,
      purpose: FilePurpose.fromJson(json['purpose'] as String),
      status: UploadStatus.fromJson(json['status'] as String),
      expiresAt: json['expires_at'] as int?,
      file: json['file'] != null
          ? FileObject.fromJson(json['file'] as Map<String, dynamic>)
          : null,
    );
  }

  /// The upload identifier.
  final String id;

  /// The object type (always "upload").
  final String object;

  /// The total size in bytes.
  final int bytes;

  /// The Unix timestamp when the upload was created.
  final int createdAt;

  /// The filename.
  final String filename;

  /// The intended purpose.
  final FilePurpose purpose;

  /// The upload status.
  final UploadStatus status;

  /// The Unix timestamp when the upload expires.
  final int? expiresAt;

  /// The resulting file object (when completed).
  final FileObject? file;

  /// Whether the upload is still pending.
  bool get isPending => status == UploadStatus.pending;

  /// Whether the upload is completed.
  bool get isCompleted => status == UploadStatus.completed;

  /// Whether the upload is cancelled.
  bool get isCancelled => status == UploadStatus.cancelled;

  /// Whether the upload has expired.
  bool get isExpired => status == UploadStatus.expired;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'bytes': bytes,
    'created_at': createdAt,
    'filename': filename,
    'purpose': purpose.toJson(),
    'status': status.toJson(),
    if (expiresAt != null) 'expires_at': expiresAt,
    if (file != null) 'file': file!.toJson(),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Upload && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Upload(id: $id, status: $status)';
}

/// A request to add a part to an upload.
@immutable
class AddUploadPartRequest {
  /// Creates an [AddUploadPartRequest].
  const AddUploadPartRequest({required this.data});

  /// The chunk of bytes for this part.
  ///
  /// Each part should be at least 5MB, except the last part.
  final Uint8List data;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddUploadPartRequest &&
          runtimeType == other.runtimeType &&
          data.length == other.data.length;

  @override
  int get hashCode => data.length.hashCode;

  @override
  String toString() => 'AddUploadPartRequest(${data.length} bytes)';
}

/// An upload part.
@immutable
class UploadPart {
  /// Creates an [UploadPart].
  const UploadPart({
    required this.id,
    required this.object,
    required this.createdAt,
    required this.uploadId,
  });

  /// Creates an [UploadPart] from JSON.
  factory UploadPart.fromJson(Map<String, dynamic> json) {
    return UploadPart(
      id: json['id'] as String,
      object: json['object'] as String,
      createdAt: json['created_at'] as int,
      uploadId: json['upload_id'] as String,
    );
  }

  /// The part identifier.
  final String id;

  /// The object type (always "upload.part").
  final String object;

  /// The Unix timestamp when the part was created.
  final int createdAt;

  /// The ID of the upload this part belongs to.
  final String uploadId;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'object': object,
    'created_at': createdAt,
    'upload_id': uploadId,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UploadPart && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'UploadPart(id: $id)';
}

/// A request to complete an upload.
@immutable
class CompleteUploadRequest {
  /// Creates a [CompleteUploadRequest].
  const CompleteUploadRequest({required this.partIds, this.md5});

  /// Creates a [CompleteUploadRequest] from JSON.
  factory CompleteUploadRequest.fromJson(Map<String, dynamic> json) {
    return CompleteUploadRequest(
      partIds: (json['part_ids'] as List<dynamic>).cast<String>(),
      md5: json['md5'] as String?,
    );
  }

  /// The ordered list of part IDs.
  final List<String> partIds;

  /// Optional MD5 checksum to verify the file.
  final String? md5;

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'part_ids': partIds,
    if (md5 != null) 'md5': md5,
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CompleteUploadRequest &&
          runtimeType == other.runtimeType &&
          partIds.length == other.partIds.length;

  @override
  int get hashCode => partIds.length.hashCode;

  @override
  String toString() => 'CompleteUploadRequest(${partIds.length} parts)';
}

/// Upload status.
enum UploadStatus {
  /// Upload is pending parts.
  pending._('pending'),

  /// Upload is completed.
  completed._('completed'),

  /// Upload was cancelled.
  cancelled._('cancelled'),

  /// Upload has expired.
  expired._('expired');

  const UploadStatus._(this._value);

  /// Creates from JSON string.
  factory UploadStatus.fromJson(String json) {
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
