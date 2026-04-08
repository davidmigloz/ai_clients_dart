import '../copy_with_sentinel.dart';
import '../metadata/modality_token_count.dart';

/// Metadata on the usage of the embedding request.
class EmbeddingUsageMetadata {
  /// Output only. Number of tokens in the prompt.
  final int? promptTokenCount;

  /// Output only. List of modalities that were processed in the request input.
  final List<ModalityTokenCount>? promptTokenDetails;

  /// Creates an [EmbeddingUsageMetadata].
  const EmbeddingUsageMetadata({
    this.promptTokenCount,
    this.promptTokenDetails,
  });

  /// Creates an [EmbeddingUsageMetadata] from JSON.
  factory EmbeddingUsageMetadata.fromJson(Map<String, dynamic> json) =>
      EmbeddingUsageMetadata(
        promptTokenCount: json['promptTokenCount'] as int?,
        promptTokenDetails: (json['promptTokenDetails'] as List<dynamic>?)
            ?.map((e) => ModalityTokenCount.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {
    if (promptTokenCount != null) 'promptTokenCount': promptTokenCount,
    if (promptTokenDetails != null)
      'promptTokenDetails': promptTokenDetails!.map((e) => e.toJson()).toList(),
  };

  /// Creates a copy with replaced values.
  EmbeddingUsageMetadata copyWith({
    Object? promptTokenCount = unsetCopyWithValue,
    Object? promptTokenDetails = unsetCopyWithValue,
  }) {
    return EmbeddingUsageMetadata(
      promptTokenCount: promptTokenCount == unsetCopyWithValue
          ? this.promptTokenCount
          : promptTokenCount as int?,
      promptTokenDetails: promptTokenDetails == unsetCopyWithValue
          ? this.promptTokenDetails
          : promptTokenDetails as List<ModalityTokenCount>?,
    );
  }
}
