import 'package:meta/meta.dart';

import '../../common/copy_with_sentinel.dart';
import '../../common/equality_helpers.dart';
import 'agent.dart';

/// Paginated list of agents.
@immutable
class ListAgentsResponse {
  /// List of agents.
  final List<Agent> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [ListAgentsResponse].
  const ListAgentsResponse({required this.data, this.nextPage});

  /// Creates a [ListAgentsResponse] from JSON.
  factory ListAgentsResponse.fromJson(Map<String, dynamic> json) {
    return ListAgentsResponse(
      data: (json['data'] as List)
          .map((e) => Agent.fromJson(e as Map<String, dynamic>))
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
  ListAgentsResponse copyWith({
    List<Agent>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListAgentsResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListAgentsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() => 'ListAgentsResponse(data: $data, nextPage: $nextPage)';
}

/// Paginated list of agent versions.
@immutable
class ListAgentVersionsResponse {
  /// Agent versions.
  final List<Agent> data;

  /// Opaque cursor for the next page. Null when no more results.
  final String? nextPage;

  /// Creates a [ListAgentVersionsResponse].
  const ListAgentVersionsResponse({required this.data, this.nextPage});

  /// Creates a [ListAgentVersionsResponse] from JSON.
  factory ListAgentVersionsResponse.fromJson(Map<String, dynamic> json) {
    return ListAgentVersionsResponse(
      data: (json['data'] as List)
          .map((e) => Agent.fromJson(e as Map<String, dynamic>))
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
  ListAgentVersionsResponse copyWith({
    List<Agent>? data,
    Object? nextPage = unsetCopyWithValue,
  }) {
    return ListAgentVersionsResponse(
      data: data ?? this.data,
      nextPage: nextPage == unsetCopyWithValue
          ? this.nextPage
          : nextPage as String?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListAgentVersionsResponse &&
          runtimeType == other.runtimeType &&
          listsEqual(data, other.data) &&
          nextPage == other.nextPage;

  @override
  int get hashCode => Object.hash(listHash(data), nextPage);

  @override
  String toString() =>
      'ListAgentVersionsResponse(data: $data, nextPage: $nextPage)';
}
