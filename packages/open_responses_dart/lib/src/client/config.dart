import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../platform/environment.dart';

/// Retry policy configuration.
class RetryPolicy {
  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Initial delay before first retry.
  final Duration initialDelay;

  /// Maximum delay between retries.
  final Duration maxDelay;

  /// Jitter factor (0.0 - 1.0).
  final double jitter;

  /// Creates a [RetryPolicy].
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.maxDelay = const Duration(seconds: 60),
    this.jitter = 0.1,
  });

  /// Default retry policy (3 retries, 1s initial delay).
  static const defaultPolicy = RetryPolicy();
}

/// Configuration for the OpenResponses client.
class OpenResponsesConfig {
  /// Base URL for the API.
  ///
  /// Defaults to `https://api.openai.com/v1` (OpenAI's OpenResponses endpoint).
  /// Can be changed to use other providers:
  /// - Ollama: `http://localhost:11434/v1`
  /// - Hugging Face: `https://evalstate-openresponses.hf.space/v1`
  /// - vLLM: Your vLLM server URL
  final String baseUrl;

  /// Authentication provider for dynamic credential retrieval.
  ///
  /// Use [BearerTokenProvider] with your API key.
  /// Use [NoAuthProvider] for local providers like Ollama.
  ///
  /// Example:
  /// ```dart
  /// OpenResponsesConfig(
  ///   authProvider: BearerTokenProvider('YOUR_API_KEY'),
  /// )
  /// ```
  final AuthProvider? authProvider;

  /// Default headers to include in all requests.
  final Map<String, String> defaultHeaders;

  /// Default query parameters to include in all requests.
  final Map<String, String> defaultQueryParams;

  /// Request timeout.
  ///
  /// Defaults to 10 minutes to handle long-running generations.
  final Duration timeout;

  /// Retry policy.
  final RetryPolicy retryPolicy;

  /// Log level.
  final Level logLevel;

  /// Fields to redact in logs (case-insensitive).
  final List<String> redactionList;

  /// Creates an [OpenResponsesConfig].
  const OpenResponsesConfig({
    this.baseUrl = 'https://api.openai.com/v1',
    this.authProvider,
    this.defaultHeaders = const {},
    this.defaultQueryParams = const {},
    this.timeout = const Duration(minutes: 10),
    this.retryPolicy = RetryPolicy.defaultPolicy,
    this.logLevel = Level.INFO,
    this.redactionList = const [
      'authorization',
      'token',
      'password',
      'secret',
      'api-key',
      'apikey',
    ],
  });

  /// Creates an [OpenResponsesConfig] using runtime environment variables.
  ///
  /// Reads `OPENAI_API_KEY` for the API key (optional).
  /// Optionally reads `OPENAI_BASE_URL` for a custom base URL.
  ///
  /// The API key is optional because OpenResponses supports local providers
  /// like Ollama that don't require authentication.
  ///
  /// Throws [UnsupportedError] on web platforms.
  factory OpenResponsesConfig.fromEnvironment() {
    final apiKey = getEnvironmentVariable('OPENAI_API_KEY');
    final baseUrl = getEnvironmentVariable('OPENAI_BASE_URL');
    return OpenResponsesConfig(
      authProvider: (apiKey != null && apiKey.isNotEmpty)
          ? BearerTokenProvider(apiKey)
          : null,
      baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
          ? baseUrl
          : 'https://api.openai.com/v1',
    );
  }

  /// Creates a copy with overridden values.
  OpenResponsesConfig copyWith({
    String? baseUrl,
    AuthProvider? authProvider,
    Map<String, String>? defaultHeaders,
    Map<String, String>? defaultQueryParams,
    Duration? timeout,
    RetryPolicy? retryPolicy,
    Level? logLevel,
    List<String>? redactionList,
  }) {
    return OpenResponsesConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      authProvider: authProvider ?? this.authProvider,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      defaultQueryParams: defaultQueryParams ?? this.defaultQueryParams,
      timeout: timeout ?? this.timeout,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      logLevel: logLevel ?? this.logLevel,
      redactionList: redactionList ?? this.redactionList,
    );
  }
}
