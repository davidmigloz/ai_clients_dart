import '../models/collections/collection.dart';
import 'base_resource.dart';

/// Resource for collection management endpoints.
///
/// This resource provides methods for managing collections within a database.
/// Collections are the main container for storing and querying records.
///
/// Example:
/// ```dart
/// final client = ChromaClient();
///
/// // Create a new collection
/// final collection = await client.collections.create(name: 'my-collection');
///
/// // List all collections
/// final collections = await client.collections.list();
///
/// // Get a collection by name
/// final retrieved = await client.collections.getByName(name: 'my-collection');
/// ```
class CollectionsResource extends ResourceBase {
  /// Creates a collections resource.
  CollectionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    required super.retryWrapper,
    super.ensureNotClosed,
  });

  /// Builds the base path for collection endpoints.
  String _basePath({String? tenant, String? database}) {
    final t = tenant ?? config.tenant;
    final d = database ?? config.database;
    return '/api/v2/tenants/${Uri.encodeComponent(t)}'
        '/databases/${Uri.encodeComponent(d)}/collections';
  }

  /// Lists all collections in a database.
  ///
  /// [tenant] - The tenant containing the database.
  ///   Defaults to the client's configured tenant.
  /// [database] - The database to list collections from.
  ///   Defaults to the client's configured database.
  /// [limit] - Maximum number of collections to return.
  /// [offset] - Number of collections to skip.
  ///
  /// Returns a list of [Collection] objects.
  ///
  /// Endpoint: `GET /api/v2/tenants/{tenant}/databases/{database}/collections`
  Future<List<Collection>> list({
    String? tenant,
    String? database,
    int? limit,
    int? offset,
  }) async {
    final queryParams = <String, String>{};
    if (limit != null) queryParams['limit'] = limit.toString();
    if (offset != null) queryParams['offset'] = offset.toString();

    final response = await get(
      _basePath(tenant: tenant, database: database),
      queryParameters: queryParams.isEmpty ? null : queryParams,
    );
    return parseJsonList(response).map(Collection.fromJson).toList();
  }

  /// Creates a new collection.
  ///
  /// [name] - The name for the new collection.
  /// [metadata] - Optional metadata for the collection.
  /// [getOrCreate] - If true, returns existing collection with this name
  ///   instead of throwing an error.
  /// [tenant] - The tenant containing the database.
  /// [database] - The database to create the collection in.
  ///
  /// Returns the created [Collection].
  ///
  /// Endpoint: `POST /api/v2/tenants/{tenant}/databases/{database}/collections`
  Future<Collection> create({
    required String name,
    Map<String, dynamic>? metadata,
    bool getOrCreate = false,
    String? tenant,
    String? database,
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'metadata': ?metadata,
      if (getOrCreate) 'get_or_create': getOrCreate,
    };

    final response = await post(
      _basePath(tenant: tenant, database: database),
      body: body,
    );
    return Collection.fromJson(parseJson(response));
  }

  /// Gets a collection by name.
  ///
  /// [name] - The collection name.
  /// [tenant] - The tenant containing the database.
  /// [database] - The database containing the collection.
  ///
  /// Returns the [Collection] if found.
  ///
  /// Throws [ChromaNotFoundException] if the collection does not exist.
  ///
  /// Endpoint: `GET /api/v2/tenants/{tenant}/databases/{database}/collections/{name}`
  Future<Collection> getByName({
    required String name,
    String? tenant,
    String? database,
  }) async {
    final response = await get(
      '${_basePath(tenant: tenant, database: database)}/${Uri.encodeComponent(name)}',
    );
    return Collection.fromJson(parseJson(response));
  }

  /// Gets a collection by Chroma Resource Name (CRN).
  ///
  /// [crn] - The Chroma Resource Name.
  ///
  /// Returns the [Collection] if found.
  ///
  /// Endpoint: `GET /api/v2/collections/{crn}`
  Future<Collection> getByCrn({required String crn}) async {
    final response = await get(
      '/api/v2/collections/${Uri.encodeComponent(crn)}',
    );
    return Collection.fromJson(parseJson(response));
  }

  /// Updates a collection.
  ///
  /// [name] - The current collection name.
  /// [newName] - The new name for the collection (optional).
  /// [newMetadata] - The new metadata for the collection (optional).
  /// [tenant] - The tenant containing the database.
  /// [database] - The database containing the collection.
  ///
  /// Returns the updated [Collection].
  ///
  /// Endpoint: `PUT /api/v2/tenants/{tenant}/databases/{database}/collections/{id}`
  Future<Collection> update({
    required String name,
    String? newName,
    Map<String, dynamic>? newMetadata,
    String? tenant,
    String? database,
  }) async {
    // First get the collection to obtain its UUID for the PUT request
    final current = await getByName(
      name: name,
      tenant: tenant,
      database: database,
    );

    final body = <String, dynamic>{
      'new_name': ?newName,
      'new_metadata': ?newMetadata,
    };

    await put(
      '${_basePath(tenant: tenant, database: database)}/${Uri.encodeComponent(current.id)}',
      body: body,
    );

    // Re-fetch using the new name if provided, otherwise original name
    return getByName(name: newName ?? name, tenant: tenant, database: database);
  }

  /// Deletes a collection by name.
  ///
  /// [name] - The collection name to delete.
  /// [tenant] - The tenant containing the database.
  /// [database] - The database containing the collection.
  ///
  /// **WARNING**: This deletes the collection and all its records.
  ///
  /// Endpoint: `DELETE /api/v2/tenants/{tenant}/databases/{database}/collections/{name}`
  Future<void> deleteByName({
    required String name,
    String? tenant,
    String? database,
  }) async {
    await delete(
      '${_basePath(tenant: tenant, database: database)}/${Uri.encodeComponent(name)}',
    );
  }

  /// Counts the number of collections in a database.
  ///
  /// [tenant] - The tenant containing the database.
  /// [database] - The database to count collections in.
  ///
  /// Returns the number of collections.
  ///
  /// Endpoint: `GET /api/v2/tenants/{tenant}/databases/{database}/collections_count`
  Future<int> count({String? tenant, String? database}) async {
    final t = tenant ?? config.tenant;
    final d = database ?? config.database;
    final response = await get(
      '/api/v2/tenants/${Uri.encodeComponent(t)}'
      '/databases/${Uri.encodeComponent(d)}/collections_count',
    );
    return parseInt(response);
  }

  /// Forks an existing collection.
  ///
  /// [collectionId] - The ID of the collection to fork.
  /// [newName] - The name for the forked collection.
  /// [tenant] - The tenant containing the database.
  /// [database] - The database containing the collection.
  ///
  /// Returns the newly created forked [Collection].
  ///
  /// Endpoint: `POST /api/v2/tenants/{tenant}/databases/{database}/collections/{id}/fork`
  Future<Collection> fork({
    required String collectionId,
    required String newName,
    String? tenant,
    String? database,
  }) async {
    final response = await post(
      '${_basePath(tenant: tenant, database: database)}/${Uri.encodeComponent(collectionId)}/fork',
      body: {'new_name': newName},
    );
    return Collection.fromJson(parseJson(response));
  }
}
