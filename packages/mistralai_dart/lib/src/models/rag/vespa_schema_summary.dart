import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Summary information about a Vespa schema within a RAG search index
/// summary (beta).
@immutable
class VespaSchemaSummary {
  /// The unique identifier of the schema.
  final String id;

  /// The name of the schema.
  final String name;

  /// The number of documents in the schema, or `null` if unknown.
  final int? documentCount;

  /// Creates a [VespaSchemaSummary].
  const VespaSchemaSummary({
    required this.id,
    required this.name,
    required this.documentCount,
  });

  /// Creates a [VespaSchemaSummary] from JSON.
  factory VespaSchemaSummary.fromJson(Map<String, dynamic> json) =>
      VespaSchemaSummary(
        id: json['id'] as String,
        name: json['name'] as String,
        documentCount: json['document_count'] as int?,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'document_count': documentCount,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  VespaSchemaSummary copyWith({
    String? id,
    String? name,
    Object? documentCount = unsetCopyWithValue,
  }) => VespaSchemaSummary(
    id: id ?? this.id,
    name: name ?? this.name,
    documentCount: documentCount == unsetCopyWithValue
        ? this.documentCount
        : documentCount as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VespaSchemaSummary &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          documentCount == other.documentCount;

  @override
  int get hashCode => Object.hash(id, name, documentCount);

  @override
  String toString() =>
      'VespaSchemaSummary(id: $id, name: $name, documentCount: $documentCount)';
}
