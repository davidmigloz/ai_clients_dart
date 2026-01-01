import 'package:meta/meta.dart';

import 'skill.dart';
import 'skill_version.dart';

/// Response for listing skills.
@immutable
class SkillListResponse {
  /// List of skills.
  final List<Skill> data;

  /// Whether there are more results available.
  ///
  /// If `true`, there are additional results that can be fetched using the
  /// `nextPage` token.
  final bool hasMore;

  /// Token for fetching the next page of results.
  ///
  /// If `null`, there are no more results available. Pass this value to the
  /// `page` parameter in the next request to get the next page.
  final String? nextPage;

  /// Creates a [SkillListResponse].
  const SkillListResponse({
    required this.data,
    required this.hasMore,
    this.nextPage,
  });

  /// Creates a [SkillListResponse] from JSON.
  factory SkillListResponse.fromJson(Map<String, dynamic> json) {
    return SkillListResponse(
      data: (json['data'] as List)
          .map((e) => Skill.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'has_more': hasMore,
    'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  SkillListResponse copyWith({
    List<Skill>? data,
    bool? hasMore,
    String? nextPage,
  }) {
    return SkillListResponse(
      data: data ?? this.data,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillListResponse &&
          runtimeType == other.runtimeType &&
          _listsEqual(data, other.data) &&
          hasMore == other.hasMore &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(Object.hashAll(data), hasMore, nextPage);

  @override
  String toString() =>
      'SkillListResponse('
      'data: $data, '
      'hasMore: $hasMore, '
      'nextPage: $nextPage)';
}

/// Response for listing skill versions.
@immutable
class SkillVersionListResponse {
  /// List of skill versions.
  final List<SkillVersion> data;

  /// Whether there are more results available.
  final bool hasMore;

  /// Token for fetching the next page of results.
  final String? nextPage;

  /// Creates a [SkillVersionListResponse].
  const SkillVersionListResponse({
    required this.data,
    required this.hasMore,
    this.nextPage,
  });

  /// Creates a [SkillVersionListResponse] from JSON.
  factory SkillVersionListResponse.fromJson(Map<String, dynamic> json) {
    return SkillVersionListResponse(
      data: (json['data'] as List)
          .map((e) => SkillVersion.fromJson(e as Map<String, dynamic>))
          .toList(),
      hasMore: json['has_more'] as bool,
      nextPage: json['next_page'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    'has_more': hasMore,
    'next_page': nextPage,
  };

  /// Creates a copy with replaced values.
  SkillVersionListResponse copyWith({
    List<SkillVersion>? data,
    bool? hasMore,
    String? nextPage,
  }) {
    return SkillVersionListResponse(
      data: data ?? this.data,
      hasMore: hasMore ?? this.hasMore,
      nextPage: nextPage ?? this.nextPage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkillVersionListResponse &&
          runtimeType == other.runtimeType &&
          _listsEqual(data, other.data) &&
          hasMore == other.hasMore &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(Object.hashAll(data), hasMore, nextPage);

  @override
  String toString() =>
      'SkillVersionListResponse('
      'data: $data, '
      'hasMore: $hasMore, '
      'nextPage: $nextPage)';
}

bool _listsEqual<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
