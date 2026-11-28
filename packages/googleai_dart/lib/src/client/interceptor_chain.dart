import 'dart:async';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import '../errors/exceptions.dart';
import '../interceptors/interceptor.dart';
import '../utils/request_id.dart';
import 'retry_wrapper.dart';

/// Builds and executes an interceptor chain.
class InterceptorChain {
  /// List of interceptors to execute in order.
  final List<Interceptor> interceptors;

  /// HTTP client for transport layer.
  final http.Client httpClient;

  /// Retry wrapper for transport execution.
  final RetryWrapper? retryWrapper;

  /// Callback to check if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Creates an [InterceptorChain].
  InterceptorChain({
    required this.interceptors,
    required this.httpClient,
    this.retryWrapper,
    this.ensureNotClosed,
  });

  /// Executes the interceptor chain for a request.
  ///
  /// The optional [abortTrigger] allows canceling the request before completion.
  ///
  /// [checkActive] can prevent an attempt from starting after asynchronous
  /// preparation and prevent reading a response that arrived after cancellation.
  /// Returns the HTTP response after all interceptors have processed it.
  Future<http.Response> execute(
    http.BaseRequest request, {
    Future<void>? abortTrigger,
    void Function()? checkActive,
  }) {
    ensureNotClosed?.call();

    final context = RequestContext(
      request: request,
      metadata: {},
      abortTrigger: abortTrigger,
    );

    return _buildChain(0, checkActive)(context);
  }

  /// Builds the interceptor chain recursively.
  InterceptorNext _buildChain(int index, void Function()? checkActive) {
    if (index >= interceptors.length) {
      // Terminal: execute the actual HTTP request
      // Per spec, retry wraps the transport execution
      return (context) {
        final originalRequest = context.request;

        // For retries, clone the request since http.BaseRequest can only be
        // finalized once. Capture body bytes before the first finalize().
        List<int>? bodyBytes;
        if (originalRequest is http.Request) {
          bodyBytes = originalRequest.bodyBytes;
        }

        // Creates a fresh request for each attempt (required for retries).
        http.BaseRequest createRequest() {
          if (originalRequest is http.Request) {
            return http.Request(originalRequest.method, originalRequest.url)
              ..headers.addAll(originalRequest.headers)
              ..followRedirects = originalRequest.followRedirects
              ..maxRedirects = originalRequest.maxRedirects
              ..persistentConnection = originalRequest.persistentConnection
              ..bodyBytes = bodyBytes ?? [];
          }
          // Non-cloneable request types (MultipartRequest, etc.) are returned
          // as-is and will not be retried.
          return originalRequest;
        }

        Future<http.Response> readResponse(http.StreamedResponse response) {
          try {
            checkActive?.call();
          } catch (_) {
            response.stream.listen(null).cancel().ignore();
            rethrow;
          }
          final abort = context.abortTrigger;
          if (checkActive == null || abort == null) {
            return http.Response.fromStream(response);
          }
          return _readAbortableResponse(response, abort, checkActive);
        }

        // Transport execution function
        Future<http.Response> executeTransport() async {
          checkActive?.call();
          final requestToSend = createRequest();
          if (context.abortTrigger != null) {
            // Wrap request to enable http client's native abort support
            final abortableRequest = _AbortableRequestWrapper(
              requestToSend,
              context.abortTrigger,
            );

            // Track stage for accurate abort reporting
            var stage = AbortionStage.beforeRequest;

            try {
              final streamedResponse = await httpClient.send(abortableRequest);
              // If we get here, request was sent successfully
              stage = AbortionStage.duringResponse;
              return await readResponse(streamedResponse);
            } on http.RequestAbortedException catch (e) {
              // Convert http package's abort exception to our AbortedException
              final correlationId =
                  context.metadata['correlationId'] as String? ??
                  context.request.headers['X-Request-ID'] ??
                  generateRequestId();
              throw AbortedException(
                message: 'Request aborted by user',
                correlationId: correlationId,
                timestamp: DateTime.now(),
                stage: stage,
                reason: e,
              );
            }
          } else {
            // No abort trigger - normal execution
            final streamedResponse = await httpClient.send(requestToSend);
            return readResponse(streamedResponse);
          }
        }

        // Execute with or without retry wrapper
        if (retryWrapper != null && originalRequest is http.Request) {
          // Extract correlation ID for retry wrapper tracing
          final correlationId =
              context.metadata['correlationId'] as String? ??
              context.request.headers['X-Request-ID'] ??
              generateRequestId();

          // Per spec: Retry wraps transport execution
          return retryWrapper!.executeWithRetry(
            originalRequest,
            executeTransport,
            context
                .abortTrigger, // Pass abort trigger for retry delay interruption
            correlationId, // Pass correlation ID for error tracing
          );
        } else {
          return executeTransport();
        }
      };
    }

    // Recursive: call current interceptor with next in chain
    return (context) {
      final interceptor = interceptors[index];
      final next = _buildChain(index + 1, checkActive);

      return interceptor.intercept(context, next);
    };
  }
}

Future<http.Response> _readAbortableResponse(
  http.StreamedResponse response,
  Future<void> abortTrigger,
  void Function() checkActive,
) {
  final result = Completer<http.Response>();
  final body = BytesBuilder();
  final subscription = response.stream.listen(
    body.add,
    onError: result.completeError,
    onDone: () {
      try {
        checkActive();
        result.complete(
          http.Response.bytes(
            body.takeBytes(),
            response.statusCode,
            request: response.request,
            headers: response.headers,
            isRedirect: response.isRedirect,
            persistentConnection: response.persistentConnection,
            reasonPhrase: response.reasonPhrase,
          ),
        );
      } catch (error, trace) {
        result.completeError(error, trace);
      }
    },
    cancelOnError: true,
  );
  unawaited(
    abortTrigger.then((_) {
      if (result.isCompleted) return;
      try {
        checkActive();
      } catch (error, trace) {
        // A custom HTTP client can ignore Abortable; release our own reader too.
        subscription.cancel().ignore();
        result.completeError(error, trace);
      }
    }, onError: (Object _, StackTrace _) {}),
  );
  return result.future;
}

/// Wrapper to make a BaseRequest abortable by implementing Abortable mixin.
///
/// This allows the http client (IOClient/BrowserClient) to properly cancel
/// the HTTP connection when the abort trigger completes, preventing resource
/// leaks and background network activity.
class _AbortableRequestWrapper extends http.BaseRequest
    implements http.Abortable {
  final http.BaseRequest _inner;

  @override
  final Future<void>? abortTrigger;

  _AbortableRequestWrapper(this._inner, this.abortTrigger)
    : super(_inner.method, _inner.url) {
    headers.addAll(_inner.headers);
    followRedirects = _inner.followRedirects;
    maxRedirects = _inner.maxRedirects;
    persistentConnection = _inner.persistentConnection;
    contentLength = _inner.contentLength;
  }

  @override
  http.ByteStream finalize() {
    super.finalize();
    return _inner.finalize();
  }
}
