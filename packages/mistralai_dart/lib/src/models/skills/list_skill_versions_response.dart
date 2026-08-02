import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'skill_version.dart';

/// Response returned by listing the versions of a skill.
@immutable
class ListSkillVersionsResponse {
  /// The versions of the skill.
  final List<SkillVersion>? data;

  /// Creates a [ListSkillVersionsResponse].
  const ListSkillVersionsResponse({this.data});

  /// Creates a [ListSkillVersionsResponse] from JSON.
  factory ListSkillVersionsResponse.fromJson(Map<String, dynamic> json) =>
      ListSkillVersionsResponse(
        data: (json['data'] as List?)
            ?.map((e) => SkillVersion.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (data != null) 'data': data!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the specified fields replaced.
  ///
  /// Pass `null` explicitly to clear nullable fields.
  ListSkillVersionsResponse copyWith({Object? data = unsetCopyWithValue}) =>
      ListSkillVersionsResponse(
        data: data == unsetCopyWithValue
            ? this.data
            : data as List<SkillVersion>?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListSkillVersionsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data);

  @override
  int get hashCode => listHash(data);

  @override
  String toString() => 'ListSkillVersionsResponse(data: ${data?.length} items)';
}
