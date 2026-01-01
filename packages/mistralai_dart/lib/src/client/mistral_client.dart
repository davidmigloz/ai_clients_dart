import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../resources/agents/agents_resource.dart';
import '../resources/audio/audio_resource.dart';
import '../resources/batch/batch_resource.dart';
import '../resources/chat_resource.dart';
import '../resources/classifications_resource.dart';
import '../resources/conversations/conversations_resource.dart';
import '../resources/embeddings_resource.dart';
import '../resources/files/files_resource.dart';
import '../resources/fim_resource.dart';
import '../resources/fine_tuning/fine_tuning_resource.dart';
import '../resources/libraries/libraries_resource.dart';
import '../resources/models_resource.dart';
import '../resources/moderations_resource.dart';
import '../resources/ocr_resource.dart';
import 'config.dart';
import 'interceptor_chain.dart';
import 'request_builder.dart';
import 'retry_wrapper.dart';

/// Main client for the Mistral AI API.
///
/// Provides access to all Mistral AI API resources through a resource-based
/// organization that mirrors the official REST API structure.
///
/// ## Resource Organization
///
/// API methods are grouped into logical resources:
/// - [chat] - Chat completions with streaming support
/// - [classifications] - Text classification
/// - [embeddings] - Text embeddings
/// - [files] - File upload and management
/// - [fim] - Fill-in-the-Middle code completions
/// - [fineTuning] - Fine-tuning job management
/// - [batch] - Batch job processing
/// - [ocr] - OCR text extraction
/// - [audio] - Audio transcription
/// - [agents] - AI agents (Beta)
/// - [conversations] - Conversations (Beta)
/// - [libraries] - Document libraries for RAG (Beta)
/// - [models] - Model listing and management
/// - [moderations] - Content moderation
///
/// ## Example Usage
///
/// ```dart
/// final client = MistralClient(
///   config: MistralConfig(
///     authProvider: ApiKeyProvider('your-api-key'),
///   ),
/// );
///
/// // Chat completion
/// final response = await client.chat.create(
///   request: ChatCompletionRequest(
///     model: 'mistral-small-latest',
///     messages: [
///       ChatMessage.user('Hello!'),
///     ],
///   ),
/// );
/// print(response.choices.first.message.content);
///
/// // Streaming chat
/// await for (final chunk in client.chat.createStream(
///   request: ChatCompletionRequest(
///     model: 'mistral-small-latest',
///     messages: [
///       ChatMessage.user('Tell me a story'),
///     ],
///   ),
/// )) {
///   final content = chunk.choices.first.delta.content;
///   if (content != null) {
///     stdout.write(content);
///   }
/// }
///
/// // List models
/// final models = await client.models.list();
/// for (final model in models.data) {
///   print('${model.id}: ${model.name}');
/// }
///
/// // Generate embeddings
/// final embeddings = await client.embeddings.create(
///   request: EmbeddingRequest.single(
///     model: 'mistral-embed',
///     input: 'Hello, world!',
///   ),
/// );
///
/// client.close();
/// ```
class MistralClient {
  /// Configuration.
  final MistralConfig config;

  /// HTTP client.
  final http.Client _httpClient;

  /// Whether we created the HTTP client internally.
  final bool _ownsHttpClient;

  /// Request builder.
  late final RequestBuilder _requestBuilder;

  /// Interceptor chain.
  late final InterceptorChain _interceptorChain;

  /// Resource for chat completions.
  late final ChatResource chat;

  /// Resource for embeddings.
  late final EmbeddingsResource embeddings;

  /// Resource for model management.
  late final ModelsResource models;

  /// Resource for Fill-in-the-Middle code completions.
  late final FimResource fim;

  /// Resource for file management.
  late final FilesResource files;

  /// Resource for content moderation.
  late final ModerationsResource moderations;

  /// Resource for text classification.
  late final ClassificationsResource classifications;

  /// Resource for fine-tuning operations.
  late final FineTuningResource fineTuning;

  /// Resource for batch processing.
  late final BatchResource batch;

  /// Resource for OCR text extraction.
  late final OcrResource ocr;

  /// Resource for audio processing.
  late final AudioResource audio;

  /// Resource for AI agents (Beta).
  late final AgentsResource agents;

  /// Resource for conversations (Beta).
  late final ConversationsResource conversations;

  /// Resource for document libraries (Beta).
  late final LibrariesResource libraries;

  /// Creates a [MistralClient].
  ///
  /// By default connects to `https://api.mistral.ai`. Pass a custom [config]
  /// to change the base URL, authentication, or other settings.
  ///
  /// You must provide an API key via [config.authProvider]:
  /// ```dart
  /// final client = MistralClient(
  ///   config: MistralConfig(
  ///     authProvider: ApiKeyProvider('your-api-key'),
  ///   ),
  /// );
  /// ```
  ///
  /// Optionally accepts a custom [httpClient] for testing or advanced use cases.
  MistralClient({MistralConfig? config, http.Client? httpClient})
    : config = config ?? const MistralConfig(),
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

    fim = FimResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    files = FilesResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    moderations = ModerationsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    classifications = ClassificationsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    fineTuning = FineTuningResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    batch = BatchResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    ocr = OcrResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    audio = AudioResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    agents = AgentsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    conversations = ConversationsResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );

    libraries = LibrariesResource(
      config: this.config,
      httpClient: _httpClient,
      interceptorChain: _interceptorChain,
      requestBuilder: _requestBuilder,
    );
  }

  /// Creates a [MistralClient] with an API key.
  ///
  /// This is a convenience factory for the common use case.
  ///
  /// ```dart
  /// final client = MistralClient.withApiKey('your-api-key');
  /// ```
  factory MistralClient.withApiKey(String apiKey) {
    return MistralClient(
      config: MistralConfig(authProvider: ApiKeyProvider(apiKey)),
    );
  }

  /// Creates a [MistralClient] with a custom base URL.
  ///
  /// This is useful for proxies or self-hosted endpoints.
  ///
  /// ```dart
  /// final client = MistralClient.withBaseUrl(
  ///   apiKey: 'your-api-key',
  ///   baseUrl: 'https://my-proxy.com',
  /// );
  /// ```
  factory MistralClient.withBaseUrl({
    required String apiKey,
    required String baseUrl,
  }) {
    return MistralClient(
      config: MistralConfig(
        baseUrl: baseUrl,
        authProvider: ApiKeyProvider(apiKey),
      ),
    );
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
