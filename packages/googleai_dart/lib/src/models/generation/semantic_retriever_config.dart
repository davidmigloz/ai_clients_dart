import '../content/content.dart';
import '../copy_with_sentinel.dart';
import 'metadata_filter.dart';

/// Configuration for retrieving grounding content from a `Corpus` or
/// `Document` created using the Semantic Retriever API.
class SemanticRetrieverConfig {
  /// Optional. Maximum number of relevant `Chunk`s to retrieve.
  final int? maxChunksCount;

  /// Optional. Filters for selecting `Document`s and/or `Chunk`s from the
  /// resource.
  final List<MetadataFilter>? metadataFilters;

  /// Optional. Minimum relevance score for retrieved relevant `Chunk`s.
  final double? minimumRelevanceScore;

  /// Required. Query to use for matching `Chunk`s in the given resource by
  /// similarity.
  final Content query;

  /// Required. Name of the resource for retrieval.
  /// Example: `corpora/123` or `corpora/123/documents/abc`.
  final String source;

  /// Creates a [SemanticRetrieverConfig].
  const SemanticRetrieverConfig({
    this.maxChunksCount,
    this.metadataFilters,
    this.minimumRelevanceScore,
    required this.query,
    required this.source,
  });

  /// Creates a [SemanticRetrieverConfig] from JSON.
  factory SemanticRetrieverConfig.fromJson(Map<String, dynamic> json) {
    return SemanticRetrieverConfig(
      maxChunksCount: json['maxChunksCount'] as int?,
      metadataFilters: json['metadataFilters'] != null
          ? (json['metadataFilters'] as List<dynamic>)
                .map(
                  (item) =>
                      MetadataFilter.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      minimumRelevanceScore: json['minimumRelevanceScore'] != null
          ? (json['minimumRelevanceScore'] as num).toDouble()
          : null,
      query: Content.fromJson(json['query'] as Map<String, dynamic>),
      source: json['source'] as String,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'maxChunksCount': ?maxChunksCount,
    if (metadataFilters != null)
      'metadataFilters': metadataFilters!.map((item) => item.toJson()).toList(),
    'minimumRelevanceScore': ?minimumRelevanceScore,
    'query': query.toJson(),
    'source': source,
  };

  /// Creates a copy with replaced values.
  SemanticRetrieverConfig copyWith({
    Object? maxChunksCount = unsetCopyWithValue,
    Object? metadataFilters = unsetCopyWithValue,
    Object? minimumRelevanceScore = unsetCopyWithValue,
    Object? query = unsetCopyWithValue,
    Object? source = unsetCopyWithValue,
  }) {
    return SemanticRetrieverConfig(
      maxChunksCount: maxChunksCount == unsetCopyWithValue
          ? this.maxChunksCount
          : maxChunksCount as int?,
      metadataFilters: metadataFilters == unsetCopyWithValue
          ? this.metadataFilters
          : metadataFilters as List<MetadataFilter>?,
      minimumRelevanceScore: minimumRelevanceScore == unsetCopyWithValue
          ? this.minimumRelevanceScore
          : minimumRelevanceScore as double?,
      query: query == unsetCopyWithValue ? this.query : query! as Content,
      source: source == unsetCopyWithValue ? this.source : source! as String,
    );
  }
}
