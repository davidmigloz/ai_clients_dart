import 'package:logging/logging.dart';
import 'package:meta/meta.dart';

import '../auth/auth_provider.dart';
import '../models/common/copy_with_sentinel.dart';
import '../platform/environment.dart';
import '../providers/vertex_provider.dart';
import 'data_residency.dart';

/// Retry policy configuration.
@immutable
class RetryPolicy {
  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Initial delay before first retry.
  final Duration initialDelay;

  /// Maximum exponential-backoff delay.
  ///
  /// A server hint up to twice this duration is honored in full. A larger
  /// valid hint returns the original HTTP error instead of retrying early.
  /// The parsed hint remains available on rate-limit/server exceptions.
  final Duration maxDelay;

  /// Jitter factor (0.0 - 1.0).
  final double jitter;

  /// Creates a [RetryPolicy].
  ///
  /// [maxRetries] must be >= 0 and [jitter] must be between 0.0 and 1.0.
  /// [initialDelay] should be positive and [maxDelay] should be >=
  /// [initialDelay] (not enforced via asserts to preserve const
  /// constructability, since [Duration] operations are not const-evaluable).
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 60),
    this.jitter = 0.1,
  }) : assert(maxRetries >= 0, 'maxRetries must be >= 0'),
       assert(jitter >= 0.0 && jitter <= 1.0, 'jitter must be 0.0 - 1.0');

  /// Default retry policy (3 retries, 1s initial delay, 60s max delay).
  static const defaultPolicy = RetryPolicy();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RetryPolicy &&
        other.maxRetries == maxRetries &&
        other.initialDelay == initialDelay &&
        other.maxDelay == maxDelay &&
        other.jitter == jitter;
  }

  @override
  int get hashCode => Object.hash(maxRetries, initialDelay, maxDelay, jitter);
}

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
///   retryPolicy: RetryPolicy(maxRetries: 3),
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
    this.retryPolicy = RetryPolicy.defaultPolicy,
    this.logLevel,
    this.defaultHeaders = const {},
    this.apiVersion,
    this.organization,
    this.project,
    this.webhookSecret,
    this.vertexProvider,
  });

  /// Configures the supported HTTP/SSE Responses lifecycle through Vertex.
  ///
  /// Authentication belongs to [provider]. OpenAI auth, organization and project
  /// headers are intentionally absent. Native credential discovery is separate:
  /// the application supplies a refreshing token callback on every platform.
  factory OpenAIConfig.vertex({
    required VertexProvider provider,
    Duration timeout = const Duration(minutes: 10),
    Duration connectTimeout = const Duration(seconds: 30),
    RetryPolicy retryPolicy = RetryPolicy.defaultPolicy,
    Level? logLevel,
    Map<String, String> defaultHeaders = const {},
  }) => OpenAIConfig(
    vertexProvider: provider,
    baseUrl: provider.baseUrl,
    timeout: timeout,
    connectTimeout: connectTimeout,
    retryPolicy: retryPolicy,
    logLevel: logLevel,
    defaultHeaders: defaultHeaders,
  );

  /// Selects a named OpenAI endpoint from the pinned official SDK mapping.
  ///
  /// Endpoint selection does not configure project residency or guarantee that
  /// a model/service supports regional processing. Google Vertex locations use
  /// [OpenAIConfig.vertex] instead. A custom base URL is an explicit alternative.
  factory OpenAIConfig.forDataResidency(
    OpenAIDataResidency region, {
    AuthProvider? authProvider,
    Duration timeout = const Duration(minutes: 10),
    Duration connectTimeout = const Duration(seconds: 30),
    RetryPolicy retryPolicy = RetryPolicy.defaultPolicy,
    Level? logLevel,
    Map<String, String> defaultHeaders = const {},
    String? apiVersion,
    String? organization,
    String? project,
    String? webhookSecret,
  }) => OpenAIConfig(
    baseUrl: region.baseUrl,
    authProvider: authProvider,
    timeout: timeout,
    connectTimeout: connectTimeout,
    retryPolicy: retryPolicy,
    logLevel: logLevel,
    defaultHeaders: defaultHeaders,
    apiVersion: apiVersion,
    organization: organization,
    project: project,
    webhookSecret: webhookSecret,
  );

  /// Creates an [OpenAIConfig] using runtime environment variables.
  ///
  /// Reads `OPENAI_API_KEY` for the API key (required).
  /// Optionally reads:
  /// - `OPENAI_BASE_URL` for a custom base URL
  /// - `OPENAI_ORG_ID` for the organization ID
  /// - `OPENAI_PROJECT_ID` for the project ID
  /// - `OPENAI_WEBHOOK_SECRET` for local signature verification
  ///
  /// A receiver that needs only a webhook secret can use
  /// `WebhookVerifier.fromEnvironment()` without an API key.
  ///
  /// All environment variables are read at runtime via [getEnvironmentVariable],
  /// consistent with [ApiKeyProvider.fromEnvironment].
  ///
  /// Throws [UnsupportedError] on web platforms where environment variables
  /// are not available.
  factory OpenAIConfig.fromEnvironment() {
    final baseUrl = getEnvironmentVariable('OPENAI_BASE_URL');
    final orgId = getEnvironmentVariable('OPENAI_ORG_ID');
    final projectId = getEnvironmentVariable('OPENAI_PROJECT_ID');
    final webhookSecret = getEnvironmentVariable('OPENAI_WEBHOOK_SECRET');

    return OpenAIConfig(
      authProvider: ApiKeyProvider.fromEnvironment(),
      baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
          ? baseUrl
          : 'https://api.openai.com/v1',
      organization: (orgId != null && orgId.isNotEmpty) ? orgId : null,
      project: (projectId != null && projectId.isNotEmpty) ? projectId : null,
      webhookSecret: (webhookSecret != null && webhookSecret.isNotEmpty)
          ? webhookSecret
          : null,
    );
  }

  /// The authentication provider for API requests.
  ///
  /// If not provided, you must set authentication headers manually
  /// using [defaultHeaders] or a custom interceptor.
  final AuthProvider? authProvider;

  /// Optional Vertex routing/authentication definition.
  ///
  /// Prefer [OpenAIConfig.vertex]. When set, [baseUrl] must match its API root,
  /// OpenAI auth/project/organization options and conflicting auth headers are
  /// rejected before credentials are acquired. Only the documented Responses
  /// HTTP/SSE lifecycle is supported; WebSocket and other resources are rejected.
  final VertexProvider? vertexProvider;

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
  ///
  /// **Note:** This parameter is currently not enforced by the default HTTP
  /// client. The standard `package:http` `Client` does not support connection
  /// timeouts. To use connection timeouts, provide a custom [http.Client] with
  /// platform-specific timeout configuration (e.g., `IOClient` with a
  /// configured `HttpClient` on native platforms).
  ///
  /// Example using `IOClient`:
  /// ```dart
  /// import 'dart:io';
  /// import 'package:http/io_client.dart';
  ///
  /// final httpClient = HttpClient()
  ///   ..connectionTimeout = Duration(seconds: 30);
  /// final client = OpenAIClient(
  ///   config: OpenAIConfig(...),
  ///   httpClient: IOClient(httpClient),
  /// );
  /// ```
  final Duration connectTimeout;

  /// Retry policy.
  final RetryPolicy retryPolicy;

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

  /// Signing secret for local webhook verification.
  ///
  /// This is never sent with outbound API requests. Per-call secrets override
  /// this value; explicit empty secrets fail rather than falling back.
  final String? webhookSecret;

  /// Creates a copy of this configuration with the given fields replaced.
  ///
  /// To clear a nullable field, pass `null` explicitly. Fields not provided
  /// retain their current values. Changing [vertexProvider] also selects its
  /// API root unless [baseUrl] is explicitly supplied. Clearing it restores the
  /// ordinary global OpenAI root. Other options are retained and validated when
  /// a client installs the configuration; clear conflicting OpenAI credentials
  /// explicitly when switching providers.
  OpenAIConfig copyWith({
    Object? authProvider = unsetCopyWithValue,
    String? baseUrl,
    Duration? timeout,
    Duration? connectTimeout,
    RetryPolicy? retryPolicy,
    Object? logLevel = unsetCopyWithValue,
    Map<String, String>? defaultHeaders,
    Object? apiVersion = unsetCopyWithValue,
    Object? organization = unsetCopyWithValue,
    Object? project = unsetCopyWithValue,
    Object? webhookSecret = unsetCopyWithValue,
    Object? vertexProvider = unsetCopyWithValue,
  }) {
    final nextVertex = _resolveField<VertexProvider>(
      vertexProvider,
      'vertexProvider',
      this.vertexProvider,
    );
    return OpenAIConfig(
      vertexProvider: nextVertex,
      authProvider: _resolveField<AuthProvider>(
        authProvider,
        'authProvider',
        this.authProvider,
      ),
      baseUrl:
          baseUrl ??
          (identical(vertexProvider, unsetCopyWithValue)
              ? this.baseUrl
              : nextVertex?.baseUrl ?? 'https://api.openai.com/v1'),
      timeout: timeout ?? this.timeout,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      logLevel: _resolveField<Level>(logLevel, 'logLevel', this.logLevel),
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      apiVersion: _resolveField<String>(
        apiVersion,
        'apiVersion',
        this.apiVersion,
      ),
      organization: _resolveField<String>(
        organization,
        'organization',
        this.organization,
      ),
      project: _resolveField<String>(project, 'project', this.project),
      webhookSecret: _resolveWebhookSecret(webhookSecret),
    );
  }

  String? _resolveWebhookSecret(Object? value) {
    if (identical(value, unsetCopyWithValue)) return webhookSecret;
    if (value == null || value is String) return value as String?;
    throw ArgumentError(
      'OpenAIConfig.copyWith: webhookSecret must be a String or null.',
    );
  }

  /// Resolves a copyWith field with runtime type checking.
  ///
  /// Returns [currentValue] if [value] is the sentinel, otherwise validates
  /// that [value] is of type [T] and returns it. Throws [ArgumentError] with
  /// a clear message if the type is wrong.
  static T? _resolveField<T>(Object? value, String fieldName, T? currentValue) {
    if (identical(value, unsetCopyWithValue)) {
      return currentValue;
    }
    if (value == null || value is T) {
      return value as T?;
    }
    throw ArgumentError(
      'OpenAIConfig.copyWith: $fieldName must be $T or null.',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OpenAIConfig &&
        other.authProvider == authProvider &&
        other.vertexProvider == vertexProvider &&
        other.baseUrl == baseUrl &&
        other.timeout == timeout &&
        other.connectTimeout == connectTimeout &&
        other.retryPolicy == retryPolicy &&
        other.logLevel == logLevel &&
        _mapEquals(other.defaultHeaders, defaultHeaders) &&
        other.apiVersion == apiVersion &&
        other.organization == organization &&
        other.project == project &&
        other.webhookSecret == webhookSecret;
  }

  @override
  int get hashCode => Object.hash(
    authProvider,
    vertexProvider,
    baseUrl,
    timeout,
    connectTimeout,
    retryPolicy,
    logLevel,
    // Use order-insensitive hash to match order-insensitive equality
    Object.hashAllUnordered(
      defaultHeaders.entries.map((e) => Object.hash(e.key, e.value)),
    ),
    apiVersion,
    organization,
    project,
    webhookSecret,
  );

  @override
  String toString() =>
      'OpenAIConfig(webhookSecret: ${webhookSecret == null ? 'not configured' : '[REDACTED]'})';

  bool _mapEquals(Map<String, String> a, Map<String, String> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (a[key] != b[key]) return false;
    }
    return true;
  }
}
