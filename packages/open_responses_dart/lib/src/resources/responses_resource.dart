import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../client/response_stream.dart';
import '../errors/exceptions.dart';
import '../models/request/create_response_request.dart';
import '../models/response/response_resource.dart';
import '../models/streaming/streaming_event.dart';
import '../utils/sse_parser.dart';
import 'base_resource.dart';

/// Resource for the Responses API.
class ResponsesResource extends ResourceBase {
  /// HTTP client for streaming requests.
  final http.Client _httpClient;

  /// Authentication provider for streaming requests.
  final AuthProvider? _authProvider;

  /// Creates a [ResponsesResource].
  ResponsesResource({
    required super.chain,
    required super.requestBuilder,
    required http.Client httpClient,
    AuthProvider? authProvider,
  }) : _httpClient = httpClient,
       _authProvider = authProvider;

  /// Creates a response (non-streaming).
  ///
  /// The optional [abortTrigger] allows canceling the request.
  Future<ResponseResource> create(
    CreateResponseRequest request, {
    Future<void>? abortTrigger,
  }) async {
    // Ensure stream is false
    final requestToSend = (request.stream ?? false)
        ? request.copyWith(stream: false)
        : request;

    final json = await post(
      '/responses',
      body: requestToSend.toJson(),
      abortTrigger: abortTrigger,
    );

    return ResponseResource.fromJson(json);
  }

  /// Creates a streaming response.
  ///
  /// Returns a stream of [StreamingEvent] objects.
  /// The optional [abortTrigger] allows canceling the request.
  Stream<StreamingEvent> createStream(
    CreateResponseRequest request, {
    Future<void>? abortTrigger,
  }) async* {
    // Ensure stream is true
    final requestToSend = request.stream != true
        ? request.copyWith(stream: true)
        : request;

    final uri = requestBuilder.buildUrl('/responses');
    final httpRequest = http.Request('POST', uri)
      ..headers.addAll(requestBuilder.buildHeaders())
      ..body = jsonEncode(requestToSend.toJson());

    // Apply authentication directly (single request for streaming)
    await _applyAuthentication(httpRequest);

    // Send single request for streaming
    final streamedResponse = await _httpClient.send(httpRequest);

    // Handle HTTP errors (since we bypass error interceptor)
    if (streamedResponse.statusCode >= 400) {
      final body = await streamedResponse.stream.bytesToString();
      throw _createExceptionFromResponse(streamedResponse.statusCode, body);
    }

    final parser = SseParser();
    await for (final json in parser.parse(streamedResponse.stream)) {
      final cleaned = json.withoutEventType();
      // Use event type from SSE or fall back to type field
      final eventType = json.sseEventType ?? cleaned['type'] as String?;
      if (eventType != null) {
        cleaned['type'] = eventType;
      }
      yield StreamingEvent.fromJson(cleaned);
    }
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    if (_authProvider == null) return;

    final credentials = await _authProvider.getCredentials();
    switch (credentials) {
      case BearerTokenCredentials(:final token):
        if (!request.headers.containsKey('authorization') &&
            !request.headers.containsKey('Authorization')) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      case NoAuthCredentials():
        // No authentication needed
        break;
    }
  }

  /// Creates an exception from an HTTP error response.
  OpenResponsesException _createExceptionFromResponse(
    int statusCode,
    String body,
  ) {
    final message = _parseErrorMessage(body);

    switch (statusCode) {
      case 400:
        return ValidationException(
          message: message,
          fieldErrors: _parseFieldErrors(body),
        );
      case 401:
        return AuthenticationException(message: message);
      case 429:
        return RateLimitException(code: statusCode, message: message);
      default:
        return ApiException(code: statusCode, message: message);
    }
  }

  /// Parses error message from response body.
  String _parseErrorMessage(String body) {
    if (body.isEmpty) return 'Unknown error';
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final error = json['error'];
        if (error is Map<String, dynamic>) {
          return error['message'] as String? ?? 'Unknown error';
        }
        return json['message'] as String? ?? body;
      }
      return body;
    } catch (_) {
      return body;
    }
  }

  /// Parses field-specific errors from response body.
  Map<String, List<String>> _parseFieldErrors(String body) {
    try {
      final json = jsonDecode(body);
      if (json is Map<String, dynamic>) {
        final error = json['error'];
        if (error is Map<String, dynamic>) {
          final param = error['param'] as String?;
          final message = error['message'] as String?;
          if (param != null && message != null) {
            return {
              param: [message],
            };
          }
        }
      }
    } catch (_) {}
    return {};
  }

  /// Creates a streaming response with builder pattern.
  ///
  /// Returns a [ResponseStream] that allows registering callbacks
  /// and accessing the final response.
  ///
  /// Example:
  /// ```dart
  /// final runner = client.responses.stream(request)
  ///   ..onTextDelta((delta) => stdout.write(delta));
  ///
  /// final response = await runner.finalResponse;
  /// print('\nFinal: ${response?.outputText}');
  /// ```
  ResponseStream stream(
    CreateResponseRequest request, {
    Future<void>? abortTrigger,
  }) {
    return ResponseStream(createStream(request, abortTrigger: abortTrigger));
  }
}
