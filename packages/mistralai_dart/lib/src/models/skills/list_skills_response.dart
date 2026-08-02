import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'skill.dart';

/// Response returned by listing skills.
@immutable
class ListSkillsResponse {
  /// The skills on this page.
  final List<Skill>? data;

  /// Token to fetch the next page, if any.
  final String? nextPageToken;

  /// Creates a [ListSkillsResponse].
  const ListSkillsResponse({this.data, this.nextPageToken});

  /// Creates a [ListSkillsResponse] from JSON.
  factory ListSkillsResponse.fromJson(Map<String, dynamic> json) =>
      ListSkillsResponse(
        data: (json['data'] as List?)
            ?.map((e) => Skill.fromJson(e as Map<String, dynamic>))
            .toList(),
        nextPageToken: json['nextPageToken'] as String?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (data != null) 'data': data!.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'nextPageToken': nextPageToken,
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  ListSkillsResponse copyWith({
    Object? data = unsetCopyWithValue,
    Object? nextPageToken = unsetCopyWithValue,
  }) => ListSkillsResponse(
    data: data == unsetCopyWithValue ? this.data : data as List<Skill>?,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListSkillsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPageToken == other.nextPageToken;

  @override
  int get hashCode => Object.hash(listHash(data), nextPageToken);

  @override
  String toString() =>
      'ListSkillsResponse(data: ${data?.length} items, '
      'nextPageToken: $nextPageToken)';
}
