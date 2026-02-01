import '../models/vector_stores/vector_stores.dart';
import 'beta_base_resource.dart';

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
class VectorStoresResource extends BetaBaseResource {
  /// Creates a [VectorStoresResource] with the given client.
  VectorStoresResource(super.client);

  static const _endpoint = '/vector_stores';

  VectorStoreFilesResource? _files;

  /// Access to vector store file operations.
  VectorStoreFilesResource get files =>
      _files ??= VectorStoreFilesResource(client);

  /// Creates a new vector store.
  ///
  /// ## Parameters
  ///
  /// - [request] - The creation request.
  ///
  /// ## Returns
  ///
  /// A [VectorStore] object.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final store = await client.beta.vectorStores.create(
  ///   CreateVectorStoreRequest(
  ///     name: 'Product Docs',
  ///     fileIds: ['file_1', 'file_2'],
  ///     expiresAfter: ExpirationPolicy(
  ///       anchor: 'last_active_at',
  ///       days: 7,
  ///     ),
  ///   ),
  /// );
  /// ```
  Future<VectorStore> create(CreateVectorStoreRequest request) async {
    final json = await postJson(_endpoint, body: request.toJson());
    return VectorStore.fromJson(json);
  }

  /// Lists vector stores.
  ///
  /// ## Parameters
  ///
  /// - [limit] - Maximum number to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc', default 'desc').
  /// - [after] - Cursor for pagination.
  /// - [before] - Cursor for pagination.
  ///
  /// ## Returns
  ///
  /// A [VectorStoreList] containing the vector stores.
  Future<VectorStoreList> list({
    int? limit,
    String? order,
    String? after,
    String? before,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;

    final json = await getJson(
      _endpoint,
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return VectorStoreList.fromJson(json);
  }

  /// Retrieves a vector store by ID.
  ///
  /// ## Parameters
  ///
  /// - [vectorStoreId] - The ID of the vector store.
  ///
  /// ## Returns
  ///
  /// A [VectorStore] with the vector store information.
  Future<VectorStore> retrieve(String vectorStoreId) async {
    final json = await getJson('$_endpoint/$vectorStoreId');
    return VectorStore.fromJson(json);
  }

  /// Modifies a vector store.
  ///
  /// ## Parameters
  ///
  /// - [vectorStoreId] - The ID of the vector store.
  /// - [request] - The modification request.
  ///
  /// ## Returns
  ///
  /// A [VectorStore] with the updated information.
  Future<VectorStore> update(
    String vectorStoreId,
    ModifyVectorStoreRequest request,
  ) async {
    final json = await postJson(
      '$_endpoint/$vectorStoreId',
      body: request.toJson(),
    );
    return VectorStore.fromJson(json);
  }

  /// Deletes a vector store.
  ///
  /// ## Parameters
  ///
  /// - [vectorStoreId] - The ID of the vector store.
  ///
  /// ## Returns
  ///
  /// A [DeleteVectorStoreResponse] confirming the deletion.
  Future<DeleteVectorStoreResponse> delete(String vectorStoreId) async {
    final json = await deleteJson('$_endpoint/$vectorStoreId');
    return DeleteVectorStoreResponse.fromJson(json);
  }
}

/// Resource for Vector Store Files operations.
class VectorStoreFilesResource extends BetaBaseResource {
  /// Creates a [VectorStoreFilesResource] with the given client.
  VectorStoreFilesResource(super.client);

  String _endpoint(String vectorStoreId) =>
      '/vector_stores/$vectorStoreId/files';

  /// Creates a vector store file.
  ///
  /// Attaches a file to a vector store for use with file_search.
  ///
  /// ## Parameters
  ///
  /// - [vectorStoreId] - The ID of the vector store.
  /// - [request] - The creation request.
  ///
  /// ## Returns
  ///
  /// A [VectorStoreFile] object.
  Future<VectorStoreFile> create(
    String vectorStoreId,
    CreateVectorStoreFileRequest request,
  ) async {
    final json = await postJson(
      _endpoint(vectorStoreId),
      body: request.toJson(),
    );
    return VectorStoreFile.fromJson(json);
  }

  /// Lists files in a vector store.
  ///
  /// ## Parameters
  ///
  /// - [vectorStoreId] - The ID of the vector store.
  /// - [limit] - Maximum number to return (1-100, default 20).
  /// - [order] - Sort order ('asc' or 'desc', default 'desc').
  /// - [after] - Cursor for pagination.
  /// - [before] - Cursor for pagination.
  /// - [filter] - Filter by status.
  ///
  /// ## Returns
  ///
  /// A [VectorStoreFileList] containing the files.
  Future<VectorStoreFileList> list(
    String vectorStoreId, {
    int? limit,
    String? order,
    String? after,
    String? before,
    String? filter,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (order != null) queryParams['order'] = order;
    if (after != null) queryParams['after'] = after;
    if (before != null) queryParams['before'] = before;
    if (filter != null) queryParams['filter'] = filter;

    final json = await getJson(
      _endpoint(vectorStoreId),
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );
    return VectorStoreFileList.fromJson(json);
  }

  /// Retrieves a vector store file.
  ///
  /// ## Parameters
  ///
  /// - [vectorStoreId] - The ID of the vector store.
  /// - [fileId] - The ID of the file.
  ///
  /// ## Returns
  ///
  /// A [VectorStoreFile] with the file information.
  Future<VectorStoreFile> retrieve(String vectorStoreId, String fileId) async {
    final json = await getJson('${_endpoint(vectorStoreId)}/$fileId');
    return VectorStoreFile.fromJson(json);
  }

  /// Deletes a vector store file.
  ///
  /// ## Parameters
  ///
  /// - [vectorStoreId] - The ID of the vector store.
  /// - [fileId] - The ID of the file.
  ///
  /// ## Returns
  ///
  /// A [DeleteVectorStoreFileResponse] confirming the deletion.
  Future<DeleteVectorStoreFileResponse> delete(
    String vectorStoreId,
    String fileId,
  ) async {
    final json = await deleteJson('${_endpoint(vectorStoreId)}/$fileId');
    return DeleteVectorStoreFileResponse.fromJson(json);
  }
}
