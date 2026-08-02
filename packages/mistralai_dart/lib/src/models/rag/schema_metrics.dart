import 'package:meta/meta.dart';

/// Document metrics for a single schema, used when setting a RAG search
/// index's metrics while online (beta).
@immutable
class SchemaMetrics {
  /// The name of the schema.
  final String name;

  /// The number of documents in the schema.
  final int documentCount;

  /// Creates a [SchemaMetrics].
  const SchemaMetrics({required this.name, required this.documentCount});

  /// Creates a [SchemaMetrics] from JSON.
  factory SchemaMetrics.fromJson(Map<String, dynamic> json) => SchemaMetrics(
    name: json['name'] as String,
    documentCount: json['document_count'] as int,
  );

  /// Converts this object to JSON.
  Map<String, dynamic> toJson() => {
    'name': name,
    'document_count': documentCount,
  };

  /// Creates a copy with the given fields replaced.
  SchemaMetrics copyWith({String? name, int? documentCount}) => SchemaMetrics(
    name: name ?? this.name,
    documentCount: documentCount ?? this.documentCount,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SchemaMetrics &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          documentCount == other.documentCount;

  @override
  int get hashCode => Object.hash(name, documentCount);

  @override
  String toString() =>
      'SchemaMetrics(name: $name, documentCount: $documentCount)';
}
