import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'memory_store.dart';

/// Paginated list of [MemoryStore]s.
@immutable
class MemoryStoreListResponse {
  /// The memory stores in this page, ordered by `created_at`.
  final List<MemoryStore> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [MemoryStoreListResponse].
  const MemoryStoreListResponse({required this.data, this.nextPage});

  /// Creates a [MemoryStoreListResponse] from JSON.
  factory MemoryStoreListResponse.fromJson(Map<String, dynamic> json) {
    return MemoryStoreListResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => MemoryStore.fromJson(e as Map<String, dynamic>))
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
  MemoryStoreListResponse copyWith({
    List<MemoryStore>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return MemoryStoreListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryStoreListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'MemoryStoreListResponse(data: ${data.length} items, nextPage: $nextPage)';
}
