import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/records/get_response.dart';
import '../models/records/include.dart';
import '../models/records/query_response.dart';
import '../models/records/search_request.dart';
import '../models/records/search_response.dart';
import 'base_resource.dart';

/// Resource for record operations within a collection.
///
/// This resource provides methods for adding, updating, querying,
/// and deleting records (embeddings, documents, metadata) in a collection.
///
/// Example:
/// ```dart
/// final client = ChromaClient();
///
/// // Get records resource for a collection
/// final records = client.records('collection-id');
///
/// // Add records
/// await records.add(
///   ids: ['id1', 'id2'],
///   embeddings: [[0.1, 0.2], [0.3, 0.4]],
///   documents: ['Hello', 'World'],
/// );
///
/// // Query by embedding
/// final results = await records.query(
///   queryEmbeddings: [[0.1, 0.2]],
///   nResults: 5,
/// );
/// ```
class RecordsResource extends ResourceBase {
  /// The collection ID this resource operates on.
  final String collectionId;

  /// The tenant (optional, uses config default).
  final String? _tenant;

  /// The database (optional, uses config default).
  final String? _database;

  /// Creates a records resource for a specific collection.
  RecordsResource({
    required this.collectionId,
    String? tenant,
    String? database,
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    required super.retryWrapper,
    super.ensureNotClosed,
  }) : _tenant = tenant,
       _database = database;

  /// Builds the base path for this collection's endpoints.
  String get _basePath {
    final t = _tenant ?? config.tenant;
    final d = _database ?? config.database;
    return '/api/v2/tenants/${Uri.encodeComponent(t)}'
        '/databases/${Uri.encodeComponent(d)}'
        '/collections/${Uri.encodeComponent(collectionId)}';
  }

  /// Adds records to the collection.
  ///
  /// [ids] - Unique identifiers for each record (required).
  /// [embeddings] - Embedding vectors for each record.
  /// [documents] - Document text for each record.
  /// [metadatas] - Metadata for each record.
  /// [uris] - URIs for each record.
  ///
  /// Either [embeddings] or [documents] must be provided (or both).
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/add`
  Future<void> add({
    required List<String> ids,
    List<List<double>>? embeddings,
    List<String>? documents,
    List<Map<String, dynamic>>? metadatas,
    List<String>? uris,
  }) async {
    final body = <String, dynamic>{
      'ids': ids,
      'embeddings': ?embeddings,
      'documents': ?documents,
      'metadatas': ?metadatas,
      'uris': ?uris,
    };

    await post('$_basePath/add', body: body);
  }

  /// Updates existing records in the collection.
  ///
  /// [ids] - IDs of records to update (required).
  /// [embeddings] - New embedding vectors.
  /// [documents] - New document text.
  /// [metadatas] - New metadata.
  /// [uris] - New URIs.
  ///
  /// Only the provided fields will be updated.
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/update`
  Future<void> update({
    required List<String> ids,
    List<List<double>>? embeddings,
    List<String>? documents,
    List<Map<String, dynamic>>? metadatas,
    List<String>? uris,
  }) async {
    final body = <String, dynamic>{
      'ids': ids,
      'embeddings': ?embeddings,
      'documents': ?documents,
      'metadatas': ?metadatas,
      'uris': ?uris,
    };

    await post('$_basePath/update', body: body);
  }

  /// Upserts records (insert or update).
  ///
  /// [ids] - Unique identifiers for each record (required).
  /// [embeddings] - Embedding vectors for each record.
  /// [documents] - Document text for each record.
  /// [metadatas] - Metadata for each record.
  /// [uris] - URIs for each record.
  ///
  /// If a record with the given ID exists, it will be updated.
  /// Otherwise, a new record will be created.
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/upsert`
  Future<void> upsert({
    required List<String> ids,
    List<List<double>>? embeddings,
    List<String>? documents,
    List<Map<String, dynamic>>? metadatas,
    List<String>? uris,
  }) async {
    final body = <String, dynamic>{
      'ids': ids,
      'embeddings': ?embeddings,
      'documents': ?documents,
      'metadatas': ?metadatas,
      'uris': ?uris,
    };

    await post('$_basePath/upsert', body: body);
  }

  /// Gets records from the collection.
  ///
  /// [ids] - Specific IDs to retrieve. If null, retrieves all (with limit).
  /// [where] - Metadata filter conditions.
  /// [whereDocument] - Document content filter conditions.
  /// [limit] - Maximum number of records to return.
  /// [offset] - Number of records to skip.
  /// [include] - Fields to include in the response.
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/get`
  Future<GetResponse> getRecords({
    List<String>? ids,
    Map<String, dynamic>? where,
    Map<String, dynamic>? whereDocument,
    int? limit,
    int? offset,
    List<Include> include = const [Include.documents, Include.metadatas],
  }) async {
    final body = <String, dynamic>{
      'ids': ?ids,
      'where': ?where,
      'where_document': ?whereDocument,
      'limit': ?limit,
      'offset': ?offset,
      'include': Include.toApiList(include),
    };

    final response = await post(
      '$_basePath/get',
      body: body,
      isIdempotent: true,
    );
    return GetResponse.fromJson(parseJson(response));
  }

  /// Queries records by embedding similarity.
  ///
  /// [queryEmbeddings] - Query embedding vectors (required).
  /// [nResults] - Number of results to return per query.
  /// [where] - Metadata filter conditions.
  /// [whereDocument] - Document content filter conditions.
  /// [include] - Fields to include in the response.
  ///
  /// Returns results ordered by similarity (closest first).
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/query`
  Future<QueryResponse> query({
    required List<List<double>> queryEmbeddings,
    int nResults = 10,
    Map<String, dynamic>? where,
    Map<String, dynamic>? whereDocument,
    List<Include> include = const [
      Include.documents,
      Include.metadatas,
      Include.distances,
    ],
  }) async {
    final body = <String, dynamic>{
      'query_embeddings': queryEmbeddings,
      'n_results': nResults,
      'where': ?where,
      'where_document': ?whereDocument,
      'include': Include.toApiList(include),
    };

    final response = await post(
      '$_basePath/query',
      body: body,
      isIdempotent: true,
    );
    return QueryResponse.fromJson(parseJson(response));
  }

  /// Performs hybrid search across the collection.
  ///
  /// [searches] - List of search payloads with filter/group/limit/rank/select.
  ///
  /// This is an advanced search method supporting:
  /// - Filtering by IDs or metadata conditions
  /// - Grouping results by metadata keys
  /// - Pagination with limit/offset
  /// - Custom ranking configurations
  /// - Field selection for results
  ///
  /// Returns results organized by search query.
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/search`
  Future<SearchResponse> search({required List<SearchPayload> searches}) async {
    final body = <String, dynamic>{
      'searches': searches.map((s) => s.toJson()).toList(),
    };

    final response = await post(
      '$_basePath/search',
      body: body,
      isIdempotent: true,
    );
    return SearchResponse.fromJson(parseJson(response));
  }

  /// Deletes records from the collection.
  ///
  /// [ids] - Specific IDs to delete.
  /// [where] - Metadata filter for records to delete.
  /// [whereDocument] - Document content filter for records to delete.
  ///
  /// At least one of [ids], [where], or [whereDocument] must be provided.
  ///
  /// Returns the IDs of deleted records.
  ///
  /// Endpoint: `POST /api/v2/.../collections/{id}/delete`
  Future<List<String>> deleteRecords({
    List<String>? ids,
    Map<String, dynamic>? where,
    Map<String, dynamic>? whereDocument,
  }) async {
    final body = <String, dynamic>{
      'ids': ?ids,
      'where': ?where,
      'where_document': ?whereDocument,
    };

    final response = await post('$_basePath/delete', body: body);
    return _parseDeleteResponse(response);
  }

  /// Parses the delete response which may be a direct array or {"ids": [...]}.
  List<String> _parseDeleteResponse(http.Response response) {
    if (response.body.isEmpty) {
      return [];
    }

    final decoded = jsonDecode(response.body);

    // Handle direct array response: ["id1", "id2"]
    if (decoded is List) {
      return decoded.cast<String>();
    }

    // Handle object response: {"ids": ["id1", "id2"]}
    if (decoded is Map<String, dynamic>) {
      final ids = decoded['ids'];
      if (ids is List) {
        return ids.cast<String>();
      }
    }

    return [];
  }

  /// Counts records in the collection.
  ///
  /// Returns the total number of records.
  ///
  /// Endpoint: `GET /api/v2/.../collections/{id}/count`
  Future<int> count() async {
    final response = await get('$_basePath/count');
    return parseInt(response);
  }
}
