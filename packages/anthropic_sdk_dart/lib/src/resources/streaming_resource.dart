import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../utils/request_id.dart';
import '../utils/streaming_parser.dart';
import 'base_resource.dart';

/// Mixin that provides streaming capabilities for resources.
///
/// Handles SSE (Server-Sent Events) streaming for Anthropic API responses.
mixin StreamingResource on ResourceBase {
  /// Makes a streaming POST request.
  ///
  /// Returns a stream of parsed SSE events as JSON maps.
  /// The optional [abortTrigger] cancels the request and closes the stream.
  /// Transport cancellation depends on support from the supplied HTTP client;
  /// it does not guarantee the server has stopped processing the request.
  Stream<Map<String, dynamic>> postStream(
    String path, {
    required Map<String, dynamic> body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) => _stream(
    'POST',
    path,
    body: body,
    queryParams: queryParams,
    headers: headers,
    abortTrigger: abortTrigger,
  );

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
        statusCode: statusCode,
        message: message,
        details: details,
      );
    }

    return ApiException(
      statusCode: statusCode,
      message: message,
      details: details,
    );
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

  /// Makes a streaming GET request.
  ///
  /// Returns a stream of parsed SSE events as JSON maps.
  /// The optional [abortTrigger] cancels the request and closes the stream.
  /// Transport cancellation depends on support from the supplied HTTP client;
  /// it does not guarantee the server has stopped processing the request.
  Stream<Map<String, dynamic>> getStream(
    String path, {
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) => _stream(
    'GET',
    path,
    queryParams: queryParams,
    headers: headers,
    abortTrigger: abortTrigger,
  );

  Stream<Map<String, dynamic>> _stream(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, dynamic>? queryParams,
    Map<String, String>? headers,
    Future<void>? abortTrigger,
  }) {
    final requestAbort = Completer<void>();
    // Canceled by stop when the stream terminates or its listener cancels.
    // ignore: cancel_subscriptions
    StreamSubscription<dynamic>? subscription;
    StreamSubscription<List<int>>? bodySubscription;
    StreamController<List<int>>? bytesController;
    var correlationId = generateRequestId();
    var stopped = false;
    late StreamController<Map<String, dynamic>> controller;

    void stop() {
      stopped = true;
      if (!requestAbort.isCompleted) requestAbort.complete();
      final current = subscription;
      if (current != null) unawaited(current.cancel());
      final body = bodySubscription;
      if (body != null) unawaited(body.cancel());
      final bytes = bytesController;
      if (bytes != null && !bytes.isClosed) unawaited(bytes.close());
    }

    Future<void> run() async {
      try {
        ensureNotClosed?.call();
        final uri = requestBuilder.buildUrl(path, queryParams: queryParams);
        final request =
            http.AbortableRequest(
                method,
                uri,
                abortTrigger: requestAbort.future,
              )
              ..headers.addAll(
                requestBuilder.buildHeaders(additionalHeaders: headers),
              );
        if (body != null) request.body = jsonEncode(body);
        await _applyAuthentication(request);
        if (stopped) return;
        correlationId = request.headers['X-Request-ID'] ?? correlationId;
        final response = await httpClient.send(request);
        if (stopped) {
          await response.stream.listen(null).cancel();
          return;
        }
        if (response.statusCode >= 400) {
          final responseBody = StringBuffer();
          subscription = response.stream
              .transform(utf8.decoder)
              .listen(
                responseBody.write,
                onError: controller.addError,
                onDone: () {
                  controller.addError(
                    _createStreamException(
                      response.statusCode,
                      responseBody.toString(),
                      correlationId,
                    ),
                  );
                  unawaited(controller.close());
                },
              );
        } else {
          late StreamController<List<int>> bytes;
          bytes = StreamController<List<int>>(
            onListen: () {
              bodySubscription = response.stream.listen(
                bytes.add,
                onError: bytes.addError,
                onDone: () => unawaited(bytes.close()),
              );
            },
            onPause: () => bodySubscription?.pause(),
            onResume: () => bodySubscription?.resume(),
            onCancel: () => bodySubscription?.cancel(),
          );
          bytesController = bytes;
          subscription = SseParser()
              .parse(bytes.stream)
              .listen(
                controller.add,
                onError: controller.addError,
                onDone: () => unawaited(controller.close()),
              );
        }
        if (controller.isPaused) subscription?.pause();
      } catch (error, stackTrace) {
        if (!stopped) {
          controller.addError(error, stackTrace);
          unawaited(controller.close());
        }
      }
    }

    controller = StreamController<Map<String, dynamic>>(
      onListen: () {
        unawaited(
          abortTrigger?.then((_) {
            if (stopped) return;
            stop();
            controller.addError(
              AbortedException(
                message: 'Stream aborted by user',
                correlationId: correlationId,
                timestamp: DateTime.now(),
                stage: AbortionStage.duringStream,
              ),
            );
            unawaited(controller.close());
          }, onError: (Object _, StackTrace stackTrace) {}),
        );
        unawaited(run());
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: stop,
    );
    return controller.stream;
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.Request request) async {
    final provider = config.authProvider;
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
