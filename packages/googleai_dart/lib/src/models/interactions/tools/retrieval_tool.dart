part of 'tools.dart';

/// A tool that enables file retrieval capabilities.
class RetrievalTool extends InteractionTool {
  @override
  String get type => 'retrieval';

  /// The types of file retrieval to enable.
  final List<String>? retrievalTypes;

  /// Configuration for Vertex AI Search.
  final VertexAISearchConfig? vertexAiSearchConfig;

  /// Creates a [RetrievalTool] instance.
  const RetrievalTool({this.retrievalTypes, this.vertexAiSearchConfig});

  /// Creates a [RetrievalTool] from JSON.
  factory RetrievalTool.fromJson(Map<String, dynamic> json) => RetrievalTool(
    retrievalTypes: (json['retrieval_types'] as List<dynamic>?)?.cast<String>(),
    vertexAiSearchConfig: json['vertex_ai_search_config'] != null
        ? VertexAISearchConfig.fromJson(
            json['vertex_ai_search_config'] as Map<String, dynamic>,
          )
        : null,
  );

  @override
  Map<String, dynamic> toJson() => {
    'type': type,
    if (retrievalTypes != null) 'retrieval_types': retrievalTypes,
    if (vertexAiSearchConfig != null)
      'vertex_ai_search_config': vertexAiSearchConfig!.toJson(),
  };

  /// Creates a copy with replaced values.
  RetrievalTool copyWith({
    Object? retrievalTypes = unsetCopyWithValue,
    Object? vertexAiSearchConfig = unsetCopyWithValue,
  }) {
    return RetrievalTool(
      retrievalTypes: retrievalTypes == unsetCopyWithValue
          ? this.retrievalTypes
          : retrievalTypes as List<String>?,
      vertexAiSearchConfig: vertexAiSearchConfig == unsetCopyWithValue
          ? this.vertexAiSearchConfig
          : vertexAiSearchConfig as VertexAISearchConfig?,
    );
  }
}
