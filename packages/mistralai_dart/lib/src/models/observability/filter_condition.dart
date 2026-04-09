import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';
import 'filter_node.dart';

/// A single filter condition for observability queries.
@immutable
class FilterCondition extends FilterNode {
  /// The field name to filter on.
  final String field;

  /// The filter operator (e.g., "eq", "neq", "contains", "gt").
  final String op;

  /// The value to compare against.
  final Object value;

  /// Creates a [FilterCondition].
  const FilterCondition({
    required this.field,
    required this.op,
    required this.value,
  });

  /// Creates a [FilterCondition] from JSON.
  factory FilterCondition.fromJson(Map<String, dynamic> json) =>
      FilterCondition(
        field: json['field'] as String? ?? '',
        op: json['op'] as String? ?? '',
        value: json['value'] ?? '',
      );

  @override
  Map<String, dynamic> toJson() => {'field': field, 'op': op, 'value': value};

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilterCondition) return false;
    if (runtimeType != other.runtimeType) return false;
    return field == other.field &&
        op == other.op &&
        valuesDeepEqual(value, other.value);
  }

  @override
  int get hashCode => Object.hash(field, op, valueDeepHashCode(value));

  @override
  String toString() => 'FilterCondition(field: $field, op: $op, value: $value)';
}
