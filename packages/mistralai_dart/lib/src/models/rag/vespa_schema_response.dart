import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Information about a single Vespa schema within a search index (beta).
@immutable
class VespaSchemaResponse {
  /// The name of the schema.
  final String name;

  /// The number of documents in the schema, or `null` if unknown.
  final int? documentCount;

  /// Creates a [VespaSchemaResponse].
  const VespaSchemaResponse({required this.name, required this.documentCount});

  /// Creates a [VespaSchemaResponse] from JSON.
  factory VespaSchemaResponse.fromJson(Map<String, dynamic> json) =>
      VespaSchemaResponse(
        name: json['name'] as String,
        documentCount: json['document_count'] as int?,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'document_count': documentCount,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  VespaSchemaResponse copyWith({
    String? name,
    Object? documentCount = unsetCopyWithValue,
  }) => VespaSchemaResponse(
    name: name ?? this.name,
    documentCount: documentCount == unsetCopyWithValue
        ? this.documentCount
        : documentCount as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VespaSchemaResponse &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          documentCount == other.documentCount;

  @override
  int get hashCode => Object.hash(name, documentCount);

  @override
  String toString() =>
      'VespaSchemaResponse(name: $name, documentCount: $documentCount)';
}
