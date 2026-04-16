import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../embeddings/embedding_function.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../loaders/data_loader.dart';
import '../models/collections/collection.dart';
import '../resources/auth_resource.dart';
import '../resources/collections_resource.dart';
import '../resources/databases_resource.dart';
import '../resources/functions_resource.dart';
import '../resources/health_resource.dart';
import '../resources/records_resource.dart';
import '../resources/tenants_resource.dart';
import '../wrappers/chroma_collection.dart';
import 'config.dart';
import 'interceptor_chain.dart';
import 'request_builder.dart';
import 'retry_wrapper.dart';

/// Client for interacting with the ChromaDB vector database API.
///
/// This is the main entry point for using the ChromaDB Dart client.
/// It provides access to all API resources and handles authentication,
/// retries, and logging.
///
/// ## Basic Usage
///
/// ```dart
/// // Create a client for local ChromaDB instance
/// final client = ChromaClient();
///
/// // Check server health
/// final heartbeat = await client.health.heartbeat();
///
/// // Don't forget to close when done
/// client.close();
/// ```
///
/// ## With Authentication
///
/// ```dart
/// final client = ChromaClient(
///   config: ChromaConfig(
///     baseUrl: 'https://api.trychroma.com',
///     authProvider: ApiKeyProvider('your-api-key'),
///   ),
/// );
/// ```
///
/// ## Factory Constructors
///
/// For convenience, factory constructors are provided for common configurations:
///
/// ```dart
/// // Local instance
/// final local = ChromaClient.local();
///
/// // With API key
/// final cloud = ChromaClient.withApiKey('your-key',
///   baseUrl: 'https://api.trychroma.com',
/// );
/// ```
class ChromaClient {
  /// The client configuration.
  final ChromaConfig config;

  final http.Client _httpClient;
  final bool _ownsHttpClient;
  bool _closed = false;

  late final RequestBuilder _requestBuilder;
  late final InterceptorChain _interceptorChain;

  /// Resource for authentication endpoints.
  late final AuthResource auth;

  /// Resource for collection management endpoints.
  late final CollectionsResource collections;

  /// Resource for database management endpoints.
  late final DatabasesResource databases;

  /// Resource for health and status endpoints.
  late final HealthResource health;

  /// Resource for tenant management endpoints.
  late final TenantsResource tenants;

  /// Creates a ChromaDB client with the given configuration.
  ///
  /// If [httpClient] is not provided, a new one will be created and
  /// automatically closed when [close] is called.
  ChromaClient({ChromaConfig? config, http.Client? httpClient})
    : config = config ?? const ChromaConfig(),
      _httpClient = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null {
    _initialize();
  }

  /// Creates a client for a local ChromaDB instance.
  ///
  /// This is a convenience constructor for development with a local server.
  factory ChromaClient.local({
    int port = 8000,
    Map<String, String> defaultHeaders = const {},
  }) {
    return ChromaClient(
      config: ChromaConfig(
        baseUrl: 'http://localhost:$port',
        defaultHeaders: defaultHeaders,
      ),
    );
  }

  /// Creates a client with API key authentication.
  ///
  /// This is a convenience constructor for connecting to ChromaDB Cloud
  /// or a secured self-hosted instance.
  factory ChromaClient.withApiKey(
    String apiKey, {
    String baseUrl = 'http://localhost:8000',
    String tenant = 'default_tenant',
    String database = 'default_database',
    Map<String, String> defaultHeaders = const {},
  }) {
    return ChromaClient(
      config: ChromaConfig(
        baseUrl: baseUrl,
        tenant: tenant,
        database: database,
        authProvider: ApiKeyProvider(apiKey),
        defaultHeaders: defaultHeaders,
      ),
    );
  }

  void _ensureNotClosed() {
    if (_closed) {
      throw StateError('Client has been closed');
    }
  }

  void _initialize() {
    // Configure logging
    if (config.logLevel != Level.OFF) {
      Logger.root.level = config.logLevel;
    }

    // Build request builder
    _requestBuilder = RequestBuilder(
      baseUrl: config.baseUrl,
      defaultHeaders: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'User-Agent': 'chromadb-dart',
        ...config.defaultHeaders, // User headers can override built-in
      },
    );

    // Build interceptor chain
    final interceptors = <Interceptor>[
      AuthInterceptor(authProvider: config.authProvider),
      const LoggingInterceptor(),
      const ErrorInterceptor(),
    ];

    // Build retry wrapper if retries are enabled
    final retryWrapper = config.retryPolicy.maxRetries > 0
        ? RetryWrapper(config: config)
        : null;

    _interceptorChain = InterceptorChain(
      interceptors: interceptors,
      httpClient: _httpClient,
      retryWrapper: retryWrapper,
      ensureNotClosed: _ensureNotClosed,
    );

    // Initialize resources
    auth = AuthResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );

    collections = CollectionsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );

    databases = DatabasesResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );

    health = HealthResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );

    tenants = TenantsResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
  }

  /// Returns a records resource for the specified collection.
  ///
  /// [collectionId] - The collection ID (UUID).
  /// [tenant] - The tenant containing the collection.
  ///   Defaults to the client's configured tenant.
  /// [database] - The database containing the collection.
  ///   Defaults to the client's configured database.
  ///
  /// Example:
  /// ```dart
  /// final records = client.records('collection-id');
  /// await records.add(ids: ['id1'], documents: ['Hello']);
  /// ```
  RecordsResource records(
    String collectionId, {
    String? tenant,
    String? database,
  }) {
    _ensureNotClosed();
    return RecordsResource(
      collectionId: collectionId,
      tenant: tenant,
      database: database,
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
  }

  /// Returns a functions resource for the specified collection.
  ///
  /// [collectionId] - The collection ID (UUID).
  /// [tenant] - The tenant containing the collection.
  ///   Defaults to the client's configured tenant.
  /// [database] - The database containing the collection.
  ///   Defaults to the client's configured database.
  ///
  /// Example:
  /// ```dart
  /// final functions = client.functions('collection-id');
  /// await functions.attach(
  ///   name: 'processor',
  ///   functionId: 'embed_processor',
  ///   outputCollection: 'processed',
  /// );
  /// ```
  FunctionsResource functions(
    String collectionId, {
    String? tenant,
    String? database,
  }) {
    _ensureNotClosed();
    return FunctionsResource(
      collectionId: collectionId,
      tenant: tenant,
      database: database,
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
  }

  // ===========================================================================
  // Collection Convenience Methods
  // ===========================================================================

  /// Gets or creates a collection with the given name.
  ///
  /// If the collection exists, it is returned.
  /// If not, a new collection is created.
  ///
  /// [name] - The collection name.
  /// [metadata] - Optional metadata for the collection.
  /// [embeddingFunction] - Optional embedding function for auto-embedding.
  /// [dataLoader] - Optional data loader for loading data from URIs.
  /// [tenant] - The tenant (defaults to client's configured tenant).
  /// [database] - The database (defaults to client's configured database).
  ///
  /// Example:
  /// ```dart
  /// final collection = await client.getOrCreateCollection(
  ///   name: 'my-docs',
  ///   embeddingFunction: myEmbedder,
  /// );
  /// await collection.add(ids: ['id1'], documents: ['Hello world']);
  /// ```
  Future<ChromaCollection> getOrCreateCollection({
    required String name,
    Map<String, dynamic>? metadata,
    EmbeddingFunction? embeddingFunction,
    DataLoader<Loadable>? dataLoader,
    String? tenant,
    String? database,
  }) async {
    final collection = await collections.create(
      name: name,
      metadata: metadata,
      getOrCreate: true,
      tenant: tenant,
      database: database,
    );

    return ChromaCollection(
      records: records(collection.id, tenant: tenant, database: database),
      collections: collections,
      functions: functions(collection.id, tenant: tenant, database: database),
      metadata: collection,
      embeddingFunction: embeddingFunction,
      dataLoader: dataLoader,
    );
  }

  /// Creates a new collection.
  ///
  /// Throws if a collection with the given name already exists.
  ///
  /// [name] - The collection name.
  /// [metadata] - Optional metadata for the collection.
  /// [embeddingFunction] - Optional embedding function for auto-embedding.
  /// [dataLoader] - Optional data loader for loading data from URIs.
  /// [tenant] - The tenant (defaults to client's configured tenant).
  /// [database] - The database (defaults to client's configured database).
  Future<ChromaCollection> createCollection({
    required String name,
    Map<String, dynamic>? metadata,
    EmbeddingFunction? embeddingFunction,
    DataLoader<Loadable>? dataLoader,
    String? tenant,
    String? database,
  }) async {
    final collection = await collections.create(
      name: name,
      metadata: metadata,
      getOrCreate: false,
      tenant: tenant,
      database: database,
    );

    return ChromaCollection(
      records: records(collection.id, tenant: tenant, database: database),
      collections: collections,
      functions: functions(collection.id, tenant: tenant, database: database),
      metadata: collection,
      embeddingFunction: embeddingFunction,
      dataLoader: dataLoader,
    );
  }

  /// Gets an existing collection by name.
  ///
  /// Throws if the collection does not exist.
  ///
  /// [name] - The collection name.
  /// [embeddingFunction] - Optional embedding function for auto-embedding.
  /// [dataLoader] - Optional data loader for loading data from URIs.
  /// [tenant] - The tenant (defaults to client's configured tenant).
  /// [database] - The database (defaults to client's configured database).
  Future<ChromaCollection> getCollection({
    required String name,
    EmbeddingFunction? embeddingFunction,
    DataLoader<Loadable>? dataLoader,
    String? tenant,
    String? database,
  }) async {
    final collection = await collections.getByName(
      name: name,
      tenant: tenant,
      database: database,
    );

    return ChromaCollection(
      records: records(collection.id, tenant: tenant, database: database),
      collections: collections,
      functions: functions(collection.id, tenant: tenant, database: database),
      metadata: collection,
      embeddingFunction: embeddingFunction,
      dataLoader: dataLoader,
    );
  }

  /// Gets an existing collection by ID.
  ///
  /// Throws if the collection does not exist.
  ///
  /// [collectionId] - The collection UUID.
  /// [embeddingFunction] - Optional embedding function for auto-embedding.
  /// [dataLoader] - Optional data loader for loading data from URIs.
  /// [tenant] - The tenant (defaults to client's configured tenant).
  /// [database] - The database (defaults to client's configured database).
  Future<ChromaCollection> getCollectionById({
    required String collectionId,
    EmbeddingFunction? embeddingFunction,
    DataLoader<Loadable>? dataLoader,
    String? tenant,
    String? database,
  }) async {
    final collection = await collections.getById(
      collectionId: collectionId,
      tenant: tenant,
      database: database,
    );

    return ChromaCollection(
      records: records(collection.id, tenant: tenant, database: database),
      collections: collections,
      functions: functions(collection.id, tenant: tenant, database: database),
      metadata: collection,
      embeddingFunction: embeddingFunction,
      dataLoader: dataLoader,
    );
  }

  /// Lists all collections in the database.
  ///
  /// [limit] - Maximum number of collections to return.
  /// [offset] - Number of collections to skip.
  /// [tenant] - The tenant (defaults to client's configured tenant).
  /// [database] - The database (defaults to client's configured database).
  Future<List<Collection>> listCollections({
    int? limit,
    int? offset,
    String? tenant,
    String? database,
  }) {
    return collections.list(
      limit: limit,
      offset: offset,
      tenant: tenant,
      database: database,
    );
  }

  /// Deletes a collection by name.
  ///
  /// [name] - The collection name.
  /// [tenant] - The tenant (defaults to client's configured tenant).
  /// [database] - The database (defaults to client's configured database).
  Future<void> deleteCollection({
    required String name,
    String? tenant,
    String? database,
  }) {
    return collections.deleteByName(
      name: name,
      tenant: tenant,
      database: database,
    );
  }

  /// Counts the number of collections in the database.
  ///
  /// [tenant] - The tenant (defaults to client's configured tenant).
  /// [database] - The database (defaults to client's configured database).
  Future<int> countCollections({String? tenant, String? database}) {
    return collections.count(tenant: tenant, database: database);
  }

  /// Closes the client and releases resources.
  ///
  /// After calling this method, any subsequent requests will throw
  /// [StateError]. This method is idempotent and can be called multiple
  /// times safely.
  ///
  /// If a custom [http.Client] was provided to the constructor,
  /// it will not be closed by this method.
  void close() {
    if (_closed) return;
    _closed = true;
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }
}
