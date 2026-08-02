import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'search_index_schema_field.dart';

/// Detailed information about a RAG search index schema (beta).
@immutable
class SearchIndexSchemaDetail {
  /// The name of the schema.
  final String name;

  /// The number of dimensions of the schema's embedding field, or `null` if
  /// the schema has no embedding field.
  final int? embeddingDimensions;

  /// The fields defined within the schema.
  final List<SearchIndexSchemaField> fields;

  /// Creates a [SearchIndexSchemaDetail].
  const SearchIndexSchemaDetail({
    required this.name,
    required this.embeddingDimensions,
    required this.fields,
  });

  /// Creates a [SearchIndexSchemaDetail] from JSON.
  factory SearchIndexSchemaDetail.fromJson(Map<String, dynamic> json) =>
      SearchIndexSchemaDetail(
        name: json['name'] as String,
        embeddingDimensions: json['embedding_dimensions'] as int?,
        fields: (json['fields'] as List<dynamic>)
            .map(
              (e) => SearchIndexSchemaField.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'embedding_dimensions': embeddingDimensions,
    'fields': fields.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  SearchIndexSchemaDetail copyWith({
    String? name,
    Object? embeddingDimensions = unsetCopyWithValue,
    List<SearchIndexSchemaField>? fields,
  }) => SearchIndexSchemaDetail(
    name: name ?? this.name,
    embeddingDimensions: embeddingDimensions == unsetCopyWithValue
        ? this.embeddingDimensions
        : embeddingDimensions as int?,
    fields: fields ?? this.fields,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchIndexSchemaDetail &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          embeddingDimensions == other.embeddingDimensions &&
          listsEqual(fields, other.fields);

  @override
  int get hashCode => Object.hash(name, embeddingDimensions, listHash(fields));

  @override
  String toString() =>
      'SearchIndexSchemaDetail('
      'name: $name, embeddingDimensions: $embeddingDimensions, '
      'fields: ${fields.length} items)';
}
