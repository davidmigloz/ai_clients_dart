import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';

/// A managed Search ManagedIndexEmbedding variant.
///
/// [MistralIndexEmbedding], [CustomIndexEmbedding], or [UnknownManagedIndexEmbedding].
@immutable
sealed class ManagedIndexEmbedding {
  const ManagedIndexEmbedding();

  /// Parses an API payload.
  factory ManagedIndexEmbedding.fromJson(Map<String, dynamic> json) =>
      switch (json['type']) {
        'mistral' => MistralIndexEmbedding.fromJson(json),
        'custom' => CustomIndexEmbedding.fromJson(json),
        _ => UnknownManagedIndexEmbedding(json),
      };

  /// Encodes the wire object.
  Map<String, dynamic> toJson();
}

/// A future ManagedIndexEmbedding value.
@immutable
final class UnknownManagedIndexEmbedding extends ManagedIndexEmbedding {
  /// Creates a fallback from the original payload.
  UnknownManagedIndexEmbedding(Map<String, dynamic> json)
    : raw = Map.unmodifiable(json);

  /// The original payload.
  final Map<String, dynamic> raw;

  @override
  Map<String, dynamic> toJson() => Map.of(raw);

  @override
  bool operator ==(Object other) =>
      other is UnknownManagedIndexEmbedding && mapsDeepEqual(raw, other.raw);

  @override
  int get hashCode => mapDeepHashCode(raw);
}

/// The CreateManagedIndexRequest wire payload.
@immutable
class CreateManagedIndexRequest {
  /// Creates a [CreateManagedIndexRequest].
  const CreateManagedIndexRequest({
    required this.config,
    required this.name,
    this.schema,
  });

  /// The config field.
  final ManagedIndexConfig config;

  /// The name field.
  final String name;

  /// The schema field.
  final ManagedIndexFields? schema;

  /// Parses a [CreateManagedIndexRequest] from JSON.
  factory CreateManagedIndexRequest.fromJson(Map<String, dynamic> json) {
    if (json['config'] == null) {
      throw const FormatException('CreateManagedIndexRequest: missing config');
    }
    if (json['name'] == null) {
      throw const FormatException('CreateManagedIndexRequest: missing name');
    }
    return CreateManagedIndexRequest(
      config: ManagedIndexConfig.fromJson(
        json['config'] as Map<String, dynamic>,
      ),
      name: json['name'] as String,
      schema: json['schema'] == null
          ? null
          : ManagedIndexFields.fromJson(json['schema'] as Map<String, dynamic>),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'config': config.toJson(),
    'name': name,
    if (schema != null) 'schema': schema!.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  CreateManagedIndexRequest copyWith({
    ManagedIndexConfig? config,
    String? name,
    Object? schema = unsetCopyWithValue,
  }) => CreateManagedIndexRequest(
    config: config ?? this.config,
    name: name ?? this.name,
    schema: schema == unsetCopyWithValue
        ? this.schema
        : schema as ManagedIndexFields?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateManagedIndexRequest &&
          runtimeType == other.runtimeType &&
          config == other.config &&
          name == other.name &&
          schema == other.schema;

  @override
  int get hashCode => Object.hashAll([config, name, schema]);

  @override
  String toString() =>
      'CreateManagedIndexRequest('
      'config: $config, '
      'name: $name, '
      'schema: $schema)';
}

/// The ManagedIndexConfig wire payload.
@immutable
class ManagedIndexConfig {
  /// Creates a [ManagedIndexConfig].
  const ManagedIndexConfig({required this.embedding});

  /// The embedding field.
  final ManagedIndexEmbedding embedding;

  /// Parses a [ManagedIndexConfig] from JSON.
  factory ManagedIndexConfig.fromJson(Map<String, dynamic> json) {
    if (json['embedding'] == null) {
      throw const FormatException('ManagedIndexConfig: missing embedding');
    }
    return ManagedIndexConfig(
      embedding: ManagedIndexEmbedding.fromJson(
        json['embedding'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'embedding': embedding.toJson()};

  /// Creates a copy with the given fields replaced.
  ManagedIndexConfig copyWith({ManagedIndexEmbedding? embedding}) =>
      ManagedIndexConfig(embedding: embedding ?? this.embedding);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedIndexConfig &&
          runtimeType == other.runtimeType &&
          embedding == other.embedding;

  @override
  int get hashCode => Object.hashAll([embedding]);

  @override
  String toString() =>
      'ManagedIndexConfig('
      'embedding: $embedding)';
}

/// The ManagedIndexFields wire payload.
@immutable
class ManagedIndexFields {
  /// Creates a [ManagedIndexFields].
  const ManagedIndexFields({this.chunkFields, this.documentFields});

  /// The chunk_fields field.
  final Map<String, ManagedIndexField>? chunkFields;

  /// The document_fields field.
  final Map<String, ManagedIndexField>? documentFields;

  /// Parses a [ManagedIndexFields] from JSON.
  factory ManagedIndexFields.fromJson(Map<String, dynamic> json) {
    return ManagedIndexFields(
      chunkFields: json['chunk_fields'] == null
          ? null
          : (json['chunk_fields'] as Map<String, dynamic>).map(
              (key, item) => MapEntry(
                key,
                ManagedIndexField.fromJson(item as Map<String, dynamic>),
              ),
            ),
      documentFields: json['document_fields'] == null
          ? null
          : (json['document_fields'] as Map<String, dynamic>).map(
              (key, item) => MapEntry(
                key,
                ManagedIndexField.fromJson(item as Map<String, dynamic>),
              ),
            ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    if (chunkFields != null)
      'chunk_fields': chunkFields!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
    if (documentFields != null)
      'document_fields': documentFields!.map(
        (key, item) => MapEntry(key, item.toJson()),
      ),
  };

  /// Creates a copy with the given fields replaced.
  ManagedIndexFields copyWith({
    Object? chunkFields = unsetCopyWithValue,
    Object? documentFields = unsetCopyWithValue,
  }) => ManagedIndexFields(
    chunkFields: chunkFields == unsetCopyWithValue
        ? this.chunkFields
        : (chunkFields as Map?)?.cast<String, ManagedIndexField>(),
    documentFields: documentFields == unsetCopyWithValue
        ? this.documentFields
        : (documentFields as Map?)?.cast<String, ManagedIndexField>(),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedIndexFields &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(chunkFields, other.chunkFields) &&
          valuesDeepEqual(documentFields, other.documentFields);

  @override
  int get hashCode => Object.hashAll([
    valueDeepHashCode(chunkFields),
    valueDeepHashCode(documentFields),
  ]);

  @override
  String toString() =>
      'ManagedIndexFields('
      'chunkFields: ${chunkFields?.length}, '
      'documentFields: ${documentFields?.length})';
}

/// Wire representation of a managed index (decoupled from the domain model).
@immutable
class ManagedSearchIndex {
  /// Creates a [ManagedSearchIndex].
  const ManagedSearchIndex({
    required this.config,
    this.createdAt,
    required this.creatorId,
    required this.id,
    this.modifiedAt,
    required this.name,
    required this.schema,
    required this.status,
    this.statusMessage,
  });

  /// The config field.
  final ManagedIndexConfig config;

  /// The created_at field.
  final String? createdAt;

  /// The creator_id field.
  final String creatorId;

  /// The id field.
  final String id;

  /// The modified_at field.
  final String? modifiedAt;

  /// The name field.
  final String name;

  /// The schema field.
  final ManagedIndexFields schema;

  /// The status field.
  final ManagedSearchIndexStatus status;

  /// The status_message field.
  final String? statusMessage;

  /// Parses a [ManagedSearchIndex] from JSON.
  factory ManagedSearchIndex.fromJson(Map<String, dynamic> json) {
    if (json['config'] == null) {
      throw const FormatException('ManagedSearchIndex: missing config');
    }
    if (json['creator_id'] == null) {
      throw const FormatException('ManagedSearchIndex: missing creator_id');
    }
    if (json['id'] == null) {
      throw const FormatException('ManagedSearchIndex: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('ManagedSearchIndex: missing name');
    }
    if (json['schema'] == null) {
      throw const FormatException('ManagedSearchIndex: missing schema');
    }
    if (json['status'] == null) {
      throw const FormatException('ManagedSearchIndex: missing status');
    }
    return ManagedSearchIndex(
      config: ManagedIndexConfig.fromJson(
        json['config'] as Map<String, dynamic>,
      ),
      createdAt: json['created_at'] == null
          ? null
          : json['created_at'] as String,
      creatorId: json['creator_id'] as String,
      id: json['id'] as String,
      modifiedAt: json['modified_at'] == null
          ? null
          : json['modified_at'] as String,
      name: json['name'] as String,
      schema: ManagedIndexFields.fromJson(
        json['schema'] as Map<String, dynamic>,
      ),
      status: ManagedSearchIndexStatus.fromJson(json['status'] as String),
      statusMessage: json['status_message'] == null
          ? null
          : json['status_message'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'config': config.toJson(),
    'created_at': ?createdAt,
    'creator_id': creatorId,
    'id': id,
    'modified_at': ?modifiedAt,
    'name': name,
    'schema': schema.toJson(),
    'status': status.toJson(),
    'status_message': ?statusMessage,
  };

  /// Creates a copy with the given fields replaced.
  ManagedSearchIndex copyWith({
    ManagedIndexConfig? config,
    Object? createdAt = unsetCopyWithValue,
    String? creatorId,
    String? id,
    Object? modifiedAt = unsetCopyWithValue,
    String? name,
    ManagedIndexFields? schema,
    ManagedSearchIndexStatus? status,
    Object? statusMessage = unsetCopyWithValue,
  }) => ManagedSearchIndex(
    config: config ?? this.config,
    createdAt: createdAt == unsetCopyWithValue
        ? this.createdAt
        : createdAt as String?,
    creatorId: creatorId ?? this.creatorId,
    id: id ?? this.id,
    modifiedAt: modifiedAt == unsetCopyWithValue
        ? this.modifiedAt
        : modifiedAt as String?,
    name: name ?? this.name,
    schema: schema ?? this.schema,
    status: status ?? this.status,
    statusMessage: statusMessage == unsetCopyWithValue
        ? this.statusMessage
        : statusMessage as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedSearchIndex &&
          runtimeType == other.runtimeType &&
          config == other.config &&
          createdAt == other.createdAt &&
          creatorId == other.creatorId &&
          id == other.id &&
          modifiedAt == other.modifiedAt &&
          name == other.name &&
          schema == other.schema &&
          status == other.status &&
          statusMessage == other.statusMessage;

  @override
  int get hashCode => Object.hashAll([
    config,
    createdAt,
    creatorId,
    id,
    modifiedAt,
    name,
    schema,
    status,
    statusMessage,
  ]);

  @override
  String toString() =>
      'ManagedSearchIndex('
      'config: $config, '
      'createdAt: $createdAt, '
      'creatorId: $creatorId, '
      'id: $id, '
      'modifiedAt: $modifiedAt, '
      'name: $name, '
      'schema: $schema, '
      'status: $status, '
      'statusMessage: $statusMessage)';
}

/// Paginated list of managed indexes.
@immutable
class ManagedSearchIndexPage {
  /// Creates a [ManagedSearchIndexPage].
  const ManagedSearchIndexPage({required this.data, this.nextPageToken});

  /// The data field.
  final List<ManagedSearchIndex> data;

  /// The next_page_token field.
  final String? nextPageToken;

  /// Parses a [ManagedSearchIndexPage] from JSON.
  factory ManagedSearchIndexPage.fromJson(Map<String, dynamic> json) {
    if (json['data'] == null) {
      throw const FormatException('ManagedSearchIndexPage: missing data');
    }
    return ManagedSearchIndexPage(
      data: (json['data'] as List)
          .map(
            (item) => ManagedSearchIndex.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      nextPageToken: json['next_page_token'] == null
          ? null
          : json['next_page_token'] as String,
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'next_page_token': ?nextPageToken,
  };

  /// Creates a copy with the given fields replaced.
  ManagedSearchIndexPage copyWith({
    List<ManagedSearchIndex>? data,
    Object? nextPageToken = unsetCopyWithValue,
  }) => ManagedSearchIndexPage(
    data: data ?? this.data,
    nextPageToken: nextPageToken == unsetCopyWithValue
        ? this.nextPageToken
        : nextPageToken as String?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedSearchIndexPage &&
          runtimeType == other.runtimeType &&
          valuesDeepEqual(data, other.data) &&
          nextPageToken == other.nextPageToken;

  @override
  int get hashCode => Object.hashAll([valueDeepHashCode(data), nextPageToken]);

  @override
  String toString() =>
      'ManagedSearchIndexPage('
      'data: ${data.length}, '
      'nextPageToken: $nextPageToken)';
}

/// The schema an index should have. Sent whole, not as a patch. No ``config``: the embedding configuration is fixed at creation, so there is nothing for a caller to send back.
@immutable
class UpdateManagedIndexRequest {
  /// Creates a [UpdateManagedIndexRequest].
  const UpdateManagedIndexRequest({required this.schema});

  /// The schema field.
  final ManagedIndexFields schema;

  /// Parses a [UpdateManagedIndexRequest] from JSON.
  factory UpdateManagedIndexRequest.fromJson(Map<String, dynamic> json) {
    if (json['schema'] == null) {
      throw const FormatException('UpdateManagedIndexRequest: missing schema');
    }
    return UpdateManagedIndexRequest(
      schema: ManagedIndexFields.fromJson(
        json['schema'] as Map<String, dynamic>,
      ),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {'schema': schema.toJson()};

  /// Creates a copy with the given fields replaced.
  UpdateManagedIndexRequest copyWith({ManagedIndexFields? schema}) =>
      UpdateManagedIndexRequest(schema: schema ?? this.schema);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UpdateManagedIndexRequest &&
          runtimeType == other.runtimeType &&
          schema == other.schema;

  @override
  int get hashCode => Object.hashAll([schema]);

  @override
  String toString() =>
      'UpdateManagedIndexRequest('
      'schema: $schema)';
}

/// Wire representation returned when an index is deleted (id, name, status).
@immutable
class DeleteManagedIndexResponse {
  /// Creates a [DeleteManagedIndexResponse].
  const DeleteManagedIndexResponse({
    required this.id,
    required this.name,
    required this.status,
  });

  /// The id field.
  final String id;

  /// The name field.
  final String name;

  /// The status field.
  final ManagedSearchIndexStatus status;

  /// Parses a [DeleteManagedIndexResponse] from JSON.
  factory DeleteManagedIndexResponse.fromJson(Map<String, dynamic> json) {
    if (json['id'] == null) {
      throw const FormatException('DeleteManagedIndexResponse: missing id');
    }
    if (json['name'] == null) {
      throw const FormatException('DeleteManagedIndexResponse: missing name');
    }
    if (json['status'] == null) {
      throw const FormatException('DeleteManagedIndexResponse: missing status');
    }
    return DeleteManagedIndexResponse(
      id: json['id'] as String,
      name: json['name'] as String,
      status: ManagedSearchIndexStatus.fromJson(json['status'] as String),
    );
  }

  /// Serializes this model.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'status': status.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  DeleteManagedIndexResponse copyWith({
    String? id,
    String? name,
    ManagedSearchIndexStatus? status,
  }) => DeleteManagedIndexResponse(
    id: id ?? this.id,
    name: name ?? this.name,
    status: status ?? this.status,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeleteManagedIndexResponse &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          status == other.status;

  @override
  int get hashCode => Object.hashAll([id, name, status]);

  @override
  String toString() =>
      'DeleteManagedIndexResponse('
      'id: $id, '
      'name: $name, '
      'status: $status)';
}

/// Values for ManagedSearchIndexStatus.
enum ManagedSearchIndexStatus {
  /// Represents provisioning.
  provisioning('provisioning'),

  /// Represents ready.
  ready('ready'),

  /// Represents failed.
  failed('failed'),

  /// Represents deleting.
  deleting('deleting'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const ManagedSearchIndexStatus(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static ManagedSearchIndexStatus fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// The MistralEmbeddingModel wire payload.
@immutable
class MistralIndexEmbedding extends ManagedIndexEmbedding {
  /// Creates a [MistralIndexEmbedding].
  const MistralIndexEmbedding({
    required this.dimensions,
    this.distanceMetric,
    this.dtype,
    required this.name,
  });

  /// The fixed type discriminator.
  String get type => 'mistral';

  /// The dimensions field.
  final int dimensions;

  /// The distance_metric field.
  final SearchDistanceMetric? distanceMetric;

  /// The dtype field.
  final SearchVectorDType? dtype;

  /// The name field.
  final String name;

  /// Parses a [MistralIndexEmbedding] from JSON.
  factory MistralIndexEmbedding.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'mistral') {
      throw FormatException('MistralIndexEmbedding: unexpected type $value');
    }
    if (json['dimensions'] == null) {
      throw const FormatException('MistralIndexEmbedding: missing dimensions');
    }
    if (json['name'] == null) {
      throw const FormatException('MistralIndexEmbedding: missing name');
    }
    return MistralIndexEmbedding(
      dimensions: json['dimensions'] as int,
      distanceMetric: json['distance_metric'] == null
          ? null
          : SearchDistanceMetric.fromJson(json['distance_metric'] as String),
      dtype: json['dtype'] == null
          ? null
          : SearchVectorDType.fromJson(json['dtype'] as String),
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'dimensions': dimensions,
    if (distanceMetric != null) 'distance_metric': distanceMetric!.toJson(),
    if (dtype != null) 'dtype': dtype!.toJson(),
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  MistralIndexEmbedding copyWith({
    int? dimensions,
    Object? distanceMetric = unsetCopyWithValue,
    Object? dtype = unsetCopyWithValue,
    String? name,
  }) => MistralIndexEmbedding(
    dimensions: dimensions ?? this.dimensions,
    distanceMetric: distanceMetric == unsetCopyWithValue
        ? this.distanceMetric
        : distanceMetric as SearchDistanceMetric?,
    dtype: dtype == unsetCopyWithValue
        ? this.dtype
        : dtype as SearchVectorDType?,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MistralIndexEmbedding &&
          runtimeType == other.runtimeType &&
          dimensions == other.dimensions &&
          distanceMetric == other.distanceMetric &&
          dtype == other.dtype &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([dimensions, distanceMetric, dtype, name]);

  @override
  String toString() =>
      'MistralIndexEmbedding('
      'dimensions: $dimensions, '
      'distanceMetric: $distanceMetric, '
      'dtype: $dtype, '
      'name: $name)';
}

/// The CustomEmbeddingModel wire payload.
@immutable
class CustomIndexEmbedding extends ManagedIndexEmbedding {
  /// Creates a [CustomIndexEmbedding].
  const CustomIndexEmbedding({
    required this.dimensions,
    this.distanceMetric,
    this.dtype,
    required this.name,
  });

  /// The fixed type discriminator.
  String get type => 'custom';

  /// The dimensions field.
  final int dimensions;

  /// The distance_metric field.
  final SearchDistanceMetric? distanceMetric;

  /// The dtype field.
  final SearchVectorDType? dtype;

  /// The name field.
  final String name;

  /// Parses a [CustomIndexEmbedding] from JSON.
  factory CustomIndexEmbedding.fromJson(Map<String, dynamic> json) {
    if (json['type'] case final value? when value != 'custom') {
      throw FormatException('CustomIndexEmbedding: unexpected type $value');
    }
    if (json['dimensions'] == null) {
      throw const FormatException('CustomIndexEmbedding: missing dimensions');
    }
    if (json['name'] == null) {
      throw const FormatException('CustomIndexEmbedding: missing name');
    }
    return CustomIndexEmbedding(
      dimensions: json['dimensions'] as int,
      distanceMetric: json['distance_metric'] == null
          ? null
          : SearchDistanceMetric.fromJson(json['distance_metric'] as String),
      dtype: json['dtype'] == null
          ? null
          : SearchVectorDType.fromJson(json['dtype'] as String),
      name: json['name'] as String,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    'dimensions': dimensions,
    if (distanceMetric != null) 'distance_metric': distanceMetric!.toJson(),
    if (dtype != null) 'dtype': dtype!.toJson(),
    'name': name,
  };

  /// Creates a copy with the given fields replaced.
  CustomIndexEmbedding copyWith({
    int? dimensions,
    Object? distanceMetric = unsetCopyWithValue,
    Object? dtype = unsetCopyWithValue,
    String? name,
  }) => CustomIndexEmbedding(
    dimensions: dimensions ?? this.dimensions,
    distanceMetric: distanceMetric == unsetCopyWithValue
        ? this.distanceMetric
        : distanceMetric as SearchDistanceMetric?,
    dtype: dtype == unsetCopyWithValue
        ? this.dtype
        : dtype as SearchVectorDType?,
    name: name ?? this.name,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CustomIndexEmbedding &&
          runtimeType == other.runtimeType &&
          dimensions == other.dimensions &&
          distanceMetric == other.distanceMetric &&
          dtype == other.dtype &&
          name == other.name;

  @override
  int get hashCode => Object.hashAll([dimensions, distanceMetric, dtype, name]);

  @override
  String toString() =>
      'CustomIndexEmbedding('
      'dimensions: $dimensions, '
      'distanceMetric: $distanceMetric, '
      'dtype: $dtype, '
      'name: $name)';
}

/// Values for SearchDistanceMetric.
enum SearchDistanceMetric {
  /// Represents cosine.
  cosine('cosine'),

  /// Represents inner_product.
  innerProduct('inner_product'),

  /// Represents l2.
  l2('l2'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const SearchDistanceMetric(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static SearchDistanceMetric fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// Values for SearchVectorDType.
enum SearchVectorDType {
  /// Represents float16.
  float16('float16'),

  /// Represents float32.
  float32('float32'),

  /// Fallback for an unrecognized server value.
  unknown('unknown');

  const SearchVectorDType(this.value);

  /// The wire value.
  final String value;

  /// Parses a wire value.
  static SearchVectorDType fromJson(String value) =>
      values.firstWhere((item) => item.value == value, orElse: () => unknown);

  /// Serializes the value.
  String toJson() => value;
}

/// A field in the document or chunk schema of a managed index.
///
/// Each field uses the same wire properties. The server interprets its
/// default value according to [type] and picks an index default when [indexed]
/// is omitted.
@immutable
class ManagedIndexField {
  /// Creates a field definition.
  const ManagedIndexField({
    required this.type,
    this.defaultValue,
    this.indexed,
    this.isRequired,
    this.system,
  });

  /// Wire type, such as text, keyword[], or dense_vector.
  final String type;

  /// Optional JSON value used when the field is absent on ingestion.
  final Object? defaultValue;

  /// Whether this field participates in indexing.
  final bool? indexed;

  /// Whether the schema requires the field.
  final bool? isRequired;

  /// Whether the field is supplied by the index.
  final bool? system;

  /// Parses a field definition.
  factory ManagedIndexField.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String?;
    if (type == null) {
      throw const FormatException('ManagedIndexField: missing type');
    }
    return ManagedIndexField(
      type: type,
      defaultValue: json['default'],
      indexed: json['indexed'] as bool?,
      isRequired: json['required'] as bool?,
      system: json['system'] as bool?,
    );
  }

  /// Serializes the field definition.
  Map<String, dynamic> toJson() => {
    'type': type,
    'default': ?defaultValue,
    'indexed': ?indexed,
    'required': ?isRequired,
    'system': ?system,
  };

  /// Creates a copy with the given fields replaced.
  ManagedIndexField copyWith({
    String? type,
    Object? defaultValue = unsetCopyWithValue,
    Object? indexed = unsetCopyWithValue,
    Object? isRequired = unsetCopyWithValue,
    Object? system = unsetCopyWithValue,
  }) => ManagedIndexField(
    type: type ?? this.type,
    defaultValue: defaultValue == unsetCopyWithValue
        ? this.defaultValue
        : defaultValue,
    indexed: indexed == unsetCopyWithValue ? this.indexed : indexed as bool?,
    isRequired: isRequired == unsetCopyWithValue
        ? this.isRequired
        : isRequired as bool?,
    system: system == unsetCopyWithValue ? this.system : system as bool?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ManagedIndexField &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          valuesDeepEqual(defaultValue, other.defaultValue) &&
          indexed == other.indexed &&
          isRequired == other.isRequired &&
          system == other.system;

  @override
  int get hashCode => Object.hash(
    type,
    valueDeepHashCode(defaultValue),
    indexed,
    isRequired,
    system,
  );

  @override
  String toString() =>
      'ManagedIndexField(type: $type, defaultValue: $defaultValue, indexed: $indexed, '
      'isRequired: $isRequired, system: $system)';
}
