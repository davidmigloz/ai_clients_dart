import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/rag/summary_field_response.dart';
import '../models/rag/summary_language.dart';
import '../models/rag/summary_stream_event.dart';
import '../models/rag/update_summary_request.dart';
import '../models/search/managed_index.dart';
import '../models/search/search_documents.dart';
import '../models/search/search_query.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Managed Search indexes and their documents (Mistral-hosted Public Preview).
///
/// Use a workspace API key with permissions for the index. Creation, update,
/// and deletion start asynchronous changes. Read the returned status or call
/// [get] to check whether an index is ready.
class ManagedSearchIndexesResource extends ResourceBase with StreamingResource {
  /// Creates the managed Search resource.
  ManagedSearchIndexesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _collection = '/v1/context/search-indexes';

  String _index(String name) => '$_collection/${Uri.encodeComponent(name)}';

  String _summary(String name, SummaryLanguage language) =>
      '${_index(name)}/summary_field/${language.toJson()}';

  /// Lists indexes using cursor pagination.
  Future<ManagedSearchIndexPage> list({
    int? pageSize,
    String? pageToken,
    String? name,
    ManagedSearchIndexStatus? status,
    String? creatorId,
  }) => _json(
    'GET',
    _collection,
    ManagedSearchIndexPage.fromJson,
    query: {
      'page_size': ?pageSize?.toString(),
      'page_token': ?pageToken,
      'name': ?name,
      'status': ?status?.toJson(),
      'creator_id': ?creatorId,
    },
  );

  /// Starts provisioning a new index.
  Future<ManagedSearchIndex> create({
    required CreateManagedIndexRequest request,
  }) => _json(
    'POST',
    _collection,
    ManagedSearchIndex.fromJson,
    body: request.toJson(),
  );

  /// Gets the current configuration and provisioning status of an index.
  Future<ManagedSearchIndex> get({required String indexName}) =>
      _json('GET', _index(indexName), ManagedSearchIndex.fromJson);

  /// Updates the schema of an index.
  Future<ManagedSearchIndex> update({
    required String indexName,
    required UpdateManagedIndexRequest request,
  }) => _json(
    'PUT',
    _index(indexName),
    ManagedSearchIndex.fromJson,
    body: request.toJson(),
  );

  /// Starts deletion of an index.
  Future<DeleteManagedIndexResponse> delete({required String indexName}) =>
      _json('DELETE', _index(indexName), DeleteManagedIndexResponse.fromJson);

  /// Ingests documents and returns accepted and rejected results.
  Future<IngestSearchDocumentsResponse> ingestDocuments({
    required String indexName,
    required IngestSearchDocumentsRequest request,
  }) => _json(
    'POST',
    '${_index(indexName)}/documents',
    IngestSearchDocumentsResponse.fromJson,
    body: request.toJson(),
  );

  /// Removes the supplied document IDs.
  Future<DeleteSearchDocumentsResponse> deleteDocuments({
    required String indexName,
    required DeleteSearchDocumentsRequest request,
  }) => _json(
    'DELETE',
    '${_index(indexName)}/documents',
    DeleteSearchDocumentsResponse.fromJson,
    body: request.toJson(),
  );

  /// Runs a keyword, vector, or hybrid search.
  Future<ManagedSearchResults> search({
    required String indexName,
    required ManagedSearchRequest request,
  }) => _json(
    'POST',
    '${_index(indexName)}/search',
    ManagedSearchResults.fromJson,
    body: request.toJson(),
  );

  /// Finds chunks before or after a selected range.
  Future<SearchNavigationResponse> navigate({
    required String indexName,
    required SearchNavigateRequest request,
  }) => _json(
    'POST',
    '${_index(indexName)}/navigate',
    SearchNavigationResponse.fromJson,
    body: request.toJson(),
  );

  /// Reads chunks within a selected range.
  Future<SearchNavigationResponse> read({
    required String indexName,
    required SearchReadRequest request,
  }) => _json(
    'POST',
    '${_index(indexName)}/read',
    SearchNavigationResponse.fromJson,
    body: request.toJson(),
  );

  /// Finds chunks containing a term or phrase.
  Future<SearchNavigationResponse> grep({
    required String indexName,
    required SearchGrepRequest request,
  }) => _json(
    'POST',
    '${_index(indexName)}/grep',
    SearchNavigationResponse.fromJson,
    body: request.toJson(),
  );

  /// Retrieves a chunk by ID.
  Future<SearchNavigationResponse> getChunk({
    required String indexName,
    required String chunkId,
  }) => _json(
    'GET',
    '${_index(indexName)}/chunks/${Uri.encodeComponent(chunkId)}',
    SearchNavigationResponse.fromJson,
  );

  /// Gets the index summary in the requested language.
  Future<SummaryFieldResponse> getSummary({
    required String indexName,
    required SummaryLanguage language,
  }) => _json(
    'GET',
    _summary(indexName, language),
    SummaryFieldResponse.fromJson,
  );

  /// Sets the index summary in the requested language.
  Future<void> setSummary({
    required String indexName,
    required SummaryLanguage language,
    required UpdateSummaryRequest request,
  }) async {
    await _send('PUT', _summary(indexName, language), body: request.toJson());
  }

  /// Generates a summary and streams its metadata, chunks, and errors.
  ///
  /// The server sends newline-delimited JSON. [abortTrigger] cancels this
  /// request without closing the shared client.
  Stream<SummaryStreamEvent> generateSummary({
    required String indexName,
    required SummaryLanguage language,
    bool? force,
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    return streamRequest(
      () =>
          http.Request(
              'POST',
              requestBuilder.buildUrl(
                _summary(indexName, language),
                queryParams: {'force': ?force?.toString()},
              ),
            )
            ..headers.addAll(
              requestBuilder.buildHeaders(
                additionalHeaders: {'Accept': 'application/x-ndjson'},
              ),
            ),
      SummaryStreamEvent.fromJson,
      parseEvents: parseNDJSON,
      checkInlineErrors: false,
      abortTrigger: abortTrigger,
    );
  }

  Future<T> _json<T>(
    String method,
    String path,
    T Function(Map<String, dynamic>) decode, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) async {
    final response = await _send(method, path, query: query, body: body);
    return decode(jsonDecode(response.body) as Map<String, dynamic>);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? body,
  }) {
    ensureNotClosed?.call();
    final request =
        http.Request(method, requestBuilder.buildUrl(path, queryParams: query))
          ..headers.addAll(
            requestBuilder.buildHeaders(
              additionalHeaders: {
                'Accept': 'application/json',
                if (body != null) 'Content-Type': 'application/json',
              },
            ),
          );
    if (body != null) request.body = jsonEncode(body);
    return interceptorChain.execute(request);
  }
}
