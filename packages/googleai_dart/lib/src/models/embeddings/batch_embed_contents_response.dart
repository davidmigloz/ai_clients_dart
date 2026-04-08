import '../copy_with_sentinel.dart';
import 'content_embedding.dart';
import 'embedding_usage_metadata.dart';

/// The response to a [BatchEmbedContentsRequest].
class BatchEmbedContentsResponse {
  /// Output only. The embeddings for each request, in the same order as
  /// provided in the batch request.
  final List<ContentEmbedding> embeddings;

  /// Output only. The usage metadata for the request.
  final EmbeddingUsageMetadata? usageMetadata;

  /// Creates a [BatchEmbedContentsResponse].
  const BatchEmbedContentsResponse({
    required this.embeddings,
    this.usageMetadata,
  });

  /// Creates a [BatchEmbedContentsResponse] from JSON.
  factory BatchEmbedContentsResponse.fromJson(Map<String, dynamic> json) =>
      BatchEmbedContentsResponse(
        embeddings: ((json['embeddings'] as List<dynamic>?) ?? [])
            .map((e) => ContentEmbedding.fromJson(e as Map<String, dynamic>))
            .toList(),
        usageMetadata: json['usageMetadata'] != null
            ? EmbeddingUsageMetadata.fromJson(
                json['usageMetadata'] as Map<String, dynamic>,
              )
            : null,
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    'embeddings': embeddings.map((e) => e.toJson()).toList(),
    if (usageMetadata != null) 'usageMetadata': usageMetadata!.toJson(),
  };

  /// Creates a copy with replaced values.
  BatchEmbedContentsResponse copyWith({
    Object? embeddings = unsetCopyWithValue,
    Object? usageMetadata = unsetCopyWithValue,
  }) {
    return BatchEmbedContentsResponse(
      embeddings: embeddings == unsetCopyWithValue
          ? this.embeddings
          : embeddings! as List<ContentEmbedding>,
      usageMetadata: usageMetadata == unsetCopyWithValue
          ? this.usageMetadata
          : usageMetadata as EmbeddingUsageMetadata?,
    );
  }
}
