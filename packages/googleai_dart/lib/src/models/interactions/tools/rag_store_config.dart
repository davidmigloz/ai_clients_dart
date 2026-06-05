import '../../copy_with_sentinel.dart';

/// Configuration for a RagStore-backed retrieval.
class RagStoreConfig {
  /// Optional. The representation of the rag source.
  final List<RagResource>? ragResources;

  /// Optional. The retrieval config for the Rag query.
  final RagRetrievalConfig? ragRetrievalConfig;

  /// Optional. (Deprecated) Number of top k results to return from the
  /// selected corpora.
  final int? similarityTopK;

  /// Optional. (Deprecated) Only return results with vector distance smaller
  /// than the threshold.
  final double? vectorDistanceThreshold;

  /// Creates a [RagStoreConfig] instance.
  const RagStoreConfig({
    this.ragResources,
    this.ragRetrievalConfig,
    this.similarityTopK,
    this.vectorDistanceThreshold,
  });

  /// Creates a [RagStoreConfig] from JSON.
  factory RagStoreConfig.fromJson(Map<String, dynamic> json) => RagStoreConfig(
    ragResources: (json['rag_resources'] as List<dynamic>?)
        ?.map((e) => RagResource.fromJson(e as Map<String, dynamic>))
        .toList(),
    ragRetrievalConfig: json['rag_retrieval_config'] != null
        ? RagRetrievalConfig.fromJson(
            json['rag_retrieval_config'] as Map<String, dynamic>,
          )
        : null,
    similarityTopK: json['similarity_top_k'] as int?,
    vectorDistanceThreshold: (json['vector_distance_threshold'] as num?)
        ?.toDouble(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (ragResources != null)
      'rag_resources': ragResources!.map((e) => e.toJson()).toList(),
    if (ragRetrievalConfig != null)
      'rag_retrieval_config': ragRetrievalConfig!.toJson(),
    if (similarityTopK != null) 'similarity_top_k': similarityTopK,
    if (vectorDistanceThreshold != null)
      'vector_distance_threshold': vectorDistanceThreshold,
  };

  /// Creates a copy with replaced values.
  RagStoreConfig copyWith({
    Object? ragResources = unsetCopyWithValue,
    Object? ragRetrievalConfig = unsetCopyWithValue,
    Object? similarityTopK = unsetCopyWithValue,
    Object? vectorDistanceThreshold = unsetCopyWithValue,
  }) {
    return RagStoreConfig(
      ragResources: ragResources == unsetCopyWithValue
          ? this.ragResources
          : ragResources as List<RagResource>?,
      ragRetrievalConfig: ragRetrievalConfig == unsetCopyWithValue
          ? this.ragRetrievalConfig
          : ragRetrievalConfig as RagRetrievalConfig?,
      similarityTopK: similarityTopK == unsetCopyWithValue
          ? this.similarityTopK
          : similarityTopK as int?,
      vectorDistanceThreshold: vectorDistanceThreshold == unsetCopyWithValue
          ? this.vectorDistanceThreshold
          : vectorDistanceThreshold as double?,
    );
  }
}

/// A representation of a RagStore source.
class RagResource {
  /// Optional. RagCorpora resource name.
  final String? ragCorpus;

  /// Optional. The files to use, which should be in the same `ragCorpus`.
  final List<String>? ragFileIds;

  /// Creates a [RagResource] instance.
  const RagResource({this.ragCorpus, this.ragFileIds});

  /// Creates a [RagResource] from JSON.
  factory RagResource.fromJson(Map<String, dynamic> json) => RagResource(
    ragCorpus: json['rag_corpus'] as String?,
    ragFileIds: (json['rag_file_ids'] as List<dynamic>?)?.cast<String>(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (ragCorpus != null) 'rag_corpus': ragCorpus,
    if (ragFileIds != null) 'rag_file_ids': ragFileIds,
  };

  /// Creates a copy with replaced values.
  RagResource copyWith({
    Object? ragCorpus = unsetCopyWithValue,
    Object? ragFileIds = unsetCopyWithValue,
  }) {
    return RagResource(
      ragCorpus: ragCorpus == unsetCopyWithValue
          ? this.ragCorpus
          : ragCorpus as String?,
      ragFileIds: ragFileIds == unsetCopyWithValue
          ? this.ragFileIds
          : ragFileIds as List<String>?,
    );
  }
}

/// Retrieval config for a Rag query.
class RagRetrievalConfig {
  /// Optional. Config for filters.
  final Filter? filter;

  /// Optional. Config for Hybrid Search.
  final HybridSearch? hybridSearch;

  /// Optional. Config for ranking and reranking.
  final RankService? ranking;

  /// Optional. The number of contexts to retrieve.
  final int? topK;

  /// Creates a [RagRetrievalConfig] instance.
  const RagRetrievalConfig({
    this.filter,
    this.hybridSearch,
    this.ranking,
    this.topK,
  });

  /// Creates a [RagRetrievalConfig] from JSON.
  factory RagRetrievalConfig.fromJson(Map<String, dynamic> json) =>
      RagRetrievalConfig(
        filter: json['filter'] != null
            ? Filter.fromJson(json['filter'] as Map<String, dynamic>)
            : null,
        hybridSearch: json['hybrid_search'] != null
            ? HybridSearch.fromJson(
                json['hybrid_search'] as Map<String, dynamic>,
              )
            : null,
        ranking: json['ranking'] != null
            ? RankService.fromJson(json['ranking'] as Map<String, dynamic>)
            : null,
        topK: json['top_k'] as int?,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (filter != null) 'filter': filter!.toJson(),
    if (hybridSearch != null) 'hybrid_search': hybridSearch!.toJson(),
    if (ranking != null) 'ranking': ranking!.toJson(),
    if (topK != null) 'top_k': topK,
  };

  /// Creates a copy with replaced values.
  RagRetrievalConfig copyWith({
    Object? filter = unsetCopyWithValue,
    Object? hybridSearch = unsetCopyWithValue,
    Object? ranking = unsetCopyWithValue,
    Object? topK = unsetCopyWithValue,
  }) {
    return RagRetrievalConfig(
      filter: filter == unsetCopyWithValue ? this.filter : filter as Filter?,
      hybridSearch: hybridSearch == unsetCopyWithValue
          ? this.hybridSearch
          : hybridSearch as HybridSearch?,
      ranking: ranking == unsetCopyWithValue
          ? this.ranking
          : ranking as RankService?,
      topK: topK == unsetCopyWithValue ? this.topK : topK as int?,
    );
  }
}

/// Filter config for a Rag retrieval.
class Filter {
  /// Optional. String for metadata filtering.
  final String? metadataFilter;

  /// Optional. Only returns contexts with vector distance smaller than the
  /// threshold.
  final double? vectorDistanceThreshold;

  /// Optional. Only returns contexts with vector similarity larger than the
  /// threshold.
  final double? vectorSimilarityThreshold;

  /// Creates a [Filter] instance.
  const Filter({
    this.metadataFilter,
    this.vectorDistanceThreshold,
    this.vectorSimilarityThreshold,
  });

  /// Creates a [Filter] from JSON.
  factory Filter.fromJson(Map<String, dynamic> json) => Filter(
    metadataFilter: json['metadata_filter'] as String?,
    vectorDistanceThreshold: (json['vector_distance_threshold'] as num?)
        ?.toDouble(),
    vectorSimilarityThreshold: (json['vector_similarity_threshold'] as num?)
        ?.toDouble(),
  );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (metadataFilter != null) 'metadata_filter': metadataFilter,
    if (vectorDistanceThreshold != null)
      'vector_distance_threshold': vectorDistanceThreshold,
    if (vectorSimilarityThreshold != null)
      'vector_similarity_threshold': vectorSimilarityThreshold,
  };

  /// Creates a copy with replaced values.
  Filter copyWith({
    Object? metadataFilter = unsetCopyWithValue,
    Object? vectorDistanceThreshold = unsetCopyWithValue,
    Object? vectorSimilarityThreshold = unsetCopyWithValue,
  }) {
    return Filter(
      metadataFilter: metadataFilter == unsetCopyWithValue
          ? this.metadataFilter
          : metadataFilter as String?,
      vectorDistanceThreshold: vectorDistanceThreshold == unsetCopyWithValue
          ? this.vectorDistanceThreshold
          : vectorDistanceThreshold as double?,
      vectorSimilarityThreshold: vectorSimilarityThreshold == unsetCopyWithValue
          ? this.vectorSimilarityThreshold
          : vectorSimilarityThreshold as double?,
    );
  }
}

/// Config for Hybrid Search.
class HybridSearch {
  /// Optional. Alpha value controls the weight between dense and sparse vector
  /// search results.
  final double? alpha;

  /// Creates a [HybridSearch] instance.
  const HybridSearch({this.alpha});

  /// Creates a [HybridSearch] from JSON.
  factory HybridSearch.fromJson(Map<String, dynamic> json) =>
      HybridSearch(alpha: (json['alpha'] as num?)?.toDouble());

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {if (alpha != null) 'alpha': alpha};

  /// Creates a copy with replaced values.
  HybridSearch copyWith({Object? alpha = unsetCopyWithValue}) {
    return HybridSearch(
      alpha: alpha == unsetCopyWithValue ? this.alpha : alpha as double?,
    );
  }
}

/// Config for the Rank Service used to rank and rerank retrieval results.
class RankService {
  /// Optional. The model name of the rank service.
  final String? modelName;

  /// Creates a [RankService] instance.
  const RankService({this.modelName});

  /// The ranking config discriminator. Per the spec this is a required
  /// `const`, so it is always `rank_service` and not user-configurable.
  String get rankingConfig => 'rank_service';

  /// Creates a [RankService] from JSON.
  factory RankService.fromJson(Map<String, dynamic> json) =>
      RankService(modelName: json['model_name'] as String?);

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (modelName != null) 'model_name': modelName,
    'ranking_config': rankingConfig,
  };

  /// Creates a copy with replaced values.
  RankService copyWith({Object? modelName = unsetCopyWithValue}) {
    return RankService(
      modelName: modelName == unsetCopyWithValue
          ? this.modelName
          : modelName as String?,
    );
  }
}
