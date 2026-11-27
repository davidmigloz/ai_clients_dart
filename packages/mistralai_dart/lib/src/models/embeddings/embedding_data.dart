import 'package:meta/meta.dart';

import '../common/equality_helpers.dart';

/// A single embedding result.
@immutable
class EmbeddingData {
  /// The object type (always "embedding").
  final String object;

  /// The index of this embedding in the list of results.
  final int index;

  /// The embedding vector.
  ///
  /// Numeric elements returned by the API. Empty for base64-encoded results.
  final List<double> embedding;

  /// Encoded embedding when the API returns a base64 string.
  ///
  /// The byte layout depends on the requested output data type.
  final String? embeddingBase64;

  /// Creates an [EmbeddingData].
  const EmbeddingData({
    required this.object,
    required this.index,
    required this.embedding,
  }) : embeddingBase64 = null;

  /// Creates an embedding from the encoded value returned by the API.
  const EmbeddingData.base64({
    required this.object,
    required this.index,
    required String this.embeddingBase64,
  }) : embedding = const [];

  /// Creates an [EmbeddingData] from JSON.
  factory EmbeddingData.fromJson(Map<String, dynamic> json) {
    final object = json['object'] as String? ?? 'embedding';
    final index = json['index'] as int? ?? 0;
    final raw = json['embedding'];
    if (raw is String) {
      return EmbeddingData.base64(
        object: object,
        index: index,
        embeddingBase64: raw,
      );
    }
    return EmbeddingData(
      object: object,
      index: index,
      embedding:
          (raw as List<dynamic>?)?.map((e) => (e as num).toDouble()).toList() ??
          [],
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'object': object,
    'index': index,
    'embedding': embeddingBase64 ?? embedding,
  };

  /// Creates a copy with replaced values.
  ///
  /// Pass [embedding] or [embeddingBase64] to choose the vector representation.
  EmbeddingData copyWith({
    String? object,
    int? index,
    List<double>? embedding,
    String? embeddingBase64,
  }) {
    if (embedding != null && embeddingBase64 != null) {
      throw ArgumentError('Provide either embedding or embeddingBase64');
    }
    final encoded =
        embeddingBase64 ?? (embedding == null ? this.embeddingBase64 : null);
    if (encoded != null) {
      return EmbeddingData.base64(
        object: object ?? this.object,
        index: index ?? this.index,
        embeddingBase64: encoded,
      );
    }
    return EmbeddingData(
      object: object ?? this.object,
      index: index ?? this.index,
      embedding: embedding ?? this.embedding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmbeddingData &&
          runtimeType == other.runtimeType &&
          object == other.object &&
          index == other.index &&
          embeddingBase64 == other.embeddingBase64 &&
          listsEqual(embedding, other.embedding);

  @override
  int get hashCode =>
      Object.hash(object, index, listHash(embedding), embeddingBase64);

  @override
  String toString() =>
      'EmbeddingData(object: $object, index: $index, embedding: '
      '${embeddingBase64 == null ? "${embedding.length} dims" : "base64"})';
}
