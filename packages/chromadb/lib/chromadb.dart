/// Dart client for the ChromaDB vector database API.
///
/// This library provides a type-safe, well-documented interface to ChromaDB
/// for Dart and Flutter applications.
///
/// ## Quick Start
///
/// ```dart
/// import 'package:chromadb/chromadb.dart';
///
/// void main() async {
///   // Create a client for local ChromaDB instance
///   final client = ChromaClient();
///
///   // Check server health
///   final heartbeat = await client.health.heartbeat();
///   print('Server time: ${heartbeat.nanosecondHeartbeat}');
///
///   // Get server version
///   final version = await client.health.version();
///   print('Server version: ${version.version}');
///
///   // Clean up
///   client.close();
/// }
/// ```
///
/// ## Authentication
///
/// For ChromaDB Cloud or secured instances, provide an API key:
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
/// ## Multi-Tenant Support
///
/// Specify tenant and database for multi-tenant deployments:
///
/// ```dart
/// final client = ChromaClient(
///   config: ChromaConfig(
///     tenant: 'my-tenant',
///     database: 'my-database',
///   ),
/// );
/// ```
library;

// Authentication
export 'src/auth/auth_provider.dart';

// Client
export 'src/client/chromadb_client.dart';
export 'src/client/config.dart' show ChromaConfig;
export 'src/client/retry_wrapper.dart' show RetryPolicy;

// Embeddings
export 'src/embeddings/embedding_function.dart';

// Errors
export 'src/errors/exceptions.dart';

// Loaders
export 'src/loaders/data_loader.dart';

// Models - Auth
export 'src/models/auth/user_identity.dart';

// Models - Collections
export 'src/models/collections/collection.dart';
export 'src/models/collections/collection_configuration.dart';
export 'src/models/collections/collection_schema.dart';
export 'src/models/collections/create_collection_request.dart';
export 'src/models/collections/fork_count_response.dart';
export 'src/models/collections/quantization.dart';
export 'src/models/collections/spann_index_config.dart';
export 'src/models/collections/update_collection_request.dart';

// Models - Databases
export 'src/models/databases/create_database_request.dart';
export 'src/models/databases/database.dart';

// Models - Functions
export 'src/models/functions/attach_function_request.dart';
export 'src/models/functions/attach_function_response.dart';
export 'src/models/functions/attached_function.dart';
export 'src/models/functions/attached_function_info.dart';
export 'src/models/functions/detach_function_request.dart';
export 'src/models/functions/detach_function_response.dart';
export 'src/models/functions/get_attached_function_response.dart';

// Models - Metadata
export 'src/models/metadata/heartbeat_response.dart';
export 'src/models/metadata/version_response.dart';

// Models - Records
export 'src/models/records/delete_collection_records_response.dart';
export 'src/models/records/get_response.dart';
export 'src/models/records/include.dart';
export 'src/models/records/index_status_response.dart';
export 'src/models/records/query_response.dart';
export 'src/models/records/read_level.dart';
export 'src/models/records/search_request.dart';
export 'src/models/records/search_response.dart';

// Models - Tenants
export 'src/models/tenants/create_tenant_request.dart';
export 'src/models/tenants/tenant.dart';
export 'src/models/tenants/update_tenant_request.dart';

// Resources
export 'src/resources/auth_resource.dart';
export 'src/resources/collections_resource.dart';
export 'src/resources/databases_resource.dart';
export 'src/resources/functions_resource.dart';
export 'src/resources/health_resource.dart';
export 'src/resources/records_resource.dart';
export 'src/resources/tenants_resource.dart';

// Wrappers
export 'src/wrappers/chroma_collection.dart';
