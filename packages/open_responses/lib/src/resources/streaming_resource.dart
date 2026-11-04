import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../auth/auth_provider.dart';
import '../errors/exceptions.dart';
import '../utils/request_id.dart';
import '../utils/sse_parser.dart';
import 'base_resource.dart';

/// Mixin providing streaming HTTP request capabilities.
///
/// Provides methods for preparing and sending streaming requests
/// that bypass the interceptor chain for unbuffered response handling.
mixin StreamingResource on ResourceBase {
  /// Prepares a streaming request by applying authentication.
  Future<http.Request> prepareStreamingRequest(http.Request request) async {
    await _applyAuthentication(request);
    return request;
  }

  /// Sends a streaming request and returns the streamed response.
  ///
  /// Throws appropriate exceptions for HTTP error responses.
  Future<http.StreamedResponse> sendStreamingRequest(
    http.Request request,
  ) async {
    final streamedResponse = await httpClient.send(request);
    if (streamedResponse.statusCode >= 400) {
      final body = await streamedResponse.stream.bytesToString();
      throw mapHttpErrorForStreaming(streamedResponse.statusCode, body);
    }
    return streamedResponse;
  }

  /// Sends and parses a streaming request with request-scoped cancellation.
  ///
  /// The request is created on listen. Cancellation closes the local stream and
  /// signals the transport without closing the shared HTTP client. Native
  /// transport cancellation depends on support from the supplied HTTP client.
  Stream<T> streamRequest<T>(
    http.AbortableRequest Function(Future<void> abortTrigger) createRequest,
    T Function(Map<String, dynamic>) parseEvent, {
    Future<void>? abortTrigger,
  }) {
    final nativeAbort = Completer<void>();
    StreamSubscription<dynamic>? subscription;
    Future<void>? cancellation;
    var finished = false;
    var stage = AbortionStage.beforeRequest;
    var correlationId = generateRequestId();
    late StreamController<T> controller;

    Future<void> cancel({bool abort = true}) {
      if (cancellation != null) return cancellation!;
      finished = true;
      if (abort && !nativeAbort.isCompleted) nativeAbort.complete();
      return cancellation ??= Future<void>.sync(() => subscription?.cancel());
    }

    void finish([Object? error, StackTrace? stackTrace]) {
      if (finished) return;
      finished = true;
      if (error != null) controller.addError(error, stackTrace);
      // Transport cleanup may outlive local completion for custom clients.
      cancel(abort: error != null).ignore();
      unawaited(controller.close());
    }

    Future<void> run() async {
      try {
        ensureNotClosed?.call();
        final request = createRequest(nativeAbort.future);
        correlationId = request.headers['X-Request-ID'] ?? correlationId;
        await prepareStreamingRequest(request);
        if (finished) return;
        stage = AbortionStage.duringRequest;
        final response = await httpClient.send(request);
        if (finished) {
          await response.stream.listen(null).cancel();
          return;
        }
        stage = AbortionStage.duringStream;
        if (response.statusCode >= 400) {
          final body = StringBuffer();
          subscription = response.stream
              .transform(utf8.decoder)
              .listen(
                body.write,
                onError: finish,
                onDone: () => finish(
                  mapHttpErrorForStreaming(
                    response.statusCode,
                    body.toString(),
                  ),
                ),
              );
        } else {
          subscription = SseParser()
              .parse(response.stream)
              .listen(
                (event) {
                  if (finished) return;
                  try {
                    controller.add(parseEvent(event));
                  } catch (error, stackTrace) {
                    finish(error, stackTrace);
                  }
                },
                onError: finish,
                onDone: finish,
              );
        }
        if (finished) {
          await subscription?.cancel();
        } else if (controller.isPaused) {
          subscription?.pause();
        }
      } catch (error, stackTrace) {
        finish(error, stackTrace);
      }
    }

    controller = StreamController<T>(
      onListen: () {
        unawaited(
          abortTrigger?.then(
            (_) => finish(
              AbortedException(
                message: 'Stream aborted by user',
                correlationId: correlationId,
                timestamp: DateTime.now(),
                stage: stage,
              ),
            ),
            onError: (Object _, StackTrace _) {},
          ),
        );
        unawaited(run());
      },
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      // Keep local cancellation prompt even if custom transport cleanup stalls.
      onCancel: () => cancel().ignore(),
    );
    return controller.stream;
  }

  /// Applies authentication to a request.
  Future<void> _applyAuthentication(http.BaseRequest request) async {
    final authProvider = config.authProvider;
    if (authProvider == null) return;
    final credentials = await authProvider.getCredentials();
    switch (credentials) {
      case BearerTokenCredentials(:final token):
        if (!request.headers.containsKey('authorization') &&
            !request.headers.containsKey('Authorization')) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      case NoAuthCredentials():
        break;
    }
  }

  /// Maps an HTTP error status code to the appropriate exception.
  OpenResponsesException mapHttpErrorForStreaming(int statusCode, String body) {
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
        return RateLimitException(statusCode: statusCode, message: message);
      default:
        return ApiException(statusCode: statusCode, message: message);
    }
  }

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
}
