import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../../utils/equality_helpers.dart';

/// Filter criteria for a search query.
///
/// Used to filter results based on IDs or metadata conditions.
@immutable
class SearchFilter {
  /// Specific record IDs to include in results.
  final List<String>? queryIds;

  /// Metadata filter conditions (where clause).
  final Map<String, dynamic>? whereClause;

  /// Creates a search filter.
  const SearchFilter({this.queryIds, this.whereClause});

  /// Creates a search filter from JSON.
  factory SearchFilter.fromJson(Map<String, dynamic> json) {
    return SearchFilter(
      queryIds: (json['query_ids'] as List?)?.cast<String>(),
      whereClause: json['where_clause'] as Map<String, dynamic>?,
    );
  }

  /// Converts this filter to JSON.
  Map<String, dynamic> toJson() {
    return {'query_ids': ?queryIds, 'where_clause': ?whereClause};
  }

  /// Creates a copy with replaced values.
  SearchFilter copyWith({
    Object? queryIds = unsetCopyWithValue,
    Object? whereClause = unsetCopyWithValue,
  }) {
    return SearchFilter(
      queryIds: queryIds == unsetCopyWithValue
          ? this.queryIds
          : queryIds as List<String>?,
      whereClause: whereClause == unsetCopyWithValue
          ? this.whereClause
          : whereClause as Map<String, dynamic>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchFilter &&
          runtimeType == other.runtimeType &&
          listsEqual(queryIds, other.queryIds) &&
          mapsEqual(whereClause, other.whereClause);

  @override
  int get hashCode => Object.hash(
    queryIds == null ? null : Object.hashAll(queryIds!),
    mapHash(whereClause),
  );

  @override
  String toString() =>
      'SearchFilter(queryIds: $queryIds, whereClause: $whereClause)';
}

/// Grouping criteria for search results.
///
/// Used to group results by metadata keys with optional aggregation.
@immutable
class SearchGroupBy {
  /// Aggregation functions to apply.
  final Map<String, dynamic>? aggregate;

  /// Metadata keys to group by.
  final List<String>? keys;

  /// Creates a search group by.
  const SearchGroupBy({this.aggregate, this.keys});

  /// Creates a search group by from JSON.
  factory SearchGroupBy.fromJson(Map<String, dynamic> json) {
    return SearchGroupBy(
      aggregate: json['aggregate'] as Map<String, dynamic>?,
      keys: (json['keys'] as List?)?.cast<String>(),
    );
  }

  /// Converts this group by to JSON.
  Map<String, dynamic> toJson() {
    return {'aggregate': ?aggregate, 'keys': ?keys};
  }

  /// Creates a copy with replaced values.
  SearchGroupBy copyWith({
    Object? aggregate = unsetCopyWithValue,
    Object? keys = unsetCopyWithValue,
  }) {
    return SearchGroupBy(
      aggregate: aggregate == unsetCopyWithValue
          ? this.aggregate
          : aggregate as Map<String, dynamic>?,
      keys: keys == unsetCopyWithValue ? this.keys : keys as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchGroupBy &&
          runtimeType == other.runtimeType &&
          mapsEqual(aggregate, other.aggregate) &&
          listsEqual(keys, other.keys);

  @override
  int get hashCode => Object.hash(
    mapHash(aggregate),
    keys == null ? null : Object.hashAll(keys!),
  );

  @override
  String toString() => 'SearchGroupBy(aggregate: $aggregate, keys: $keys)';
}

/// Pagination limits for search results.
@immutable
class SearchLimit {
  /// Maximum number of results to return.
  final int? limit;

  /// Number of results to skip.
  final int? offset;

  /// Creates a search limit.
  const SearchLimit({this.limit, this.offset});

  /// Creates a search limit from JSON.
  factory SearchLimit.fromJson(Map<String, dynamic> json) {
    return SearchLimit(
      limit: json['limit'] as int?,
      offset: json['offset'] as int?,
    );
  }

  /// Converts this limit to JSON.
  Map<String, dynamic> toJson() {
    return {'limit': ?limit, 'offset': ?offset};
  }

  /// Creates a copy with replaced values.
  SearchLimit copyWith({
    Object? limit = unsetCopyWithValue,
    Object? offset = unsetCopyWithValue,
  }) {
    return SearchLimit(
      limit: limit == unsetCopyWithValue ? this.limit : limit as int?,
      offset: offset == unsetCopyWithValue ? this.offset : offset as int?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchLimit &&
          runtimeType == other.runtimeType &&
          limit == other.limit &&
          offset == other.offset;

  @override
  int get hashCode => Object.hash(limit, offset);

  @override
  String toString() => 'SearchLimit(limit: $limit, offset: $offset)';
}

/// Field selection for search results.
///
/// Specifies which fields to include in the response.
@immutable
class SearchSelect {
  /// List of field keys to include.
  ///
  /// Valid values include: 'Document', 'Embedding', 'Metadata', 'Score',
  /// or custom metadata field names.
  final List<String>? keys;

  /// Creates a search select.
  const SearchSelect({this.keys});

  /// Creates a search select from JSON.
  factory SearchSelect.fromJson(Map<String, dynamic> json) {
    return SearchSelect(keys: (json['keys'] as List?)?.cast<String>());
  }

  /// Converts this select to JSON.
  Map<String, dynamic> toJson() {
    return {'keys': ?keys};
  }

  /// Creates a copy with replaced values.
  SearchSelect copyWith({Object? keys = unsetCopyWithValue}) {
    return SearchSelect(
      keys: keys == unsetCopyWithValue ? this.keys : keys as List<String>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchSelect &&
          runtimeType == other.runtimeType &&
          listsEqual(keys, other.keys);

  @override
  int get hashCode => keys == null ? 0 : Object.hashAll(keys!);

  @override
  String toString() => 'SearchSelect(keys: $keys)';
}

/// A single search query within a search request.
///
/// Defines the criteria for one search operation, including filtering,
/// grouping, pagination, ranking, and field selection.
@immutable
class SearchPayload {
  /// Filter criteria for the search.
  final SearchFilter? filter;

  /// Grouping criteria for results.
  final SearchGroupBy? groupBy;

  /// Pagination limits.
  final SearchLimit? limit;

  /// Ranking configuration.
  ///
  /// This is a flexible map that can contain various ranking parameters.
  final Map<String, dynamic>? rank;

  /// Field selection for results.
  final SearchSelect? select;

  /// Creates a search payload.
  const SearchPayload({
    this.filter,
    this.groupBy,
    this.limit,
    this.rank,
    this.select,
  });

  /// Creates a search payload from JSON.
  factory SearchPayload.fromJson(Map<String, dynamic> json) {
    return SearchPayload(
      filter: json['filter'] != null
          ? SearchFilter.fromJson(json['filter'] as Map<String, dynamic>)
          : null,
      groupBy: json['group_by'] != null
          ? SearchGroupBy.fromJson(json['group_by'] as Map<String, dynamic>)
          : null,
      limit: json['limit'] != null
          ? SearchLimit.fromJson(json['limit'] as Map<String, dynamic>)
          : null,
      rank: json['rank'] as Map<String, dynamic>?,
      select: json['select'] != null
          ? SearchSelect.fromJson(json['select'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts this payload to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (filter != null) 'filter': filter!.toJson(),
      if (groupBy != null) 'group_by': groupBy!.toJson(),
      if (limit != null) 'limit': limit!.toJson(),
      'rank': ?rank,
      if (select != null) 'select': select!.toJson(),
    };
  }

  /// Creates a copy with replaced values.
  SearchPayload copyWith({
    Object? filter = unsetCopyWithValue,
    Object? groupBy = unsetCopyWithValue,
    Object? limit = unsetCopyWithValue,
    Object? rank = unsetCopyWithValue,
    Object? select = unsetCopyWithValue,
  }) {
    return SearchPayload(
      filter: filter == unsetCopyWithValue
          ? this.filter
          : filter as SearchFilter?,
      groupBy: groupBy == unsetCopyWithValue
          ? this.groupBy
          : groupBy as SearchGroupBy?,
      limit: limit == unsetCopyWithValue ? this.limit : limit as SearchLimit?,
      rank: rank == unsetCopyWithValue
          ? this.rank
          : rank as Map<String, dynamic>?,
      select: select == unsetCopyWithValue
          ? this.select
          : select as SearchSelect?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchPayload &&
          runtimeType == other.runtimeType &&
          filter == other.filter &&
          groupBy == other.groupBy &&
          limit == other.limit &&
          mapsEqual(rank, other.rank) &&
          select == other.select;

  @override
  int get hashCode =>
      Object.hash(filter, groupBy, limit, mapHash(rank), select);

  @override
  String toString() =>
      'SearchPayload('
      'filter: $filter, '
      'groupBy: $groupBy, '
      'limit: $limit, '
      'rank: $rank, '
      'select: $select)';
}
