import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../interceptors/interceptor.dart';
import '../utils/private_agent_inspection_http.dart';
import '../utils/request_id.dart';
import '../utils/speech_redaction.dart';
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
  InterceptorChain({
    required this.interceptors,
    required this.httpClient,
    this.retryWrapper,
    this.timeout,
    this.ensureNotClosed,
  });

  /// The list of interceptors to execute in order.
  final List<Interceptor> interceptors;

  /// The HTTP client for the transport layer.
  final http.Client httpClient;

  /// Optional retry wrapper for handling transient failures.
  final RetryWrapper? retryWrapper;

  /// Optional timeout for individual requests.
  ///
  /// If set, requests will throw [RequestTimeoutException] if they exceed
  /// this duration.
  final Duration? timeout;

  /// Optional callback to verify the client hasn't been closed.
  ///
  /// When provided, this is called at the start of [execute] to fail fast
  /// if the client has been closed, rather than proceeding with a request
  /// that would fail later.
  final void Function()? ensureNotClosed;

  /// Executes the interceptor chain for a request.
  ///
  /// The optional [abortTrigger] allows canceling the request before completion.
  /// When the abort trigger completes, any in-flight operation will be cancelled.
  ///
  /// Returns the HTTP response after all interceptors have processed it.
  /// When [allowRetries] is false, transport runs once and repeated interceptor
  /// continuations receive that same result or failure. This prevents replay of
  /// sensitive authentication submissions, including by custom retry middleware.
  Future<http.Response> execute(
    http.BaseRequest request, {
    Future<void>? abortTrigger,
    bool allowRetries = true,
  }) {
    ensureNotClosed?.call();

    final context = RequestContext(
      request: request,
      metadata: {if (!allowRetries) 'automaticRetriesDisabled': true},
      abortTrigger: abortTrigger,
    );

    Future<http.Response>? firstTransport;
    final InterceptorNext? terminal = allowRetries
        ? null
        : (context) => firstTransport ??= Future<http.Response>.microtask(
            () => _executeTransport(context, allowRetries: false),
          );
    return _buildChain(0, terminal: terminal)(context);
  }

  /// Builds the interceptor chain recursively.
  InterceptorNext _buildChain(int index, {InterceptorNext? terminal}) {
    if (index >= interceptors.length) {
      // Terminal: execute the actual HTTP request
      return terminal ?? _executeTransport;
    }

    // Recursive: call current interceptor with next in chain
    return (context) {
      final interceptor = interceptors[index];
      final next = _buildChain(index + 1, terminal: terminal);
      return interceptor.intercept(context, next);
    };
  }

  /// Executes the HTTP transport with optional retry wrapper.
  Future<http.Response> _executeTransport(
    RequestContext context, {
    bool allowRetries = true,
  }) {
    final originalRequest = context.request;

    // Extract correlation ID upfront for tracing (used in retries and abort).
    // Priority: metadata > request header > generate new.
    // Always ensure X-Request-ID header is present for server-side tracing.
    // Treat empty/whitespace IDs as missing.
    final rawMetadataCorrelationId =
        context.metadata['correlationId'] as String?;
    final rawHeaderCorrelationId = context.request.headers['X-Request-ID'];
    final metadataCorrelationId =
        (rawMetadataCorrelationId?.trim().isNotEmpty ?? false)
        ? rawMetadataCorrelationId!.trim()
        : null;
    final headerCorrelationId =
        (rawHeaderCorrelationId?.trim().isNotEmpty ?? false)
        ? rawHeaderCorrelationId!.trim()
        : null;
    final correlationId =
        metadataCorrelationId ?? headerCorrelationId ?? generateRequestId();
    // Add/overwrite header if it was missing or blank
    final needsCorrelationIdHeader =
        rawHeaderCorrelationId == null || rawHeaderCorrelationId.trim().isEmpty;

    // Persist to metadata for downstream interceptors and logging
    context.metadata['correlationId'] = correlationId;

    // For retries, we need to clone the request since http.BaseRequest
    // can only be finalized once. Capture body bytes upfront.
    List<int>? bodyBytes;
    if (originalRequest is http.Request) {
      bodyBytes = originalRequest.bodyBytes;
    }

    // Creates a fresh request for each attempt (required for retries)
    http.BaseRequest createRequest() {
      if (originalRequest is http.Request) {
        final request =
            http.Request(originalRequest.method, originalRequest.url)
              ..headers.addAll(originalRequest.headers)
              ..followRedirects = originalRequest.followRedirects
              ..maxRedirects = originalRequest.maxRedirects
              ..persistentConnection = originalRequest.persistentConnection;
        // Add correlation ID header if it was generated (not already present)
        if (needsCorrelationIdHeader) {
          request.headers['X-Request-ID'] = correlationId;
        }
        if (bodyBytes != null && bodyBytes.isNotEmpty) {
          request.bodyBytes = bodyBytes;
        }
        return request;
      }
      // For other request types (MultipartRequest, etc.), add correlation ID
      // header directly since we can't clone them for retries anyway.
      if (needsCorrelationIdHeader) {
        originalRequest.headers['X-Request-ID'] = correlationId;
      }
      return originalRequest;
    }

    // Transport execution function (single attempt)
    Future<http.Response> executeTransport() {
      final requestToSend = createRequest();

      Future<http.Response> sendRequest() async {
        if (context.abortTrigger != null) {
          // Wrap request to enable http client's native abort support
          final abortableRequest = _AbortableRequestWrapper(
            requestToSend,
            context.abortTrigger,
          );

          try {
            return await privateAgentInspectionTransport(
              abortableRequest,
              () async {
                final streamedResponse = await httpClient.send(
                  abortableRequest,
                );
                return _bufferPrivateResponse(
                  streamedResponse,
                  abortableRequest,
                );
              },
            );
          } on http.RequestAbortedException catch (e) {
            // Convert http package's abort exception to our AbortedException
            throw AbortedException(
              message: 'Request aborted by user',
              cause: e,
              stage: AbortionStage.duringRequest,
              correlationId: correlationId,
            );
          }
        } else {
          // No abort trigger - normal execution
          return privateAgentInspectionTransport(requestToSend, () async {
            final streamedResponse = await httpClient.send(requestToSend);
            return _bufferPrivateResponse(streamedResponse, requestToSend);
          });
        }
      }

      // Apply timeout per-attempt so that timeouts can be retried
      if (timeout case final timeoutDuration?) {
        return sendRequest().timeout(
          timeoutDuration,
          onTimeout: () {
            throw RequestTimeoutException(
              message: 'Request timed out after ${timeoutDuration.inSeconds}s',
              timeout: timeoutDuration,
            );
          },
        );
      }

      return sendRequest();
    }

    // Execute with or without retry wrapper
    // Note: Retries are only supported for http.Request types because other
    // request types (MultipartRequest, StreamedRequest) cannot be safely cloned.
    if (retryWrapper case final wrapper?
        when originalRequest is http.Request && allowRetries) {
      return wrapper.executeWithRetry(
        originalRequest,
        executeTransport,
        context.abortTrigger,
        correlationId,
      );
    }

    return executeTransport();
  }
}

Future<http.Response> _bufferPrivateResponse(
  http.StreamedResponse streamed,
  http.BaseRequest sentRequest,
) async {
  final response = await http.Response.fromStream(streamed);
  if (!isAgentSessionSubagentRequest(sentRequest) &&
      (response.request != null || !isPrivateAudioRequest(sentRequest))) {
    return response;
  }
  // Some injected transports omit request context. Retain the actual sent
  // auth/trace headers for all private response modes, including 1xx/3xx errors.
  return http.Response.bytes(
    response.bodyBytes,
    response.statusCode,
    request: sentRequest,
    headers: response.headers,
    isRedirect: response.isRedirect,
    persistentConnection: response.persistentConnection,
    reasonPhrase: response.reasonPhrase,
  );
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
    contentLength = _inner.contentLength;
  }

  final http.BaseRequest _inner;

  @override
  final Future<void>? abortTrigger;

  @override
  http.ByteStream finalize() {
    // Finalize the inner request first so any values it computes during
    // finalize (e.g. multipart Content-Type boundary, content length) are
    // available before we mirror them onto this wrapper.
    final stream = _inner.finalize();

    // Mirror headers and contentLength from the inner request *before*
    // finalizing this wrapper. Once super.finalize() runs, the contentLength
    // setter on http.BaseRequest throws StateError, which previously broke
    // every non-streaming request that supplied an abortTrigger.
    headers
      ..clear()
      ..addAll(_inner.headers);
    contentLength = _inner.contentLength;

    super.finalize();
    return stream;
  }
}
