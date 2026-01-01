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

/// Configuration for the Anthropic client.
class AnthropicConfig {
  /// Base URL for the Anthropic API.
  ///
  /// Defaults to `https://api.anthropic.com`.
  final String baseUrl;

  /// Authentication provider for dynamic credential retrieval.
  ///
  /// Use [ApiKeyProvider] with your Anthropic API key.
  ///
  /// Example:
  /// ```dart
  /// AnthropicConfig(
  ///   authProvider: ApiKeyProvider('YOUR_API_KEY'),
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

  /// API version header value.
  ///
  /// Defaults to `2023-06-01`.
  final String apiVersion;

  /// Creates an [AnthropicConfig].
  const AnthropicConfig({
    this.baseUrl = 'https://api.anthropic.com',
    this.authProvider,
    this.defaultHeaders = const {},
    this.defaultQueryParams = const {},
    this.timeout = const Duration(minutes: 10),
    this.retryPolicy = RetryPolicy.defaultPolicy,
    this.logLevel = Level.INFO,
    this.redactionList = const [
      'x-api-key',
      'authorization',
      'token',
      'password',
      'secret',
    ],
    this.apiVersion = '2023-06-01',
  });

  /// Creates a copy with overridden values.
  AnthropicConfig copyWith({
    String? baseUrl,
    AuthProvider? authProvider,
    Map<String, String>? defaultHeaders,
    Map<String, String>? defaultQueryParams,
    Duration? timeout,
    RetryPolicy? retryPolicy,
    Level? logLevel,
    List<String>? redactionList,
    String? apiVersion,
  }) {
    return AnthropicConfig(
      baseUrl: baseUrl ?? this.baseUrl,
      authProvider: authProvider ?? this.authProvider,
      defaultHeaders: defaultHeaders ?? this.defaultHeaders,
      defaultQueryParams: defaultQueryParams ?? this.defaultQueryParams,
      timeout: timeout ?? this.timeout,
      retryPolicy: retryPolicy ?? this.retryPolicy,
      logLevel: logLevel ?? this.logLevel,
      redactionList: redactionList ?? this.redactionList,
      apiVersion: apiVersion ?? this.apiVersion,
    );
  }
}
