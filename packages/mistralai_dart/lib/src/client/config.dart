import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';

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

/// Configuration for the Mistral AI client.
class MistralConfig {
  /// Base URL for the Mistral AI API.
  ///
  /// Defaults to `https://api.mistral.ai` for the official Mistral AI API.
  final String baseUrl;

  /// Authentication provider for dynamic credential retrieval.
  ///
  /// Mistral AI requires authentication for all requests. Use [ApiKeyProvider]
  /// or [BearerTokenProvider] to provide your API key.
  ///
  /// Example:
  /// ```dart
  /// MistralConfig(
  ///   authProvider: ApiKeyProvider('YOUR_API_KEY'),
  /// )
  /// ```
  final AuthProvider? authProvider;

  /// Default headers to include in all requests.
  final Map<String, String> defaultHeaders;

  /// Default query parameters to include in all requests.
  final Map<String, String> defaultQueryParams;

  /// Request timeout.
  final Duration timeout;

  /// Retry policy.
  final RetryPolicy retryPolicy;

  /// Log level.
  final Level logLevel;

  /// Fields to redact in logs (case-insensitive).
  final List<String> redactionList;

  /// Creates a [MistralConfig].
  const MistralConfig({
    this.baseUrl = 'https://api.mistral.ai',
    this.authProvider,
    this.defaultHeaders = const {},
    this.defaultQueryParams = const {},
    this.timeout = const Duration(minutes: 5),
    this.retryPolicy = RetryPolicy.defaultPolicy,
    this.logLevel = Level.INFO,
    this.redactionList = const [
      'authorization',
      'token',
      'password',
      'secret',
      'bearer',
      'api-key',
      'apikey',
    ],
  });

  /// Creates a copy with overridden values.
  MistralConfig copyWith({
    String? baseUrl,
    AuthProvider? authProvider,
    Map<String, String>? defaultHeaders,
    Map<String, String>? defaultQueryParams,
    Duration? timeout,
    RetryPolicy? retryPolicy,
    Level? logLevel,
    List<String>? redactionList,
  }) {
    return MistralConfig(
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
