import '../platform/environment.dart';

/// Abstract interface for providing authentication credentials.
///
/// Implementations of this interface provide different authentication
/// strategies for the OpenAI API.
abstract interface class AuthProvider {
  /// Returns a map of HTTP headers to be included with each request.
  ///
  /// These headers typically include the `Authorization` header with
  /// the appropriate credentials.
  Map<String, String> getHeaders();
}

/// Provides API key authentication for the OpenAI API.
///
/// Uses the standard `Authorization: Bearer <api_key>` header format.
///
/// ## Example
///
/// ```dart
/// final auth = ApiKeyProvider('sk-...');
/// final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
/// ```
class ApiKeyProvider implements AuthProvider {
  /// Creates an [ApiKeyProvider] with the given API key.
  const ApiKeyProvider(this.apiKey);

  /// Creates an [ApiKeyProvider] from the `OPENAI_API_KEY` environment variable.
  ///
  /// Throws [StateError] if the environment variable is not set.
  /// Throws [UnsupportedError] on web platforms where environment variables
  /// are not available.
  factory ApiKeyProvider.fromEnvironment([String envVar = 'OPENAI_API_KEY']) {
    final apiKey = getEnvironmentVariable(envVar);
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError(
        'Environment variable $envVar is not set. '
        'Please set it to your OpenAI API key.',
      );
    }
    return ApiKeyProvider(apiKey);
  }

  /// The OpenAI API key.
  final String apiKey;

  @override
  Map<String, String> getHeaders() {
    return {'Authorization': 'Bearer $apiKey'};
  }
}

/// Provides organization-scoped authentication for the OpenAI API.
///
/// Includes both the API key and the organization ID in the request headers.
/// This is useful when your API key has access to multiple organizations.
///
/// ## Example
///
/// ```dart
/// final auth = OrganizationApiKeyProvider(
///   apiKey: 'sk-...',
///   organization: 'org-...',
/// );
/// final client = OpenAIClient(config: OpenAIConfig(authProvider: auth));
/// ```
class OrganizationApiKeyProvider implements AuthProvider {
  /// Creates an [OrganizationApiKeyProvider] with the given credentials.
  const OrganizationApiKeyProvider({
    required this.apiKey,
    required this.organization,
    this.project,
  });

  /// Creates an [OrganizationApiKeyProvider] from environment variables.
  ///
  /// Uses `OPENAI_API_KEY` for the API key and `OPENAI_ORG_ID` for the
  /// organization ID. Optionally reads `OPENAI_PROJECT_ID` for the project.
  ///
  /// Throws [StateError] if required environment variables are not set.
  /// Throws [UnsupportedError] on web platforms where environment variables
  /// are not available.
  factory OrganizationApiKeyProvider.fromEnvironment() {
    final apiKey = getEnvironmentVariable('OPENAI_API_KEY');
    final organization = getEnvironmentVariable('OPENAI_ORG_ID');
    final project = getEnvironmentVariable('OPENAI_PROJECT_ID');

    if (apiKey == null || apiKey.isEmpty) {
      throw StateError(
        'Environment variable OPENAI_API_KEY is not set. '
        'Please set it to your OpenAI API key.',
      );
    }
    if (organization == null || organization.isEmpty) {
      throw StateError(
        'Environment variable OPENAI_ORG_ID is not set. '
        'Please set it to your OpenAI organization ID.',
      );
    }

    return OrganizationApiKeyProvider(
      apiKey: apiKey,
      organization: organization,
      project: project,
    );
  }

  /// The OpenAI API key.
  final String apiKey;

  /// The OpenAI organization ID.
  final String organization;

  /// Optional OpenAI project ID.
  final String? project;

  @override
  Map<String, String> getHeaders() {
    final headers = {
      'Authorization': 'Bearer $apiKey',
      'OpenAI-Organization': organization,
    };
    if (project case final p?) {
      headers['OpenAI-Project'] = p;
    }
    return headers;
  }
}

/// Provides Azure OpenAI Service authentication.
///
/// Uses the `api-key` header format required by Azure OpenAI.
///
/// ## Example
///
/// ```dart
/// final auth = AzureApiKeyProvider('your-azure-api-key');
/// final client = OpenAIClient(
///   config: OpenAIConfig(
///     authProvider: auth,
///     baseUrl: 'https://your-resource.openai.azure.com',
///   ),
/// );
/// ```
class AzureApiKeyProvider implements AuthProvider {
  /// Creates an [AzureApiKeyProvider] with the given API key.
  const AzureApiKeyProvider(this.apiKey);

  /// Creates an [AzureApiKeyProvider] from the `AZURE_OPENAI_API_KEY`
  /// environment variable.
  ///
  /// Throws [StateError] if the environment variable is not set.
  /// Throws [UnsupportedError] on web platforms where environment variables
  /// are not available.
  factory AzureApiKeyProvider.fromEnvironment([
    String envVar = 'AZURE_OPENAI_API_KEY',
  ]) {
    final apiKey = getEnvironmentVariable(envVar);
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError(
        'Environment variable $envVar is not set. '
        'Please set it to your Azure OpenAI API key.',
      );
    }
    return AzureApiKeyProvider(apiKey);
  }

  /// The Azure OpenAI API key.
  final String apiKey;

  @override
  Map<String, String> getHeaders() {
    return {'api-key': apiKey};
  }
}
