import 'package:http/http.dart' as http;

import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../resources/files_resource.dart';
import '../resources/message_batches_resource.dart';
import '../resources/messages_resource.dart';
import '../resources/models_resource.dart';
import '../resources/skills_resource.dart';
import 'config.dart';
import 'interceptor_chain.dart';
import 'request_builder.dart';
import 'retry_wrapper.dart';

/// Dart client for the Anthropic API.
///
/// Provides type-safe access to Claude models via the Anthropic API.
///
/// ## Basic Usage
///
/// ```dart
/// final client = AnthropicClient(
///   config: AnthropicConfig(
///     authProvider: ApiKeyProvider('your-api-key'),
///   ),
/// );
///
/// // Use client.messages, client.models, etc.
///
/// client.close();
/// ```
///
/// ## Environment Configuration
///
/// ```dart
/// final client = AnthropicClient.fromEnvironment();
/// // Uses ANTHROPIC_API_KEY environment variable
/// ```
class AnthropicClient {
  /// Client configuration.
  final AnthropicConfig config;

  /// HTTP client for requests.
  final http.Client _httpClient;

  /// Whether this client owns the HTTP client (and should close it).
  final bool _ownsHttpClient;

  /// Whether the client has been closed.
  bool _closed = false;

  /// Interceptor chain for request processing.
  late final InterceptorChain _chain;

  /// Request builder for URL and header construction.
  late final RequestBuilder _requestBuilder;

  /// Resource for the Messages API.
  late final MessagesResource messages;

  /// Resource for the Models API.
  late final ModelsResource models;

  /// Resource for the Message Batches API.
  ///
  /// **Deprecated:** Use [messages.batches] instead for consistency with the
  /// API structure.
  @Deprecated('Use client.messages.batches instead')
  MessageBatchesResource get batches => messages.batches;

  /// Resource for the Files API (Beta).
  late final FilesResource files;

  /// Resource for the Skills API (Beta).
  late final SkillsResource skills;

  /// Creates an [AnthropicClient].
  ///
  /// Optionally accepts a custom [httpClient] for testing or advanced use
  /// cases. If not provided, a new client is created and will be closed when
  /// [close] is called. If provided, you are responsible for closing it.
  AnthropicClient({AnthropicConfig? config, http.Client? httpClient})
    : config = config ?? const AnthropicConfig(),
      _httpClient = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null {
    _initialize();
  }

  /// Creates an [AnthropicClient] from environment variables.
  ///
  /// Reads `ANTHROPIC_API_KEY` for the API key (required).
  /// Optionally reads `ANTHROPIC_BASE_URL` for custom API endpoints.
  ///
  /// Throws [StateError] if `ANTHROPIC_API_KEY` is not set.
  /// Throws [UnsupportedError] on web platforms.
  factory AnthropicClient.fromEnvironment({http.Client? httpClient}) {
    return AnthropicClient(
      config: AnthropicConfig.fromEnvironment(),
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
    _chain = InterceptorChain(
      interceptors: interceptors,
      httpClient: _httpClient,
      retryWrapper: retryWrapper,
      ensureNotClosed: _ensureNotClosed,
    );

    // Initialize resources
    messages = MessagesResource(
      chain: _chain,
      requestBuilder: _requestBuilder,
      httpClient: _httpClient,
      ensureNotClosed: _ensureNotClosed,
    );
    models = ModelsResource(
      chain: _chain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
    // Note: batches is now accessible via messages.batches (nested resource)
    files = FilesResource(
      chain: _chain,
      requestBuilder: _requestBuilder,
      httpClient: _httpClient,
      ensureNotClosed: _ensureNotClosed,
    );
    skills = SkillsResource(
      chain: _chain,
      requestBuilder: _requestBuilder,
      httpClient: _httpClient,
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

  /// Throws a [StateError] if the client has been closed.
  void _ensureNotClosed() {
    if (_closed) {
      throw StateError('Client has been closed');
    }
  }

  /// Gets the interceptor chain for advanced usage.
  ///
  /// This is primarily for internal use by resources.
  InterceptorChain get chain => _chain;

  /// Gets the request builder for advanced usage.
  ///
  /// This is primarily for internal use by resources.
  RequestBuilder get requestBuilder => _requestBuilder;

  /// Gets the HTTP client for streaming requests.
  ///
  /// This is primarily for internal use by streaming resources.
  http.Client get httpClient => _httpClient;
}
