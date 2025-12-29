import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/embeddings/embed_request.dart';
import '../models/embeddings/embed_response.dart';
import 'base_resource.dart';

/// Resource for the Embeddings API.
///
/// Provides embedding generation for text inputs.
class EmbeddingsResource extends ResourceBase {
  /// Creates an [EmbeddingsResource].
  EmbeddingsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Generates embeddings for the input text.
  ///
  /// The [request] contains the model and input text(s).
  ///
  /// Returns an [EmbedResponse] containing the embedding vectors.
  Future<EmbedResponse> create({required EmbedRequest request}) async {
    final url = requestBuilder.buildUrl('/api/embed');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return EmbedResponse.fromJson(responseBody);
  }
}
