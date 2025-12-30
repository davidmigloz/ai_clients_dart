import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../models/chat/chat_request.dart';
import '../models/chat/chat_response.dart';
import '../models/chat/chat_stream_event.dart';
import '../utils/request_id.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

/// Resource for the Chat API.
///
/// Provides chat message generation with optional streaming.
class ChatResource extends ResourceBase {
  /// Creates a [ChatResource].
  ChatResource({
    required super.config,
    required super.httpClient,
    required super.interceptorChain,
    required super.requestBuilder,
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
  Stream<ChatStreamEvent> createStream({required ChatRequest request}) async* {
    final url = requestBuilder.buildUrl('/api/chat');

    final headers = requestBuilder.buildHeaders(
      additionalHeaders: {'Content-Type': 'application/json'},
    );

    // Ensure stream is true for streaming
    final requestData = request.copyWith(stream: true);

    var httpRequest = http.Request('POST', url)
      ..headers.addAll(headers)
      ..body = jsonEncode(requestData.toJson());

    // Apply interceptor logic manually for streaming
    // 1. Auth
    final credentials = config.authProvider != null
        ? await config.authProvider!.getCredentials()
        : null;
    httpRequest = _applyAuthToRequest(httpRequest, credentials);

    // 2. Logging
    httpRequest = _applyLoggingToRequest(httpRequest);

    // 3. Send streaming request
    http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await httpClient.send(httpRequest);

      if (streamedResponse.statusCode >= 400) {
        final response = await http.Response.fromStream(streamedResponse);
        throw _mapHttpError(response);
      }
    } catch (e) {
      _logStreamError(
        e,
        httpRequest.headers['X-Request-ID'] ?? generateRequestId(),
      );
      rethrow;
    }

    // Parse NDJSON stream
    await for (final json in parseNDJSON(streamedResponse.stream)) {
      yield ChatStreamEvent.fromJson(json);
    }
  }

  // Helper methods for streaming

  http.Request _applyAuthToRequest(
    http.Request request,
    AuthCredentials? credentials,
  ) {
    if (credentials == null) return request;

    return switch (credentials) {
      BearerTokenCredentials(:final token) =>
        http.Request(request.method, request.url)
          ..headers.addAll(request.headers)
          ..headers['Authorization'] = 'Bearer $token'
          ..bodyBytes = request.bodyBytes
          ..encoding = request.encoding,
      NoAuthCredentials() => request,
    };
  }

  http.Request _applyLoggingToRequest(http.Request request) {
    if (!request.headers.containsKey('X-Request-ID')) {
      final requestId = generateRequestId();
      final updatedRequest = http.Request(request.method, request.url)
        ..headers.addAll(request.headers)
        ..headers['X-Request-ID'] = requestId
        ..bodyBytes = request.bodyBytes
        ..encoding = request.encoding;

      if (config.logLevel.value <= Level.INFO.value) {
        Logger(
          'Ollama.HTTP',
        ).info('REQUEST [$requestId] ${request.method} ${request.url}');
      }

      return updatedRequest;
    }

    return request;
  }

  OllamaException _mapHttpError(http.Response response) {
    final statusCode = response.statusCode;
    var message = 'HTTP $statusCode error';

    try {
      final errorDetails = jsonDecode(response.body);
      if (errorDetails is Map<String, dynamic>) {
        message = errorDetails['error']?.toString() ?? message;
      }
    } catch (_) {
      if (response.body.isNotEmpty && response.body.length < 200) {
        message = response.body;
      }
    }

    if (statusCode == 429) {
      DateTime? retryAfter;
      final retryHeader = response.headers['retry-after'];
      if (retryHeader != null) {
        final seconds = int.tryParse(retryHeader);
        if (seconds != null) {
          retryAfter = DateTime.now().add(Duration(seconds: seconds));
        }
      }

      return RateLimitException(
        code: statusCode,
        message: message,
        retryAfter: retryAfter,
      );
    }

    return ApiException(code: statusCode, message: message);
  }

  void _logStreamError(Object error, String requestId) {
    if (config.logLevel.value <= Level.SEVERE.value) {
      Logger('Ollama.HTTP').severe('STREAM ERROR [$requestId] $error', error);
    }
  }
}
