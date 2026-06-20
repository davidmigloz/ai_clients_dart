import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/rag/create_search_index_info_request.dart';
import '../../models/rag/search_index_response.dart';
import '../base_resource.dart';

/// Resource for RAG search index operations (beta).
///
/// Search indexes store the documents and embeddings used for retrieval.
///
/// Example usage:
/// ```dart
/// // Get the search index info
/// final indexes = await client.rag.searchIndexes.list();
///
/// // Register (or re-register) a search index
/// final index = await client.rag.searchIndexes.register(
///   request: CreateSearchIndexInfoRequest(
///     name: 'My index',
///     index: const CreateVespaSearchIndexInfoRequest(
///       k8sCluster: 'cluster',
///       k8sNamespace: 'namespace',
///       vespaInstanceName: 'instance',
///       schemas: [],
///     ),
///   ),
/// );
/// ```
class SearchIndexesResource extends ResourceBase {
  /// Creates a [SearchIndexesResource].
  SearchIndexesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Gets the search index info.
  ///
  /// Maps to the official `get_search_indexes`
  /// (`GET /v1/rag/search_index`).
  Future<List<SearchIndexResponse>> list() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/rag/search_index');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as List<dynamic>;
    return responseBody
        .map((e) => SearchIndexResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Registers (or re-registers) a search index.
  ///
  /// Maps to the official `register_search_index`
  /// (`PUT /v1/rag/search_index`).
  Future<SearchIndexResponse> register({
    required CreateSearchIndexInfoRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/rag/search_index');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SearchIndexResponse.fromJson(responseBody);
  }
}
