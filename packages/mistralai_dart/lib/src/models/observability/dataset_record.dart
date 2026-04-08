import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'conversation_payload.dart';
import 'conversation_source.dart';

/// A record within an observability dataset.
@immutable
class DatasetRecord {
  /// Unique identifier.
  final String id;

  /// When the record was created.
  final DateTime createdAt;

  /// When the record was last updated.
  final DateTime updatedAt;

  /// When the record was deleted (null if active).
  final DateTime? deletedAt;

  /// The dataset this record belongs to.
  final String datasetId;

  /// The conversation payload.
  final ConversationPayload payload;

  /// Additional properties (free-form).
  final Map<String, dynamic> properties;

  /// Source of the conversation.
  final ConversationSource source;

  /// Creates a [DatasetRecord].
  DatasetRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.datasetId,
    required this.payload,
    required Map<String, dynamic> properties,
    required this.source,
  }) : properties = Map.unmodifiable(properties);

  /// Creates a [DatasetRecord] from JSON.
  factory DatasetRecord.fromJson(Map<String, dynamic> json) => DatasetRecord(
    id: json['id'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['created_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    updatedAt:
        DateTime.tryParse(json['updated_at'] as String? ?? '') ??
        DateTime.fromMillisecondsSinceEpoch(0, isUtc: true),
    deletedAt: json['deleted_at'] != null
        ? DateTime.tryParse(json['deleted_at'] as String)
        : null,
    datasetId: json['dataset_id'] as String? ?? '',
    payload: ConversationPayload.fromJson(
      json['payload'] as Map<String, dynamic>? ?? {},
    ),
    properties: Map<String, dynamic>.from(json['properties'] as Map? ?? {}),
    source: ConversationSource.fromJson(json['source'] as String?),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'deleted_at': deletedAt?.toIso8601String(),
    'dataset_id': datasetId,
    'payload': payload.toJson(),
    'properties': Map<String, dynamic>.from(properties),
    'source': source.value,
  };

  /// Creates a copy with replaced values.
  DatasetRecord copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Object? deletedAt = unsetCopyWithValue,
    String? datasetId,
    ConversationPayload? payload,
    Map<String, dynamic>? properties,
    ConversationSource? source,
  }) {
    return DatasetRecord(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt == unsetCopyWithValue
          ? this.deletedAt
          : deletedAt as DateTime?,
      datasetId: datasetId ?? this.datasetId,
      payload: payload ?? this.payload,
      properties: properties ?? this.properties,
      source: source ?? this.source,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! DatasetRecord) return false;
    if (runtimeType != other.runtimeType) return false;
    return id == other.id &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        deletedAt == other.deletedAt &&
        datasetId == other.datasetId &&
        payload == other.payload &&
        mapsDeepEqual(properties, other.properties) &&
        source == other.source;
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    datasetId,
    payload,
    mapDeepHashCode(properties),
    source,
  );

  @override
  String toString() =>
      'DatasetRecord(id: $id, datasetId: $datasetId, source: ${source.value})';
}
