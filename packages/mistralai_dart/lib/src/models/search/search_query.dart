import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A managed Search ManagedSearchFilter variant.
///
/// [SearchAndFilter], [SearchOrFilter], [SearchNotFilter], [SearchEqualFilter], [SearchInFilter], [SearchRangeFilter], or [UnknownManagedSearchFilter].
@immutable
sealed class ManagedSearchFilter {
  const ManagedSearchFilter();

  /// Parses an API payload.
  factory ManagedSearchFilter.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'and' => SearchAndFilter.fromJson(json),
        'or' => SearchOrFilter.fromJson(json),
        'not' => SearchNotFilter.fromJson(json),
        'equal' => SearchEqualFilter.fromJson(json),
        'in' => SearchInFilter.fromJson(json),
        'range' => SearchRangeFilter.fromJson(json),
        _ => UnknownManagedSearchFilter(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ManagedSearchFilter value.
@immutable
final class UnknownManagedSearchFilter extends ManagedSearchFilter {
  /// Creates a fallback from the original payload.
  UnknownManagedSearchFilter(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownManagedSearchFilter && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A managed Search ManagedRetriever variant.
///
/// [KeywordRetriever], [NearestNeighbourRetriever], [RrfRetriever], or [UnknownManagedRetriever].
@immutable
sealed class ManagedRetriever {
  const ManagedRetriever();

  /// Parses an API payload.
  factory ManagedRetriever.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'keyword' => KeywordRetriever.fromJson(json),
        'nearest_neighbour' => NearestNeighbourRetriever.fromJson(json),
        'rrf' => RrfRetriever.fromJson(json),
        _ => UnknownManagedRetriever(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ManagedRetriever value.
@immutable
final class UnknownManagedRetriever extends ManagedRetriever {
  /// Creates a fallback from the original payload.
  UnknownManagedRetriever(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownManagedRetriever && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// A managed Search ManagedLeafRetriever variant.
///
/// [KeywordRetriever], [NearestNeighbourRetriever], or [UnknownManagedLeafRetriever].
@immutable
sealed class ManagedLeafRetriever extends ManagedRetriever {
  const ManagedLeafRetriever();

  /// Parses an API payload.
  factory ManagedLeafRetriever.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'keyword' => KeywordRetriever.fromJson(json),
        'nearest_neighbour' => NearestNeighbourRetriever.fromJson(json),
        _ => UnknownManagedLeafRetriever(json),
      };
}

/// A future ManagedLeafRetriever value.
@immutable
final class UnknownManagedLeafRetriever extends ManagedLeafRetriever {
  /// Creates a fallback from the original payload.
  UnknownManagedLeafRetriever(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownManagedLeafRetriever && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The SearchRequest wire payload.
@immutable
class ManagedSearchRequest {
  /// Creates a [ManagedSearchRequest].
  const ManagedSearchRequest({required this.retriever});

  /// The retriever field.
  final ManagedRetriever retriever;

  /// Parses a [ManagedSearchRequest] from JSON.
  factory ManagedSearchRequest.fromJson(Map<String, dynamic> json) {
    if (json['retriever'] == null) {
      throw const FormatException('ManagedSearchRequest: missing retriever');
    }
    return ManagedSearchRequest(
      retriever: ManagedRetriever.fromJson(
        json['retriever'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'retriever': retriever.toJson()};

  /// Creates a copy with the given fields replaced.
  ManagedSearchRequest copyWith({ManagedRetriever? retriever}) =>
      ManagedSearchRequest(retriever: retriever ?? this.retriever);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedSearchRequest &&
          runtimeType == other.runtimeType &&
          retriever == other.retriever;

  @override
  int get hashCode => Object.hashAll([retriever]);

  @override
  String toString() =>
      'ManagedSearchRequest('
      'retriever: $retriever)';
}

/// Retrieve document chunks with similar keywords to the given query. Uses the default settings for the index on the field.
@immutable
class KeywordRetriever extends ManagedLeafRetriever {
  /// Creates a [KeywordRetriever].
  const KeywordRetriever({
    this.field,
    this.filter,
    this.matchOperator,
    required this.query,
    this.topK,
  });

  /// The fixed type discriminator.
  String get type => 'keyword';

  /// The field field.
  final String? field;

  /// The filter field.
  final ManagedSearchFilter? filter;

  /// The operator field.
  final String? matchOperator;

  /// The query string from which to match keywords: at most 20 whitespace-separated words.
  final String query;

  /// The top_k field.
  final int? topK;

  /// Parses a [KeywordRetriever] from JSON.
  factory KeywordRetriever.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'keyword') {
      throw FormatException('KeywordRetriever: unexpected type $value');
    }
    if (json['query'] == null) {
      throw const FormatException('KeywordRetriever: missing query');
    }
    return KeywordRetriever(
      field: json['field'] == null ? null : json['field'] as String,
      filter: json['filter'] == null
          ? null
          : ManagedSearchFilter.fromJson(
              json['filter'] as Map<String, dynamic>,
            ),
      matchOperator: json['operator'] == null
          ? null
          : json['operator'] as String,
      query: json['query'] as String,
      topK: json['top_k'] == null ? null : json['top_k'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'field': ?field,
    if (filter != null) 'filter': filter!.toJson(),
    'operator': ?matchOperator,
    'query': query,
    'top_k': ?topK,
  };

  /// Creates a copy with the given fields replaced.
  KeywordRetriever copyWith({
    Object? field = unsetCopyWithValue,
    Object? filter = unsetCopyWithValue,
    Object? matchOperator = unsetCopyWithValue,
    String? query,
    Object? topK = unsetCopyWithValue,
  }) => KeywordRetriever(
    field: field == unsetCopyWithValue ? this.field : field as String?,
    filter: filter == unsetCopyWithValue
        ? this.filter
        : filter as ManagedSearchFilter?,
    matchOperator: matchOperator == unsetCopyWithValue
        ? this.matchOperator
        : matchOperator as String?,
    query: query ?? this.query,
    topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is KeywordRetriever &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          filter == other.filter &&
          matchOperator == other.matchOperator &&
          query == other.query &&
          topK == other.topK;

  @override
  int get hashCode =>
      Object.hashAll([field, filter, matchOperator, query, topK]);

  @override
  String toString() =>
      'KeywordRetriever('
      'field: $field, '
      'filter: $filter, '
      'matchOperator: $matchOperator, '
      'query: $query, '
      'topK: $topK)';
}

/// Retrieve document chunks whose embeddings are closest to the query's.
@immutable
class NearestNeighbourRetriever extends ManagedLeafRetriever {
  /// Creates a [NearestNeighbourRetriever].
  const NearestNeighbourRetriever({
    this.field,
    this.filter,
    this.maxCandidates,
    this.query,
    this.queryEmbedding,
    this.topK,
  });

  /// The fixed type discriminator.
  String get type => 'nearest_neighbour';

  /// The field field.
  final String? field;

  /// The filter field.
  final ManagedSearchFilter? filter;

  /// The max_candidates field.
  final int? maxCandidates;

  /// The query field.
  final String? query;

  /// The query_embedding field.
  final List<double>? queryEmbedding;

  /// The top_k field.
  final int? topK;

  /// Parses a [NearestNeighbourRetriever] from JSON.
  factory NearestNeighbourRetriever.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'nearest_neighbour') {
      throw FormatException(
        'NearestNeighbourRetriever: unexpected type $value',
      );
    }
    return NearestNeighbourRetriever(
      field: json['field'] == null ? null : json['field'] as String,
      filter: json['filter'] == null
          ? null
          : ManagedSearchFilter.fromJson(
              json['filter'] as Map<String, dynamic>,
            ),
      maxCandidates: json['max_candidates'] == null
          ? null
          : json['max_candidates'] as int,
      query: json['query'] == null ? null : json['query'] as String,
      queryEmbedding: json['query_embedding'] == null
          ? null
          : (json['query_embedding'] as List)
                .map((item) => (item as num).toDouble())
                .toList(),
      topK: json['top_k'] == null ? null : json['top_k'] as int,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'field': ?field,
    if (filter != null) 'filter': filter!.toJson(),
    'max_candidates': ?maxCandidates,
    'query': ?query,
    'query_embedding': ?queryEmbedding,
    'top_k': ?topK,
  };

  /// Creates a copy with the given fields replaced.
  NearestNeighbourRetriever copyWith({
    Object? field = unsetCopyWithValue,
    Object? filter = unsetCopyWithValue,
    Object? maxCandidates = unsetCopyWithValue,
    Object? query = unsetCopyWithValue,
    Object? queryEmbedding = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
  }) => NearestNeighbourRetriever(
    field: field == unsetCopyWithValue ? this.field : field as String?,
    filter: filter == unsetCopyWithValue
        ? this.filter
        : filter as ManagedSearchFilter?,
    maxCandidates: maxCandidates == unsetCopyWithValue
        ? this.maxCandidates
        : maxCandidates as int?,
    query: query == unsetCopyWithValue ? this.query : query as String?,
    queryEmbedding: queryEmbedding == unsetCopyWithValue
        ? this.queryEmbedding
        : queryEmbedding as List<double>?,
    topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NearestNeighbourRetriever &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          filter == other.filter &&
          maxCandidates == other.maxCandidates &&
          query == other.query &&
          valuesDeepEqual(queryEmbedding, other.queryEmbedding) &&
          topK == other.topK;

  @override
  int get hashCode => Object.hashAll([
    field,
    filter,
    maxCandidates,
    query,
    valueDeepHashCode(queryEmbedding),
    topK,
  ]);

  @override
  String toString() =>
      'NearestNeighbourRetriever('
      'field: $field, '
      'filter: $filter, '
      'maxCandidates: $maxCandidates, '
      'query: $query, '
      'queryEmbedding: ${queryEmbedding?.length}, '
      'topK: $topK)';
}

/// Fuse child retriever rankings via reciprocal rank fusion.
@immutable
class RrfRetriever extends ManagedRetriever {
  /// Creates a [RrfRetriever].
  const RrfRetriever({
    this.filter,
    this.rankConstant,
    required this.retrievers,
    this.topK,
    this.weights,
  });

  /// The fixed type discriminator.
  String get type => 'rrf';

  /// The filter field.
  final ManagedSearchFilter? filter;

  /// The rank_constant field.
  final int? rankConstant;

  /// The retrievers field.
  final List<ManagedLeafRetriever> retrievers;

  /// The top_k field.
  final int? topK;

  /// The weights field.
  final List<double>? weights;

  /// Parses a [RrfRetriever] from JSON.
  factory RrfRetriever.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'rrf') {
      throw FormatException('RrfRetriever: unexpected type $value');
    }
    if (json['retrievers'] == null) {
      throw const FormatException('RrfRetriever: missing retrievers');
    }
    return RrfRetriever(
      filter: json['filter'] == null
          ? null
          : ManagedSearchFilter.fromJson(
              json['filter'] as Map<String, dynamic>,
            ),
      rankConstant: json['rank_constant'] == null
          ? null
          : json['rank_constant'] as int,
      retrievers: (json['retrievers'] as List)
          .map(
            (item) =>
                ManagedLeafRetriever.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      topK: json['top_k'] == null ? null : json['top_k'] as int,
      weights: json['weights'] == null
          ? null
          : (json['weights'] as List)
                .map((item) => (item as num).toDouble())
                .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (filter != null) 'filter': filter!.toJson(),
    'rank_constant': ?rankConstant,
    'retrievers': retrievers.map((item) => item.toJson()).toList(),
    'top_k': ?topK,
    'weights': ?weights,
  };

  /// Creates a copy with the given fields replaced.
  RrfRetriever copyWith({
    Object? filter = unsetCopyWithValue,
    Object? rankConstant = unsetCopyWithValue,
    List<ManagedLeafRetriever>? retrievers,
    Object? topK = unsetCopyWithValue,
    Object? weights = unsetCopyWithValue,
  }) => RrfRetriever(
    filter: filter == unsetCopyWithValue
        ? this.filter
        : filter as ManagedSearchFilter?,
    rankConstant: rankConstant == unsetCopyWithValue
        ? this.rankConstant
        : rankConstant as int?,
    retrievers: retrievers ?? this.retrievers,
    topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
    weights: weights == unsetCopyWithValue
        ? this.weights
        : weights as List<double>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RrfRetriever &&
          runtimeType == other.runtimeType &&
          filter == other.filter &&
          rankConstant == other.rankConstant &&
          valuesDeepEqual(retrievers, other.retrievers) &&
          topK == other.topK &&
          valuesDeepEqual(weights, other.weights);

  @override
  int get hashCode => Object.hashAll([
    filter,
    rankConstant,
    valueDeepHashCode(retrievers),
    topK,
    valueDeepHashCode(weights),
  ]);

  @override
  String toString() =>
      'RrfRetriever('
      'filter: $filter, '
      'rankConstant: $rankConstant, '
      'retrievers: ${retrievers.length}, '
      'topK: $topK, '
      'weights: ${weights?.length})';
}

/// Conjunction: rows must match every sub-filter.
@immutable
class SearchAndFilter extends ManagedSearchFilter {
  /// Creates a [SearchAndFilter].
  const SearchAndFilter({required this.matches});

  /// The fixed type discriminator.
  String get type => 'and';

  /// The matches field.
  final List<ManagedSearchFilter> matches;

  /// Parses a [SearchAndFilter] from JSON.
  factory SearchAndFilter.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'and') {
      throw FormatException('SearchAndFilter: unexpected type $value');
    }
    if (json['matches'] == null) {
      throw const FormatException('SearchAndFilter: missing matches');
    }
    return SearchAndFilter(
      matches: (json['matches'] as List)
          .map(
            (item) =>
                ManagedSearchFilter.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'matches': matches.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  SearchAndFilter copyWith({List<ManagedSearchFilter>? matches}) =>
      SearchAndFilter(matches: matches ?? this.matches);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchAndFilter &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(matches, other.matches);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(matches)]);

  @override
  String toString() =>
      'SearchAndFilter('
      'matches: ${matches.length})';
}

/// Disjunction: rows must match at least one sub-filter.
@immutable
class SearchOrFilter extends ManagedSearchFilter {
  /// Creates a [SearchOrFilter].
  const SearchOrFilter({required this.matches});

  /// The fixed type discriminator.
  String get type => 'or';

  /// The matches field.
  final List<ManagedSearchFilter> matches;

  /// Parses a [SearchOrFilter] from JSON.
  factory SearchOrFilter.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'or') {
      throw FormatException('SearchOrFilter: unexpected type $value');
    }
    if (json['matches'] == null) {
      throw const FormatException('SearchOrFilter: missing matches');
    }
    return SearchOrFilter(
      matches: (json['matches'] as List)
          .map(
            (item) =>
                ManagedSearchFilter.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'matches': matches.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  SearchOrFilter copyWith({List<ManagedSearchFilter>? matches}) =>
      SearchOrFilter(matches: matches ?? this.matches);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchOrFilter &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(matches, other.matches);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(matches)]);

  @override
  String toString() =>
      'SearchOrFilter('
      'matches: ${matches.length})';
}

/// Negate a filter: rows must not match.
@immutable
class SearchNotFilter extends ManagedSearchFilter {
  /// Creates a [SearchNotFilter].
  const SearchNotFilter({required this.match});

  /// The fixed type discriminator.
  String get type => 'not';

  /// The match field.
  final ManagedSearchFilter match;

  /// Parses a [SearchNotFilter] from JSON.
  factory SearchNotFilter.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'not') {
      throw FormatException('SearchNotFilter: unexpected type $value');
    }
    if (json['match'] == null) {
      throw const FormatException('SearchNotFilter: missing match');
    }
    return SearchNotFilter(
      match: ManagedSearchFilter.fromJson(
        json['match'] as Map<String, dynamic>,
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {'type': type, 'match': match.toJson()};

  /// Creates a copy with the given fields replaced.
  SearchNotFilter copyWith({ManagedSearchFilter? match}) =>
      SearchNotFilter(match: match ?? this.match);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchNotFilter &&
          runtimeType == other.runtimeType &&
          match == other.match;

  @override
  int get hashCode => Object.hashAll([match]);

  @override
  String toString() =>
      'SearchNotFilter('
      'match: $match)';
}

/// Field equals a scalar value.
@immutable
class SearchEqualFilter extends ManagedSearchFilter {
  /// Creates a [SearchEqualFilter].
  const SearchEqualFilter({required this.field, required this.value});

  /// The fixed type discriminator.
  String get type => 'equal';

  /// The field field.
  final String field;

  /// The value field.
  final Object value;

  /// Parses a [SearchEqualFilter] from JSON.
  factory SearchEqualFilter.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'equal') {
      throw FormatException('SearchEqualFilter: unexpected type $value');
    }
    if (json['field'] == null) {
      throw const FormatException('SearchEqualFilter: missing field');
    }
    if (json['value'] == null) {
      throw const FormatException('SearchEqualFilter: missing value');
    }
    return SearchEqualFilter(
      field: json['field'] as String,
      value: json['value'] as Object,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'field': field,
    'value': value,
  };

  /// Creates a copy with the given fields replaced.
  SearchEqualFilter copyWith({String? field, Object? value}) =>
      SearchEqualFilter(field: field ?? this.field, value: value ?? this.value);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchEqualFilter &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          valuesDeepEqual(value, other.value);

  @override
  int get hashCode => Object.hashAll([field, valueDeepHashCode(value)]);

  @override
  String toString() =>
      'SearchEqualFilter('
      'field: $field, '
      'value: $value)';
}

/// Field is one of a set of values.
@immutable
class SearchInFilter extends ManagedSearchFilter {
  /// Creates a [SearchInFilter].
  const SearchInFilter({required this.field, required this.values});

  /// The fixed type discriminator.
  String get type => 'in';

  /// The field field.
  final String field;

  /// The values field.
  final List<Object> values;

  /// Parses a [SearchInFilter] from JSON.
  factory SearchInFilter.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'in') {
      throw FormatException('SearchInFilter: unexpected type $value');
    }
    if (json['field'] == null) {
      throw const FormatException('SearchInFilter: missing field');
    }
    if (json['values'] == null) {
      throw const FormatException('SearchInFilter: missing values');
    }
    return SearchInFilter(
      field: json['field'] as String,
      values: (json['values'] as List).map((item) => item as Object).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'field': field,
    'values': values,
  };

  /// Creates a copy with the given fields replaced.
  SearchInFilter copyWith({String? field, List<Object>? values}) =>
      SearchInFilter(field: field ?? this.field, values: values ?? this.values);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchInFilter &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          valuesDeepEqual(values, other.values);

  @override
  int get hashCode => Object.hashAll([field, valueDeepHashCode(values)]);

  @override
  String toString() =>
      'SearchInFilter('
      'field: $field, '
      'values: ${values.length})';
}

/// Check that the given field falls in a range. Requires at least one operator.
@immutable
class SearchRangeFilter extends ManagedSearchFilter {
  /// Creates a [SearchRangeFilter].
  const SearchRangeFilter({
    required this.field,
    this.gt,
    this.gte,
    this.lt,
    this.lte,
  });

  /// The fixed type discriminator.
  String get type => 'range';

  /// The field field.
  final String field;

  /// The gt field.
  final Object? gt;

  /// The gte field.
  final Object? gte;

  /// The lt field.
  final Object? lt;

  /// The lte field.
  final Object? lte;

  /// Parses a [SearchRangeFilter] from JSON.
  factory SearchRangeFilter.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'range') {
      throw FormatException('SearchRangeFilter: unexpected type $value');
    }
    if (json['field'] == null) {
      throw const FormatException('SearchRangeFilter: missing field');
    }
    return SearchRangeFilter(
      field: json['field'] as String,
      gt: json['gt'],
      gte: json['gte'],
      lt: json['lt'],
      lte: json['lte'],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'field': field,
    'gt': ?gt,
    'gte': ?gte,
    'lt': ?lt,
    'lte': ?lte,
  };

  /// Creates a copy with the given fields replaced.
  SearchRangeFilter copyWith({
    String? field,
    Object? gt = unsetCopyWithValue,
    Object? gte = unsetCopyWithValue,
    Object? lt = unsetCopyWithValue,
    Object? lte = unsetCopyWithValue,
  }) => SearchRangeFilter(
    field: field ?? this.field,
    gt: gt == unsetCopyWithValue ? this.gt : gt,
    gte: gte == unsetCopyWithValue ? this.gte : gte,
    lt: lt == unsetCopyWithValue ? this.lt : lt,
    lte: lte == unsetCopyWithValue ? this.lte : lte,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchRangeFilter &&
          runtimeType == other.runtimeType &&
          field == other.field &&
          valuesDeepEqual(gt, other.gt) &&
          valuesDeepEqual(gte, other.gte) &&
          valuesDeepEqual(lt, other.lt) &&
          valuesDeepEqual(lte, other.lte);

  @override
  int get hashCode => Object.hashAll([
    field,
    valueDeepHashCode(gt),
    valueDeepHashCode(gte),
    valueDeepHashCode(lt),
    valueDeepHashCode(lte),
  ]);

  @override
  String toString() =>
      'SearchRangeFilter('
      'field: $field, '
      'gt: $gt, '
      'gte: $gte, '
      'lt: $lt, '
      'lte: $lte)';
}

/// The SearchResponse wire payload.
@immutable
class ManagedSearchResults {
  /// Creates a [ManagedSearchResults].
  const ManagedSearchResults({required this.hits});

  /// The hits field.
  final List<ManagedSearchHit> hits;

  /// Parses a [ManagedSearchResults] from JSON.
  factory ManagedSearchResults.fromJson(Map<String, dynamic> json) {
    if (json['hits'] == null) {
      throw const FormatException('ManagedSearchResults: missing hits');
    }
    return ManagedSearchResults(
      hits: (json['hits'] as List)
          .map(
            (item) => ManagedSearchHit.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'hits': hits.map((item) => item.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ManagedSearchResults copyWith({List<ManagedSearchHit>? hits}) =>
      ManagedSearchResults(hits: hits ?? this.hits);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedSearchResults &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(hits, other.hits);

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(hits)]);

  @override
  String toString() =>
      'ManagedSearchResults('
      'hits: ${hits.length})';
}

/// The SearchHitResponse wire payload.
@immutable
class ManagedSearchHit {
  /// Creates a [ManagedSearchHit].
  const ManagedSearchHit({
    required this.chunk,
    this.distance,
    required this.indexName,
    required this.score,
  });

  /// The chunk field.
  final ManagedSearchChunk chunk;

  /// The distance field.
  final double? distance;

  /// The index_name field.
  final String indexName;

  /// The score field.
  final double score;

  /// Parses a [ManagedSearchHit] from JSON.
  factory ManagedSearchHit.fromJson(Map<String, dynamic> json) {
    if (json['chunk'] == null) {
      throw const FormatException('ManagedSearchHit: missing chunk');
    }
    if (json['index_name'] == null) {
      throw const FormatException('ManagedSearchHit: missing index_name');
    }
    if (json['score'] == null) {
      throw const FormatException('ManagedSearchHit: missing score');
    }
    return ManagedSearchHit(
      chunk: ManagedSearchChunk.fromJson(json['chunk'] as Map<String, dynamic>),
      distance: json['distance'] == null
          ? null
          : (json['distance'] as num).toDouble(),
      indexName: json['index_name'] as String,
      score: (json['score'] as num).toDouble(),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'chunk': chunk.toJson(),
    'distance': ?distance,
    'index_name': indexName,
    'score': score,
  };

  /// Creates a copy with the given fields replaced.
  ManagedSearchHit copyWith({
    ManagedSearchChunk? chunk,
    Object? distance = unsetCopyWithValue,
    String? indexName,
    double? score,
  }) => ManagedSearchHit(
    chunk: chunk ?? this.chunk,
    distance: distance == unsetCopyWithValue
        ? this.distance
        : distance as double?,
    indexName: indexName ?? this.indexName,
    score: score ?? this.score,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedSearchHit &&
          runtimeType == other.runtimeType &&
          chunk == other.chunk &&
          distance == other.distance &&
          indexName == other.indexName &&
          score == other.score;

  @override
  int get hashCode => Object.hashAll([chunk, distance, indexName, score]);

  @override
  String toString() =>
      'ManagedSearchHit('
      'chunk: $chunk, '
      'distance: $distance, '
      'indexName: $indexName, '
      'score: $score)';
}

/// Wire chunk: atom fields plus any custom fields (via ``extra``).
@immutable
class ManagedSearchChunk {
  /// Creates a [ManagedSearchChunk].
  const ManagedSearchChunk({
    required this.chunkType,
    required this.content,
    required this.endOffset,
    required this.id,
    required this.locator,
    this.metadata,
    this.parentRef,
    required this.sourceId,
    required this.startOffset,
    this.extra,
  });

  /// The chunk_type field.
  final String chunkType;

  /// The content field.
  final String content;

  /// The end_offset field.
  final int? endOffset;

  /// The id field.
  final String id;

  /// The locator field.
  final String locator;

  /// The metadata field.
  final Map<String, dynamic>? metadata;

  /// The parent_ref field.
  final String? parentRef;

  /// The source_id field.
  final String sourceId;

  /// The start_offset field.
  final int? startOffset;

  /// Additional API fields.
  final Map<String, dynamic>? extra;

  /// Parses a [ManagedSearchChunk] from JSON.
  factory ManagedSearchChunk.fromJson(Map<String, dynamic> json) {
    if (json['chunk_type'] == null) {
      throw const FormatException('ManagedSearchChunk: missing chunk_type');
    }
    if (json['content'] == null) {
      throw const FormatException('ManagedSearchChunk: missing content');
    }
    if (!json.containsKey('end_offset')) {
      throw const FormatException('ManagedSearchChunk: missing end_offset');
    }
    if (json['id'] == null) {
      throw const FormatException('ManagedSearchChunk: missing id');
    }
    if (json['locator'] == null) {
      throw const FormatException('ManagedSearchChunk: missing locator');
    }
    if (json['source_id'] == null) {
      throw const FormatException('ManagedSearchChunk: missing source_id');
    }
    if (!json.containsKey('start_offset')) {
      throw const FormatException('ManagedSearchChunk: missing start_offset');
    }
    return ManagedSearchChunk(
      chunkType: json['chunk_type'] as String,
      content: json['content'] as String,
      endOffset: json['end_offset'] == null ? null : json['end_offset'] as int,
      id: json['id'] as String,
      locator: json['locator'] as String,
      metadata: json['metadata'] == null
          ? null
          : json['metadata'] as Map<String, dynamic>,
      parentRef: json['parent_ref'] == null
          ? null
          : json['parent_ref'] as String,
      sourceId: json['source_id'] as String,
      startOffset: json['start_offset'] == null
          ? null
          : json['start_offset'] as int,
      extra: {
        for (final entry in json.entries)
          if (!const {
            'chunk_type',
            'content',
            'end_offset',
            'id',
            'locator',
            'metadata',
            'parent_ref',
            'source_id',
            'start_offset',
          }.contains(entry.key))
            entry.key: entry.value,
      },
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    ...?extra,
    'chunk_type': chunkType,
    'content': content,
    'end_offset': endOffset,
    'id': id,
    'locator': locator,
    'metadata': ?metadata,
    'parent_ref': ?parentRef,
    'source_id': sourceId,
    'start_offset': startOffset,
  };

  /// Creates a copy with the given fields replaced.
  ManagedSearchChunk copyWith({
    String? chunkType,
    String? content,
    Object? endOffset = unsetCopyWithValue,
    String? id,
    String? locator,
    Object? metadata = unsetCopyWithValue,
    Object? parentRef = unsetCopyWithValue,
    String? sourceId,
    Object? startOffset = unsetCopyWithValue,
    Object? extra = unsetCopyWithValue,
  }) => ManagedSearchChunk(
    chunkType: chunkType ?? this.chunkType,
    content: content ?? this.content,
    endOffset: endOffset == unsetCopyWithValue
        ? this.endOffset
        : endOffset as int?,
    id: id ?? this.id,
    locator: locator ?? this.locator,
    metadata: metadata == unsetCopyWithValue
        ? this.metadata
        : metadata as Map<String, dynamic>?,
    parentRef: parentRef == unsetCopyWithValue
        ? this.parentRef
        : parentRef as String?,
    sourceId: sourceId ?? this.sourceId,
    startOffset: startOffset == unsetCopyWithValue
        ? this.startOffset
        : startOffset as int?,
    extra: extra == unsetCopyWithValue
        ? this.extra
        : extra as Map<String, dynamic>?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedSearchChunk &&
          runtimeType == other.runtimeType &&
          chunkType == other.chunkType &&
          content == other.content &&
          endOffset == other.endOffset &&
          id == other.id &&
          locator == other.locator &&
          valuesDeepEqual(metadata, other.metadata) &&
          parentRef == other.parentRef &&
          sourceId == other.sourceId &&
          startOffset == other.startOffset &&
          valuesDeepEqual(extra, other.extra);

  @override
  int get hashCode => Object.hashAll([
    chunkType,
    content,
    endOffset,
    id,
    locator,
    valueDeepHashCode(metadata),
    parentRef,
    sourceId,
    startOffset,
    valueDeepHashCode(extra),
  ]);

  @override
  String toString() =>
      'ManagedSearchChunk('
      'chunkType: $chunkType, '
      'content: $content, '
      'endOffset: $endOffset, '
      'id: $id, '
      'locator: $locator, '
      'metadata: ${metadata?.length}, '
      'parentRef: $parentRef, '
      'sourceId: $sourceId, '
      'startOffset: $startOffset, '
      'extra: ${extra?.length})';
}
