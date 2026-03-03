import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../resources/chat_resource.dart';
import '../resources/completions_resource.dart';
import '../resources/embeddings_resource.dart';
import '../resources/models_resource.dart';
import '../resources/version_resource.dart';
import 'config.dart';
import 'interceptor_chain.dart';
import 'request_builder.dart';
import 'retry_wrapper.dart';

/// Main client for the Ollama API.
///
/// Provides access to all Ollama API resources through a resource-based
/// organization that mirrors the official REST API structure.
///
/// ## Resource Organization
///
/// API methods are grouped into logical resources:
/// - [completions] - Text generation (generate endpoint)
/// - [chat] - Chat message generation (chat endpoint)
/// - [embeddings] - Text embeddings (embed endpoint)
/// - [models] - Model management (list, show, create, copy, delete, pull, push)
/// - [version] - Server version information
///
/// ## Example Usage
///
/// ```dart
/// final client = OllamaClient();
///
/// // Chat completion
/// final response = await client.chat.create(
///   request: ChatRequest(
///     model: 'gpt-oss',
///     messages: [
///       ChatMessage.user('Hello!'),
///     ],
///   ),
/// );
/// print(response.message?.content);
///
/// // Streaming chat
/// await for (final chunk in client.chat.createStream(
///   request: ChatRequest(
///     model: 'gpt-oss',
///     messages: [
///       ChatMessage.user('Tell me a story'),
///     ],
///   ),
/// )) {
///   print(chunk.message?.content);
/// }
///
/// // List models
/// final models = await client.models.list();
/// for (final model in models.models ?? []) {
///   print(model.name);
/// }
///
/// // Generate embeddings
/// final embeddings = await client.embeddings.create(
///   request: EmbedRequest(
///     model: 'nomic-embed-text',
///     input: 'Hello, world!',
///   ),
/// );
///
/// client.close();
/// ```
class OllamaClient {
  /// Configuration.
  final OllamaConfig config;

  /// HTTP client.
  final http.Client _httpClient;

  /// Whether we created the HTTP client internally.
  final bool _ownsHttpClient;

  /// Whether the client has been closed.
  bool _closed = false;

  /// Request builder.
  late final RequestBuilder _requestBuilder;

  /// Interceptor chain.
  late final InterceptorChain _interceptorChain;

  /// Resource for text completions (generate endpoint).
  late final CompletionsResource completions;

  /// Resource for chat completions (chat endpoint).
  late final ChatResource chat;

  /// Resource for embeddings (embed endpoint).
  late final EmbeddingsResource embeddings;

  /// Resource for model management (list, show, create, copy, delete, pull, push).
  late final ModelsResource models;

  /// Resource for server version information.
  late final VersionResource version;

  /// Creates an [OllamaClient].
  ///
  /// By default connects to `http://localhost:11434`. Pass a custom [config]
  /// to change the base URL, authentication, or other settings.
  ///
  /// Optionally accepts a custom [httpClient] for testing or advanced use cases.
  OllamaClient({OllamaConfig? config, http.Client? httpClient})
    : config = config ?? const OllamaConfig(),
      _httpClient = httpClient ?? http.Client(),
      _ownsHttpClient = httpClient == null {
    _requestBuilder = RequestBuilder(config: this.config);

    // Build interceptor list based on configuration
    final interceptors = <Interceptor>[
      // Auth interceptor only if auth provider is configured
      if (this.config.authProvider != null)
        AuthInterceptor(authProvider: this.config.authProvider!),
      // Logging interceptor
      LoggingInterceptor(
        logLevel: this.config.logLevel,
        redactionList: this.config.redactionList,
      ),
      // Error interceptor
      const ErrorInterceptor(),
    ];

    // Interceptor order is Auth → Logging → Error
    // Retry wraps the transport layer, not in the interceptor chain
    _interceptorChain = InterceptorChain(
      httpClient: _httpClient,
      interceptors: interceptors,
      retryWrapper: RetryWrapper(config: this.config),
      ensureNotClosed: _ensureNotClosed,
    );

    // Initialize all API resources
    completions = CompletionsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );

    chat = ChatResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );

    embeddings = EmbeddingsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );

    models = ModelsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );

    version = VersionResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
      ensureNotClosed: _ensureNotClosed,
    );
  }

  /// Creates an [OllamaClient] with a custom base URL.
  ///
  /// This is a convenience factory for common use cases.
  factory OllamaClient.withBaseUrl(String baseUrl) {
    return OllamaClient(config: OllamaConfig(baseUrl: baseUrl));
  }

  /// Creates an [OllamaClient] with the given API key.
  ///
  /// This is a convenience constructor for remote Ollama servers
  /// that require authentication (e.g., behind a reverse proxy).
  ///
  /// Optionally accepts a [baseUrl] to override the default
  /// `http://localhost:11434`.
  factory OllamaClient.withApiKey(
    String apiKey, {
    String? baseUrl,
    http.Client? httpClient,
  }) {
    return OllamaClient(
      config: OllamaConfig(
        authProvider: BearerTokenProvider(apiKey),
        baseUrl: baseUrl ?? 'http://localhost:11434',
      ),
      httpClient: httpClient,
    );
  }

  /// Creates an [OllamaClient] from environment variables.
  ///
  /// Optionally reads `OLLAMA_HOST` for a custom base URL.
  /// Defaults to `http://localhost:11434` if not set.
  ///
  /// Throws [UnsupportedError] on web platforms.
  factory OllamaClient.fromEnvironment({http.Client? httpClient}) {
    return OllamaClient(
      config: OllamaConfig.fromEnvironment(),
      httpClient: httpClient,
    );
  }

  /// Throws a [StateError] if the client has been closed.
  void _ensureNotClosed() {
    if (_closed) {
      throw StateError('Client has been closed');
    }
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
}
