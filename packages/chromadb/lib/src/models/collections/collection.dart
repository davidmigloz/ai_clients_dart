import 'package:meta/meta.dart';

import '../../utils/copy_with_sentinel.dart';
import '../../utils/equality_helpers.dart';
import 'collection_configuration.dart';
import 'collection_schema.dart';

/// A ChromaDB collection.
///
/// Collections are the main container for storing and querying records
/// (embeddings, documents, and metadata) in ChromaDB.
@immutable
class Collection {
  /// The collection's unique identifier (UUID).
  final String id;

  /// The collection's name.
  final String name;

  /// Custom metadata attached to the collection.
  final Map<String, dynamic>? metadata;

  /// The tenant this collection belongs to.
  final String tenant;

  /// The database this collection belongs to.
  final String database;

  /// The current log position for this collection.
  final int logPosition;

  /// The collection's version number.
  final int version;

  /// The collection's configuration (HNSW, SPANN, embedding function).
  final CollectionConfiguration configurationJson;

  /// The dimension of vectors in this collection.
  final int? dimension;

  /// The collection's schema for index configurations.
  final CollectionSchema? schema;

  /// Creates a collection.
  const Collection({
    required this.id,
    required this.name,
    this.metadata,
    required this.tenant,
    required this.database,
    required this.logPosition,
    required this.version,
    required this.configurationJson,
    this.dimension,
    this.schema,
  });

  /// Creates a collection from JSON.
  ///
  /// The [id] and [name] fields are expected to be present.
  /// Some server responses may omit [id], in which case [name] is used.
  factory Collection.fromJson(Map<String, dynamic> json) {
    final name = json['name'] as String?;
    final id = json['id'] as String?;

    if (name == null && id == null) {
      throw FormatException(
        'Collection JSON must contain at least "id" or "name"',
        json,
      );
    }

    return Collection(
      id: id ?? name!,
      name: name ?? id!,
      metadata: json['metadata'] as Map<String, dynamic>?,
      tenant: json['tenant'] as String,
      database: json['database'] as String,
      logPosition: json['log_position'] as int,
      version: json['version'] as int,
      configurationJson: CollectionConfiguration.fromJson(
        json['configuration_json'] as Map<String, dynamic>,
      ),
      dimension: json['dimension'] as int?,
      schema: json['schema'] != null
          ? CollectionSchema.fromJson(json['schema'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Converts this collection to JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'metadata': ?metadata,
      'tenant': tenant,
      'database': database,
      'log_position': logPosition,
      'version': version,
      'configuration_json': configurationJson.toJson(),
      'dimension': ?dimension,
      if (schema != null) 'schema': schema!.toJson(),
    };
  }

  /// Creates a copy of this collection with optional modifications.
  Collection copyWith({
    String? id,
    String? name,
    Object? metadata = unsetCopyWithValue,
    String? tenant,
    String? database,
    int? logPosition,
    int? version,
    CollectionConfiguration? configurationJson,
    Object? dimension = unsetCopyWithValue,
    Object? schema = unsetCopyWithValue,
  }) {
    return Collection(
      id: id ?? this.id,
      name: name ?? this.name,
      metadata: metadata == unsetCopyWithValue
          ? this.metadata
          : metadata as Map<String, dynamic>?,
      tenant: tenant ?? this.tenant,
      database: database ?? this.database,
      logPosition: logPosition ?? this.logPosition,
      version: version ?? this.version,
      configurationJson: configurationJson ?? this.configurationJson,
      dimension: dimension == unsetCopyWithValue
          ? this.dimension
          : dimension as int?,
      schema: schema == unsetCopyWithValue
          ? this.schema
          : schema as CollectionSchema?,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Collection &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          mapsEqual(metadata, other.metadata) &&
          tenant == other.tenant &&
          database == other.database &&
          logPosition == other.logPosition &&
          version == other.version &&
          configurationJson == other.configurationJson &&
          dimension == other.dimension &&
          schema == other.schema;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    mapHash(metadata),
    tenant,
    database,
    logPosition,
    version,
    configurationJson,
    dimension,
    schema,
  );

  @override
  String toString() =>
      'Collection(id: $id, name: $name, metadata: $metadata, '
      'tenant: $tenant, database: $database, '
      'logPosition: $logPosition, version: $version, '
      'configurationJson: $configurationJson, '
      'dimension: $dimension, schema: ${schema != null})';
}
