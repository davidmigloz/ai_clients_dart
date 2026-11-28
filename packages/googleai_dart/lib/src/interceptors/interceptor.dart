import 'package:http/http.dart' as http;

import '../utils/redactor.dart';

/// Copies a buffered request before an interceptor changes its URL or headers.
http.Request copyBufferedRequest(http.Request request, {Uri? uri}) =>
    http.Request(request.method, uri ?? request.url)
      ..headers.addAll(request.headers)
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection
      ..bodyBytes = request.bodyBytes
      ..encoding = request.encoding;

/// Context for an HTTP request/response.
class RequestContext {
  /// HTTP request.
  final http.BaseRequest request;

  /// Optional HTTP response (set after transport).
  final http.Response? response;

  /// Request metadata.
  final Map<String, dynamic> metadata;

  /// Optional abort trigger for this request.
  final Future<void>? abortTrigger;

  /// Redaction for diagnostics specific to the operation.
  final Redactor? diagnosticRedactor;

  /// Whether the operation already supplied its own authentication.
  final bool skipAuthentication;

  /// Whether to omit the response body from diagnostic logs.
  final bool skipResponseBodyDiagnostics;

  /// Creates a [RequestContext].
  const RequestContext({
    required this.request,
    this.response,
    this.metadata = const {},
    this.abortTrigger,
    this.diagnosticRedactor,
    this.skipAuthentication = false,
    this.skipResponseBodyDiagnostics = false,
  });

  /// Creates a copy with updated values.
  RequestContext copyWith({
    http.BaseRequest? request,
    http.Response? response,
    Map<String, dynamic>? metadata,
    Future<void>? abortTrigger,
  }) {
    return RequestContext(
      request: request ?? this.request,
      response: response ?? this.response,
      metadata: metadata ?? this.metadata,
      abortTrigger: abortTrigger ?? this.abortTrigger,
      diagnosticRedactor: diagnosticRedactor,
      skipAuthentication: skipAuthentication,
      skipResponseBodyDiagnostics: skipResponseBodyDiagnostics,
    );
  }
}

/// Function signature for interceptor chain continuation.
typedef InterceptorNext =
    Future<http.Response> Function(RequestContext context);

/// Base interceptor interface for HTTP requests.
abstract interface class Interceptor {
  /// Intercepts an HTTP request/response.
  ///
  /// The [context] contains the request and metadata.
  /// The [next] function calls the next interceptor in the chain.
  ///
  /// Returns the HTTP response.
  Future<http.Response> intercept(RequestContext context, InterceptorNext next);
}
