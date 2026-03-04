import 'package:meta/meta.dart';

import '../../utils/equality_helpers.dart';

/// Configuration settings for a collection.
///
/// Contains optional configurations for HNSW index, SPANN index,
/// and embedding functions.
@immutable
class CollectionConfiguration {
  /// HNSW index configuration.
  final Map<String, dynamic>? hnsw;

  /// SPANN index configuration.
  final Map<String, dynamic>? spann;

  /// Embedding function configuration.
  final Map<String, dynamic>? embeddingFunction;

  /// Creates a collection configuration.
  const CollectionConfiguration({
    this.hnsw,
    this.spann,
    this.embeddingFunction,
  });

  /// Creates a collection configuration from JSON.
  factory CollectionConfiguration.fromJson(Map<String, dynamic> json) {
    return CollectionConfiguration(
      hnsw: json['hnsw'] as Map<String, dynamic>?,
      spann: json['spann'] as Map<String, dynamic>?,
      embeddingFunction: json['embedding_function'] as Map<String, dynamic>?,
    );
  }

  /// Converts this configuration to JSON.
  Map<String, dynamic> toJson() {
    return {
      if (hnsw != null) 'hnsw': hnsw,
      if (spann != null) 'spann': spann,
      if (embeddingFunction != null) 'embedding_function': embeddingFunction,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CollectionConfiguration &&
          runtimeType == other.runtimeType &&
          mapsEqual(hnsw, other.hnsw) &&
          mapsEqual(spann, other.spann) &&
          mapsEqual(embeddingFunction, other.embeddingFunction);

  @override
  int get hashCode =>
      Object.hash(mapHash(hnsw), mapHash(spann), mapHash(embeddingFunction));

  @override
  String toString() =>
      'CollectionConfiguration('
      'hnsw: ${hnsw != null}, '
      'spann: ${spann != null}, '
      'embeddingFunction: ${embeddingFunction != null})';
}
