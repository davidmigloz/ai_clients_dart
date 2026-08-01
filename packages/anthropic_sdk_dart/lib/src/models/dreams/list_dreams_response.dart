import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'dream.dart';

/// Response containing a paginated list of dreams.
@immutable
class ListDreamsResponse {
  /// List of dreams.
  final List<Dream> data;

  /// Pagination token for the next page, or null if no more results.
  final String? nextPage;

  /// Creates a [ListDreamsResponse].
  const ListDreamsResponse({required this.data, this.nextPage});

  /// Creates a [ListDreamsResponse] from JSON.
  factory ListDreamsResponse.fromJson(Map<String, dynamic> json) {
    final rawData = json['data'] as List? ?? [];
    final data = rawData.map((e) {
      if (e is! Map<String, dynamic>) {
        throw FormatException(
          'ListDreamsResponse.data: expected Map, got ${e.runtimeType}',
        );
      }
      return Dream.fromJson(e);
    }).toList();

    return ListDreamsResponse(
      data: data,
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  ListDreamsResponse copyWith({
    List<Dream>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListDreamsResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListDreamsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'ListDreamsResponse(data: ${data.length} items, nextPage: $nextPage)';
}
