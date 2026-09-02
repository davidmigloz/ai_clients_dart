import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

import 'skill.dart';
import 'skill_version.dart';

/// Response for listing skills.
@immutable
class SkillListResponse {
  /// List of skills.
  final List<Skill> data;

  /// Token for fetching the next page of results.
  ///
  /// If `null`, there are no more results available. Pass this value to the
  /// `page` parameter in the next request to get the next page.
  final String? nextPage;

  /// Creates a [SkillListResponse].
  const SkillListResponse({required this.data, this.nextPage});

  /// Creates a [SkillListResponse] from JSON.
  factory SkillListResponse.fromJson(Map<String, dynamic> json) {
    return SkillListResponse(
      data: (json['data'] as List)
          .map((e) => Skill.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  SkillListResponse copyWith({
    List<Skill>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return SkillListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() => 'SkillListResponse(data: $data, nextPage: $nextPage)';
}

/// Response for listing skill versions.
@immutable
class SkillVersionListResponse {
  /// List of skill versions.
  final List<SkillVersion> data;

  /// Token for fetching the next page of results.
  final String? nextPage;

  /// Creates a [SkillVersionListResponse].
  const SkillVersionListResponse({required this.data, this.nextPage});

  /// Creates a [SkillVersionListResponse] from JSON.
  factory SkillVersionListResponse.fromJson(Map<String, dynamic> json) {
    return SkillVersionListResponse(
      data: (json['data'] as List)
          .map((e) => SkillVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  SkillVersionListResponse copyWith({
    List<SkillVersion>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return SkillVersionListResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillVersionListResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'SkillVersionListResponse(data: $data, nextPage: $nextPage)';
}
