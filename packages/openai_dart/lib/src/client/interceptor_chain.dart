import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../interceptors/interceptor.dart';
import '../utils/request_id.dart';
import 'retry_wrapper.dart';

/// Builds and executes an interceptor chain.
///
/// The interceptor chain provides a pipeline for processing HTTP requests
/// and responses. Interceptors are executed in order, with each one having
/// the opportunity to modify the request, response, or short-circuit the chain.
///
/// ## Architecture
///
/// ```text
/// Request → [Interceptor 1] → [Interceptor 2] → ... → [Transport] → Response
///                                                           ↑
///                                                      (RetryWrapper)
/// ```
///
/// The retry wrapper is applied at the transport layer, meaning retries
/// happen after all interceptors have processed the request but before
/// they process the response.
class InterceptorChain {
  /// Creates an [InterceptorChain].
  const InterceptorChain({
    required this.interceptors,
    required this.httpClient,
    this.retryWrapper,
  });

  /// The list of interceptors to execute in order.
  final List<Interceptor> interceptors;

  /// The HTTP client for the transport layer.
  final http.Client httpClient;

  /// Optional retry wrapper for handling transient failures.
  final RetryWrapper? retryWrapper;

  /// Executes the interceptor chain for a request.
  ///
  /// The optional [abortTrigger] allows canceling the request before completion.
  /// When the abort trigger completes, any in-flight operation will be cancelled.
  ///
  /// Returns the HTTP response after all interceptors have processed it.
  Future<http.Response> execute(
    http.BaseRequest request, {
    Future<void>? abortTrigger,
  }) {
    final context = RequestContext(
      request: request,
      metadata: {},
      abortTrigger: abortTrigger,
    );

    return _buildChain(0)(context);
  }

  /// Builds the interceptor chain recursively.
  InterceptorNext _buildChain(int index) {
    if (index >= interceptors.length) {
      // Terminal: execute the actual HTTP request
      return _executeTransport;
    }

    // Recursive: call current interceptor with next in chain
    return (context) {
      final interceptor = interceptors[index];
      final next = _buildChain(index + 1);
      return interceptor.intercept(context, next);
    };
  }

  /// Executes the HTTP transport with optional retry wrapper.
  Future<http.Response> _executeTransport(RequestContext context) {
    final requestToSend = context.request;

    // Transport execution function
    Future<http.Response> executeTransport() async {
      if (context.abortTrigger != null) {
        // Wrap request to enable http client's native abort support
        final abortableRequest = _AbortableRequestWrapper(
          requestToSend,
          context.abortTrigger,
        );

        try {
          final streamedResponse = await httpClient.send(abortableRequest);
          return http.Response.fromStream(streamedResponse);
        } on http.RequestAbortedException catch (e) {
          // Convert http package's abort exception to our AbortedException
          throw AbortedException(message: 'Request aborted by user', cause: e);
        }
      } else {
        // No abort trigger - normal execution
        final streamedResponse = await httpClient.send(requestToSend);
        return http.Response.fromStream(streamedResponse);
      }
    }

    // Execute with or without retry wrapper
    if (retryWrapper case final wrapper?) {
      // Extract correlation ID for retry wrapper tracing
      final correlationId =
          context.metadata['correlationId'] as String? ??
          context.request.headers['X-Request-ID'] ??
          generateRequestId();

      return wrapper.executeWithRetry(
        requestToSend,
        executeTransport,
        context.abortTrigger,
        correlationId,
      );
    } else {
      return executeTransport();
    }
  }
}

/// Wrapper to make a BaseRequest abortable.
///
/// This implements the [http.Abortable] mixin, allowing the http client
/// to properly cancel the HTTP connection when the abort trigger completes.
class _AbortableRequestWrapper extends http.BaseRequest
    implements http.Abortable {
  _AbortableRequestWrapper(this._inner, this.abortTrigger)
    : super(_inner.method, _inner.url) {
    headers.addAll(_inner.headers);
    followRedirects = _inner.followRedirects;
    maxRedirects = _inner.maxRedirects;
    persistentConnection = _inner.persistentConnection;
  }

  final http.BaseRequest _inner;

  @override
  final Future<void>? abortTrigger;

  @override
  http.ByteStream finalize() {
    super.finalize();
    return _inner.finalize();
  }
}
