import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat/chat.dart';
import '../models/streaming/streaming.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for chat-related operations.
///
/// Access this resource through [OpenAIClient.chat].
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
class ChatResource extends ResourceBase {
  /// Creates a [ChatResource].
  ChatResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  ChatCompletionsResource? _completions;

  /// Access to chat completions operations.
  ChatCompletionsResource get completions =>
      _completions ??= ChatCompletionsResource(
        config: config,
        httpClient: httpClient,
        interceptorChain: interceptorChain,
        requestBuilder: requestBuilder,
        ensureNotClosed: ensureNotClosed,
        streamClientFactory: streamClientFactory,
      );
}

/// Resource for chat completions operations.
///
/// Provides methods to create chat completions, including streaming.
///
/// ## Example
///
/// ```dart
/// // Non-streaming
/// final response = await client.chat.completions.create(
///   ChatCompletionCreateRequest(
///     model: 'gpt-4o',
///     messages: [ChatMessage.user('Hello!')],
///   ),
/// );
///
/// // Streaming
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
class ChatCompletionsResource extends ResourceBase with StreamingResource {
  /// Creates a [ChatCompletionsResource].
  ChatCompletionsResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
    super.streamClientFactory,
  });

  static const _endpoint = '/chat/completions';

  /// Creates a chat completion.
  ///
  /// Given a list of messages comprising a conversation, the model will
  /// return a response.
  ///
  /// ## Parameters
  ///
  /// - [request] - The chat completion request parameters.
  /// - [abortTrigger] - Optional future that cancels the request when completed.
  ///
  /// ## Returns
  ///
  /// A [ChatCompletion] containing the model's response.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final response = await client.chat.completions.create(
  ///   ChatCompletionCreateRequest(
  ///     model: 'gpt-4o',
  ///     messages: [
  ///       ChatMessage.system('You are a helpful assistant.'),
  ///       ChatMessage.user('What is the capital of France?'),
  ///     ],
  ///   ),
  /// );
  ///
  /// print(response.text); // Paris
  /// ```
  Future<ChatCompletion> create(
    ChatCompletionCreateRequest request, {
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();
    final url = requestBuilder.buildUrl(_endpoint);
    final headers = requestBuilder.buildHeaders();
    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(request.toJson());
    final response = await interceptorChain.execute(
      httpRequest,
      abortTrigger: abortTrigger,
    );
    return ChatCompletion.fromJson(
      jsonDecode(response.body) as Map<String, dynamic>,
    );
  }

  /// Creates a streaming chat completion.
  ///
  /// Returns a stream of [ChatStreamEvent] objects as the model generates
  /// the response. This is useful for long responses where you want to
  /// display output incrementally.
  ///
  /// ## Parameters
  ///
  /// - [request] - The chat completion request parameters.
  /// - [abortTrigger] - Optional future that cancels the stream when completed.
  ///
  /// ## Returns
  ///
  /// A [Stream] of [ChatStreamEvent] objects.
  ///
  /// ## Example
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
  ///   final content = event.choices.firstOrNull?.delta.content;
  ///   if (content != null) {
  ///     stdout.write(content);
  ///   }
  /// }
  /// ```
  Stream<ChatStreamEvent> createStream(
    ChatCompletionCreateRequest request, {
    Future<void>? abortTrigger,
  }) {
    // Ensure stream is enabled in the request body
    final requestBody = request.toJson();
    requestBody['stream'] = true;

    return streamSseEvents(
      endpoint: _endpoint,
      body: requestBody,
      abortTrigger: abortTrigger,
    ).map(ChatStreamEvent.fromJson);
  }

  /// Creates a streaming chat completion with accumulated events.
  ///
  /// Similar to [createStream], but wraps events in a [ChatStreamAccumulator]
  /// that provides access to the accumulated state, making it easier to
  /// reconstruct the full response.
  ///
  /// ## Parameters
  ///
  /// - [request] - The chat completion request parameters.
  /// - [abortTrigger] - Optional future that cancels the stream when completed.
  ///
  /// ## Example
  ///
  /// ```dart
  /// final accumulator = ChatStreamAccumulator();
  /// final stream = client.chat.completions.createStream(
  ///   ChatCompletionCreateRequest(
  ///     model: 'gpt-4o',
  ///     messages: [ChatMessage.user('Hello!')],
  ///   ),
  /// );
  ///
  /// await for (final event in stream) {
  ///   accumulator.add(event);
  ///   print('Current text: ${accumulator.content}');
  /// }
  /// ```
  Stream<ChatStreamAccumulator> createStreamWithAccumulator(
    ChatCompletionCreateRequest request, {
    Future<void>? abortTrigger,
  }) {
    final accumulator = ChatStreamAccumulator();
    return createStream(request, abortTrigger: abortTrigger).map((event) {
      accumulator.add(event);
      return accumulator;
    });
  }
}
