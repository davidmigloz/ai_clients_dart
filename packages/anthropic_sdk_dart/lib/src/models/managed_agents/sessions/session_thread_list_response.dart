import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'session_thread.dart';

/// Paginated list of session threads.
@immutable
class ListSessionThreadsResponse {
  /// List of session threads.
  final List<SessionThread> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [ListSessionThreadsResponse].
  const ListSessionThreadsResponse({required this.data, this.nextPage});

  /// Creates a [ListSessionThreadsResponse] from JSON.
  factory ListSessionThreadsResponse.fromJson(Map<String, dynamic> json) {
    return ListSessionThreadsResponse(
      data: (json['data'] as List)
          .map((e) => SessionThread.fromJson(e as Map<String, dynamic>))
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
  ListSessionThreadsResponse copyWith({
    List<SessionThread>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListSessionThreadsResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListSessionThreadsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'ListSessionThreadsResponse(data: $data, nextPage: $nextPage)';
}
