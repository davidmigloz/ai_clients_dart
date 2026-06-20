import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Keyset pagination metadata returned alongside a page of results.
@immutable
class PaginationResponse {
  /// The page size used for this page.
  final int pageSize;

  /// The cursor to pass to fetch the next page, or null if there are no more.
  final String? nextCursor;

  /// Creates a [PaginationResponse].
  const PaginationResponse({required this.pageSize, this.nextCursor});

  /// Creates a [PaginationResponse] from JSON.
  factory PaginationResponse.fromJson(Map<String, dynamic> json) =>
      PaginationResponse(
        pageSize: json['page_size'] as int? ?? 0,
        nextCursor: json['next_cursor'] as String?,
      );

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() => {
    'page_size': pageSize,
    if (nextCursor != null) 'next_cursor': nextCursor,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for [nextCursor] to clear it explicitly; omit to keep.
  PaginationResponse copyWith({
    int? pageSize,
    Object? nextCursor = unsetCopyWithValue,
  }) => PaginationResponse(
    pageSize: pageSize ?? this.pageSize,
    nextCursor: nextCursor == unsetCopyWithValue
        ? this.nextCursor
        : nextCursor as String?,
  );

  /// Whether there is another page available.
  bool get hasMore => nextCursor != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaginationResponse &&
          runtimeType == other.runtimeType &&
          pageSize == other.pageSize &&
          nextCursor == other.nextCursor;

  @override
  int get hashCode => Object.hash(pageSize, nextCursor);

  @override
  String toString() =>
      'PaginationResponse(pageSize: $pageSize, nextCursor: $nextCursor)';
}
