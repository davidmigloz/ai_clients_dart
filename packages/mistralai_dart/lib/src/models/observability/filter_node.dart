import 'filter_condition.dart';
import 'filter_group.dart';

/// Base type for filter nodes in observability queries.
///
/// A filter node is either a [FilterCondition] (leaf node matching a
/// field/operator/value) or a [FilterGroup] (AND/OR combinator of child
/// filter nodes).
///
/// Use [FilterNode.fromJson] to deserialize, or construct subtypes directly:
/// ```dart
/// final node = FilterCondition(field: 'model', op: 'eq', value: 'mistral');
/// final group = FilterGroup(and: [node]);
/// ```
// Note: abstract class (not sealed) because Dart sealed classes require all
// subtypes in the same library file. This achieves the same compile-time
// type safety for fields typed as FilterNode.
abstract class FilterNode {
  /// Creates a [FilterNode].
  const FilterNode();

  /// Creates a [FilterNode] from JSON by discriminating on the presence
  /// of `field` and `op` keys.
  factory FilterNode.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('field') && json.containsKey('op')) {
      return FilterCondition.fromJson(json);
    }
    return FilterGroup.fromJson(json);
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson();
}
