import 'package:meta/meta.dart';

import '../common/copy_with_sentinel.dart';

/// Request body describing a single Vespa schema when registering a search
/// index (beta).
@immutable
class CreateVespaSchemaRequest {
  /// The name of the schema.
  final String name;

  /// The number of documents in the schema, or `null` if unknown.
  final int? documentCount;

  /// Creates a [CreateVespaSchemaRequest].
  const CreateVespaSchemaRequest({required this.name, this.documentCount});

  /// Creates a [CreateVespaSchemaRequest] from JSON.
  factory CreateVespaSchemaRequest.fromJson(Map<String, dynamic> json) =>
      CreateVespaSchemaRequest(
        name: json['name'] as String,
        documentCount: json['document_count'] as int?,
      );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    if (documentCount != null) 'document_count': documentCount,
  };

  /// Creates a copy with the given fields replaced.
  ///
  /// Pass `null` for nullable fields to clear them explicitly; omit to keep.
  CreateVespaSchemaRequest copyWith({
    String? name,
    Object? documentCount = unsetCopyWithValue,
  }) => CreateVespaSchemaRequest(
    name: name ?? this.name,
    documentCount: documentCount == unsetCopyWithValue
        ? this.documentCount
        : documentCount as int?,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CreateVespaSchemaRequest &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          documentCount == other.documentCount;

  @override
  int get hashCode => Object.hash(name, documentCount);

  @override
  String toString() =>
      'CreateVespaSchemaRequest(name: $name, documentCount: $documentCount)';
}
