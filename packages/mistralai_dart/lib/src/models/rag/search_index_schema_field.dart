import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'schema_field_data_type.dart';
import 'schema_field_index.dart';
import 'schema_field_storage.dart';

/// A single field definition within a RAG search index schema's detail view
/// (beta).
@immutable
class SearchIndexSchemaField {
  /// The name of the field.
  final String name;

  /// The data type of the field.
  final SchemaFieldDataType type;

  /// The storage mode of the field.
  final SchemaFieldStorage storage;

  /// The index type of the field, or `null` if not indexed.
  final SchemaFieldIndex? indexType;

  /// Creates a [SearchIndexSchemaField].
  const SearchIndexSchemaField({
    required this.name,
    required this.type,
    required this.storage,
    required this.indexType,
  });

  /// Creates a [SearchIndexSchemaField] from JSON.
  factory SearchIndexSchemaField.fromJson(Map<String, dynamic> json) =>
      SearchIndexSchemaField(
        name: json['name'] as String,
        type: SchemaFieldDataType.fromJson(json['type'] as String?),
        storage: SchemaFieldStorage.fromJson(json['storage'] as String?),
        indexType: json['index_type'] != null
            ? SchemaFieldIndex.fromJson(json['index_type'] as String?)
            : null,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.toJson(),
    'storage': storage.toJson(),
    'index_type': indexType?.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  SearchIndexSchemaField copyWith({
    String? name,
    SchemaFieldDataType? type,
    SchemaFieldStorage? storage,
    Object? indexType = unsetCopyWithValue,
  }) => SearchIndexSchemaField(
    name: name ?? this.name,
    type: type ?? this.type,
    storage: storage ?? this.storage,
    indexType: indexType == unsetCopyWithValue
        ? this.indexType
        : indexType as SchemaFieldIndex?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchIndexSchemaField &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          storage == other.storage &&
          indexType == other.indexType;

  @override
  int get hashCode => Object.hash(name, type, storage, indexType);

  @override
  String toString() =>
      'SearchIndexSchemaField('
      'name: $name, type: $type, storage: $storage, indexType: $indexType)';
}
