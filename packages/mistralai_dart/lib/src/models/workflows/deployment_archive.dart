import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// Size of the gzipped tar archive to upload.
@immutable
class CreateDeploymentArchiveRequest {
  /// Archive size in bytes. The limit is 256 MiB.
  final int size;

  /// Creates a [CreateDeploymentArchiveRequest].
  const CreateDeploymentArchiveRequest({required this.size});

  /// Creates a [CreateDeploymentArchiveRequest] from JSON.
  factory CreateDeploymentArchiveRequest.fromJson(Map<String, dynamic> json) {
    final size = json['size'] as int?;
    if (size == null) {
      throw const FormatException(
        'CreateDeploymentArchiveRequest: missing required "size"',
      );
    }
    if (size <= 0 || size > 268435456) {
      throw const FormatException(
        'Archive size must be between 1 and 256 MiB in bytes',
      );
    }
    return CreateDeploymentArchiveRequest(size: size);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() {
    if (size <= 0 || size > 268435456) {
      throw ArgumentError.value(size, 'size', 'Expected 1 to 268435456 bytes');
    }
    return {'size': size};
  }

  /// Creates a copy with the given fields replaced.
  CreateDeploymentArchiveRequest copyWith({int? size}) =>
      CreateDeploymentArchiveRequest(size: size ?? this.size);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateDeploymentArchiveRequest && size == other.size;

  @override
  int get hashCode => size.hashCode;

  @override
  String toString() => 'CreateDeploymentArchiveRequest(size: $size)';
}

/// Signed transfer details for uploading a deployment archive.
@immutable
class DeploymentArchiveUploadResponse {
  /// Identifier to use in the worker spec after the upload.
  final String archiveId;

  /// Signed URL to PUT the gzipped tar archive to. Treat it as a credential.
  final String uploadUrl;

  /// Headers required by the signed upload URL.
  final Map<String, String> uploadHeaders;

  /// Creates a [DeploymentArchiveUploadResponse].
  const DeploymentArchiveUploadResponse({
    required this.archiveId,
    required this.uploadUrl,
    required this.uploadHeaders,
  });

  /// Creates a [DeploymentArchiveUploadResponse] from JSON.
  factory DeploymentArchiveUploadResponse.fromJson(Map<String, dynamic> json) {
    final archiveId = json['archive_id'] as String?;
    final uploadUrl = json['upload_url'] as String?;
    final uploadHeaders = (json['upload_headers'] as Map<String, dynamic>?)
        ?.cast<String, String>();
    if (archiveId == null) {
      throw const FormatException(
        'DeploymentArchiveUploadResponse: missing required "archive_id"',
      );
    }
    if (uploadUrl == null) {
      throw const FormatException(
        'DeploymentArchiveUploadResponse: missing required "upload_url"',
      );
    }
    if (uploadHeaders == null) {
      throw const FormatException(
        'DeploymentArchiveUploadResponse: missing required "upload_headers"',
      );
    }
    return DeploymentArchiveUploadResponse(
      archiveId: archiveId,
      uploadUrl: uploadUrl,
      uploadHeaders: uploadHeaders,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'archive_id': archiveId,
    'upload_url': uploadUrl,
    'upload_headers': uploadHeaders,
  };

  /// Creates a copy with the given fields replaced.
  DeploymentArchiveUploadResponse copyWith({
    String? archiveId,
    String? uploadUrl,
    Map<String, String>? uploadHeaders,
  }) => DeploymentArchiveUploadResponse(
    archiveId: archiveId ?? this.archiveId,
    uploadUrl: uploadUrl ?? this.uploadUrl,
    uploadHeaders: uploadHeaders ?? this.uploadHeaders,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentArchiveUploadResponse &&
          archiveId == other.archiveId &&
          uploadUrl == other.uploadUrl &&
          mapsEqual(uploadHeaders, other.uploadHeaders);

  @override
  int get hashCode => Object.hash(archiveId, uploadUrl, mapHash(uploadHeaders));

  @override
  String toString() =>
      'DeploymentArchiveUploadResponse(archiveId: $archiveId, uploadUrl: [redacted], uploadHeaders: [redacted])';
}

/// Signed transfer details for downloading a deployment archive.
@immutable
class DeploymentArchiveResponse {
  /// Identifier of the deployment archive.
  final String archiveId;

  /// Signed download URL, or null if the archive was deleted.
  final String? downloadUrl;

  /// Creates a [DeploymentArchiveResponse].
  const DeploymentArchiveResponse({required this.archiveId, this.downloadUrl});

  /// Creates a [DeploymentArchiveResponse] from JSON.
  factory DeploymentArchiveResponse.fromJson(Map<String, dynamic> json) {
    final archiveId = json['archive_id'] as String?;
    final downloadUrl = json['download_url'] as String?;
    if (archiveId == null) {
      throw const FormatException(
        'DeploymentArchiveResponse: missing required "archive_id"',
      );
    }
    return DeploymentArchiveResponse(
      archiveId: archiveId,
      downloadUrl: downloadUrl,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'archive_id': archiveId,
    if (downloadUrl != null) 'download_url': downloadUrl,
  };

  /// Creates a copy with the given fields replaced.
  DeploymentArchiveResponse copyWith({
    String? archiveId,
    Object? downloadUrl = unsetCopyWithValue,
  }) => DeploymentArchiveResponse(
    archiveId: archiveId ?? this.archiveId,
    downloadUrl: downloadUrl == unsetCopyWithValue
        ? this.downloadUrl
        : downloadUrl as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeploymentArchiveResponse &&
          archiveId == other.archiveId &&
          downloadUrl == other.downloadUrl;

  @override
  int get hashCode => Object.hash(archiveId, downloadUrl);

  @override
  String toString() =>
      'DeploymentArchiveResponse(archiveId: $archiveId, downloadUrl: ${downloadUrl == null ? "null" : "[redacted]"})';
}
