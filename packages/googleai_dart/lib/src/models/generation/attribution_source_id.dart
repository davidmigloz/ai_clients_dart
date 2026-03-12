import '../copy_with_sentinel.dart';
import 'grounding_passage_id.dart';
import 'semantic_retriever_chunk.dart';

/// Identifier for the source contributing to this attribution.
class AttributionSourceId {
  /// Identifier for an inline passage.
  final GroundingPassageId? groundingPassage;

  /// Identifier for a `Chunk` fetched via Semantic Retriever.
  final SemanticRetrieverChunk? semanticRetrieverChunk;

  /// Creates an [AttributionSourceId].
  const AttributionSourceId({
    this.groundingPassage,
    this.semanticRetrieverChunk,
  });

  /// Creates an [AttributionSourceId] from JSON.
  factory AttributionSourceId.fromJson(Map<String, dynamic> json) {
    return AttributionSourceId(
      groundingPassage: json['groundingPassage'] != null
          ? GroundingPassageId.fromJson(
              json['groundingPassage'] as Map<String, dynamic>,
            )
          : null,
      semanticRetrieverChunk: json['semanticRetrieverChunk'] != null
          ? SemanticRetrieverChunk.fromJson(
              json['semanticRetrieverChunk'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (groundingPassage != null)
      'groundingPassage': groundingPassage!.toJson(),
    if (semanticRetrieverChunk != null)
      'semanticRetrieverChunk': semanticRetrieverChunk!.toJson(),
  };

  /// Creates a copy with replaced values.
  AttributionSourceId copyWith({
    Object? groundingPassage = unsetCopyWithValue,
    Object? semanticRetrieverChunk = unsetCopyWithValue,
  }) {
    return AttributionSourceId(
      groundingPassage: groundingPassage == unsetCopyWithValue
          ? this.groundingPassage
          : groundingPassage as GroundingPassageId?,
      semanticRetrieverChunk: semanticRetrieverChunk == unsetCopyWithValue
          ? this.semanticRetrieverChunk
          : semanticRetrieverChunk as SemanticRetrieverChunk?,
    );
  }
}
