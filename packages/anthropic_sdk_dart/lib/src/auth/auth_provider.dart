/// API beta enabling OAuth bearer authentication.
const oauthBetaHeader = 'oauth-2025-04-20';

/// Authentication provider interface for the Anthropic client.
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

/// API key authentication credentials.
///
/// Anthropic uses `x-api-key` header for authentication.
class ApiKeyCredentials extends AuthCredentials {
  /// The API key to use for authentication.
  final String apiKey;

  /// Creates [ApiKeyCredentials].
  const ApiKeyCredentials(this.apiKey);
}

/// OAuth credentials sent in the Authorization header.
final class BearerTokenCredentials extends AuthCredentials {
  /// Creates bearer credentials. A workspace-scoped token cannot be rerouted
  /// with an `anthropic-workspace-id` header.
  const BearerTokenCredentials(this.token, {this.workspaceScoped = false});

  /// The OAuth access token.
  final String token;

  /// Whether the token already identifies its workspace.
  final bool workspaceScoped;

  @override
  String toString() => 'BearerTokenCredentials([REDACTED])';
}

/// No authentication credentials.
class NoAuthCredentials extends AuthCredentials {
  /// Creates [NoAuthCredentials].
  const NoAuthCredentials();
}

/// Simple API key provider with static credentials.
///
/// This provider returns the same API key on every call to [getCredentials].
///
/// Example:
/// ```dart
/// final client = AnthropicClient(
///   config: AnthropicConfig(
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
    return ApiKeyCredentials(apiKey);
  }
}

/// Provider for an existing OAuth access token.
final class BearerTokenProvider implements AuthProvider {
  /// Creates a provider for [token].
  const BearerTokenProvider(this.token);

  /// The OAuth access token.
  final String token;

  @override
  Future<AuthCredentials> getCredentials() async =>
      BearerTokenCredentials(token);

  @override
  String toString() => 'BearerTokenProvider([REDACTED])';
}

/// Provider that returns no authentication credentials.
class NoAuthProvider implements AuthProvider {
  /// Creates a [NoAuthProvider].
  const NoAuthProvider();

  @override
  Future<AuthCredentials> getCredentials() async {
    return const NoAuthCredentials();
  }
}
