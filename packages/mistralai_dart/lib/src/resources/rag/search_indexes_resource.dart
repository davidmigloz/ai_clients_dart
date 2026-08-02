import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../models/rag/register_search_index_request.dart';
import '../../models/rag/register_search_index_response.dart';
import '../../models/rag/search_index_detail.dart';
import '../../models/rag/search_index_retrievable.dart';
import '../../models/rag/search_index_schema_detail.dart';
import '../../models/rag/search_index_schema_sd_file.dart';
import '../../models/rag/search_index_summary.dart';
import '../../models/rag/summary_field_response.dart';
import '../../models/rag/summary_language.dart';
import '../../models/rag/summary_stream_event.dart';
import '../../models/rag/update_index_metrics_request.dart';
import '../../models/rag/update_summary_request.dart';
import '../../utils/streaming_parser.dart';
import '../base_resource.dart';
import '../streaming_resource.dart';

/// Resource for RAG search index operations (beta).
///
/// Search indexes store the documents and embeddings used for retrieval.
/// Currently only Vespa-backed indexes are supported.
///
/// Example usage:
/// ```dart
/// // Register (or re-register) a search index
/// final registered = await client.rag.searchIndexes.register(
///   request: RegisterSearchIndexRequest(
///     name: 'My index',
///     index: RegisterVespaIndexRequest(
///       k8sCluster: 'cluster',
///       k8sNamespace: 'namespace',
///       vespaInstanceName: 'instance',
///       vespaVersion: '8.0.0',
///       queryUrl: 'https://vespa.example.com',
///       schemas: [],
///     ),
///   ),
/// );
///
/// // Fetch detailed information about the index
/// final detail = await client.rag.searchIndexes.getDetail(
///   indexId: registered.id,
/// );
/// ```
class SearchIndexesResource extends ResourceBase with StreamingResource {
  /// Creates a [SearchIndexesResource].
  SearchIndexesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Registers (or re-registers) a search index.
  ///
  /// Maps to the official `register_search_index`
  /// (`PUT /v1/rag/indexes`).
  Future<RegisterSearchIndexResponse> register({
    required RegisterSearchIndexRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/rag/indexes');
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return RegisterSearchIndexResponse.fromJson(responseBody);
  }

  /// Unregisters a search index.
  ///
  /// Maps to the official `unregister_search_index`
  /// (`DELETE /v1/rag/indexes/index/{index_id}`).
  Future<void> unregister({required String indexId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/rag/indexes/index/$indexId');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);

    await interceptorChain.execute(httpRequest);
  }

  /// Gets detailed information about a search index.
  ///
  /// Maps to the official `get_index_details`
  /// (`GET /v1/rag/indexes/index/{index_id}/detail`).
  Future<SearchIndexDetail> getDetail({required String indexId}) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/detail',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SearchIndexDetail.fromJson(responseBody);
  }

  /// Updates the metrics of a search index.
  ///
  /// Maps to the official `update_index_metrics`
  /// (`PUT /v1/rag/indexes/index/{index_id}/metrics`).
  Future<void> updateMetrics({
    required String indexId,
    required UpdateIndexMetricsRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/metrics',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }

  /// Lists summaries of all registered search indexes.
  ///
  /// Maps to the official `get_index_summaries`
  /// (`GET /v1/rag/indexes/summary`).
  Future<List<SearchIndexSummary>> listSummaries() async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('/v1/rag/indexes/summary');
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as List<dynamic>;
    return responseBody
        .map((e) => SearchIndexSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Gets detailed information about a search index schema.
  ///
  /// Maps to the official `get_index_schema_detail`
  /// (`GET /v1/rag/indexes/index/{index_id}/schemas/schema/{schema_id}/detail`).
  Future<SearchIndexSchemaDetail> getSchemaDetail({
    required String indexId,
    required String schemaId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/schemas/schema/$schemaId/detail',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SearchIndexSchemaDetail.fromJson(responseBody);
  }

  /// Gets the raw Vespa schema definition (`.sd` file) of a search index
  /// schema.
  ///
  /// Maps to the official `get_index_schema_file`
  /// (`GET /v1/rag/indexes/index/{index_id}/schemas/schema/{schema_id}/file`).
  Future<SearchIndexSchemaSdFile> getSchemaFile({
    required String indexId,
    required String schemaId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/schemas/schema/$schemaId/file',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SearchIndexSchemaSdFile.fromJson(responseBody);
  }

  /// Lists retrievable documents stored within a search index schema.
  ///
  /// [groupId] optionally restricts results to a single group.
  ///
  /// Maps to the official `document_fetch`
  /// (`GET /v1/rag/indexes/index/{index_id}/schemas/schema/{schema_id}/retrievables`).
  Future<List<SearchIndexRetrievable>> listRetrievables({
    required String indexId,
    required String schemaId,
    String? groupId,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{'group_id': ?groupId};
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/schemas/schema/$schemaId/retrievables',
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as List<dynamic>;
    return responseBody
        .map((e) => SearchIndexRetrievable.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Gets a single retrievable document stored within a search index schema.
  ///
  /// [documentId] is the native ID of the document in the underlying index.
  ///
  /// Maps to the official `document_lookup`
  /// (`GET /v1/rag/indexes/index/{index_id}/schemas/schema/{schema_id}/retrievables/retrievable/{document_id}`).
  Future<SearchIndexRetrievable> getRetrievable({
    required String indexId,
    required String schemaId,
    required String documentId,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/schemas/schema/$schemaId'
      '/retrievables/retrievable/$documentId',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SearchIndexRetrievable.fromJson(responseBody);
  }

  /// Gets the summary field of a search index.
  ///
  /// Maps to the official `get_index_summary`
  /// (`GET /v1/rag/indexes/index/{index_id}/summary_field/{language}`).
  Future<SummaryFieldResponse> getSummary({
    required String indexId,
    required SummaryLanguage language,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/summary_field/${language.toJson()}',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SummaryFieldResponse.fromJson(responseBody);
  }

  /// Generates (streams) the summary field of a search index.
  ///
  /// Maps to the official `generate_index_summary`
  /// (`POST /v1/rag/indexes/index/{index_id}/summary_field/{language}`).
  Stream<SummaryStreamEvent> generateSummary({
    required String indexId,
    required SummaryLanguage language,
  }) {
    ensureNotClosed?.call();
    return _generateSummaryImpl(indexId: indexId, language: language);
  }

  Stream<SummaryStreamEvent> _generateSummaryImpl({
    required String indexId,
    required SummaryLanguage language,
  }) async* {
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/summary_field/${language.toJson()}',
    );
    final headers = requestBuilder.buildHeaders();

    var httpRequest = http.Request('POST', url)..headers.addAll(headers);
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    await for (final json in parseNDJSON(streamedResponse.stream)) {
      yield SummaryStreamEvent.fromJson(json);
    }
  }

  /// Sets the summary field of a search index.
  ///
  /// Maps to the official `set_index_summary`
  /// (`PUT /v1/rag/indexes/index/{index_id}/summary_field/{language}`).
  Future<void> setSummary({
    required String indexId,
    required SummaryLanguage language,
    required UpdateSummaryRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/summary_field/${language.toJson()}',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }

  /// Gets the summary field of a search index schema.
  ///
  /// Maps to the official `get_schema_summary`
  /// (`GET /v1/rag/indexes/index/{index_id}/schemas/schema/{schema_id}/summary_field/{language}`).
  Future<SummaryFieldResponse> getSchemaSummary({
    required String indexId,
    required String schemaId,
    required SummaryLanguage language,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/schemas/schema/$schemaId'
      '/summary_field/${language.toJson()}',
    );
    final headers = requestBuilder.buildHeaders();

    final httpRequest = http.Request('GET', url)..headers.addAll(headers);

    final response = await interceptorChain.execute(httpRequest);
    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return SummaryFieldResponse.fromJson(responseBody);
  }

  /// Generates (streams) the summary field of a search index schema.
  ///
  /// Maps to the official `generate_schema_summary_post`
  /// (`POST /v1/rag/indexes/index/{index_id}/schemas/schema/{schema_id}/summary_field/{language}`).
  Stream<SummaryStreamEvent> generateSchemaSummary({
    required String indexId,
    required String schemaId,
    required SummaryLanguage language,
  }) {
    ensureNotClosed?.call();
    return _generateSchemaSummaryImpl(
      indexId: indexId,
      schemaId: schemaId,
      language: language,
    );
  }

  Stream<SummaryStreamEvent> _generateSchemaSummaryImpl({
    required String indexId,
    required String schemaId,
    required SummaryLanguage language,
  }) async* {
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/schemas/schema/$schemaId'
      '/summary_field/${language.toJson()}',
    );
    final headers = requestBuilder.buildHeaders();

    var httpRequest = http.Request('POST', url)..headers.addAll(headers);
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    await for (final json in parseNDJSON(streamedResponse.stream)) {
      yield SummaryStreamEvent.fromJson(json);
    }
  }

  /// Sets the summary field of a search index schema.
  ///
  /// Maps to the official `set_schema_summary`
  /// (`PUT /v1/rag/indexes/index/{index_id}/schemas/schema/{schema_id}/summary_field/{language}`).
  Future<void> setSchemaSummary({
    required String indexId,
    required String schemaId,
    required SummaryLanguage language,
    required UpdateSummaryRequest request,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(
      '/v1/rag/indexes/index/$indexId/schemas/schema/$schemaId'
      '/summary_field/${language.toJson()}',
    );
    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    final httpRequest = http.Request('PUT', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());

    await interceptorChain.execute(httpRequest);
  }
}
