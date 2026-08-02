import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Summary information about a schema within a RAG search index's detail
/// view (beta).
@immutable
class SearchIndexDetailSchema {
  /// The name of the schema.
  final String name;

  /// The unique identifier of the schema.
  final String id;

  /// The number of documents in the schema, or `null` if unknown.
  final int? documentCount;

  /// When the schema was last modified.
  final DateTime lastModified;

  /// The p95 query latency threshold (in seconds), or `null` if unset.
  final double? latencyP95SThreshold;

  /// Creates a [SearchIndexDetailSchema].
  const SearchIndexDetailSchema({
    required this.name,
    required this.id,
    required this.documentCount,
    required this.lastModified,
    required this.latencyP95SThreshold,
  });

  /// Creates a [SearchIndexDetailSchema] from JSON.
  factory SearchIndexDetailSchema.fromJson(Map<String, dynamic> json) =>
      SearchIndexDetailSchema(
        name: json['name'] as String,
        id: json['id'] as String,
        documentCount: json['document_count'] as int?,
        lastModified: DateTime.parse(json['last_modified'] as String),
        latencyP95SThreshold: (json['latency_p95_s_threshold'] as num?)
            ?.toDouble(),
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'id': id,
    'document_count': documentCount,
    'last_modified': lastModified.toIso8601String(),
    'latency_p95_s_threshold': latencyP95SThreshold,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  SearchIndexDetailSchema copyWith({
    String? name,
    String? id,
    Object? documentCount = unsetCopyWithValue,
    DateTime? lastModified,
    Object? latencyP95SThreshold = unsetCopyWithValue,
  }) => SearchIndexDetailSchema(
    name: name ?? this.name,
    id: id ?? this.id,
    documentCount: documentCount == unsetCopyWithValue
        ? this.documentCount
        : documentCount as int?,
    lastModified: lastModified ?? this.lastModified,
    latencyP95SThreshold: latencyP95SThreshold == unsetCopyWithValue
        ? this.latencyP95SThreshold
        : latencyP95SThreshold as double?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchIndexDetailSchema &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          id == other.id &&
          documentCount == other.documentCount &&
          lastModified == other.lastModified &&
          latencyP95SThreshold == other.latencyP95SThreshold;

  @override
  int get hashCode =>
      Object.hash(name, id, documentCount, lastModified, latencyP95SThreshold);

  @override
  String toString() =>
      'SearchIndexDetailSchema('
      'name: $name, id: $id, documentCount: $documentCount, '
      'lastModified: $lastModified, '
      'latencyP95SThreshold: $latencyP95SThreshold)';
}
