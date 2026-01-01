/// Authentication provider interface for the Mistral AI client.
///
/// This interface allows for dynamic authentication credential retrieval.
/// Mistral AI requires an API key for all requests.
abstract interface class AuthProvider {
  /// Retrieves authentication credentials.
  Future<AuthCredentials> getCredentials();
}

/// Authentication credentials returned by [AuthProvider].
sealed class AuthCredentials {
  /// Creates an [AuthCredentials].
  const AuthCredentials();
}

/// Bearer token authentication credentials.
class BearerTokenCredentials extends AuthCredentials {
  /// The bearer token to use for authentication.
  final String token;

  /// Creates [BearerTokenCredentials].
  const BearerTokenCredentials(this.token);
}

/// No authentication credentials.
class NoAuthCredentials extends AuthCredentials {
  /// Creates [NoAuthCredentials].
  const NoAuthCredentials();
}

/// API key authentication provider.
///
/// This is the standard authentication method for Mistral AI.
/// The API key is sent as a Bearer token in the Authorization header.
///
/// Example:
/// ```dart
/// final client = MistralClient(
///   config: MistralConfig(
///     authProvider: ApiKeyProvider('YOUR_API_KEY'),
///   ),
/// );
/// ```
class ApiKeyProvider implements AuthProvider {
  /// The API key to use for authentication.
  final String apiKey;

  /// Creates an [ApiKeyProvider].
  const ApiKeyProvider(this.apiKey);

  @override
  Future<AuthCredentials> getCredentials() async {
    return BearerTokenCredentials(apiKey);
  }
}

/// Simple bearer token provider with static credentials.
///
/// This provider returns the same bearer token on every call to [getCredentials].
/// This is an alias for [ApiKeyProvider] for consistency with other clients.
///
/// Example:
/// ```dart
/// final client = MistralClient(
///   config: MistralConfig(
///     authProvider: BearerTokenProvider('YOUR_TOKEN'),
///   ),
/// );
/// ```
class BearerTokenProvider implements AuthProvider {
  /// The bearer token to use for authentication.
  final String token;

  /// Creates a [BearerTokenProvider].
  const BearerTokenProvider(this.token);

  @override
  Future<AuthCredentials> getCredentials() async {
    return BearerTokenCredentials(token);
  }
}

/// Provider that returns no authentication credentials.
///
/// This is generally not useful for Mistral AI as authentication is required,
/// but is provided for testing or edge cases.
///
/// Example:
/// ```dart
/// final client = MistralClient(
///   config: MistralConfig(
///     authProvider: NoAuthProvider(),
///   ),
/// );
/// ```
class NoAuthProvider implements AuthProvider {
  /// Creates a [NoAuthProvider].
  const NoAuthProvider();

  @override
  Future<AuthCredentials> getCredentials() async {
    return const NoAuthCredentials();
  }
}
