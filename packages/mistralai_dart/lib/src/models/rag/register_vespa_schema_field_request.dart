import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import 'schema_field_data_type.dart';
import 'schema_field_index.dart';
import 'schema_field_ranking_type.dart';
import 'schema_field_storage.dart';

/// A single field definition within a Vespa schema being registered (beta).
@immutable
class RegisterVespaSchemaFieldRequest {
  /// The name of the field.
  final String name;

  /// The data type of the field.
  final SchemaFieldDataType type;

  /// The storage mode of the field.
  final SchemaFieldStorage storage;

  /// The ranking type used for the field.
  final SchemaFieldRankingType ranking;

  /// The index type of the field, or `null` if not indexed.
  final SchemaFieldIndex? indexType;

  /// Whether the field is multidimensional.
  final bool multidimensional;

  /// Creates a [RegisterVespaSchemaFieldRequest].
  const RegisterVespaSchemaFieldRequest({
    required this.name,
    required this.type,
    required this.storage,
    required this.ranking,
    required this.indexType,
    required this.multidimensional,
  });

  /// Creates a [RegisterVespaSchemaFieldRequest] from JSON.
  factory RegisterVespaSchemaFieldRequest.fromJson(Map<String, dynamic> json) =>
      RegisterVespaSchemaFieldRequest(
        name: json['name'] as String,
        type: SchemaFieldDataType.fromJson(json['type'] as String?),
        storage: SchemaFieldStorage.fromJson(json['storage'] as String?),
        ranking: SchemaFieldRankingType.fromJson(json['ranking'] as String?),
        indexType: json['index_type'] != null
            ? SchemaFieldIndex.fromJson(json['index_type'] as String?)
            : null,
        multidimensional: json['multidimensional'] as bool,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'type': type.toJson(),
    'storage': storage.toJson(),
    'ranking': ranking.toJson(),
    'index_type': indexType?.toJson(),
    'multidimensional': multidimensional,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  RegisterVespaSchemaFieldRequest copyWith({
    String? name,
    SchemaFieldDataType? type,
    SchemaFieldStorage? storage,
    SchemaFieldRankingType? ranking,
    Object? indexType = unsetCopyWithValue,
    bool? multidimensional,
  }) => RegisterVespaSchemaFieldRequest(
    name: name ?? this.name,
    type: type ?? this.type,
    storage: storage ?? this.storage,
    ranking: ranking ?? this.ranking,
    indexType: indexType == unsetCopyWithValue
        ? this.indexType
        : indexType as SchemaFieldIndex?,
    multidimensional: multidimensional ?? this.multidimensional,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RegisterVespaSchemaFieldRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          type == other.type &&
          storage == other.storage &&
          ranking == other.ranking &&
          indexType == other.indexType &&
          multidimensional == other.multidimensional;

  @override
  int get hashCode =>
      Object.hash(name, type, storage, ranking, indexType, multidimensional);

  @override
  String toString() =>
      'RegisterVespaSchemaFieldRequest('
      'name: $name, type: $type, storage: $storage, ranking: $ranking, '
      'indexType: $indexType, multidimensional: $multidimensional)';
}
