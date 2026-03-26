import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'voice_response.dart';

/// Paginated list of voices.
@immutable
class VoiceListResponse {
  /// The list of voices.
  final List<VoiceResponse> items;

  /// Total number of voices.
  final int total;

  /// Current page number.
  final int page;

  /// Number of items per page.
  final int pageSize;

  /// Total number of pages.
  final int totalPages;

  /// Creates a [VoiceListResponse].
  const VoiceListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
  });

  /// Creates a [VoiceListResponse] from JSON.
  factory VoiceListResponse.fromJson(Map<String, dynamic> json) =>
      VoiceListResponse(
        items:
            (json['items'] as List?)
                ?.map((e) => VoiceResponse.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        total: json['total'] as int? ?? 0,
        page: json['page'] as int? ?? 0,
        pageSize: json['page_size'] as int? ?? 0,
        totalPages: json['total_pages'] as int? ?? 0,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'page': page,
    'page_size': pageSize,
    'total_pages': totalPages,
  };

  /// Creates a copy with the given fields replaced.
  VoiceListResponse copyWith({
    List<VoiceResponse>? items,
    int? total,
    int? page,
    int? pageSize,
    int? totalPages,
  }) => VoiceListResponse(
    items: items ?? this.items,
    total: total ?? this.total,
    page: page ?? this.page,
    pageSize: pageSize ?? this.pageSize,
    totalPages: totalPages ?? this.totalPages,
  );

  /// Whether the list is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the list is not empty.
  bool get isNotEmpty => items.isNotEmpty;

  /// Number of items in this page.
  int get length => items.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VoiceListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(items, other.items) &&
          total == other.total &&
          page == other.page &&
          pageSize == other.pageSize &&
          totalPages == other.totalPages;

  @override
  int get hashCode =>
      Object.hash(listHash(items), total, page, pageSize, totalPages);

  @override
  String toString() =>
      'VoiceListResponse(items: ${items.length}, '
      'total: $total, '
      'page: $page, '
      'pageSize: $pageSize, '
      'totalPages: $totalPages)';
}
