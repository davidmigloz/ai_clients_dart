import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../resources/responses_resource.dart';
import 'config.dart';
import 'interceptor_chain.dart';
import 'request_builder.dart';
import 'retry_wrapper.dart';

/// Dart client for the OpenResponses API.
///
/// Provides type-safe access to LLM models via the OpenResponses specification.
/// Compatible with OpenAI, Ollama, Hugging Face, and other providers.
///
/// ## Basic Usage
///
/// ```dart
/// final client = OpenResponsesClient(
///   config: OpenResponsesConfig(
///     authProvider: BearerTokenProvider('your-api-key'),
///   ),
/// );
///
/// final response = await client.responses.create(
///   CreateResponseRequest(
///     model: 'gpt-4o',
///     input: 'Hello, world!',
///   ),
/// );
///
/// print(response.outputText);
///
/// client.close();
/// ```
///
/// ## Using with Ollama (Local)
///
/// ```dart
/// final client = OpenResponsesClient(
///   config: OpenResponsesConfig(
///     baseUrl: 'http://localhost:11434/v1',
///     // No auth needed for local Ollama
///   ),
/// );
/// ```
///
/// ## Environment Configuration
///
/// ```dart
/// final client = OpenResponsesClient.fromEnvironment();
/// // Uses OPENAI_API_KEY environment variable
/// ```
class OpenResponsesClient {
  /// Client configuration.
  final OpenResponsesConfig config;

  /// HTTP client for requests.
  final http.Client _httpClient;

  /// Whether this client owns the HTTP client (and should close it).
  final bool _ownsHttpClient;

  /// Whether the client has been closed.
  bool _closed = false;

  /// Interceptor chain for request processing.
  late final InterceptorChain _interceptorChain;

  /// Request builder for URL and header construction.
  late final RequestBuilder _requestBuilder;

  /// Resource for the Responses API.
  late final ResponsesResource responses;

  /// Creates an [OpenResponsesClient].
  ///
  /// If [httpClient] is not provided, a new client is created and will be
  /// closed when [close] is called.
  OpenResponsesClient({OpenResponsesConfig? config, http.Client? httpClient})
    : config = config ?? const OpenResponsesConfig(),
      _httpClient = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null {
    _initialize();
  }

  /// Creates an [OpenResponsesClient] from environment variables.
  ///
  /// Reads `OPENAI_API_KEY` from environment (optional).
  /// Optionally reads `OPENAI_BASE_URL` for custom API endpoints.
  ///
  /// Throws [UnsupportedError] on web platforms.
  factory OpenResponsesClient.fromEnvironment({http.Client? httpClient}) {
    return OpenResponsesClient(
      config: OpenResponsesConfig.fromEnvironment(),
      httpClient: httpClient,
    );
  }

  /// Creates an [OpenResponsesClient] with the given API key.
  ///
  /// This is a convenience constructor for simple use cases.
  factory OpenResponsesClient.withApiKey(
    String apiKey, {
    http.Client? httpClient,
  }) {
    return OpenResponsesClient(
      config: OpenResponsesConfig(authProvider: BearerTokenProvider(apiKey)),
      httpClient: httpClient,
    );
  }

  /// Initializes the client with interceptor chain and resources.
  void _initialize() {
    // Build request builder
    _requestBuilder = RequestBuilder(config: config);

    // Build interceptor list
    // Order: Auth → Logging → Error → Transport (wrapped by Retry)
    final interceptors = <Interceptor>[
      if (config.authProvider != null)
        AuthInterceptor(authProvider: config.authProvider!),
      LoggingInterceptor(
        logLevel: config.logLevel,
        redactionList: config.redactionList,
      ),
      const ErrorInterceptor(),
    ];

    // Build retry wrapper if retries are enabled
    final retryWrapper = config.retryPolicy.maxRetries > 0
        ? RetryWrapper(config: config)
        : null;

    // Build interceptor chain
    _interceptorChain = InterceptorChain(
      interceptors: interceptors,
      httpClient: _httpClient,
      retryWrapper: retryWrapper,
      ensureNotClosed: _ensureNotClosed,
    );

    // Initialize resources
    responses = ResponsesResource(
      config: config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
  }

  /// Closes the client and releases resources.
  ///
  /// After calling this method, any subsequent requests will throw
  /// [StateError]. This method is idempotent and can be called multiple
  /// times safely.
  ///
  /// If a custom [http.Client] was provided to the constructor,
  /// it will not be closed by this method.
  void close() {
    if (_closed) return;
    _closed = true;
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }

  /// Throws [StateError] if the client has been closed.
  void _ensureNotClosed() {
    if (_closed) {
      throw StateError('Client has been closed');
    }
  }

  /// Gets the interceptor chain for advanced usage.
  ///
  /// This is primarily for internal use by resources.
  InterceptorChain get interceptorChain => _interceptorChain;

  /// Gets the request builder for advanced usage.
  ///
  /// This is primarily for internal use by resources.
  RequestBuilder get requestBuilder => _requestBuilder;

  /// Gets the HTTP client for streaming requests.
  ///
  /// This is primarily for internal use by streaming resources.
  http.Client get httpClient => _httpClient;
}
