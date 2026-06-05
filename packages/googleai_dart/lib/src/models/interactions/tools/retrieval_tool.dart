part of 'tools.dart';

/// A tool that enables file retrieval capabilities.
class RetrievalTool extends InteractionTool {
  @override
  String get type => 'retrieval';

  /// The types of file retrieval to enable.
  final List<String>? retrievalTypes;

  /// Configuration for Vertex AI Search.
  final VertexAISearchConfig? vertexAiSearchConfig;

  /// Configuration for ExaAISearch.
  final ExaAISearchConfig? exaAiSearchConfig;

  /// Configuration for ParallelAISearch.
  final ParallelAISearchConfig? parallelAiSearchConfig;

  /// Configuration for RagStore.
  final RagStoreConfig? ragStoreConfig;

  /// Creates a [RetrievalTool] instance.
  const RetrievalTool({
    this.retrievalTypes,
    this.vertexAiSearchConfig,
    this.exaAiSearchConfig,
    this.parallelAiSearchConfig,
    this.ragStoreConfig,
  });

  /// Creates a [RetrievalTool] from JSON.
  factory RetrievalTool.fromJson(Map<String, dynamic> json) => RetrievalTool(
    retrievalTypes: (json['retrieval_types'] as List<dynamic>?)?.cast<String>(),
    vertexAiSearchConfig: json['vertex_ai_search_config'] != null
        ? VertexAISearchConfig.fromJson(
            json['vertex_ai_search_config'] as Map<String, dynamic>,
          )
        : null,
    exaAiSearchConfig: json['exa_ai_search_config'] != null
        ? ExaAISearchConfig.fromJson(
            json['exa_ai_search_config'] as Map<String, dynamic>,
          )
        : null,
    parallelAiSearchConfig: json['parallel_ai_search_config'] != null
        ? ParallelAISearchConfig.fromJson(
            json['parallel_ai_search_config'] as Map<String, dynamic>,
          )
        : null,
    ragStoreConfig: json['rag_store_config'] != null
        ? RagStoreConfig.fromJson(
            json['rag_store_config'] as Map<String, dynamic>,
          )
        : null,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (retrievalTypes != null) 'retrieval_types': retrievalTypes,
    if (vertexAiSearchConfig != null)
      'vertex_ai_search_config': vertexAiSearchConfig!.toJson(),
    if (exaAiSearchConfig != null)
      'exa_ai_search_config': exaAiSearchConfig!.toJson(),
    if (parallelAiSearchConfig != null)
      'parallel_ai_search_config': parallelAiSearchConfig!.toJson(),
    if (ragStoreConfig != null) 'rag_store_config': ragStoreConfig!.toJson(),
  };

  /// Creates a copy with replaced values.
  RetrievalTool copyWith({
    Object? retrievalTypes = unsetCopyWithValue,
    Object? vertexAiSearchConfig = unsetCopyWithValue,
    Object? exaAiSearchConfig = unsetCopyWithValue,
    Object? parallelAiSearchConfig = unsetCopyWithValue,
    Object? ragStoreConfig = unsetCopyWithValue,
  }) {
    return RetrievalTool(
      retrievalTypes: retrievalTypes == unsetCopyWithValue
          ? this.retrievalTypes
          : retrievalTypes as List<String>?,
      vertexAiSearchConfig: vertexAiSearchConfig == unsetCopyWithValue
          ? this.vertexAiSearchConfig
          : vertexAiSearchConfig as VertexAISearchConfig?,
      exaAiSearchConfig: exaAiSearchConfig == unsetCopyWithValue
          ? this.exaAiSearchConfig
          : exaAiSearchConfig as ExaAISearchConfig?,
      parallelAiSearchConfig: parallelAiSearchConfig == unsetCopyWithValue
          ? this.parallelAiSearchConfig
          : parallelAiSearchConfig as ParallelAISearchConfig?,
      ragStoreConfig: ragStoreConfig == unsetCopyWithValue
          ? this.ragStoreConfig
          : ragStoreConfig as RagStoreConfig?,
    );
  }
}
