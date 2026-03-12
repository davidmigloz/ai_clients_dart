import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../../utils/equality_helpers.dart';
import 'include.dart';

/// Response from a query records operation.
///
/// Contains the query results organized by query. Each outer list
/// corresponds to one query embedding, and each inner list contains
/// the results for that query ordered by similarity.
@immutable
class QueryResponse {
  /// The IDs of the matched records.
  /// Outer list: per query, inner list: per result.
  final List<List<String>> ids;

  /// The embedding vectors (if requested).
  final List<List<List<double>>>? embeddings;

  /// The document contents (if requested).
  final List<List<String?>>? documents;

  /// The metadata for each record (if requested).
  final List<List<Map<String, dynamic>?>>? metadatas;

  /// The distances from the query embedding.
  final List<List<double>>? distances;

  /// The URIs for each record (if requested).
  final List<List<String?>>? uris;

  /// The loaded data (if requested and DataLoader configured).
  final List<List<String>>? data;

  /// The fields that were included in the response.
  final List<Include> include;

  /// Creates a query response.
  const QueryResponse({
    required this.ids,
    this.embeddings,
    this.documents,
    this.metadatas,
    this.distances,
    this.uris,
    this.data,
    required this.include,
  });

  /// Creates a query response from JSON.
  factory QueryResponse.fromJson(Map<String, dynamic> json) {
    return QueryResponse(
      ids: (json['ids'] as List<dynamic>)
          .map((e) => (e as List<dynamic>? ?? []).cast<String>())
          .toList(),
      embeddings: (json['embeddings'] as List<dynamic>?)
          ?.map(
            (queryResults) => (queryResults as List<dynamic>? ?? [])
                .map((e) => (e as List<dynamic>? ?? []).cast<double>())
                .toList(),
          )
          .toList(),
      documents: (json['documents'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<String?>())
          .toList(),
      metadatas: (json['metadatas'] as List<dynamic>?)
          ?.map(
            (e) => (e as List<dynamic>? ?? [])
                .map((m) => m as Map<String, dynamic>?)
                .toList(),
          )
          .toList(),
      distances: (json['distances'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<double>())
          .toList(),
      uris: (json['uris'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<String?>())
          .toList(),
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<String>())
          .toList(),
      include: Include.fromApiList(json['include'] as List<dynamic>),
    );
  }

  /// Converts this response to JSON.
  Map<String, dynamic> toJson() {
    return {
      'ids': ids,
      'embeddings': ?embeddings,
      'documents': ?documents,
      'metadatas': ?metadatas,
      'distances': ?distances,
      'uris': ?uris,
      'data': ?data,
      'include': Include.toApiList(include),
    };
  }

  /// The number of queries in this response.
  int get queryCount => ids.length;

  /// Creates a copy with replaced values.
  QueryResponse copyWith({
    List<List<String>>? ids,
    Object? embeddings = unsetCopyWithValue,
    Object? documents = unsetCopyWithValue,
    Object? metadatas = unsetCopyWithValue,
    Object? distances = unsetCopyWithValue,
    Object? uris = unsetCopyWithValue,
    Object? data = unsetCopyWithValue,
    List<Include>? include,
  }) {
    return QueryResponse(
      ids: ids ?? this.ids,
      embeddings: embeddings == unsetCopyWithValue
          ? this.embeddings
          : embeddings as List<List<List<double>>>?,
      documents: documents == unsetCopyWithValue
          ? this.documents
          : documents as List<List<String?>>?,
      metadatas: metadatas == unsetCopyWithValue
          ? this.metadatas
          : metadatas as List<List<Map<String, dynamic>?>>?,
      distances: distances == unsetCopyWithValue
          ? this.distances
          : distances as List<List<double>>?,
      uris: uris == unsetCopyWithValue
          ? this.uris
          : uris as List<List<String?>>?,
      data: data == unsetCopyWithValue
          ? this.data
          : data as List<List<String>>?,
      include: include ?? this.include,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueryResponse &&
          runtimeType == other.runtimeType &&
          deepEquals(ids, other.ids) &&
          deepEquals(embeddings, other.embeddings) &&
          deepEquals(documents, other.documents) &&
          deepEquals(metadatas, other.metadatas) &&
          deepEquals(distances, other.distances) &&
          deepEquals(uris, other.uris) &&
          deepEquals(data, other.data) &&
          deepEquals(include, other.include);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(ids.map(Object.hashAll)),
    embeddings == null
        ? null
        : Object.hashAll(
            embeddings!.map((e) => Object.hashAll(e.map(Object.hashAll))),
          ),
    documents == null ? null : Object.hashAll(documents!.map(Object.hashAll)),
    metadatas == null ? null : Object.hashAll(metadatas!.map(Object.hashAll)),
    distances == null ? null : Object.hashAll(distances!.map(Object.hashAll)),
    uris == null ? null : Object.hashAll(uris!.map(Object.hashAll)),
    data == null ? null : Object.hashAll(data!.map(Object.hashAll)),
    Object.hashAll(include),
  );

  @override
  String toString() =>
      'QueryResponse(ids: ${ids.length} queries, '
      'embeddings: ${embeddings != null}, '
      'documents: ${documents != null}, '
      'metadatas: ${metadatas != null}, '
      'distances: ${distances != null}, '
      'uris: ${uris != null}, '
      'data: ${data != null}, '
      'include: $include)';
}
