import 'package:meta/meta.dart';

import 'filter_node.dart';

/// Payload containing filter parameters for observability queries.
///
/// The [filters] field can be either a [FilterGroup] (with AND/OR logic)
/// or a single [FilterCondition], or null for no filtering.
@immutable
class FilterPayload {
  /// The filter to apply. Can be a [FilterGroup] or [FilterCondition].
  final FilterNode? filters;

  /// Creates a [FilterPayload].
  const FilterPayload({this.filters});

  /// Creates a [FilterPayload] from JSON.
  factory FilterPayload.fromJson(Map<String, dynamic> json) {
    final filtersJson = json['filters'];
    if (filtersJson == null) {
      return const FilterPayload();
    }
    return FilterPayload(
      filters: FilterNode.fromJson(filtersJson as Map<String, dynamic>),
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (filters != null) 'filters': filters!.toJson(),
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
