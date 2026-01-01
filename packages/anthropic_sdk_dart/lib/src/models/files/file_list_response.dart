import 'package:meta/meta.dart';

import 'file_metadata.dart';

/// Response for listing files.
@immutable
class FileListResponse {
  /// List of file metadata objects.
  final List<FileMetadata> data;

  /// Whether there are more results available.
  final bool hasMore;

  /// ID of the first file in this page of results.
  final String? firstId;

  /// ID of the last file in this page of results.
  final String? lastId;

  /// Creates a [FileListResponse].
  const FileListResponse({
    required this.data,
    this.hasMore = false,
    this.firstId,
    this.lastId,
  });

  /// Creates a [FileListResponse] from JSON.
  factory FileListResponse.fromJson(Map<String, dynamic> json) {
    return FileListResponse(
      data: (json['data'] as List)
          .map((e) => FileMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool? ?? false,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'has_more': hasMore,
    if (firstId != null) 'first_id': firstId,
    if (lastId != null) 'last_id': lastId,
  };

  /// Creates a copy with replaced values.
  FileListResponse copyWith({
    List<FileMetadata>? data,
    bool? hasMore,
    String? firstId,
    String? lastId,
  }) {
    return FileListResponse(
      data: data ?? this.data,
      hasMore: hasMore ?? this.hasMore,
      firstId: firstId ?? this.firstId,
      lastId: lastId ?? this.lastId,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileListResponse &&
          runtimeType == other.runtimeType &&
          _listsEqual(data, other.data) &&
          hasMore == other.hasMore &&
          firstId == other.firstId &&
          lastId == other.lastId;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(data), hasMore, firstId, lastId);

  @override
  String toString() =>
      'FileListResponse('
      'data: $data, '
      'hasMore: $hasMore, '
      'firstId: $firstId, '
      'lastId: $lastId)';
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
