/// The index type of a Vespa schema field.
enum SchemaFieldIndex {
  /// Approximate nearest neighbor index (for embeddings).
  ann('ann'),

  /// BM25 text ranking index.
  bm25('bm25'),

  /// Plain attribute index.
  attribute('attribute'),

  /// Unknown index type (forward-compatible fallback).
  unknown('unknown');

  const SchemaFieldIndex(this.value);

  /// The string value of this type.
  final String value;

  /// Converts to a JSON value.
  String toJson() => value;

  /// Creates a [SchemaFieldIndex] from a JSON value.
  static SchemaFieldIndex fromJson(String? value) => fromString(value);

  /// Creates a [SchemaFieldIndex] from a string value.
  static SchemaFieldIndex fromString(String? value) {
    if (value == null) return SchemaFieldIndex.unknown;
    return SchemaFieldIndex.values.firstWhere(
      (e) => e.value == value,
      orElse: () => SchemaFieldIndex.unknown,
    );
  }
}
