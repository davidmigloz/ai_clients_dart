import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A single retrievable document stored within a RAG search index (beta).
@immutable
class SearchIndexRetrievable {
  /// The native ID of the document in the underlying index.
  final String id;

  /// The fields stored for this document.
  final Map<String, dynamic> fields;

  /// Creates a [SearchIndexRetrievable].
  const SearchIndexRetrievable({required this.id, required this.fields});

  /// Creates a [SearchIndexRetrievable] from JSON.
  factory SearchIndexRetrievable.fromJson(Map<String, dynamic> json) =>
      SearchIndexRetrievable(
        id: json['id'] as String,
        fields: json['fields'] as Map<String, dynamic>,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {'id': id, 'fields': fields};

  /// Creates a copy with the given fields replaced.
  SearchIndexRetrievable copyWith({String? id, Map<String, dynamic>? fields}) =>
      SearchIndexRetrievable(id: id ?? this.id, fields: fields ?? this.fields);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchIndexRetrievable &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          mapsEqual(fields, other.fields);

  @override
  int get hashCode => Object.hash(id, mapHash(fields));

  @override
  String toString() =>
      'SearchIndexRetrievable(id: $id, fields: ${fields.length} items)';
}
