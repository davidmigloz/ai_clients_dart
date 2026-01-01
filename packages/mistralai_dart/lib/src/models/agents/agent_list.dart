import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';
import 'agent.dart';

/// A paginated list of agents.
@immutable
class AgentList {
  /// Object type.
  final String object;

  /// The list of agents.
  final List<Agent> data;

  /// Total number of agents available.
  final int? total;

  /// Whether there are more results.
  final bool? hasMore;

  /// Creates an [AgentList].
  const AgentList({
    this.object = 'list',
    required this.data,
    this.total,
    this.hasMore,
  });

  /// Creates an [AgentList] from JSON.
  factory AgentList.fromJson(Map<String, dynamic> json) => AgentList(
    object: json['object'] as String? ?? 'list',
    data:
        (json['data'] as List?)
            ?.map((e) => Agent.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
    total: json['total'] as int?,
    hasMore: json['has_more'] as bool?,
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'data': data.map((e) => e.toJson()).toList(),
    if (total != null) 'total': total,
    if (hasMore != null) 'has_more': hasMore,
  };

  /// Returns true if the list is empty.
  bool get isEmpty => data.isEmpty;

  /// Returns true if the list is not empty.
  bool get isNotEmpty => data.isNotEmpty;

  /// Number of agents in this page.
  int get length => data.length;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AgentList &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          listEquals(data, other.data) &&
          total == other.total &&
          hasMore == other.hasMore;

  @override
  int get hashCode => Object.hash(object, Object.hashAll(data), total, hasMore);

  @override
  String toString() => 'AgentList(count: ${data.length}, total: $total)';
}
