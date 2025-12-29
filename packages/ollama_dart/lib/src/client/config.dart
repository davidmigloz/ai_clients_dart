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

/// Configuration for the Ollama client.
class OllamaConfig {
  /// Base URL for the Ollama API.
  ///
  /// Defaults to `http://localhost:11434` for local Ollama instances.
  final String baseUrl;

  /// Authentication provider for dynamic credential retrieval.
  ///
  /// For local Ollama instances, this can be left as null or set to
  /// [NoAuthProvider]. For remote instances with authentication,
  /// use [BearerTokenProvider].
  ///
  /// Example:
  /// ```dart
  /// OllamaConfig(
  ///   authProvider: BearerTokenProvider('YOUR_TOKEN'),
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

  /// Creates an [OllamaConfig].
  const OllamaConfig({
    this.baseUrl = 'http://localhost:11434',
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
    ],
  });

  /// Creates a copy with overridden values.
  OllamaConfig copyWith({
    String? baseUrl,
    AuthProvider? authProvider,
    Map<String, String>? defaultHeaders,
    Map<String, String>? defaultQueryParams,
    Duration? timeout,
    RetryPolicy? retryPolicy,
    Level? logLevel,
    List<String>? redactionList,
  }) {
    return OllamaConfig(
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
