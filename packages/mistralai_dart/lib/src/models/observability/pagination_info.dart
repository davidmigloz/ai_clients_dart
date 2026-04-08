import 'package:meta/meta.dart';

/// Pagination metadata.
@immutable
class PaginationInfo {
  /// Total number of items.
  final int totalItems;

  /// Total number of pages.
  final int totalPages;

  /// Current page number.
  final int currentPage;

  /// Number of items per page.
  final int pageSize;

  /// Whether there are more pages.
  final bool hasMore;

  /// Creates a [PaginationInfo].
  const PaginationInfo({
    required this.totalItems,
    required this.totalPages,
    required this.currentPage,
    required this.pageSize,
    required this.hasMore,
  });

  /// Creates a [PaginationInfo] from JSON.
  factory PaginationInfo.fromJson(Map<String, dynamic> json) => PaginationInfo(
    totalItems: json['total_items'] as int? ?? 0,
    totalPages: json['total_pages'] as int? ?? 0,
    currentPage: json['current_page'] as int? ?? 0,
    pageSize: json['page_size'] as int? ?? 0,
    hasMore: json['has_more'] as bool? ?? false,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'total_items': totalItems,
    'total_pages': totalPages,
    'current_page': currentPage,
    'page_size': pageSize,
    'has_more': hasMore,
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PaginationInfo) return false;
    if (runtimeType != other.runtimeType) return false;
    return totalItems == other.totalItems &&
        totalPages == other.totalPages &&
        currentPage == other.currentPage &&
        pageSize == other.pageSize &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode =>
      Object.hash(totalItems, totalPages, currentPage, pageSize, hasMore);

  @override
  String toString() =>
      'PaginationInfo(totalItems: $totalItems, totalPages: $totalPages, '
      'currentPage: $currentPage, pageSize: $pageSize, hasMore: $hasMore)';
}
