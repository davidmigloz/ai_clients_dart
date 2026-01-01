import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../client/request_builder.dart';
import '../errors/exceptions.dart';
import '../utils/request_id.dart';
import '../utils/streaming_parser.dart';

/// Mixin that provides streaming capabilities for resources.
///
/// Handles SSE (Server-Sent Events) streaming for Anthropic API responses.
mixin StreamingResource {
  /// The HTTP client for streaming requests.
  http.Client get httpClient;

  /// The request builder for constructing URLs and headers.
  RequestBuilder get requestBuilder;

  /// The authentication provider for streaming requests.
  ///
  /// Returns null if no authentication is configured.
  AuthProvider? get authProvider;

  /// Makes a streaming POST request.
  ///
  /// Returns a stream of parsed SSE events as JSON maps.
  /// The optional [abortTrigger] allows canceling the stream.
  Stream<Map<String, dynamic>> postStream(
    String path, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) async* {
    final uri = requestBuilder.buildUrl(path, queryParams: queryParams);
    final request = http.Request('POST', uri)
      ..headers.addAll(requestBuilder.buildHeaders(additionalHeaders: headers))
      ..body = jsonEncode(body);

    // Add authentication header if auth provider is configured
    await _applyAuthentication(request);

    final correlationId =
        request.headers['X-Request-ID'] ?? generateRequestId();

    // Send the request
    final streamedResponse = await httpClient.send(request);

    // Check for errors
    if (streamedResponse.statusCode >= 400) {
      final responseBody = await streamedResponse.stream.bytesToString();
      throw _createStreamException(
        streamedResponse.statusCode,
        responseBody,
        correlationId,
      );
    }

    // Parse SSE stream
    final parser = SseParser();
    final eventStream = parser.parse(streamedResponse.stream);

    // Handle abort during streaming
    if (abortTrigger != null) {
      var aborted = false;

      // Listen for abort signal
      abortTrigger.then((_) {
        aborted = true;
      }).ignore();

      await for (final event in eventStream) {
        if (aborted) {
          throw AbortedException(
            message: 'Stream aborted by user',
            correlationId: correlationId,
            timestamp: DateTime.now(),
            stage: AbortionStage.duringStream,
          );
        }
        yield event;
      }
    } else {
      yield* eventStream;
    }
  }

  /// Creates an exception for streaming errors.
  AnthropicException _createStreamException(
    int statusCode,
    String body,
    String correlationId,
  ) {
    final (message, details) = _parseErrorBody(body);

    if (statusCode == 401) {
      return AuthenticationException(message: message);
    }

    if (statusCode == 429) {
      return RateLimitException(
        code: statusCode,
        message: message,
        details: details,
      );
    }

    return ApiException(code: statusCode, message: message, details: details);
  }

  /// Parses error message and details from response body.
  (String, List<Object>) _parseErrorBody(String body) {
    if (body.isEmpty) {
      return ('Unknown error', <Object>[]);
    }

    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        // Anthropic error format: {"type": "error", "error": {"type": "...", "message": "..."}}
        final error = json['error'];
        if (error is Map<String, dynamic>) {
          final message = error['message'] as String? ?? 'Unknown error';
          final errorType = error['type'] as String?;
          return (
            message,
            errorType != null ? <Object>[errorType] : <Object>[],
          );
        }
        // Fallback: {"message": "..."}
        final message = json['message'];
        if (message is String) {
          return (message, <Object>[]);
        }
        return (body, <Object>[]);
      }
      return (body, <Object>[]);
    } catch (_) {
      return (body, <Object>[]);
    }
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.Request request) async {
    final provider = authProvider;
    if (provider == null) return;

    final credentials = await provider.getCredentials();
    switch (credentials) {
      case ApiKeyCredentials(:final apiKey):
        if (!request.headers.containsKey('x-api-key')) {
          request.headers['x-api-key'] = apiKey;
        }
      case NoAuthCredentials():
        // No authentication needed
        break;
    }
  }
}
