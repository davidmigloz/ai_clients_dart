import 'package:http/http.dart' as http;

import '../models/common/copy_with_sentinel.dart';

/// Context for an HTTP request/response.
///
/// This class encapsulates all the information needed to process
/// a request through the interceptor chain, including metadata
/// for tracing and optional abort support.
class RequestContext {
  /// Creates a new [RequestContext].
  const RequestContext({
    required this.request,
    this.response,
    this.metadata = const {},
    this.abortTrigger,
  });

  /// The HTTP request being processed.
  final http.BaseRequest request;

  /// The HTTP response (set after transport).
  final http.Response? response;

  /// Request metadata for tracing and debugging.
  ///
  /// Common metadata keys:
  /// - `correlationId`: Unique ID for request tracing
  /// - `startTime`: Request start timestamp
  /// - `attempt`: Current retry attempt number
  final Map<String, dynamic> metadata;

  /// Optional future that, when completed, signals the request should abort.
  ///
  /// Used for cancellation support. When this future completes, any
  /// in-flight operation should be cancelled as soon as possible.
  final Future<void>? abortTrigger;

  /// Creates a copy with updated values.
  ///
  /// Nullable fields can be explicitly set to `null` to clear them.
  RequestContext copyWith({
    http.BaseRequest? request,
    Object? response = unsetCopyWithValue,
    Map<String, dynamic>? metadata,
    Object? abortTrigger = unsetCopyWithValue,
  }) {
    return RequestContext(
      request: request ?? this.request,
      response: response == unsetCopyWithValue
          ? this.response
          : response as http.Response?,
      metadata: metadata ?? this.metadata,
      abortTrigger: abortTrigger == unsetCopyWithValue
          ? this.abortTrigger
          : abortTrigger as Future<void>?,
    );
  }
}

/// Function signature for interceptor chain continuation.
///
/// Called by an interceptor to invoke the next interceptor in the chain.
typedef InterceptorNext =
    Future<http.Response> Function(RequestContext context);

/// Base interface for HTTP request interceptors.
///
/// Interceptors form a chain that processes HTTP requests and responses.
/// Each interceptor can:
/// - Modify the request before passing it down the chain
/// - Modify the response before returning it up the chain
/// - Short-circuit the chain by returning early
/// - Add metadata for downstream interceptors
///
/// ## Example
///
/// ```dart
/// class LoggingInterceptor implements Interceptor {
///   @override
///   Future<http.Response> intercept(
///     RequestContext context,
///     InterceptorNext next,
///   ) async {
///     print('Request: ${context.request.method} ${context.request.url}');
///     final startTime = DateTime.now();
///
///     final response = await next(context);
///
///     final duration = DateTime.now().difference(startTime);
///     print('Response: ${response.statusCode} in ${duration.inMilliseconds}ms');
///
///     return response;
///   }
/// }
/// ```
abstract interface class Interceptor {
  /// Intercepts an HTTP request/response.
  ///
  /// The [context] contains the request and metadata.
  /// The [next] function calls the next interceptor in the chain.
  ///
  /// Returns the HTTP response after processing.
  Future<http.Response> intercept(RequestContext context, InterceptorNext next);
}
