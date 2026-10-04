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

  /// Whether to send the `X-Request-ID` header on outgoing requests.
  ///
  /// Defaults to `false`. A request ID is always generated internally for
  /// logging and error correlation; this flag only controls whether that ID is
  /// added to the outgoing HTTP request.
  ///
  /// It defaults to `false` because Mistral's CORS allow-list does not include
  /// `X-Request-ID`, so sending it triggers a failed preflight in browser
  /// targets (Flutter Web / dart2wasm). Enable it only when talking to an
  /// intermediary (e.g. a reverse proxy) that you've configured to accept it.
  ///
  /// An `X-Request-ID` set explicitly by the caller (e.g. via [defaultHeaders])
  /// is always sent, regardless of this flag.
  final bool sendRequestIdHeader;

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
    this.sendRequestIdHeader = false,
  });

  /// Creates a [MistralConfig] using runtime environment variables.
  ///
  /// Reads `MISTRAL_API_KEY` for the API key (required).
  /// Optionally reads `MISTRAL_BASE_URL` for a custom base URL.
  ///
  /// Throws [StateError] if `MISTRAL_API_KEY` is not set.
  /// Throws [UnsupportedError] on web platforms.
  factory MistralConfig.fromEnvironment() {
    final apiKey = getEnvironmentVariable('MISTRAL_API_KEY');
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError(
        'Environment variable MISTRAL_API_KEY is not set. '
        'Set it to your Mistral API key.',
      );
    }
    final baseUrl = getEnvironmentVariable('MISTRAL_BASE_URL');
    return MistralConfig(
      authProvider: ApiKeyProvider(apiKey),
      baseUrl: (baseUrl != null && baseUrl.isNotEmpty)
          ? baseUrl
          : 'https://api.mistral.ai',
    );
  }

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
    bool? sendRequestIdHeader,
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
      sendRequestIdHeader: sendRequestIdHeader ?? this.sendRequestIdHeader,
    );
  }
}
