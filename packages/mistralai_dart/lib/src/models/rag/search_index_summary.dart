import 'package:meta/meta.dart';

import 'search_index_status.dart';
import 'vespa_index_summary.dart';

/// Summary information about a registered RAG search index (beta).
@immutable
class SearchIndexSummary {
  /// The unique identifier of the search index.
  final String id;

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

  /// Summary of the backend-specific information about the index.
  ///
  /// Currently only Vespa indexes are supported.
  final VespaIndexSummary index;

  /// Creates a [SearchIndexSummary].
  const SearchIndexSummary({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.documentCount,
    required this.status,
    required this.createdAt,
    required this.modifiedAt,
    required this.index,
  });

  /// Creates a [SearchIndexSummary] from JSON.
  factory SearchIndexSummary.fromJson(Map<String, dynamic> json) =>
      SearchIndexSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        creatorId: json['creator_id'] as String,
        documentCount: json['document_count'] as int,
        status: SearchIndexStatus.fromJson(json['status'] as String?),
        createdAt: DateTime.parse(json['created_at'] as String),
        modifiedAt: DateTime.parse(json['modified_at'] as String),
        index: VespaIndexSummary.fromJson(
          json['index'] as Map<String, dynamic>,
        ),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'creator_id': creatorId,
    'document_count': documentCount,
    'status': status.toJson(),
    'created_at': createdAt.toIso8601String(),
    'modified_at': modifiedAt.toIso8601String(),
    'index': index.toJson(),
  };

  /// Creates a copy with the given fields replaced.
  SearchIndexSummary copyWith({
    String? id,
    String? name,
    String? creatorId,
    int? documentCount,
    SearchIndexStatus? status,
    DateTime? createdAt,
    DateTime? modifiedAt,
    VespaIndexSummary? index,
  }) => SearchIndexSummary(
    id: id ?? this.id,
    name: name ?? this.name,
    creatorId: creatorId ?? this.creatorId,
    documentCount: documentCount ?? this.documentCount,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    modifiedAt: modifiedAt ?? this.modifiedAt,
    index: index ?? this.index,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchIndexSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          creatorId == other.creatorId &&
          documentCount == other.documentCount &&
          status == other.status &&
          createdAt == other.createdAt &&
          modifiedAt == other.modifiedAt &&
          index == other.index;

  @override
  int get hashCode => Object.hash(
    id,
    name,
    creatorId,
    documentCount,
    status,
    createdAt,
    modifiedAt,
    index,
  );

  @override
  String toString() =>
      'SearchIndexSummary('
      'id: $id, name: $name, creatorId: $creatorId, '
      'documentCount: $documentCount, status: $status, '
      'createdAt: $createdAt, modifiedAt: $modifiedAt, index: $index)';
}
