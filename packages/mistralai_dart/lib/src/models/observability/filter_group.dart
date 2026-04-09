import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'filter_node.dart';

/// A group of filters combined with AND/OR logic.
///
/// Filters can be nested: each element in [and] or [or] can itself be
/// a [FilterGroup] or a [FilterCondition].
@immutable
class FilterGroup extends FilterNode {
  /// Conditions combined with AND logic.
  final List<FilterNode>? and;

  /// Conditions combined with OR logic.
  final List<FilterNode>? or;

  /// Creates a [FilterGroup].
  FilterGroup({List<FilterNode>? and, List<FilterNode>? or})
    : and = and != null ? List.unmodifiable(and) : null,
      or = or != null ? List.unmodifiable(or) : null;

  /// Creates a [FilterGroup] from JSON.
  factory FilterGroup.fromJson(Map<String, dynamic> json) => FilterGroup(
    and: _parseFilterList(json['AND'] as List?),
    or: _parseFilterList(json['OR'] as List?),
  );

  static List<FilterNode>? _parseFilterList(List<dynamic>? list) {
    if (list == null) return null;
    return list
        .map((e) => FilterNode.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Map<String, dynamic> toJson() => {
    if (and != null) 'AND': and!.map((e) => e.toJson()).toList(),
    if (or != null) 'OR': or!.map((e) => e.toJson()).toList(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilterGroup) return false;
    if (runtimeType != other.runtimeType) return false;
    return listsEqual(and, other.and) && listsEqual(or, other.or);
  }

  @override
  int get hashCode => Object.hash(listHash(and), listHash(or));

  @override
  String toString() =>
      'FilterGroup(and: ${and?.length ?? 0} conditions, '
      'or: ${or?.length ?? 0} conditions)';
}
