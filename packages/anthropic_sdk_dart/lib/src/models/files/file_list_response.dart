import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

import 'file_metadata.dart';

/// Response for listing files.
@immutable
class FileListResponse {
  /// List of file metadata objects.
  final List<FileMetadata> data;

  /// Opaque cursor for the next page.
  ///
  /// Supply as the `page` parameter to [FilesResource.list] to fetch the
  /// next page; `null` when there are no more results.
  final String? nextPage;

  /// Creates a [FileListResponse].
  const FileListResponse({required this.data, this.nextPage});

  /// Creates a [FileListResponse] from JSON.
  factory FileListResponse.fromJson(Map<String, dynamic> json) {
    return FileListResponse(
      data: (json['data'] as List)
          .map((e) => FileMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (nextPage != null) 'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  FileListResponse copyWith({
    List<FileMetadata>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return FileListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() => 'FileListResponse(data: $data, nextPage: $nextPage)';
}
