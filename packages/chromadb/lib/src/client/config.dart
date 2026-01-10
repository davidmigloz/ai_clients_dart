import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import 'retry_wrapper.dart';

/// Configuration for the ChromaDB client.
///
/// This class configures all aspects of client behavior including:
/// - Server connection (URL, tenant, database)
/// - Authentication
/// - Timeouts and retry behavior
/// - Logging
///
/// Example:
/// ```dart
/// final config = ChromaConfig(
///   baseUrl: 'https://api.trychroma.com',
///   authProvider: ApiKeyProvider('your-api-key'),
///   tenant: 'my-tenant',
///   database: 'my-database',
/// );
///
/// final client = ChromaClient(config: config);
/// ```
class ChromaConfig {
  /// The base URL for the ChromaDB server.
  ///
  /// Defaults to `http://localhost:8000` for local development.
  final String baseUrl;

  /// The tenant to use for multi-tenant deployments.
  ///
  /// Defaults to `default_tenant`.
  final String tenant;

  /// The database to use within the tenant.
  ///
  /// Defaults to `default_database`.
  final String database;

  /// The authentication provider to use.
  ///
  /// Defaults to [NoAuthProvider] for local instances.
  final AuthProvider authProvider;

  /// Timeout for individual requests.
  ///
  /// Defaults to 30 seconds.
  final Duration timeout;

  /// Policy for retrying failed requests.
  ///
  /// Defaults to [RetryPolicy] with 3 retries.
  final RetryPolicy retryPolicy;

  /// The minimum log level for HTTP logging.
  ///
  /// Set to [Level.OFF] to disable logging.
  /// Defaults to [Level.INFO].
  final Level logLevel;

  /// Creates a ChromaDB configuration.
  ///
  /// All parameters have sensible defaults for local development:
  /// - [baseUrl]: `http://localhost:8000`
  /// - [tenant]: `default_tenant`
  /// - [database]: `default_database`
  /// - [authProvider]: No authentication
  /// - [timeout]: 30 seconds
  /// - [retryPolicy]: 3 retries with exponential backoff
  /// - [logLevel]: INFO
  const ChromaConfig({
    this.baseUrl = 'http://localhost:8000',
    this.tenant = 'default_tenant',
    this.database = 'default_database',
    this.authProvider = const NoAuthProvider(),
    this.timeout = const Duration(seconds: 30),
    this.retryPolicy = const RetryPolicy(),
    this.logLevel = Level.INFO,
  });

  /// Creates a copy of this configuration with optional modifications.
  ChromaConfig copyWith({
    String? baseUrl,
    String? tenant,
    String? database,
    AuthProvider? authProvider,
    Duration? timeout,
    RetryPolicy? retryPolicy,
    Level? logLevel,
  }) {
    return ChromaConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      tenant: tenant ?? this.tenant,
      database: database ?? this.database,
      authProvider: authProvider ?? this.authProvider,
      timeout: timeout ?? this.timeout,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      logLevel: logLevel ?? this.logLevel,
    );
  }
}
