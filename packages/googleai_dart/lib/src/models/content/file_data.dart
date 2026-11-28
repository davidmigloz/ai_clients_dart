import '../copy_with_sentinel.dart';

/// Reference to an uploaded file (via /v1beta/files).
class FileData {
  /// File identifier (e.g., files/abc123).
  final String fileUri;

  /// MIME type (optional hint).
  final String? mimeType;

  /// Display name on API surfaces that accept media labels.
  final String? displayName;

  /// Creates a [FileData].
  const FileData({required this.fileUri, this.mimeType, this.displayName});

  /// Creates a [FileData] from JSON.
  factory FileData.fromJson(Map<String, dynamic> json) => FileData(
    fileUri: json['fileUri'] as String,
    mimeType: json['mimeType'] as String?,
    displayName: json['displayName'] as String?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'fileUri': fileUri,
    if (mimeType != null) 'mimeType': mimeType,
    if (displayName != null) 'displayName': displayName,
  };

  /// Creates a copy with replaced values.
  FileData copyWith({
    Object? fileUri = unsetCopyWithValue,
    Object? mimeType = unsetCopyWithValue,
    Object? displayName = unsetCopyWithValue,
  }) {
    return FileData(
      fileUri: fileUri == unsetCopyWithValue
          ? this.fileUri
          : fileUri! as String,
      mimeType: mimeType == unsetCopyWithValue
          ? this.mimeType
          : mimeType as String?,
      displayName: displayName == unsetCopyWithValue
          ? this.displayName
          : displayName as String?,
    );
  }
}
