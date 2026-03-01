import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/vector_stores/vector_stores.dart';
import 'base_resource.dart';

/// Resource for Vector Stores API operations (Beta).
///
/// Vector stores are used by the file_search tool in the Assistants API.
///
/// Access this resource through [OpenAIClient.beta.vectorStores].
///
/// ## Example
///
/// ```dart
/// // Create a vector store
/// final store = await client.beta.vectorStores.create(
///   CreateVectorStoreRequest(name: 'My Documents'),
/// );
///
/// // Add files
/// await client.beta.vectorStores.files.create(
///   store.id,
///   CreateVectorStoreFileRequest(fileId: 'file_abc123'),
/// );
/// ```
class VectorStoresResource extends ResourceBase {
  /// Creates a [VectorStoresResource].
  VectorStoresResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _endpoint = '/vector_stores';
  static const _betaFeature = 'assistants=v2';

  VectorStoreFilesResource? _files;

  /// Access to vector store file operations.
  VectorStoreFilesResource get files => _files ??= VectorStoreFilesResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Creates a new vector store.
  Future<VectorStore> create(CreateVectorStoreRequest request) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return VectorStore.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists vector stores.
  Future<VectorStoreList> list({
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final url = requestBuilder.buildUrl(
      _endpoint,
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return VectorStoreList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a vector store by ID.
  Future<VectorStore> retrieve(String vectorStoreId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$vectorStoreId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return VectorStore.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Modifies a vector store.
  Future<VectorStore> update(
    String vectorStoreId,
    ModifyVectorStoreRequest request,
  ) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$vectorStoreId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return VectorStore.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a vector store.
  Future<DeleteVectorStoreResponse> delete(String vectorStoreId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('$_endpoint/$vectorStoreId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteVectorStoreResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}

/// Resource for Vector Store Files operations.
class VectorStoreFilesResource extends ResourceBase {
  /// Creates a [VectorStoreFilesResource].
  VectorStoreFilesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  static const _betaFeature = 'assistants=v2';

  String _endpoint(String vectorStoreId) =>
      '/vector_stores/$vectorStoreId/files';

  /// Creates a vector store file.
  Future<VectorStoreFile> create(
    String vectorStoreId,
    CreateVectorStoreFileRequest request,
  ) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint(vectorStoreId));
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(httpRequest);
    return VectorStoreFile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Lists files in a vector store.
  Future<VectorStoreFileList> list(
    String vectorStoreId, {
    int? limit,
    String? order,
    String? after,
    String? before,
    String? filter,
  }) async {
    ensureNotClosed?.call();
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;
    if (filter != null) queryParams['filter'] = filter;

    final url = requestBuilder.buildUrl(
      _endpoint(vectorStoreId),
      queryParams: queryParams.isNotEmpty ? queryParams : null,
    );
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return VectorStoreFileList.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Retrieves a vector store file.
  Future<VectorStoreFile> retrieve(String vectorStoreId, String fileId) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('${_endpoint(vectorStoreId)}/$fileId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('GET', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return VectorStoreFile.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Deletes a vector store file.
  Future<DeleteVectorStoreFileResponse> delete(
    String vectorStoreId,
    String fileId,
  ) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl('${_endpoint(vectorStoreId)}/$fileId');
    final headers = requestBuilder.buildBetaHeaders(betaFeature: _betaFeature);
    final httpRequest = http.Request('DELETE', url)..headers.addAll(headers);
    final response = await interceptorChain.execute(httpRequest);
    return DeleteVectorStoreFileResponse.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }
}
