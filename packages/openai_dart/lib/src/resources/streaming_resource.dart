import 'dart:async' show StreamController, StreamSubscription, unawaited;
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';

import '../errors/exceptions.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

/// Mixin that adds streaming capabilities to a [ResourceBase].
///
/// Provides [sendStream] for making SSE streaming requests with
/// proper abort support, dedicated HTTP client per stream, and cleanup
/// on completion, error, and subscription cancellation.
mixin StreamingResource on ResourceBase {
  /// Sends a streaming POST request and yields parsed SSE JSON events.
  ///
  /// Creates a dedicated HTTP client per stream for abort support.
  /// The [abortTrigger] parameter allows canceling the request. When the
  /// future completes, the underlying HTTP connection is closed, which
  /// terminates the stream.
  ///
  /// Returns the raw [http.StreamedResponse] for resources that need
  /// custom SSE parsing (e.g., typed event deserialization).
  ///
  /// Note: Streaming requests are NOT retried (non-idempotent, body consumed).
  /// The interceptor chain is bypassed since streaming requires low-level
  /// access to the response stream.
  Future<http.StreamedResponse> sendStream({
    required http.Request request,
    String? jsonBody,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async {
    ensureNotClosed?.call();

    // Add streaming-specific headers
    final streamHeaders = requestBuilder.buildStreamingHeaders(
      additionalHeaders: additionalHeaders,
    );
    request.headers.addAll(streamHeaders);

    // Set body AFTER headers so body setter adds charset to Content-Type
    // (e.g., application/json → application/json; charset=utf-8)
    if (jsonBody != null) {
      request.body = jsonBody;
    }

    // Log request if logging is enabled
    Logger('OpenAIClient').fine('Streaming ${request.method} ${request.url}');

    // For abort support, create a dedicated HTTP client for this stream.
    // When abortTrigger completes, we close the client which cancels
    // the in-flight request and terminates the stream.
    if (abortTrigger != null) {
      final dedicatedClient = streamClientFactory?.call() ?? http.Client();
      var aborted = false;
      var clientClosed = false;

      void closeClientOnce() {
        if (!clientClosed) {
          clientClosed = true;
          dedicatedClient.close();
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
        final response = await dedicatedClient.send(request);

        // Use StreamController to ensure client cleanup on ALL termination
        // paths:
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
    return httpClient.send(request);
  }

  /// Parses an error response from a streaming request.
  ApiException parseStreamError(int statusCode, String body, String requestId) {
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

  /// Helper to create a streaming POST request with a JSON body.
  ///
  /// Returns the [http.StreamedResponse] with proper error checking.
  Future<http.StreamedResponse> sendStreamRequest({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) {
    final url = requestBuilder.buildUrl(endpoint);
    final request = http.Request('POST', url);

    return sendStream(
      request: request,
      jsonBody: jsonEncode(body),
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );
  }

  /// Streams SSE events from a streaming POST request.
  ///
  /// Yields parsed JSON maps from Server-Sent Events. Handles error
  /// responses (status >= 400) by throwing appropriate [ApiException]s.
  Stream<Map<String, dynamic>> streamSseEvents({
    required String endpoint,
    required Map<String, dynamic> body,
    Map<String, String>? additionalHeaders,
    Future<void>? abortTrigger,
  }) async* {
    final response = await sendStreamRequest(
      endpoint: endpoint,
      body: body,
      additionalHeaders: additionalHeaders,
      abortTrigger: abortTrigger,
    );

    // Extract request ID from response headers for error reporting
    final requestId =
        response.headers['x-request-id'] ??
        response.request?.headers['X-Request-ID'] ??
        'unknown';

    try {
      if (response.statusCode >= 400) {
        final responseBody = await response.stream.bytesToString();
        throw parseStreamError(response.statusCode, responseBody, requestId);
      }

      const parser = SseParser();
      await for (final json in parser.parse(response.stream)) {
        yield json;
      }
    } on AbortedException {
      rethrow;
    }
  }

  /// Checks for inline errors in SSE stream data and throws
  /// [StreamException] if found.
  ///
  /// Detects two error patterns:
  /// 1. SSE `event: error` — parser sets `_event: "error"` in the JSON map
  /// 2. Error objects in data — from providers like AWS Bedrock that embed
  ///    errors in HTTP 200 SSE responses
  ///
  /// Supports multiple error formats:
  /// - Standard OpenAI: `{"error": {"message": "...", "type": "..."}}`
  /// - AWS Bedrock: `{"error": {"error": "...", "error_code": 4001}}`
  /// - Plain string: `{"error": "Something went wrong"}`
  ///
  /// This is intentionally NOT called from [streamSseEvents] because some
  /// resources (e.g., Responses API) handle `ErrorEvent` as a normal stream
  /// event rather than as an exception.
  Never throwInlineStreamError(
    Map<String, dynamic> json,
    String? sseEvent,
    Object? error,
  ) {
    String message;
    if (error is Map<String, dynamic>) {
      message = (error['message'] ?? error['error'] ?? 'Unknown stream error')
          .toString();
    } else if (error is String) {
      message = error;
    } else if (sseEvent == 'error') {
      message = 'Stream error event received';
    } else {
      message = 'Unknown stream error';
    }

    Logger('OpenAIClient').warning('Inline stream error: $message');

    // Strip internal `_event` field and encode as JSON for partialData
    final cleanJson = Map<String, dynamic>.from(json)..remove('_event');
    throw StreamException(message: message, partialData: jsonEncode(cleanJson));
  }
}
