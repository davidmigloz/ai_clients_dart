import '../copy_with_sentinel.dart';
import 'content_embedding.dart';
import 'embedding_usage_metadata.dart';

/// Response from embedding content.
class EmbedContentResponse {
  /// The embedding for the content.
  final ContentEmbedding embedding;

  /// Output only. The usage metadata for the request.
  final EmbeddingUsageMetadata? usageMetadata;

  /// Creates an [EmbedContentResponse].
  const EmbedContentResponse({required this.embedding, this.usageMetadata});

  /// Creates an [EmbedContentResponse] from JSON.
  factory EmbedContentResponse.fromJson(Map<String, dynamic> json) =>
      EmbedContentResponse(
        embedding: ContentEmbedding.fromJson(
          json['embedding'] as Map<String, dynamic>,
        ),
        usageMetadata: json['usageMetadata'] != null
            ? EmbeddingUsageMetadata.fromJson(
                json['usageMetadata'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'embedding': embedding.toJson(),
    if (usageMetadata != null) 'usageMetadata': usageMetadata!.toJson(),
  };

  /// Creates a copy with replaced values.
  EmbedContentResponse copyWith({
    Object? embedding = unsetCopyWithValue,
    Object? usageMetadata = unsetCopyWithValue,
  }) {
    return EmbedContentResponse(
      embedding: embedding == unsetCopyWithValue
          ? this.embedding
          : embedding! as ContentEmbedding,
      usageMetadata: usageMetadata == unsetCopyWithValue
          ? this.usageMetadata
          : usageMetadata as EmbeddingUsageMetadata?,
    );
  }
}
