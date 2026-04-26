import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'memory_version.dart';

/// Paginated list of [MemoryVersion]s.
@immutable
class MemoryVersionListResponse {
  /// The memory versions in this page.
  final List<MemoryVersion> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [MemoryVersionListResponse].
  const MemoryVersionListResponse({required this.data, this.nextPage});

  /// Creates a [MemoryVersionListResponse] from JSON.
  factory MemoryVersionListResponse.fromJson(Map<String, dynamic> json) {
    return MemoryVersionListResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => MemoryVersion.fromJson(e as Map<String, dynamic>))
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
  MemoryVersionListResponse copyWith({
    List<MemoryVersion>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return MemoryVersionListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryVersionListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'MemoryVersionListResponse(data: ${data.length} items, nextPage: $nextPage)';
}
