/// Authentication provider interface for the Ollama client.
///
/// This interface allows for dynamic authentication credential retrieval.
/// For local Ollama instances, authentication is typically not required.
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

/// Simple bearer token provider with static credentials.
///
/// This provider returns the same bearer token on every call to [getCredentials].
///
/// Example:
/// ```dart
/// final client = OllamaClient(
///   config: OllamaConfig(
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
/// This is the default for local Ollama instances which typically
/// don't require authentication.
///
/// Example:
/// ```dart
/// final client = OllamaClient(
///   config: OllamaConfig(
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
