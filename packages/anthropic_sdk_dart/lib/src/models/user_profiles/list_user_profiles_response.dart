import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'user_profile.dart';

/// Response containing a paginated list of user profiles.
@immutable
class ListUserProfilesResponse {
  /// User profiles on this page.
  final List<UserProfile> data;

  /// Cursor for the next page, or `null` when there are no more results.
  final String? nextPage;
  final bool _includeNullNextPage;

  /// Creates a [ListUserProfilesResponse].
  const ListUserProfilesResponse({required this.data, this.nextPage})
    : _includeNullNextPage = false;

  const ListUserProfilesResponse._(
    this.data,
    this.nextPage,
    this._includeNullNextPage,
  );

  /// Creates a [ListUserProfilesResponse] from JSON.
  factory ListUserProfilesResponse.fromJson(Map<String, dynamic> json) {
    return ListUserProfilesResponse._(
      (json['data'] as List?)
              ?.map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      json['next_page'] as String?,
      json.containsKey('next_page'),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (nextPage != null || _includeNullNextPage) 'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  ListUserProfilesResponse copyWith({
    List<UserProfile>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListUserProfilesResponse._(
      data ?? this.data,
      nextPage == unsetCopyWithValue ? this.nextPage : nextPage as String?,
      _includeNullNextPage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListUserProfilesResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'ListUserProfilesResponse(data: $data, nextPage: $nextPage)';
}
