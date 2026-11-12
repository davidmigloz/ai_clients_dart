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
  /// Supply as the `page` parameter to `client.files.list` to fetch the
  /// next page; `null` when there are no more results.
  final String? nextPage;

  /// Legacy pagination indicator when supplied by a beta response.
  final bool? hasMore;

  /// First file ID in a legacy beta response.
  final String? firstId;

  /// Last file ID in a legacy beta response.
  final String? lastId;

  /// Creates a [FileListResponse].
  const FileListResponse({
    required this.data,
    this.nextPage,
    this.hasMore,
    this.firstId,
    this.lastId,
  });

  /// Creates a [FileListResponse] from JSON.
  factory FileListResponse.fromJson(Map<String, dynamic> json) {
    return FileListResponse(
      data: (json['data'] as List)
          .map((e) => FileMetadata.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPage: json['next_page'] as String?,
      hasMore: json['has_more'] as bool?,
      firstId: json['first_id'] as String?,
      lastId: json['last_id'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'next_page': ?nextPage,
    'has_more': ?hasMore,
    'first_id': ?firstId,
    'last_id': ?lastId,
  };

  /// Creates a copy with replaced values.
  FileListResponse copyWith({
    List<FileMetadata>? data,
    Object? nextPage = unsetCopyWithValue,
    Object? hasMore = unsetCopyWithValue,
    Object? firstId = unsetCopyWithValue,
    Object? lastId = unsetCopyWithValue,
  }) {
    return FileListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
      hasMore: hasMore == unsetCopyWithValue ? this.hasMore : hasMore as bool?,
      firstId: firstId == unsetCopyWithValue
          ? this.firstId
          : firstId as String?,
      lastId: lastId == unsetCopyWithValue ? this.lastId : lastId as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FileListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage &&
          hasMore == other.hasMore &&
          firstId == other.firstId &&
          lastId == other.lastId;

  @override
  int get hashCode =>
      Object.hash(listHash(data), nextPage, hasMore, firstId, lastId);

  @override
  String toString() =>
      'FileListResponse(data: $data, nextPage: $nextPage, hasMore: $hasMore, '
      'firstId: $firstId, lastId: $lastId)';
}
