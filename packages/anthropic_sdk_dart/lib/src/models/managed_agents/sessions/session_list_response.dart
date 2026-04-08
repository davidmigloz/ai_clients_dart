import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'session.dart';

/// Paginated list of sessions.
@immutable
class ListSessionsResponse {
  /// List of sessions.
  final List<Session> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [ListSessionsResponse].
  const ListSessionsResponse({required this.data, this.nextPage});

  /// Creates a [ListSessionsResponse] from JSON.
  factory ListSessionsResponse.fromJson(Map<String, dynamic> json) {
    return ListSessionsResponse(
      data: (json['data'] as List)
          .map((e) => Session.fromJson(e as Map<String, dynamic>))
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
  ListSessionsResponse copyWith({
    List<Session>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListSessionsResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListSessionsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() => 'ListSessionsResponse(data: $data, nextPage: $nextPage)';
}
