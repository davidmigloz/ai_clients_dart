/// Provides authentication credentials for ChromaDB API requests.
///
/// Implement this interface to supply custom authentication logic.
///
/// Example:
/// ```dart
/// class ApiKeyProvider implements AuthProvider {
///   final String apiKey;
///   const ApiKeyProvider(this.apiKey);
///
///   @override
///   Future<AuthCredentials> getCredentials() async =>
///       ApiKeyCredentials(apiKey: apiKey);
/// }
/// ```
abstract interface class AuthProvider {
  /// Returns the authentication credentials to use for API requests.
  ///
  /// This method is called before each request to get fresh credentials,
  /// enabling dynamic credential refresh if needed.
  Future<AuthCredentials> getCredentials();
}

/// Represents authentication credentials for API requests.
///
/// This is a sealed class with specific implementations for each
/// authentication type supported by ChromaDB.
sealed class AuthCredentials {
  const AuthCredentials();
}

/// Indicates no authentication should be used.
///
/// Use this for local ChromaDB instances without authentication.
class NoAuthCredentials extends AuthCredentials {
  /// Creates credentials indicating no authentication.
  const NoAuthCredentials();
}

/// API key authentication using the `x-chroma-token` header.
///
/// This is the standard authentication method for ChromaDB Cloud
/// and secured self-hosted instances.
class ApiKeyCredentials extends AuthCredentials {
  /// The API key to use for authentication.
  final String apiKey;

  /// Creates API key credentials.
  const ApiKeyCredentials({required this.apiKey});
}

/// Bearer token authentication using the `Authorization` header.
///
/// Some ChromaDB deployments may use OAuth or JWT tokens.
class BearerTokenCredentials extends AuthCredentials {
  /// The bearer token to use for authentication.
  final String token;

  /// Creates bearer token credentials.
  const BearerTokenCredentials({required this.token});
}

// ============================================================================
// Built-in Providers
// ============================================================================

/// Provider that supplies no authentication credentials.
///
/// Use this for local ChromaDB instances without authentication configured.
class NoAuthProvider implements AuthProvider {
  /// Creates a no-auth provider.
  const NoAuthProvider();

  @override
  Future<AuthCredentials> getCredentials() async => const NoAuthCredentials();
}

/// Provider for API key authentication.
///
/// ChromaDB uses the `x-chroma-token` header for API key authentication.
///
/// Example:
/// ```dart
/// final client = ChromaClient(
///   config: ChromaConfig(
///     baseUrl: 'https://api.trychroma.com',
///     authProvider: ApiKeyProvider('your-api-key'),
///   ),
/// );
/// ```
class ApiKeyProvider implements AuthProvider {
  /// The API key to use for authentication.
  final String apiKey;

  /// Creates an API key provider with the given [apiKey].
  const ApiKeyProvider(this.apiKey);

  @override
  Future<AuthCredentials> getCredentials() async =>
      ApiKeyCredentials(apiKey: apiKey);
}

/// Provider for bearer token authentication.
///
/// Some ChromaDB deployments may use OAuth or JWT tokens for authentication.
///
/// Example:
/// ```dart
/// final client = ChromaClient(
///   config: ChromaConfig(
///     baseUrl: 'https://your-chroma-instance.com',
///     authProvider: BearerTokenProvider('your-jwt-token'),
///   ),
/// );
/// ```
class BearerTokenProvider implements AuthProvider {
  /// The bearer token to use for authentication.
  final String token;

  /// Creates a bearer token provider with the given [token].
  const BearerTokenProvider(this.token);

  @override
  Future<AuthCredentials> getCredentials() async =>
      BearerTokenCredentials(token: token);
}
