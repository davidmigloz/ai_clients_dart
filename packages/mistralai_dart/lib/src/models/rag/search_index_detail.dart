import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';
import '../common/equality_helpers.dart';
import 'search_index_detail_schema.dart';
import 'search_index_status.dart';

/// Detailed information about a RAG search index (beta).
@immutable
class SearchIndexDetail {
  /// The human-readable name of the search index.
  final String name;

  /// The identifier of the user that created the search index.
  final String creatorId;

  /// The number of documents in the search index.
  final int documentCount;

  /// The status of the search index.
  final SearchIndexStatus status;

  /// When the search index was created.
  final DateTime createdAt;

  /// When the search index was last modified.
  final DateTime modifiedAt;

  /// The version of Vespa running the index, or `null` if unknown.
  final String? vespaVersion;

  /// Summary information about the schemas defined within the index.
  final List<SearchIndexDetailSchema> schemas;

  /// Creates a [SearchIndexDetail].
  const SearchIndexDetail({
    required this.name,
    required this.creatorId,
    required this.documentCount,
    required this.status,
    required this.createdAt,
    required this.modifiedAt,
    required this.vespaVersion,
    required this.schemas,
  });

  /// Creates a [SearchIndexDetail] from JSON.
  factory SearchIndexDetail.fromJson(Map<String, dynamic> json) =>
      SearchIndexDetail(
        name: json['name'] as String,
        creatorId: json['creator_id'] as String,
        documentCount: json['document_count'] as int,
        status: SearchIndexStatus.fromJson(json['status'] as String?),
        createdAt: DateTime.parse(json['created_at'] as String),
        modifiedAt: DateTime.parse(json['modified_at'] as String),
        vespaVersion: json['vespa_version'] as String?,
        schemas: (json['schemas'] as List<dynamic>)
            .map(
              (e) =>
                  SearchIndexDetailSchema.fromJson(e as Map<String, dynamic>),
            )
            .toList(),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'creator_id': creatorId,
    'document_count': documentCount,
    'status': status.toJson(),
    'created_at': createdAt.toIso8601String(),
    'modified_at': modifiedAt.toIso8601String(),
    'vespa_version': vespaVersion,
    'schemas': schemas.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  SearchIndexDetail copyWith({
    String? name,
    String? creatorId,
    int? documentCount,
    SearchIndexStatus? status,
    DateTime? createdAt,
    DateTime? modifiedAt,
    Object? vespaVersion = unsetCopyWithValue,
    List<SearchIndexDetailSchema>? schemas,
  }) => SearchIndexDetail(
    name: name ?? this.name,
    creatorId: creatorId ?? this.creatorId,
    documentCount: documentCount ?? this.documentCount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    vespaVersion: vespaVersion == unsetCopyWithValue
        ? this.vespaVersion
        : vespaVersion as String?,
    schemas: schemas ?? this.schemas,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchIndexDetail &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          creatorId == other.creatorId &&
          documentCount == other.documentCount &&
          status == other.status &&
          createdAt == other.createdAt &&
          modifiedAt == other.modifiedAt &&
          vespaVersion == other.vespaVersion &&
          listsEqual(schemas, other.schemas);

  @override
  int get hashCode => Object.hash(
    name,
    creatorId,
    documentCount,
    status,
    createdAt,
    modifiedAt,
    vespaVersion,
    listHash(schemas),
  );

  @override
  String toString() =>
      'SearchIndexDetail('
      'name: $name, creatorId: $creatorId, documentCount: $documentCount, '
      'status: $status, createdAt: $createdAt, modifiedAt: $modifiedAt, '
      'vespaVersion: $vespaVersion, schemas: ${schemas.length} items)';
}
