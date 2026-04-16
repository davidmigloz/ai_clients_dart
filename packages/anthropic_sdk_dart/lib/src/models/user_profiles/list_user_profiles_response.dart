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

  /// Creates a [ListUserProfilesResponse].
  const ListUserProfilesResponse({required this.data, this.nextPage});

  /// Creates a [ListUserProfilesResponse] from JSON.
  factory ListUserProfilesResponse.fromJson(Map<String, dynamic> json) {
    return ListUserProfilesResponse(
      data:
          (json['data'] as List?)
              ?.map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
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
  ListUserProfilesResponse copyWith({
    List<UserProfile>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListUserProfilesResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
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
