import 'package:http/http.dart' as http;

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
///       ChatMessage.user(content: 'Hello!'),
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
///       ChatMessage.user(content: 'Tell me a story'),
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
    );

    // Initialize all API resources
    completions = CompletionsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    chat = ChatResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    embeddings = EmbeddingsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    models = ModelsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    version = VersionResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );
  }

  /// Creates an [OllamaClient] with a custom base URL.
  ///
  /// This is a convenience factory for common use cases.
  factory OllamaClient.withBaseUrl(String baseUrl) {
    return OllamaClient(config: OllamaConfig(baseUrl: baseUrl));
  }

  /// Closes the HTTP client and releases resources.
  ///
  /// Only closes the HTTP client if it was created internally.
  /// If you passed a custom HTTP client, you're responsible for closing it.
  void close() {
    if (_ownsHttpClient) {
      _httpClient.close();
    }
  }
}
