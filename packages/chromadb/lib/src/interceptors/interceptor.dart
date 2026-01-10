import 'package:http/http.dart' as http;

/// Context for a request as it passes through the interceptor chain.
///
/// This class holds the mutable state of a request, allowing interceptors
/// to modify headers, query parameters, and other request properties.
class RequestContext {
  /// The HTTP method for the request.
  final String method;

  /// The URL path (without base URL).
  final String path;

  /// Query parameters to append to the URL.
  final Map<String, String> queryParameters;

  /// Headers to include in the request.
  final Map<String, String> headers;

  /// The request body, if any.
  final Object? body;

  /// The fully resolved URL for this request.
  ///
  /// Set by the resource layer before passing to the interceptor chain.
  /// Used for accurate metadata in error responses.
  final Uri? fullUrl;

  /// The timestamp when this request was created.
  final DateTime timestamp;

  /// The attempt number for retry tracking (1-indexed).
  final int attemptNumber;

  /// Creates a new request context.
  RequestContext({
    required this.method,
    required this.path,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    this.body,
    this.fullUrl,
    DateTime? timestamp,
    this.attemptNumber = 1,
  }) : queryParameters = queryParameters ?? {},
       headers = headers ?? {},
       timestamp = timestamp ?? DateTime.now();

  /// Creates a copy of this context with optional modifications.
  RequestContext copyWith({
    String? method,
    String? path,
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    Object? body,
    Uri? fullUrl,
    DateTime? timestamp,
    int? attemptNumber,
  }) {
    return RequestContext(
      method: method ?? this.method,
      path: path ?? this.path,
      queryParameters: queryParameters ?? Map.of(this.queryParameters),
      headers: headers ?? Map.of(this.headers),
      body: body ?? this.body,
      fullUrl: fullUrl ?? this.fullUrl,
      timestamp: timestamp ?? this.timestamp,
      attemptNumber: attemptNumber ?? this.attemptNumber,
    );
  }
}

/// Function signature for the next step in the interceptor chain.
typedef InterceptorNext =
    Future<http.Response> Function(RequestContext context);

/// Interface for request interceptors.
///
/// Interceptors can modify requests before they are sent and responses
/// after they are received. They form a chain where each interceptor
/// can decide whether to continue to the next interceptor or return
/// early (e.g., for caching or error handling).
///
/// Example:
/// ```dart
/// class MyInterceptor implements Interceptor {
///   @override
///   Future<http.Response> intercept(
///     RequestContext context,
///     InterceptorNext next,
///   ) async {
///     // Modify request
///     context.headers['X-Custom'] = 'value';
///
///     // Call next interceptor
///     final response = await next(context);
///
///     // Process response
///     return response;
///   }
/// }
/// ```
abstract interface class Interceptor {
  /// Intercepts a request, optionally modifying it or the response.
  ///
  /// Call [next] to continue to the next interceptor in the chain.
  /// The final interceptor will make the actual HTTP request.
  Future<http.Response> intercept(RequestContext context, InterceptorNext next);
}
