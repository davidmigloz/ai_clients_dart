import 'dart:async';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../interceptors/interceptor.dart';
import '../utils/request_id.dart';
import 'buffered_http_attempt.dart';
import 'retry_wrapper.dart';

/// Builds and executes an interceptor chain.
class InterceptorChain {
  /// List of interceptors to execute in order.
  final List<Interceptor> interceptors;

  /// HTTP client for transport layer.
  final http.Client httpClient;

  /// Retry wrapper for transport execution.
  final RetryWrapper? retryWrapper;

  /// Deadline for a single buffered HTTP attempt.
  final Duration? timeout;

  /// Callback to check if the client has been closed.
  final void Function()? ensureNotClosed;

  /// Creates an [InterceptorChain].
  InterceptorChain({
    required this.interceptors,
    required this.httpClient,
    this.retryWrapper,
    this.timeout,
    this.ensureNotClosed,
  });

  /// Executes the interceptor chain for a request.
  ///
  /// The optional [abortTrigger] allows canceling the request before completion.
  ///
  /// Returns the HTTP response after all interceptors have processed it.
  Future<http.Response> execute(
    http.BaseRequest request, {
    Future<void>? abortTrigger,
  }) {
    ensureNotClosed?.call();
    final context = RequestContext(
      request: request,
      metadata: {},
      abortTrigger: abortTrigger,
    );

    final nativeRequest = request is http.Abortable ? request : null;
    if (abortTrigger == null) {
      return _buildChain(0, nativeRequest: nativeRequest)(context);
    }

    final admission = _TransportAdmission(request.headers['X-Request-ID']);
    return admission.run(
      abortTrigger,
      () => _buildChain(0, admission: admission, nativeRequest: nativeRequest)(
        context,
      ),
    );
  }

  /// Builds the interceptor chain recursively.
  InterceptorNext _buildChain(
    int index, {
    _TransportAdmission? admission,
    http.Abortable? nativeRequest,
  }) {
    if (index >= interceptors.length) {
      // Terminal: execute the actual HTTP request
      // Per spec, retry wraps the transport execution
      return (context) async {
        if (admission != null) {
          // Drain cancellation queued in the same event turn as authentication.
          // Hand off to the transport synchronously after checking admission.
          await Future<void>.delayed(Duration.zero);
          admission.enter();
        }
        final originalRequest = context.request;

        // For retries, clone the request since http.BaseRequest can only be
        // finalized once. Capture body bytes before the first finalize().
        List<int>? bodyBytes;
        if (originalRequest is http.Request) {
          bodyBytes = originalRequest.bodyBytes;
        }

        // Creates a fresh request for each attempt (required for retries).
        http.BaseRequest createRequest([Future<void>? abortTrigger]) {
          if (originalRequest is http.Request) {
            return (abortTrigger == null
                  ? http.Request(originalRequest.method, originalRequest.url)
                  : http.AbortableRequest(
                      originalRequest.method,
                      originalRequest.url,
                      abortTrigger: abortTrigger,
                    ))
              ..headers.addAll(originalRequest.headers)
              ..followRedirects = originalRequest.followRedirects
              ..maxRedirects = originalRequest.maxRedirects
              ..persistentConnection = originalRequest.persistentConnection
              ..bodyBytes = bodyBytes ?? [];
          }
          // Non-cloneable requests are sent only once.
          return abortTrigger == null
              ? originalRequest
              : _AbortableRequestWrapper(originalRequest, abortTrigger);
        }

        final correlationId =
            context.metadata['correlationId'] as String? ??
            context.request.headers['X-Request-ID'] ??
            generateRequestId();

        Future<http.Response> executeTransport() async {
          ensureNotClosed?.call();
          if (timeout == null &&
              context.abortTrigger == null &&
              nativeRequest?.abortTrigger == null) {
            return http.Response.fromStream(
              await httpClient.send(createRequest()),
            );
          }
          return sendBufferedHttpAttempt(
            send: (abortTrigger) =>
                httpClient.send(createRequest(abortTrigger)),
            timeout: timeout,
            abortTrigger: context.abortTrigger,
            correlationId: correlationId,
            nativeRequest: nativeRequest,
          );
        }

        // Execute with or without retry wrapper
        if (retryWrapper != null && originalRequest is http.Request) {
          // Per spec: Retry wraps transport execution
          return retryWrapper!.executeWithRetry(
            originalRequest,
            executeTransport,
            context.abortTrigger,
            correlationId,
          );
        } else {
          return executeTransport();
        }
      };
    }

    // Recursive: call current interceptor with next in chain
    return (context) {
      final interceptor = interceptors[index];
      final next = _buildChain(
        index + 1,
        admission: admission,
        nativeRequest: nativeRequest,
      );

      return interceptor.intercept(context, next);
    };
  }
}

/// Cancels while the interceptor chain is waiting to reach transport.
class _TransportAdmission {
  _TransportAdmission(this._correlationId);

  final String? _correlationId;
  Completer<http.Response>? _pending = Completer();
  AbortedException? _failure;

  Future<http.Response> run(
    Future<void> abortTrigger,
    Future<http.Response> Function() execute,
  ) {
    final result = _pending!;
    unawaited(
      abortTrigger.then<void>(_abort, onError: (Object _, StackTrace _) {}),
    );
    unawaited(_complete(result, execute));
    return result.future;
  }

  Future<void> _complete(
    Completer<http.Response> result,
    Future<http.Response> Function() execute,
  ) async {
    try {
      // Give an already-completed abort trigger a chance to prevent admission.
      final response = await Future<http.Response>.microtask(() {
        _throwIfAborted();
        return execute();
      });
      if (!result.isCompleted) result.complete(response);
    } catch (error, stackTrace) {
      if (!result.isCompleted) result.completeError(error, stackTrace);
    } finally {
      _pending = null;
    }
  }

  void enter() {
    _throwIfAborted();
    // The transport and retry wrapper handle cancellation from this point on.
    _pending = null;
  }

  void _abort(void _) {
    final pending = _pending;
    if (pending == null) return;
    final failure = AbortedException(
      message: 'Request aborted by user',
      correlationId: _correlationId ?? generateRequestId(),
      timestamp: DateTime.now(),
      stage: AbortionStage.beforeRequest,
    );
    _failure = failure;
    _pending = null;
    pending.completeError(failure);
  }

  void _throwIfAborted() {
    if (_failure case final failure?) throw failure;
  }
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
    final stream = _inner.finalize();
    // Multipart requests set their boundary during finalization.
    headers.addAll(_inner.headers);
    contentLength = _inner.contentLength;
    super.finalize();
    return stream;
  }
}
