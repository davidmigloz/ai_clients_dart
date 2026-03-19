import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'include.dart';

/// Response from a get records operation.
///
/// Contains the requested records with their IDs and optionally
/// documents, embeddings, metadatas, and URIs based on the include parameter.
@immutable
class GetResponse {
  /// The IDs of the returned records.
  final List<String> ids;

  /// The embedding vectors (if requested).
  final List<List<double>>? embeddings;

  /// The document contents (if requested).
  final List<String?>? documents;

  /// The metadata for each record (if requested).
  final List<Map<String, dynamic>?>? metadatas;

  /// The URIs for each record (if requested).
  final List<String?>? uris;

  /// The loaded data (if requested and DataLoader configured).
  final List<String>? data;

  /// The fields that were included in the response.
  final List<Include> include;

  /// Creates a get response.
  const GetResponse({
    required this.ids,
    this.embeddings,
    this.documents,
    this.metadatas,
    this.uris,
    this.data,
    required this.include,
  });

  /// Creates a get response from JSON.
  factory GetResponse.fromJson(Map<String, dynamic> json) {
    return GetResponse(
      ids: (json['ids'] as List<dynamic>).cast<String>(),
      embeddings: (json['embeddings'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>? ?? []).cast<double>())
          .toList(),
      documents: (json['documents'] as List<dynamic>?)?.cast<String?>(),
      metadatas: (json['metadatas'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>?)
          .toList(),
      uris: (json['uris'] as List<dynamic>?)?.cast<String?>(),
      data: (json['data'] as List<dynamic>?)?.cast<String>(),
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
      'uris': ?uris,
      'data': ?data,
      'include': Include.toApiList(include),
    };
  }

  /// The number of records in this response.
  int get length => ids.length;

  /// Whether this response contains no records.
  bool get isEmpty => ids.isEmpty;

  /// Whether this response contains records.
  bool get isNotEmpty => ids.isNotEmpty;

  /// Creates a copy with replaced values.
  GetResponse copyWith({
    List<String>? ids,
    Object? embeddings = unsetCopyWithValue,
    Object? documents = unsetCopyWithValue,
    Object? metadatas = unsetCopyWithValue,
    Object? uris = unsetCopyWithValue,
    Object? data = unsetCopyWithValue,
    List<Include>? include,
  }) {
    return GetResponse(
      ids: ids ?? this.ids,
      embeddings: embeddings == unsetCopyWithValue
          ? this.embeddings
          : embeddings as List<List<double>>?,
      documents: documents == unsetCopyWithValue
          ? this.documents
          : documents as List<String?>?,
      metadatas: metadatas == unsetCopyWithValue
          ? this.metadatas
          : metadatas as List<Map<String, dynamic>?>?,
      uris: uris == unsetCopyWithValue ? this.uris : uris as List<String?>?,
      data: data == unsetCopyWithValue ? this.data : data as List<String>?,
      include: include ?? this.include,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GetResponse &&
          runtimeType == other.runtimeType &&
          deepEquals(ids, other.ids) &&
          deepEquals(embeddings, other.embeddings) &&
          deepEquals(documents, other.documents) &&
          deepEquals(metadatas, other.metadatas) &&
          deepEquals(uris, other.uris) &&
          deepEquals(data, other.data) &&
          deepEquals(include, other.include);

  @override
  int get hashCode => Object.hash(
    Object.hashAll(ids),
    embeddings == null ? null : Object.hashAll(embeddings!.map(Object.hashAll)),
    documents == null ? null : Object.hashAll(documents!),
    metadatas == null ? null : Object.hashAll(metadatas!),
    uris == null ? null : Object.hashAll(uris!),
    data == null ? null : Object.hashAll(data!),
    Object.hashAll(include),
  );

  @override
  String toString() =>
      'GetResponse(ids: ${ids.length} records, '
      'embeddings: ${embeddings != null}, '
      'documents: ${documents != null}, '
      'metadatas: ${metadatas != null}, '
      'uris: ${uris != null}, '
      'data: ${data != null}, '
      'include: $include)';
}
