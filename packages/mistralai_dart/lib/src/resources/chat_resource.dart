import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat/chat_completion_request.dart';
import '../models/chat/chat_completion_response.dart';
import '../models/chat/chat_completion_stream_response.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Chat Completions API.
///
/// Provides chat message generation with optional streaming.
///
/// Example usage:
/// ```dart
/// final response = await client.chat.create(
///   request: ChatCompletionRequest(
///     model: 'mistral-small-latest',
///     messages: [
///       ChatMessage.user('Hello, how are you?'),
///     ],
///   ),
/// );
/// print(response.choices.first.message.content);
/// ```
class ChatResource extends ResourceBase with StreamingResource {
  /// Creates a [ChatResource].
  ChatResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
  });

  /// Generates a chat completion.
  ///
  /// The [request] contains the model, messages, and completion settings.
  ///
  /// Returns a [ChatCompletionResponse] containing the assistant's reply.
  ///
  /// Throws [MistralException] if the request fails.
  Future<ChatCompletionResponse> create({
    required ChatCompletionRequest request,
  }) async {
    final url = requestBuilder.buildUrl('/v1/chat/completions');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is false for non-streaming
    final requestData = request.copyWith(stream: false);

    final httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    final response = await interceptorChain.execute(httpRequest);

    final responseBody = jsonDecode(response.body) as Map<String, dynamic>;
    return ChatCompletionResponse.fromJson(responseBody);
  }

  /// Generates a chat completion with streaming.
  ///
  /// The [request] contains the model, messages, and completion settings.
  ///
  /// Returns a stream of [ChatCompletionStreamResponse] chunks.
  ///
  /// Example:
  /// ```dart
  /// final stream = client.chat.createStream(
  ///   request: ChatCompletionRequest(
  ///     model: 'mistral-small-latest',
  ///     messages: [ChatMessage.user('Tell me a story')],
  ///   ),
  /// );
  ///
  /// await for (final chunk in stream) {
  ///   final content = chunk.choices.first.delta.content;
  ///   if (content != null) {
  ///     stdout.write(content);
  ///   }
  /// }
  /// ```
  Stream<ChatCompletionStreamResponse> createStream({
    required ChatCompletionRequest request,
  }) async* {
    final url = requestBuilder.buildUrl('/v1/chat/completions');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is true for streaming
    final requestData = request.copyWith(stream: true);

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    // Use mixin methods for streaming request handling
    httpRequest = await prepareStreamingRequest(httpRequest);
    final streamedResponse = await sendStreamingRequest(httpRequest);

    // Parse SSE stream
    await for (final json in parseSSE(streamedResponse.stream)) {
      yield ChatCompletionStreamResponse.fromJson(json);
    }
  }
}
