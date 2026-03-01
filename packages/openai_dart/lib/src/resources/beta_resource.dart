import 'assistants_resource.dart';
import 'base_resource.dart';
import 'threads_resource.dart';
import 'vector_stores_resource.dart';

/// Resource for Beta API features.
///
/// This resource provides access to OpenAI's beta features including
/// the Assistants API.
///
/// Access this resource through [OpenAIClient.beta].
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
/// // Create a thread
/// final thread = await client.beta.threads.create();
///
/// // Add a message
/// await client.beta.threads.messages.create(
///   thread.id,
///   CreateMessageRequest(role: 'user', content: 'Hello!'),
/// );
///
/// // Create a run
/// final run = await client.beta.threads.runs.create(
///   thread.id,
///   CreateRunRequest(assistantId: assistant.id),
/// );
/// ```
class BetaResource extends ResourceBase {
  /// Creates a [BetaResource].
  BetaResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  AssistantsResource? _assistants;
  ThreadsResource? _threads;
  VectorStoresResource? _vectorStores;

  /// Access to Assistants API.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final assistant = await client.beta.assistants.create(
  ///   CreateAssistantRequest(
  ///     model: 'gpt-4o',
  ///     name: 'Code Helper',
  ///   ),
  /// );
  /// ```
  AssistantsResource get assistants => _assistants ??= AssistantsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
  );

  /// Access to Threads API.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final thread = await client.beta.threads.create();
  /// ```
  ThreadsResource get threads => _threads ??= ThreadsResource(
    config: config,
    httpClient: httpClient,
    interceptorChain: interceptorChain,
    requestBuilder: requestBuilder,
    ensureNotClosed: ensureNotClosed,
    streamClientFactory: streamClientFactory,
  );

  /// Access to Vector Stores API.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final store = await client.beta.vectorStores.create(
  ///   CreateVectorStoreRequest(name: 'My Store'),
  /// );
  /// ```
  VectorStoresResource get vectorStores =>
      _vectorStores ??= VectorStoresResource(
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
      );
}
