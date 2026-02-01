import 'dart:async';
import 'dart:convert';

import '../errors/exceptions.dart';
import '../models/chat/chat.dart';
import '../models/streaming/streaming.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

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
class ChatResource extends BaseResource {
  /// Creates a [ChatResource] with the given client.
  ChatResource(super.client);

  ChatCompletionsResource? _completions;

  /// Access to chat completions operations.
  ChatCompletionsResource get completions =>
      _completions ??= ChatCompletionsResource(client);
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
class ChatCompletionsResource extends BaseResource {
  /// Creates a [ChatCompletionsResource] with the given client.
  ChatCompletionsResource(super.client);

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
    final json = await postJson(
      _endpoint,
      body: request.toJson(),
      abortTrigger: abortTrigger,
    );
    return ChatCompletion.fromJson(json);
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
  }) async* {
    // Ensure stream is enabled in the request body
    final requestBody = request.toJson();
    requestBody['stream'] = true;

    final response = await client.sendStream(
      endpoint: _endpoint,
      body: requestBody,
      abortTrigger: abortTrigger,
    );

    // Extract request ID from response headers for error reporting
    final requestId =
        response.headers['x-request-id'] ??
        response.request?.headers['X-Request-ID'] ??
        'unknown';

    try {
      if (response.statusCode >= 400) {
        final body = await response.stream.bytesToString();
        throw _parseStreamError(response.statusCode, body, requestId);
      }

      const parser = SseParser();
      await for (final json in parser.parse(response.stream)) {
        yield ChatStreamEvent.fromJson(json);
      }
    } on AbortedException {
      // Abort is expected, just re-throw
      rethrow;
    }
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

  /// Parses an error response from a streaming request.
  ApiException _parseStreamError(
    int statusCode,
    String body,
    String requestId,
  ) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final error = json['error'] as Map<String, dynamic>?;
      return createApiException(
        statusCode: statusCode,
        message: error?['message'] as String? ?? 'Unknown error',
        type: error?['type'] as String?,
        code: error?['code'] as String?,
        param: error?['param'] as String?,
        requestId: requestId,
        body: json,
      );
    } catch (_) {
      return ApiException(
        message: body.isNotEmpty ? body : 'HTTP $statusCode error',
        statusCode: statusCode,
        requestId: requestId,
      );
    }
  }
}
