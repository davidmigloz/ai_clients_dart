/// Authentication provider interface for the OpenResponses client.
///
/// This interface allows for dynamic authentication credential retrieval.
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
///
/// OpenResponses uses `Authorization: Bearer <token>` header for authentication.
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

/// Simple bearer token provider with static credentials.
///
/// This provider returns the same token on every call to [getCredentials].
///
/// Example:
/// ```dart
/// final client = OpenResponsesClient(
///   config: OpenResponsesConfig(
///     authProvider: BearerTokenProvider('YOUR_API_KEY'),
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
/// Use this for local providers like Ollama that don't require authentication.
class NoAuthProvider implements AuthProvider {
  /// Creates a [NoAuthProvider].
  const NoAuthProvider();

  @override
  Future<AuthCredentials> getCredentials() async {
    return const NoAuthCredentials();
  }
}
