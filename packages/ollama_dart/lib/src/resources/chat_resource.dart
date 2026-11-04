import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/chat/chat_request.dart';
import '../models/chat/chat_response.dart';
import '../models/chat/chat_stream_event.dart';
import 'base_resource.dart';
import 'streaming_resource.dart';

/// Resource for the Chat API.
///
/// Provides chat message generation with optional streaming.
class ChatResource extends ResourceBase with StreamingResource {
  /// Creates a [ChatResource].
  ChatResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
    super.ensureNotClosed,
  });

  /// Generates a chat response.
  ///
  /// The [request] contains the model, messages, and chat settings.
  ///
  /// Returns a [ChatResponse] containing the assistant's reply.
  Future<ChatResponse> create({required ChatRequest request}) async {
    final url = requestBuilder.buildUrl('/api/chat');

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
    return ChatResponse.fromJson(responseBody);
  }

  /// Generates a chat response with streaming.
  ///
  /// The [request] contains the model, messages, and chat settings.
  ///
  /// Returns a stream of [ChatStreamEvent] chunks.
  /// The optional [abortTrigger] cancels the request and response stream.
  Stream<ChatStreamEvent> createStream({
    required ChatRequest request,
    Future<void>? abortTrigger,
  }) {
    return streamRequest(
      createRequest: () {
        final url = requestBuilder.buildUrl('/api/chat');

        final headers = requestBuilder.buildHeaders(
          additionalHeaders: {'Content-Type': 'application/json'},
        );

        // Ensure stream is true for streaming
        final requestData = request.copyWith(stream: true);

        final httpRequest = http.Request('POST', url)
          ..headers.addAll(headers)
          ..body = jsonEncode(requestData.toJson());
        return httpRequest;
      },
      abortTrigger: abortTrigger,
      fromJson: ChatStreamEvent.fromJson,
    );
  }
}
