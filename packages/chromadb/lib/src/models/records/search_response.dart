import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../../utils/equality_helpers.dart';

/// Response from a search records operation.
///
/// Contains the search results organized by search query. Each outer list
/// corresponds to one search payload, and each inner list contains
/// the results for that search ordered by relevance.
@immutable
class SearchResponse {
  /// The IDs of the matched records.
  /// Outer list: per search, inner list: per result.
  final List<List<String>> ids;

  /// The document contents (if requested).
  final List<List<String?>>? documents;

  /// The embedding vectors (if requested).
  final List<List<List<double>>>? embeddings;

  /// The metadata for each record (if requested).
  final List<List<Map<String, dynamic>?>>? metadatas;

  /// The relevance scores for each result.
  /// Note: This is "scores" not "distances" (higher is better).
  final List<List<double>>? scores;

  /// The selected fields (if select was specified).
  final List<List<String>>? included;

  /// The URIs for each record (if requested).
  final List<List<String?>>? uris;

  /// Creates a search response.
  const SearchResponse({
    required this.ids,
    this.documents,
    this.embeddings,
    this.metadatas,
    this.scores,
    this.included,
    this.uris,
  });

  /// Creates a search response from JSON.
  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      ids: (json['ids'] as List<dynamic>)
          .map((e) => (e as List<dynamic>? ?? []).cast<String>())
          .toList(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<String?>())
          .toList(),
      embeddings: (json['embeddings'] as List<dynamic>?)
          ?.map(
            (queryResults) => (queryResults as List<dynamic>? ?? [])
                .map((e) => (e as List<dynamic>? ?? []).cast<double>())
                .toList(),
          )
          .toList(),
      metadatas: (json['metadatas'] as List<dynamic>?)
          ?.map(
            (e) => (e as List<dynamic>? ?? [])
                .map((m) => m as Map<String, dynamic>?)
                .toList(),
          )
          .toList(),
      scores: (json['scores'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<double>())
          .toList(),
      included: (json['included'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<String>())
          .toList(),
      uris: (json['uris'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<String?>())
          .toList(),
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {
      'ids': ids,
      'documents': ?documents,
      'embeddings': ?embeddings,
      'metadatas': ?metadatas,
      'scores': ?scores,
      'included': ?included,
      'uris': ?uris,
    };
  }

  /// The number of searches in this response.
  int get searchCount => ids.length;

  /// Creates a copy with replaced values.
  SearchResponse copyWith({
    List<List<String>>? ids,
    Object? documents = unsetCopyWithValue,
    Object? embeddings = unsetCopyWithValue,
    Object? metadatas = unsetCopyWithValue,
    Object? scores = unsetCopyWithValue,
    Object? included = unsetCopyWithValue,
    Object? uris = unsetCopyWithValue,
  }) {
    return SearchResponse(
      ids: ids ?? this.ids,
      documents: documents == unsetCopyWithValue
          ? this.documents
          : documents as List<List<String?>>?,
      embeddings: embeddings == unsetCopyWithValue
          ? this.embeddings
          : embeddings as List<List<List<double>>>?,
      metadatas: metadatas == unsetCopyWithValue
          ? this.metadatas
          : metadatas as List<List<Map<String, dynamic>?>>?,
      scores: scores == unsetCopyWithValue
          ? this.scores
          : scores as List<List<double>>?,
      included: included == unsetCopyWithValue
          ? this.included
          : included as List<List<String>>?,
      uris: uris == unsetCopyWithValue
          ? this.uris
          : uris as List<List<String?>>?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchResponse &&
          runtimeType == other.runtimeType &&
          deepEquals(ids, other.ids) &&
          deepEquals(documents, other.documents) &&
          deepEquals(embeddings, other.embeddings) &&
          deepEquals(metadatas, other.metadatas) &&
          deepEquals(scores, other.scores) &&
          deepEquals(included, other.included) &&
          deepEquals(uris, other.uris);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(ids.map(Object.hashAll)),
    documents == null ? null : Object.hashAll(documents!.map(Object.hashAll)),
    embeddings == null
        ? null
        : Object.hashAll(
            embeddings!.map((e) => Object.hashAll(e.map(Object.hashAll))),
          ),
    metadatas == null ? null : Object.hashAll(metadatas!.map(Object.hashAll)),
    scores == null ? null : Object.hashAll(scores!.map(Object.hashAll)),
    included == null ? null : Object.hashAll(included!.map(Object.hashAll)),
    uris == null ? null : Object.hashAll(uris!.map(Object.hashAll)),
  );

  @override
  String toString() =>
      'SearchResponse(searches: $searchCount, '
      'documents: ${documents != null}, '
      'embeddings: ${embeddings != null}, '
      'metadatas: ${metadatas != null}, '
      'scores: ${scores != null}, '
      'included: ${included != null}, '
      'uris: ${uris != null})';
}
