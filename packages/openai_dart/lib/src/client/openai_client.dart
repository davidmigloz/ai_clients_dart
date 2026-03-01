import 'dart:async' show StreamController, StreamSubscription, unawaited;
import 'dart:convert' show jsonEncode;

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../interceptors/auth_interceptor.dart';
import '../interceptors/error_interceptor.dart';
import '../interceptors/interceptor.dart';
import '../interceptors/logging_interceptor.dart';
import '../resources/audio_resource.dart';
import '../resources/batches_resource.dart';
import '../resources/beta_resource.dart';
import '../resources/chat_resource.dart';
import '../resources/chatkit_resource.dart';
import '../resources/completions_resource.dart';
import '../resources/containers_resource.dart';
import '../resources/conversations_resource.dart';
import '../resources/embeddings_resource.dart';
import '../resources/evals_resource.dart';
import '../resources/files_resource.dart';
import '../resources/fine_tuning_resource.dart';
import '../resources/images_resource.dart';
import '../resources/models_resource.dart';
import '../resources/moderations_resource.dart';
import '../resources/realtime_resource.dart';
import '../resources/realtime_sessions_resource.dart';
import '../resources/responses_resource.dart';
import '../resources/skills_resource.dart';
import '../resources/uploads_resource.dart';
import '../resources/videos_resource.dart';
import '../utils/request_id.dart';
import 'config.dart';
import 'interceptor_chain.dart';
import 'retry_wrapper.dart';

/// The main client for interacting with the OpenAI API.
///
/// This client provides access to all OpenAI API resources through
/// a resource-based API design. Each major API area is accessible
/// through a dedicated resource property.
///
/// ## Quick Start
///
/// ```dart
/// // Create client from environment variables
/// final client = OpenAIClient.fromEnvironment();
///
/// // Create a chat completion
/// final response = await client.chat.completions.create(
///   ChatCompletionCreateRequest(
///     model: 'gpt-4o',
///     messages: [ChatMessage.user('Hello!')],
///   ),
/// );
///
/// print(response.text);
///
/// // Don't forget to close when done
/// client.close();
/// ```
///
/// ## Resources
///
/// The client provides access to the following API resources:
///
/// - [chat] - Chat completions (GPT-4, GPT-3.5, etc.)
/// - [completions] - Legacy text completions
/// - [embeddings] - Text embeddings
/// - [audio] - Text-to-speech and speech-to-text
/// - [images] - Image generation (DALL-E)
/// - [files] - File management
/// - [uploads] - Multipart file uploads
/// - [batches] - Batch processing
/// - [models] - Model information
/// - [moderations] - Content moderation
/// - [fineTuning] - Fine-tuning jobs
/// - [skills] - Skills API for skill bundles and versions
/// - [beta] - Beta features (Assistants, Threads, etc.)
/// - [realtime] - Real-time API (WebSocket)
///
/// ## Configuration
///
/// ```dart
/// final client = OpenAIClient(
///   config: OpenAIConfig(
///     authProvider: ApiKeyProvider('sk-...'),
///     timeout: Duration(seconds: 60),
///     retryPolicy: RetryPolicy(maxRetries: 3),
///     logLevel: Level.INFO,
///   ),
/// );
/// ```
///
/// ## Streaming
///
/// Many endpoints support streaming responses:
///
/// ```dart
/// final stream = client.chat.completions.createStream(
///   ChatCompletionCreateRequest(
///     model: 'gpt-4o',
///     messages: [ChatMessage.user('Tell me a story')],
///   ),
/// );
///
/// await for (final event in stream) {
///   print(event.choices.first.delta.content);
/// }
/// ```
class OpenAIClient {
  /// Creates a new [OpenAIClient] with the given configuration.
  ///
  /// If [httpClient] is provided, it will be used for HTTP requests.
  /// Otherwise, a default client will be created.
  ///
  /// The optional [streamClientFactory] is used to create HTTP clients for
  /// streaming requests with abort support. This is primarily useful for
  /// testing, allowing mock clients to be injected for the abort path.
  OpenAIClient({
    OpenAIConfig? config,
    http.Client? httpClient,
    http.Client Function()? streamClientFactory,
  }) : _config = config ?? const OpenAIConfig(),
       _httpClient = httpClient ?? http.Client(),
       _streamClientFactory = streamClientFactory ?? http.Client.new,
       _ownsHttpClient = httpClient == null {
    // Initialize logging first so LoggingInterceptor uses the configured level
    _initializeLogging();
    _initializeInterceptorChain();
  }

  /// Creates a new [OpenAIClient] using environment variables.
  ///
  /// Delegates to [OpenAIConfig.fromEnvironment] for configuration.
  /// See that method for details on which environment variables are read.
  ///
  /// The optional [streamClientFactory] is used to create HTTP clients for
  /// streaming requests with abort support. This is primarily useful for
  /// testing, allowing mock clients to be injected for the abort path.
  ///
  /// Throws [UnsupportedError] on web platforms where environment variables
  /// are not available.
  factory OpenAIClient.fromEnvironment({
    http.Client? httpClient,
    http.Client Function()? streamClientFactory,
  }) {
    return OpenAIClient(
      config: OpenAIConfig.fromEnvironment(),
      httpClient: httpClient,
      streamClientFactory: streamClientFactory,
    );
  }

  /// Creates a new [OpenAIClient] with the given API key.
  ///
  /// This is a convenience constructor for simple use cases.
  ///
  /// The optional [streamClientFactory] is used to create HTTP clients for
  /// streaming requests with abort support. This is primarily useful for
  /// testing, allowing mock clients to be injected for the abort path.
  factory OpenAIClient.withApiKey(
    String apiKey, {
    String? organization,
    String? project,
    http.Client? httpClient,
    http.Client Function()? streamClientFactory,
  }) {
    return OpenAIClient(
      config: OpenAIConfig(
        authProvider: ApiKeyProvider(apiKey),
        organization: organization,
        project: project,
      ),
      httpClient: httpClient,
      streamClientFactory: streamClientFactory,
    );
  }

  final OpenAIConfig _config;
  final http.Client _httpClient;
  final http.Client Function() _streamClientFactory;
  final bool _ownsHttpClient;
  bool _closed = false;
  Logger? _logger;
  late final InterceptorChain _interceptorChain;

  /// The configuration for this client.
  OpenAIConfig get config => _config;

  /// The logger for this client, if logging is enabled.
  Logger? get logger => _logger;

  /// The interceptor chain for HTTP requests.
  ///
  /// This is exposed for testing and advanced use cases.
  InterceptorChain get interceptorChain => _interceptorChain;

  void _initializeLogging() {
    // Set up logging if configured
    if (_config.logLevel case final level?) {
      _logger = Logger('OpenAIClient')..level = level;
    }
  }

  void _initializeInterceptorChain() {
    // Build the list of interceptors
    final interceptors = <Interceptor>[];

    // Add auth interceptor if auth provider is configured
    if (_config.authProvider case final authProvider?) {
      interceptors.add(AuthInterceptor(authProvider: authProvider));
    }

    // Add logging interceptor if logging is enabled
    if (_config.logLevel != null) {
      _logger ??= Logger('OpenAIClient');
      interceptors.add(
        LoggingInterceptor(
          logger: _logger!,
          logRequestBody: _config.logLevel == Level.FINEST,
          logResponseBody: _config.logLevel == Level.FINEST,
        ),
      );
    }

    // Add error interceptor (always)
    interceptors.add(const ErrorInterceptor());

    // Create retry wrapper
    final retryWrapper = _config.retryPolicy.maxRetries > 0
        ? RetryWrapper(config: _config)
        : null;

    // Build the interceptor chain
    _interceptorChain = InterceptorChain(
      interceptors: interceptors,
      httpClient: _httpClient,
      retryWrapper: retryWrapper,
      timeout: _config.timeout,
      ensureNotClosed: _ensureNotClosed,
    );
  }

  /// Returns the base headers for API requests.
  ///
  /// Note: Auth headers are added by the [AuthInterceptor] in the
  /// interceptor chain.
  Map<String, String> get _baseHeaders {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      ..._config.defaultHeaders,
    };

    // Add API version if configured
    if (_config.apiVersion case final version?) {
      headers['OpenAI-Version'] = version;
    }

    // Add organization/project headers if configured
    // These are added here (not in AuthInterceptor) so they work regardless
    // of the auth mechanism (authProvider, defaultHeaders, or custom interceptor)
    if (_config.organization case final org?) {
      headers['OpenAI-Organization'] = org;
    }
    if (_config.project case final proj?) {
      headers['OpenAI-Project'] = proj;
    }

    // Add request ID for tracing
    headers['X-Request-ID'] = generateRequestId();

    return headers;
  }

  /// Builds a URL for an API endpoint.
  ///
  /// Normalizes the base URL and endpoint to avoid double slashes or
  /// missing separators. Correctly handles base URLs with existing query
  /// parameters (e.g., Azure OpenAI endpoints with `api-version`).
  ///
  /// This method is exposed for resources that need to build URLs manually
  /// (e.g., for multipart or streaming requests).
  Uri buildUrl(String endpoint, {Map<String, String>? queryParameters}) {
    // Parse baseUrl as a Uri to correctly handle existing paths and query params
    final baseUri = Uri.parse(_config.baseUrl);

    // Normalize base path and requested path to avoid double slashes
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final combinedPath = '$basePath$normalizedEndpoint';

    // Merge query params: base URL params + request params (request wins on conflict)
    final mergedQueryParams = <String, String>{
      ...baseUri.queryParameters,
      if (queryParameters != null) ...queryParameters,
    };

    return baseUri.replace(
      path: combinedPath,
      queryParameters: mergedQueryParams.isEmpty ? null : mergedQueryParams,
    );
  }

  /// Builds a URL for an API endpoint with support for repeated query parameters.
  ///
  /// This method handles arrays in query parameters using `queryParametersAll`,
  /// which is necessary for OpenAI's API where array params must be sent as
  /// repeated keys (e.g., `?include[]=a&include[]=b`).
  ///
  /// Use this instead of [buildUrl] when you need to pass array-valued query
  /// parameters. Single-value params can be passed directly in [queryParameters],
  /// while repeated params go in [queryParametersAll].
  Uri buildUrlWithQueryAll(
    String endpoint, {
    Map<String, String>? queryParameters,
    Map<String, List<String>>? queryParametersAll,
  }) {
    // Parse baseUrl as a Uri to correctly handle existing paths and query params
    final baseUri = Uri.parse(_config.baseUrl);

    // Normalize base path and requested path to avoid double slashes
    final basePath = baseUri.path.endsWith('/')
        ? baseUri.path.substring(0, baseUri.path.length - 1)
        : baseUri.path;
    final normalizedEndpoint = endpoint.startsWith('/')
        ? endpoint
        : '/$endpoint';
    final combinedPath = '$basePath$normalizedEndpoint';

    // Merge query params: base URL params + single params + repeated params
    // Convert everything to List<String> format for queryParametersAll
    final mergedQueryParamsAll = <String, List<String>>{
      // Add base URL params
      for (final entry in baseUri.queryParametersAll.entries)
        entry.key: entry.value,
      // Add single-value params (converted to list)
      if (queryParameters != null)
        for (final entry in queryParameters.entries) entry.key: [entry.value],
      // Add repeated params (these override single-value params with same key)
      if (queryParametersAll != null) ...queryParametersAll,
    };

    // Build the URI with queryParametersAll.
    // Note: Dart's Uri constructor accepts Map<String, List<String>> for the
    // queryParameters parameter, treating each list as repeated query parameters
    // (e.g., include[]=a&include[]=b). This behavior is documented in the Dart
    // SDK and is used here to support OpenAI's array query parameter format.
    //
    // We preserve all URI components from the base URL:
    // - userInfo: credentials in URL (user:pass@host)
    // - fragment: hash section (#section)
    // - port: explicit port (even standard ports like 80/443 if specified)
    return Uri(
      scheme: baseUri.scheme,
      userInfo: baseUri.userInfo.isEmpty ? null : baseUri.userInfo,
      host: baseUri.host,
      port: baseUri.hasPort ? baseUri.port : null,
      path: combinedPath,
      queryParameters: mergedQueryParamsAll.isEmpty
          ? null
          : mergedQueryParamsAll,
      fragment: baseUri.fragment.isEmpty ? null : baseUri.fragment,
    );
  }

  /// Returns the base headers for API requests.
  ///
  /// These include authentication, organization/project, API version,
  /// and request ID headers. Exposed for resources that need to build
  /// requests manually (e.g., streaming or multipart).
  ///
  /// Note: Auth headers are added by the [AuthInterceptor] in the
  /// interceptor chain for regular requests, but streaming requests
  /// bypass the chain and need these headers directly.
  Map<String, String> get baseHeaders => _baseHeaders;

  /// Sends a streaming request with proper headers and URL building.
  ///
  /// This method is used by streaming resources to ensure they use the
  /// same headers and URL normalization as regular requests. Returns a
  /// [http.StreamedResponse] for processing as a stream.
  ///
  /// The [abortTrigger] parameter allows canceling the request. When the
  /// future completes, the underlying HTTP connection is closed, which
  /// terminates the stream. Downstream stream consumers will receive an
  /// error or the stream will end.
  ///
  /// Note: Streaming requests are NOT retried (non-idempotent, body consumed).
  /// The interceptor chain is bypassed since streaming requires low-level
  /// access to the response stream.
  Future<http.StreamedResponse> sendStream({
    required String endpoint,
    required Object body,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) async {
    _ensureNotClosed();

    final url = buildUrl(endpoint);
    final request = http.Request('POST', url);

    // Add base headers (org/project, api version, request ID, default headers)
    request.headers.addAll(_baseHeaders);

    // Add auth headers (normally handled by AuthInterceptor, but streaming
    // bypasses the interceptor chain)
    if (_config.authProvider case final authProvider?) {
      request.headers.addAll(authProvider.getHeaders());
    }

    // Add streaming-specific header
    request.headers['Accept'] = 'text/event-stream';

    // Add any additional headers
    if (headers != null) {
      request.headers.addAll(headers);
    }

    // Encode body
    request.body = jsonEncode(body);

    // Log request if logging is enabled
    _logger?.fine('Streaming POST $url');

    // For abort support, create a dedicated HTTP client for this stream.
    // When abortTrigger completes, we close the client which cancels
    // the in-flight request and terminates the stream.
    if (abortTrigger != null) {
      final streamClient = _streamClientFactory();
      var aborted = false;
      var clientClosed = false;

      void closeClientOnce() {
        if (!clientClosed) {
          clientClosed = true;
          streamClient.close();
        }
      }

      unawaited(
        abortTrigger.then(
          (_) {
            aborted = true;
            closeClientOnce();
          },
          onError: (_) {
            // Treat any abort trigger error as an abort signal
            aborted = true;
            closeClientOnce();
          },
        ),
      );

      try {
        final response = await streamClient.send(request);

        // Use StreamController to ensure client cleanup on ALL termination paths:
        // - Normal completion (onDone)
        // - Errors (onError)
        // - Early subscription cancellation (onCancel)
        //
        // StreamTransformer.fromHandlers does NOT handle subscription
        // cancellation, which would leak the client.
        //
        // IMPORTANT: We capture the subscription and cancel it in onCancel.
        // Without this, the underlying subscription continues pushing data
        // into the controller even when there are no listeners, causing a
        // resource leak.
        final controller = StreamController<List<int>>();
        late final StreamSubscription<List<int>> subscription;
        var controllerClosed = false;

        void closeController() {
          if (!controllerClosed) {
            controllerClosed = true;
            unawaited(controller.close());
          }
        }

        subscription = response.stream.listen(
          controller.add,
          onError: (Object e, StackTrace st) {
            closeClientOnce();
            controller.addError(e, st);
            unawaited(subscription.cancel());
            closeController();
          },
          onDone: () {
            closeClientOnce();
            closeController();
          },
          cancelOnError: false,
        );

        controller.onCancel = () async {
          closeClientOnce();
          await subscription.cancel();
          closeController();
        };

        return http.StreamedResponse(
          controller.stream,
          response.statusCode,
          contentLength: response.contentLength,
          request: response.request,
          headers: response.headers,
          isRedirect: response.isRedirect,
          persistentConnection: response.persistentConnection,
          reasonPhrase: response.reasonPhrase,
        );
      } catch (e) {
        // If we were aborted, convert the exception to AbortedException
        if (aborted) {
          throw AbortedException.fromHttpException(
            e,
            stage: AbortionStage.duringStream,
            correlationId: request.headers['X-Request-ID'],
          );
        }
        // Close client on send() error too
        closeClientOnce();
        rethrow;
      }
    }

    // No abort trigger - use the shared HTTP client
    return _httpClient.send(request);
  }

  // ============================================================
  // Resources
  // ============================================================

  ChatResource? _chat;

  /// Chat completions resource.
  ///
  /// Use this to create chat completions with GPT models.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.chat.completions.create(
  ///   ChatCompletionCreateRequest(
  ///     model: 'gpt-4o',
  ///     messages: [ChatMessage.user('Hello!')],
  ///   ),
  /// );
  /// print(response.text);
  /// ```
  ChatResource get chat => _chat ??= ChatResource(this);

  CompletionsResource? _completions;

  /// Legacy completions resource.
  ///
  /// **Note:** This API is deprecated. Use [chat] for new applications.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final completion = await client.completions.create(
  ///   CompletionRequest(
  ///     model: 'gpt-3.5-turbo-instruct',
  ///     prompt: 'Say this is a test',
  ///   ),
  /// );
  /// print(completion.text);
  /// ```
  CompletionsResource get completions =>
      _completions ??= CompletionsResource(this);

  EmbeddingsResource? _embeddings;

  /// Embeddings resource.
  ///
  /// Use this to create text embeddings for similarity search,
  /// clustering, and other ML tasks.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.embeddings.create(
  ///   EmbeddingRequest(
  ///     model: 'text-embedding-3-small',
  ///     input: EmbeddingInput.text('Hello, world!'),
  ///   ),
  /// );
  /// print('Dimensions: ${response.data.first.embedding.length}');
  /// ```
  EmbeddingsResource get embeddings => _embeddings ??= EmbeddingsResource(this);

  AudioResource? _audio;

  /// Audio resource (speech, transcription, translation).
  ///
  /// Use this for text-to-speech and speech-to-text operations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Text-to-speech
  /// final audioBytes = await client.audio.speech.create(
  ///   SpeechRequest(
  ///     model: 'tts-1',
  ///     input: 'Hello, world!',
  ///     voice: SpeechVoice.alloy,
  ///   ),
  /// );
  ///
  /// // Speech-to-text
  /// final transcript = await client.audio.transcriptions.create(
  ///   TranscriptionRequest(
  ///     file: audioBytes,
  ///     filename: 'audio.mp3',
  ///     model: 'whisper-1',
  ///   ),
  /// );
  /// ```
  AudioResource get audio => _audio ??= AudioResource(this);

  ImagesResource? _images;

  /// Images resource (DALL-E).
  ///
  /// Use this for image generation, editing, and variations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.images.generate(
  ///   ImageGenerationRequest(
  ///     model: 'dall-e-3',
  ///     prompt: 'A white cat wearing a top hat',
  ///     size: ImageSize.size1024x1024,
  ///   ),
  /// );
  /// print('Image URL: ${response.data.first.url}');
  /// ```
  ImagesResource get images => _images ??= ImagesResource(this);

  FilesResource? _files;

  /// Files resource.
  ///
  /// Use this to upload, list, and manage files.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final file = await client.files.upload(
  ///   bytes: File('data.jsonl').readAsBytesSync(),
  ///   filename: 'data.jsonl',
  ///   purpose: FilePurpose.fineTune,
  /// );
  /// ```
  FilesResource get files => _files ??= FilesResource(this);

  UploadsResource? _uploads;

  /// Uploads resource for large file uploads.
  ///
  /// Use this for uploading files larger than 512 MB in parts.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final upload = await client.uploads.create(
  ///   CreateUploadRequest(
  ///     filename: 'large-file.jsonl',
  ///     purpose: FilePurpose.fineTune,
  ///     bytes: fileSize,
  ///     mimeType: 'application/jsonl',
  ///   ),
  /// );
  /// ```
  UploadsResource get uploads => _uploads ??= UploadsResource(this);

  BatchesResource? _batches;

  /// Batches resource for asynchronous batch processing.
  ///
  /// Use this to process large numbers of requests asynchronously.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final batch = await client.batches.create(
  ///   CreateBatchRequest(
  ///     inputFileId: 'file-abc123',
  ///     endpoint: BatchEndpoint.chatCompletions,
  ///     completionWindow: CompletionWindow.h24,
  ///   ),
  /// );
  /// ```
  BatchesResource get batches => _batches ??= BatchesResource(this);

  ModelsResource? _models;

  /// Models resource.
  ///
  /// Use this to list and retrieve available models.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final models = await client.models.list();
  /// for (final model in models.data) {
  ///   print(model.id);
  /// }
  /// ```
  ModelsResource get models => _models ??= ModelsResource(this);

  ModerationsResource? _moderations;

  /// Moderations resource for content moderation.
  ///
  /// Use this to classify text or images for harmful content.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final result = await client.moderations.create(
  ///   ModerationRequest(
  ///     input: ModerationInput.text('Check this text'),
  ///   ),
  /// );
  /// print('Flagged: ${result.results.first.flagged}');
  /// ```
  ModerationsResource get moderations =>
      _moderations ??= ModerationsResource(this);

  FineTuningResource? _fineTuning;

  /// Fine-tuning resource for training custom models.
  ///
  /// Use this to create, manage, and monitor fine-tuning jobs.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final job = await client.fineTuning.jobs.create(
  ///   CreateFineTuningJobRequest(
  ///     model: 'gpt-4o-mini-2024-07-18',
  ///     trainingFile: 'file-abc123',
  ///   ),
  /// );
  /// ```
  FineTuningResource get fineTuning => _fineTuning ??= FineTuningResource(this);

  EvalsResource? _evals;

  /// Evals resource for model evaluation and testing.
  ///
  /// Use this to create evaluations, run them against data sources,
  /// and analyze the results.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create an evaluation
  /// final eval = await client.evals.create(
  ///   CreateEvalRequest(
  ///     name: 'My Evaluation',
  ///     dataSourceConfig: EvalDataSourceConfig.custom(
  ///       itemSchema: {
  ///         'type': 'object',
  ///         'properties': {'prompt': {'type': 'string'}},
  ///       },
  ///     ),
  ///     testingCriteria: [
  ///       EvalGrader.stringCheck(
  ///         name: 'matches_hello',
  ///         input: '{{sample.output_text}}',
  ///         operation: StringCheckOperation.ilike,
  ///         reference: '%hello%',
  ///       ),
  ///     ],
  ///   ),
  /// );
  ///
  /// // Run the evaluation
  /// final run = await client.evals.runs.create(
  ///   eval.id,
  ///   CreateEvalRunRequest(
  ///     dataSource: EvalRunDataSource.jsonlContent([
  ///       {'prompt': 'Say hello'},
  ///     ]),
  ///   ),
  /// );
  /// ```
  EvalsResource get evals => _evals ??= EvalsResource(this);

  BetaResource? _beta;

  /// Beta features (Assistants, Threads, Vector Stores).
  ///
  /// Use this to access OpenAI's beta API features.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create an assistant
  /// final assistant = await client.beta.assistants.create(
  ///   CreateAssistantRequest(
  ///     model: 'gpt-4o',
  ///     name: 'My Assistant',
  ///   ),
  /// );
  ///
  /// // Create a thread and run
  /// final thread = await client.beta.threads.create();
  /// await client.beta.threads.messages.create(
  ///   thread.id,
  ///   CreateMessageRequest(role: 'user', content: 'Hello!'),
  /// );
  /// final run = await client.beta.threads.runs.create(
  ///   thread.id,
  ///   CreateRunRequest(assistantId: assistant.id),
  /// );
  /// ```
  BetaResource get beta => _beta ??= BetaResource(this);

  RealtimeResource? _realtime;

  /// Real-time API resource (WebSocket).
  ///
  /// Use this for real-time audio conversations with the model using WebSockets.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final session = await client.realtime.connect(
  ///   model: 'gpt-4o-realtime-preview',
  /// );
  ///
  /// session.events.listen((event) {
  ///   if (event is ResponseTextDeltaEvent) {
  ///     stdout.write(event.delta);
  ///   }
  /// });
  ///
  /// session.createResponse();
  /// ```
  RealtimeResource get realtime => _realtime ??= RealtimeResource(this);

  RealtimeSessionsResource? _realtimeSessions;

  /// Real-time sessions API resource (HTTP).
  ///
  /// Use this to create realtime sessions, client secrets, and manage
  /// WebRTC calls via HTTP endpoints.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create a session with ephemeral key
  /// final session = await client.realtimeSessions.create(
  ///   RealtimeSessionCreateRequest(
  ///     model: 'gpt-4o-realtime-preview',
  ///     voice: RealtimeVoice.alloy,
  ///   ),
  /// );
  ///
  /// // Use the client secret for WebSocket authentication
  /// print('Client secret: ${session.clientSecret.value}');
  /// ```
  RealtimeSessionsResource get realtimeSessions =>
      _realtimeSessions ??= RealtimeSessionsResource(this);

  ResponsesResource? _responses;

  /// Responses API resource.
  ///
  /// Use this for the next-generation responses interface with support for
  /// multi-turn conversations, built-in tools, and background processing.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Basic text response
  /// final response = await client.responses.create(
  ///   CreateResponseRequest(
  ///     model: 'gpt-4o',
  ///     input: ResponseInput.text('Hello, how are you?'),
  ///   ),
  /// );
  /// print(response.outputText);
  ///
  /// // Streaming response
  /// final stream = client.responses.createStream(
  ///   CreateResponseRequest(
  ///     model: 'gpt-4o',
  ///     input: ResponseInput.text('Tell me a story'),
  ///   ),
  /// );
  ///
  /// await for (final event in stream) {
  ///   if (event is OutputTextDeltaEvent) {
  ///     stdout.write(event.delta);
  ///   }
  /// }
  /// ```
  ResponsesResource get responses => _responses ??= ResponsesResource(this);

  SkillsResource? _skills;

  /// Skills API resource.
  ///
  /// Use this to create, list, retrieve, version, and delete skill bundles.
  SkillsResource get skills => _skills ??= SkillsResource(this);

  ConversationsResource? _conversations;

  /// Conversations API resource.
  ///
  /// Use this for server-side conversation state management with the
  /// Responses API. Conversations provide persistent storage without the
  /// 30-day TTL, making them ideal for long-running conversations.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create a conversation
  /// final conversation = await client.conversations.create(
  ///   ConversationCreateRequest(
  ///     items: [MessageItem.userText('Hello!')],
  ///     metadata: {'user_id': 'user_123'},
  ///   ),
  /// );
  ///
  /// // Use with Responses API
  /// final response = await client.responses.create(
  ///   CreateResponseRequest(
  ///     model: 'gpt-4o',
  ///     input: ResponseInput.text('Continue our conversation'),
  ///   ),
  /// );
  ///
  /// // Add items to the conversation
  /// await client.conversations.items.create(
  ///   conversation.id,
  ///   ItemsCreateRequest(items: [
  ///     MessageItem.userText('What is the weather?'),
  ///   ]),
  /// );
  ///
  /// // Clean up
  /// await client.conversations.delete(conversation.id);
  /// ```
  ConversationsResource get conversations =>
      _conversations ??= ConversationsResource(this);

  VideosResource? _videos;

  /// Videos resource for Sora video generation.
  ///
  /// Use this to generate, manage, and download AI-generated videos.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create a video
  /// final video = await client.videos.create(
  ///   CreateVideoRequest(
  ///     prompt: 'A cat playing piano',
  ///     model: 'sora-2',
  ///     size: VideoSize.size1280x720,
  ///   ),
  /// );
  ///
  /// // Check status
  /// final status = await client.videos.retrieve(video.id);
  /// print('Progress: ${status.progress}%');
  ///
  /// // Download when complete
  /// if (status.isCompleted) {
  ///   final content = await client.videos.retrieveContent(video.id);
  ///   File('video.mp4').writeAsBytesSync(content);
  /// }
  /// ```
  VideosResource get videos => _videos ??= VideosResource(this);

  ContainersResource? _containers;

  /// Containers resource for isolated execution environments.
  ///
  /// Use this to create and manage containers for running code
  /// with access to files and dependencies.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create a container
  /// final container = await client.containers.create(
  ///   CreateContainerRequest(
  ///     name: 'my-container',
  ///     fileIds: ['file-abc123'],
  ///   ),
  /// );
  ///
  /// // List container files
  /// final files = await client.containers.files.list(container.id);
  ///
  /// // Clean up
  /// await client.containers.delete(container.id);
  /// ```
  ContainersResource get containers => _containers ??= ContainersResource(this);

  ChatkitResource? _chatkit;

  /// ChatKit resource for building chat interfaces.
  ///
  /// Use this to create ChatKit sessions and manage conversation threads
  /// powered by OpenAI workflows.
  ///
  /// ## Example
  ///
  /// ```dart
  /// // Create a session
  /// final session = await client.chatkit.sessions.create(
  ///   CreateChatSessionRequest(
  ///     workflow: WorkflowParam(id: 'workflow-abc'),
  ///     user: 'user-123',
  ///   ),
  /// );
  ///
  /// // Use the client secret for client-side auth
  /// print('Client secret: ${session.clientSecret}');
  ///
  /// // List threads
  /// final threads = await client.chatkit.threads.list();
  /// ```
  ChatkitResource get chatkit => _chatkit ??= ChatkitResource(this);

  // ============================================================
  // HTTP Methods - internal use
  // ============================================================

  /// Makes a GET request to the given endpoint.
  ///
  /// The optional [abortTrigger] allows canceling the request before completion.
  Future<http.Response> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Future<void>? abortTrigger,
  }) {
    _ensureNotClosed();

    final url = buildUrl(endpoint, queryParameters: queryParameters);
    final request = http.Request('GET', url)
      ..headers.addAll({..._baseHeaders, ...?headers});

    return _interceptorChain.execute(request, abortTrigger: abortTrigger);
  }

  /// Makes a GET request with support for repeated query parameters.
  ///
  /// Use this for endpoints that require array parameters like `include[]`.
  /// The optional [abortTrigger] allows canceling the request before completion.
  Future<http.Response> getWithRepeatedParams(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParameters,
    Map<String, List<String>>? queryParametersAll,
    Future<void>? abortTrigger,
  }) {
    _ensureNotClosed();

    final url = buildUrlWithQueryAll(
      endpoint,
      queryParameters: queryParameters,
      queryParametersAll: queryParametersAll,
    );
    final request = http.Request('GET', url)
      ..headers.addAll({..._baseHeaders, ...?headers});

    return _interceptorChain.execute(request, abortTrigger: abortTrigger);
  }

  /// Makes a POST request to the given endpoint.
  ///
  /// The optional [abortTrigger] allows canceling the request before completion.
  Future<http.Response> post(
    String endpoint, {
    Map<String, String>? headers,
    Object? body,
    Future<void>? abortTrigger,
  }) {
    _ensureNotClosed();

    final url = buildUrl(endpoint);
    final request = http.Request('POST', url)
      ..headers.addAll({..._baseHeaders, ...?headers});

    if (body != null) {
      if (body is String) {
        request.body = body;
      } else if (body is List<int>) {
        request.bodyBytes = body;
      } else if (body is Map) {
        request.body = jsonEncode(body);
      } else {
        throw ArgumentError(
          'Unsupported body type: ${body.runtimeType}. '
          'Supported types are String, List<int>, and Map.',
        );
      }
    }

    return _interceptorChain.execute(request, abortTrigger: abortTrigger);
  }

  /// Makes a DELETE request to the given endpoint.
  ///
  /// The optional [abortTrigger] allows canceling the request before completion.
  Future<http.Response> delete(
    String endpoint, {
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) {
    _ensureNotClosed();

    final url = buildUrl(endpoint);
    final request = http.Request('DELETE', url)
      ..headers.addAll({..._baseHeaders, ...?headers});

    return _interceptorChain.execute(request, abortTrigger: abortTrigger);
  }

  /// Makes a multipart POST request.
  ///
  /// The [request] should already have its URL set. Used for file uploads
  /// and other multipart form data.
  /// The optional [abortTrigger] allows canceling the request before completion.
  Future<http.Response> postMultipart({
    required http.MultipartRequest request,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) {
    _ensureNotClosed();

    // Add base headers (except Content-Type which is set by MultipartRequest)
    final baseHeaders = Map<String, String>.from(_baseHeaders)
      ..remove('Content-Type');
    request.headers.addAll({...baseHeaders, ...?headers});

    return _interceptorChain.execute(request, abortTrigger: abortTrigger);
  }

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
