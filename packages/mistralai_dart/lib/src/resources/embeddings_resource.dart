import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/embeddings/embedding_request.dart';
import '../models/embeddings/embedding_response.dart';
import 'base_resource.dart';

/// Resource for the Embeddings API.
///
/// Provides text embedding generation for semantic search, clustering,
/// and other NLP tasks.
///
/// Example usage:
/// ```dart
/// final response = await client.embeddings.create(
///   request: EmbeddingRequest.single(
///     model: 'mistral-embed',
///     input: 'Hello, world!',
///   ),
/// );
/// final embedding = response.data.first.embedding;
/// print('Embedding dimension: ${embedding.length}');
/// ```
class EmbeddingsResource extends ResourceBase {
  /// Creates an [EmbeddingsResource].
  EmbeddingsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Generates embeddings for the given input.
  ///
  /// The [request] contains the model and input text(s) to embed.
  ///
  /// Returns an [EmbeddingResponse] containing the embedding vectors.
  ///
  /// Throws [MistralException] if the request fails.
  ///
  /// Example with single input:
  /// ```dart
  /// final response = await client.embeddings.create(
  ///   request: EmbeddingRequest.single(
  ///     model: 'mistral-embed',
  ///     input: 'Hello, world!',
  ///   ),
  /// );
  /// ```
  ///
  /// Example with batch input:
  /// ```dart
  /// final response = await client.embeddings.create(
  ///   request: EmbeddingRequest.batch(
  ///     model: 'mistral-embed',
  ///     input: ['Hello', 'World'],
  ///   ),
  /// );
  /// ```
  Future<EmbeddingResponse> create({required EmbeddingRequest request}) async {
    final url = requestBuilder.buildUrl('/v1/embeddings');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return EmbeddingResponse.fromJson(responseBody);
  }
}
