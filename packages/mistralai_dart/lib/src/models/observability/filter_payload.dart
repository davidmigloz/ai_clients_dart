import 'package:meta/meta.dart';

import 'filter_condition.dart';
import 'filter_group.dart';

/// Payload containing filter parameters for observability queries.
///
/// The [filters] field can be either a [FilterGroup] (with AND/OR logic)
/// or a single [FilterCondition], or null for no filtering.
@immutable
class FilterPayload {
  /// The filter to apply. Can be a [FilterGroup] or [FilterCondition].
  final Object? filters;

  /// Creates a [FilterPayload].
  const FilterPayload({this.filters});

  /// Creates a [FilterPayload] from JSON.
  factory FilterPayload.fromJson(Map<String, dynamic> json) {
    final filtersJson = json['filters'];
    if (filtersJson == null) {
      return const FilterPayload();
    }
    final map = filtersJson as Map<String, dynamic>;
    if (map.containsKey('field') && map.containsKey('op')) {
      return FilterPayload(filters: FilterCondition.fromJson(map));
    }
    return FilterPayload(filters: FilterGroup.fromJson(map));
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'filters': filters == null
        ? null
        : filters is FilterCondition
        ? (filters! as FilterCondition).toJson()
        : (filters! as FilterGroup).toJson(),
  };

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! FilterPayload) return false;
    if (runtimeType != other.runtimeType) return false;
    return filters == other.filters;
  }

  @override
  int get hashCode => filters.hashCode;

  @override
  String toString() => 'FilterPayload(filters: $filters)';
}
