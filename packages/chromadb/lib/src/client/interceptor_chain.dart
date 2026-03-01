import 'dart:async';

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
  /// When [isIdempotent] is true, POST requests are treated as idempotent
  /// for retry purposes.
  Future<http.Response> execute(
    http.BaseRequest request, {
    Future<void>? abortTrigger,
    bool isIdempotent = false,
  }) {
    ensureNotClosed?.call();

    final context = RequestContext(
      request: request,
      metadata: {'timestamp': DateTime.now()},
      abortTrigger: abortTrigger,
    );

    return _buildChain(0, isIdempotent: isIdempotent)(context);
  }

  /// Builds the interceptor chain recursively.
  InterceptorNext _buildChain(int index, {bool isIdempotent = false}) {
    if (index >= interceptors.length) {
      // Terminal: execute the actual HTTP request
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

        // Transport execution function
        Future<http.Response> executeTransport() async {
          final requestToSend = createRequest();
          if (context.abortTrigger != null) {
            final abortableRequest = _AbortableRequestWrapper(
              requestToSend,
              context.abortTrigger,
            );

            try {
              final streamedResponse = await httpClient.send(abortableRequest);
              return await http.Response.fromStream(streamedResponse);
            } on http.RequestAbortedException catch (e) {
              throw AbortedException(
                message: 'Request aborted by user',
                cause: e,
              );
            }
          } else {
            final streamedResponse = await httpClient.send(requestToSend);
            return http.Response.fromStream(streamedResponse);
          }
        }

        // Execute with or without retry wrapper
        if (retryWrapper != null && originalRequest is http.Request) {
          final correlationId =
              context.metadata['correlationId'] as String? ??
              context.request.headers['X-Request-ID'] ??
              generateRequestId();

          return retryWrapper!.executeWithRetry(
            originalRequest,
            executeTransport,
            context.abortTrigger,
            correlationId,
            isIdempotent: isIdempotent,
          );
        } else {
          return executeTransport();
        }
      };
    }

    // Recursive: call current interceptor with next in chain
    return (context) {
      final interceptor = interceptors[index];
      final next = _buildChain(index + 1, isIdempotent: isIdempotent);

      return interceptor.intercept(context, next);
    };
  }
}

/// Wrapper to make a BaseRequest abortable by implementing Abortable mixin.
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
