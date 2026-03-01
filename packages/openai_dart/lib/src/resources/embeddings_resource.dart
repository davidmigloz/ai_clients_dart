import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/embeddings/embeddings.dart';
import 'base_resource.dart';

/// Resource for generating embeddings.
///
/// Embeddings are numerical representations of text that can be used
/// for similarity comparisons, search, clustering, and other ML tasks.
///
/// Access this resource through [OpenAIClient.embeddings].
///
/// ## Example
///
/// ```dart
/// final response = await client.embeddings.create(
///   EmbeddingRequest(
///     model: 'text-embedding-3-small',
///     input: EmbeddingInput.text('Hello, world!'),
///   ),
/// );
///
/// final vector = response.data.first.embedding;
/// print('Dimensions: ${vector.length}');
/// ```
class EmbeddingsResource extends ResourceBase {
  /// Creates an [EmbeddingsResource].
  EmbeddingsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/embeddings';

  /// Creates embeddings for the given input.
  ///
  /// Embeddings are vectors representing the semantic meaning of text.
  /// The resulting vectors can be used for:
  /// - Similarity search (finding similar documents)
  /// - Clustering (grouping related content)
  /// - Recommendations (finding related items)
  /// - Anomaly detection (finding outliers)
  /// - Classification (categorizing text)
  ///
  /// ## Parameters
  ///
  /// - [request] - The embedding request parameters.
  ///
  /// ## Returns
  ///
  /// An [EmbeddingResponse] containing the generated embeddings.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Single text embedding
  /// final response = await client.embeddings.create(
  ///   EmbeddingRequest(
  ///     model: 'text-embedding-3-small',
  ///     input: EmbeddingInput.text('Hello, world!'),
  ///   ),
  /// );
  ///
  /// // Multiple text embeddings
  /// final batchResponse = await client.embeddings.create(
  ///   EmbeddingRequest(
  ///     model: 'text-embedding-3-small',
  ///     input: EmbeddingInput.textList(['Hello', 'World']),
  ///     dimensions: 256, // Reduce dimensions for faster processing
  ///   ),
  /// );
  /// ```
  Future<EmbeddingResponse> create(
    EmbeddingRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return EmbeddingResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
