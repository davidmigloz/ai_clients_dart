import '../copy_with_sentinel.dart';

/// Identifier for a `Chunk` retrieved via Semantic Retriever specified in the
/// `GenerateAnswerRequest` using `SemanticRetrieverConfig`.
class SemanticRetrieverChunk {
  /// Output only. Name of the `Chunk` containing the attributed text.
  /// Example: `corpora/123/documents/abc/chunks/xyz`
  final String? chunk;

  /// Output only. Name of the source matching the request's
  /// `SemanticRetrieverConfig.source`.
  /// Example: `corpora/123` or `corpora/123/documents/abc`
  final String? source;

  /// Creates a [SemanticRetrieverChunk].
  const SemanticRetrieverChunk({this.chunk, this.source});

  /// Creates a [SemanticRetrieverChunk] from JSON.
  factory SemanticRetrieverChunk.fromJson(Map<String, dynamic> json) {
    return SemanticRetrieverChunk(
      chunk: json['chunk'] as String?,
      source: json['source'] as String?,
    );
  }

  /// Converts to JSON.
  Map<String, dynamic> toJson() => {'chunk': ?chunk, 'source': ?source};

  /// Creates a copy with replaced values.
  SemanticRetrieverChunk copyWith({
    Object? chunk = unsetCopyWithValue,
    Object? source = unsetCopyWithValue,
  }) {
    return SemanticRetrieverChunk(
      chunk: chunk == unsetCopyWithValue ? this.chunk : chunk as String?,
      source: source == unsetCopyWithValue ? this.source : source as String?,
    );
  }
}
