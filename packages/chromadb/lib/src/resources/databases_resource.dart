import '../models/databases/database.dart';
import 'base_resource.dart';

/// Resource for database management endpoints.
///
/// This resource provides methods for managing databases within a tenant.
/// Databases provide a logical grouping of collections.
///
/// Example:
/// ```dart
/// final client = ChromaClient();
///
/// // List all databases in the default tenant
/// final databases = await client.databases.list();
///
/// // Create a new database
/// final db = await client.databases.create(name: 'my-database');
///
/// // Get a database by name
/// final retrieved = await client.databases.getByName(name: 'my-database');
/// ```
class DatabasesResource extends ResourceBase {
  /// Creates a databases resource.
  DatabasesResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    required super.retryWrapper,
    super.ensureNotClosed,
  });

  /// Lists all databases in a tenant.
  ///
  /// [tenant] - The tenant to list databases from.
  ///   Defaults to the client's configured tenant.
  ///
  /// Returns a list of [Database] objects.
  ///
  /// Endpoint: `GET /api/v2/tenants/{tenant}/databases`
  Future<List<Database>> list({String? tenant}) async {
    final t = tenant ?? config.tenant;
    final response = await get(
      '/api/v2/tenants/${Uri.encodeComponent(t)}/databases',
    );
    return parseJsonList(response).map(Database.fromJson).toList();
  }

  /// Creates a new database.
  ///
  /// [name] - The name for the new database.
  /// [tenant] - The tenant to create the database in.
  ///   Defaults to the client's configured tenant.
  ///
  /// Returns the created [Database].
  ///
  /// Endpoint: `POST /api/v2/tenants/{tenant}/databases`
  Future<Database> create({required String name, String? tenant}) async {
    final t = tenant ?? config.tenant;
    await post(
      '/api/v2/tenants/${Uri.encodeComponent(t)}/databases',
      body: {'name': name},
    );

    // Re-fetch the database since the create response may be incomplete
    return getByName(name: name, tenant: t);
  }

  /// Gets a database by name.
  ///
  /// [name] - The name of the database to retrieve.
  /// [tenant] - The tenant containing the database.
  ///   Defaults to the client's configured tenant.
  ///
  /// Returns the [Database] if found.
  ///
  /// Throws [ChromaNotFoundException] if the database does not exist.
  ///
  /// Endpoint: `GET /api/v2/tenants/{tenant}/databases/{database}`
  Future<Database> getByName({required String name, String? tenant}) async {
    final t = tenant ?? config.tenant;
    final response = await get(
      '/api/v2/tenants/${Uri.encodeComponent(t)}/databases/${Uri.encodeComponent(name)}',
    );
    return Database.fromJson(parseJson(response));
  }

  /// Deletes a database.
  ///
  /// [name] - The name of the database to delete.
  /// [tenant] - The tenant containing the database.
  ///   Defaults to the client's configured tenant.
  ///
  /// **WARNING**: This deletes the database and all its collections.
  ///
  /// Endpoint: `DELETE /api/v2/tenants/{tenant}/databases/{database}`
  Future<void> deleteByName({required String name, String? tenant}) async {
    final t = tenant ?? config.tenant;
    await delete(
      '/api/v2/tenants/${Uri.encodeComponent(t)}/databases/${Uri.encodeComponent(name)}',
    );
  }
}
