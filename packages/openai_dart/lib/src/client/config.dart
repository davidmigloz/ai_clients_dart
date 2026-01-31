import 'dart:io' show Platform;

import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../auth/auth_provider.dart';

/// Private sentinel class to distinguish "not provided" from "set to null".
///
/// Using a private class prevents callers from accidentally passing the sentinel
/// value, unlike `const Object()` which is globally canonicalized.
class _Unset {
  const _Unset();
}

/// Sentinel value for copyWith to distinguish "not provided" from "set to null".
const Object _unset = _Unset();

/// Configuration for the OpenAI client.
///
/// This class provides a centralized way to configure all aspects of the
/// OpenAI client, including authentication, timeouts, retry behavior,
/// and logging.
///
/// ## Example
///
/// ```dart
/// final config = OpenAIConfig(
///   authProvider: ApiKeyProvider('sk-...'),
///   timeout: Duration(seconds: 60),
///   maxRetries: 3,
///   logLevel: Level.INFO,
/// );
///
/// final client = OpenAIClient(config: config);
/// ```
@immutable
class OpenAIConfig {
  /// Creates a new [OpenAIConfig] with the given settings.
  const OpenAIConfig({
    this.authProvider,
    this.baseUrl = 'https://api.openai.com/v1',
    this.timeout = const Duration(minutes: 10),
    this.connectTimeout = const Duration(seconds: 30),
    this.maxRetries = 2,
    this.retryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(seconds: 30),
    this.logLevel,
    this.defaultHeaders = const {},
    this.apiVersion,
    this.organization,
    this.project,
  });

  /// Creates an [OpenAIConfig] using runtime environment variables.
  ///
  /// Reads `OPENAI_API_KEY` for the API key (required).
  /// Optionally reads:
  /// - `OPENAI_BASE_URL` for a custom base URL
  /// - `OPENAI_ORG_ID` for the organization ID
  /// - `OPENAI_PROJECT_ID` for the project ID
  ///
  /// All environment variables are read at runtime via [Platform.environment],
  /// consistent with [ApiKeyProvider.fromEnvironment].
  factory OpenAIConfig.fromEnvironment() {
    final baseUrl = Platform.environment['OPENAI_BASE_URL'];
    final orgId = Platform.environment['OPENAI_ORG_ID'];
    final projectId = Platform.environment['OPENAI_PROJECT_ID'];

    return OpenAIConfig(
      authProvider: ApiKeyProvider.fromEnvironment(),
      baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
          ? baseUrl
          : 'https://api.openai.com/v1',
      organization: (orgId != null && orgId.isNotEmpty) ? orgId : null,
      project: (projectId != null && projectId.isNotEmpty) ? projectId : null,
    );
  }

  /// The authentication provider for API requests.
  ///
  /// If not provided, you must set authentication headers manually
  /// using [defaultHeaders] or a custom interceptor.
  final AuthProvider? authProvider;

  /// The base URL for the OpenAI API.
  ///
  /// Defaults to `https://api.openai.com/v1`.
  ///
  /// Change this to use a different API endpoint, such as:
  /// - Azure OpenAI: `https://{resource}.openai.azure.com/openai/deployments/{deployment}`
  /// - Local proxy: `http://localhost:8080/v1`
  final String baseUrl;

  /// The timeout for individual HTTP requests.
  ///
  /// Defaults to 10 minutes to accommodate long-running operations
  /// like image generation and large file uploads.
  final Duration timeout;

  /// The timeout for establishing a connection.
  ///
  /// Defaults to 30 seconds.
  final Duration connectTimeout;

  /// The maximum number of retry attempts for failed requests.
  ///
  /// Defaults to 2. Set to 0 to disable retries.
  ///
  /// Retries are attempted for:
  /// - Network errors (connection failures, timeouts)
  /// - 429 (rate limit) responses
  /// - 5xx (server error) responses
  final int maxRetries;

  /// The initial delay between retry attempts.
  ///
  /// Defaults to 1 second. Uses exponential backoff with jitter.
  final Duration retryDelay;

  /// The maximum delay between retry attempts.
  ///
  /// Defaults to 30 seconds. The retry delay will not exceed this value
  /// even with exponential backoff.
  final Duration maxRetryDelay;

  /// The logging level for the client.
  ///
  /// If null, logging is disabled. Common levels:
  /// - [Level.FINE] for request/response details
  /// - [Level.INFO] for high-level operations
  /// - [Level.WARNING] for errors and retries
  final Level? logLevel;

  /// Additional headers to include with every request.
  ///
  /// These headers are merged with authentication headers and any
  /// request-specific headers. Request-specific headers take precedence.
  final Map<String, String> defaultHeaders;

  /// The API version to use.
  ///
  /// If set, this is included as the `OpenAI-Version` header.
  /// Leave null to use the default API version.
  final String? apiVersion;

  /// The organization ID to use for API requests.
  ///
  /// If set, this is included as the `OpenAI-Organization` header.
  /// This can also be set via [OrganizationApiKeyProvider].
  final String? organization;

  /// The project ID to use for API requests.
  ///
  /// If set, this is included as the `OpenAI-Project` header.
  final String? project;

  /// Creates a copy of this configuration with the given fields replaced.
  ///
  /// To clear a nullable field, pass `null` explicitly. Fields not provided
  /// retain their current values.
  OpenAIConfig copyWith({
    Object? authProvider = _unset,
    String? baseUrl,
    Duration? timeout,
    Duration? connectTimeout,
    int? maxRetries,
    Duration? retryDelay,
    Duration? maxRetryDelay,
    Object? logLevel = _unset,
    Map<String, String>? defaultHeaders,
    Object? apiVersion = _unset,
    Object? organization = _unset,
    Object? project = _unset,
  }) {
    return OpenAIConfig(
      authProvider:
          authProvider == _unset ? this.authProvider : authProvider as AuthProvider?,
      baseUrl: baseUrl ?? this.baseUrl,
      timeout: timeout ?? this.timeout,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      maxRetries: maxRetries ?? this.maxRetries,
      retryDelay: retryDelay ?? this.retryDelay,
      maxRetryDelay: maxRetryDelay ?? this.maxRetryDelay,
      logLevel: logLevel == _unset ? this.logLevel : logLevel as Level?,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      apiVersion: apiVersion == _unset ? this.apiVersion : apiVersion as String?,
      organization:
          organization == _unset ? this.organization : organization as String?,
      project: project == _unset ? this.project : project as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIConfig &&
        other.authProvider == authProvider &&
        other.baseUrl == baseUrl &&
        other.timeout == timeout &&
        other.connectTimeout == connectTimeout &&
        other.maxRetries == maxRetries &&
        other.retryDelay == retryDelay &&
        other.maxRetryDelay == maxRetryDelay &&
        other.logLevel == logLevel &&
        _mapEquals(other.defaultHeaders, defaultHeaders) &&
        other.apiVersion == apiVersion &&
        other.organization == organization &&
        other.project == project;
  }

  @override
  int get hashCode => Object.hash(
    authProvider,
    baseUrl,
    timeout,
    connectTimeout,
    maxRetries,
    retryDelay,
    maxRetryDelay,
    logLevel,
    // Use order-insensitive hash to match order-insensitive equality
    Object.hashAllUnordered(
      defaultHeaders.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    apiVersion,
    organization,
    project,
  );

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}

