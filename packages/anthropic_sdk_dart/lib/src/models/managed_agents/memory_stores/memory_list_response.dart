import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'memory.dart';

/// Paginated list of [MemoryListItem]s — memories and/or path prefixes
/// summarising nested entries beyond the requested depth.
@immutable
class MemoryListResponse {
  /// The memories or prefixes in this page.
  final List<MemoryListItem> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [MemoryListResponse].
  const MemoryListResponse({required this.data, this.nextPage});

  /// Creates a [MemoryListResponse] from JSON.
  factory MemoryListResponse.fromJson(Map<String, dynamic> json) {
    return MemoryListResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => MemoryListItem.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (nextPage != null) 'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  MemoryListResponse copyWith({
    List<MemoryListItem>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return MemoryListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'MemoryListResponse(data: ${data.length} items, nextPage: $nextPage)';
}
