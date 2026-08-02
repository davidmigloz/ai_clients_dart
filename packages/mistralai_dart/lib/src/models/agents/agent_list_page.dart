import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'agent.dart';

/// A cursor-paginated page of agent entities.
///
/// Returned by `GET /v1/agents/pages`, which — unlike the deprecated
/// `GET /v1/agents` — paginates by opaque cursor and honors per-agent
/// sharing, returning only agents the caller is authorized to see.
@immutable
class AgentListPage {
  /// The agents in this page.
  final List<Agent> data;

  /// The cursor to pass as `pageToken` to fetch the next page, if any.
  final String? nextPageToken;

  /// Object type.
  final String object;

  /// Creates an [AgentListPage].
  AgentListPage({
    required List<Agent> data,
    this.nextPageToken,
    this.object = 'list',
  }) : data = List.unmodifiable(data);

  /// Creates an [AgentListPage] from JSON.
  factory AgentListPage.fromJson(Map<String, dynamic> json) => AgentListPage(
    data:
        (json['data'] as List?)
            ?.map((e) => Agent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    nextPageToken: json['next_page_token'] as String?,
    object: json['object'] as String? ?? 'list',
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((e) => e.toJson()).toList(),
    if (nextPageToken != null) 'next_page_token': nextPageToken,
    'object': object,
  };

  /// Whether this page is empty.
  bool get isEmpty => data.isEmpty;

  /// Whether this page has any agents.
  bool get isNotEmpty => data.isNotEmpty;

  /// The number of agents in this page.
  int get length => data.length;

  /// Creates a copy with replaced values.
  AgentListPage copyWith({
    List<Agent>? data,
    Object? nextPageToken = unsetCopyWithValue,
    String? object,
  }) {
    return AgentListPage(
      data: data ?? this.data,
      nextPageToken: nextPageToken == unsetCopyWithValue
          ? this.nextPageToken
          : nextPageToken as String?,
      object: object ?? this.object,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! AgentListPage) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(data, other.data) &&
        nextPageToken == other.nextPageToken &&
        object == other.object;
  }

  @override
  int get hashCode => Object.hash(listHash(data), nextPageToken, object);

  @override
  String toString() =>
      'AgentListPage('
      'data: ${data.length} items, '
      'nextPageToken: $nextPageToken, '
      'object: $object'
      ')';
}
