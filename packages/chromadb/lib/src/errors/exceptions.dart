/// Base class for all ChromaDB exceptions.
///
/// This is a sealed class with specific implementations for different
/// error types that can occur when using the ChromaDB client.
sealed class ChromaException implements Exception {
  /// A human-readable description of the error.
  String get message;

  /// The stack trace at the point where the exception was thrown.
  StackTrace? get stackTrace;

  /// The underlying cause of this exception, if any.
  Exception? get cause;

  @override
  String toString() => 'ChromaException: $message';
}

/// Exception thrown when the API returns an error response.
///
/// This is the most common exception type and includes metadata about
/// both the request and response for debugging purposes.
class ApiException extends ChromaException {
  @override
  final String message;

  @override
  final StackTrace? stackTrace;

  @override
  final Exception? cause;

  /// Metadata about the request that caused the error.
  final RequestMetadata? request;

  /// Metadata about the error response.
  final ResponseMetadata? response;

  /// Creates an API exception.
  ApiException({
    required this.message,
    this.stackTrace,
    this.cause,
    this.request,
    this.response,
  });

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message');
    if (response?.statusCode != null) {
      buffer.write(' (${response!.statusCode})');
    }
    return buffer.toString();
  }
}

/// Exception thrown when authentication fails.
///
/// This occurs when the API returns a 401 or 403 status code.
class AuthenticationException extends ApiException {
  /// Creates an authentication exception.
  AuthenticationException({
    required super.message,
    super.stackTrace,
    super.cause,
    super.request,
    super.response,
  });

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception thrown when a requested resource is not found.
///
/// This occurs when the API returns a 404 status code.
class NotFoundException extends ApiException {
  /// Creates a not found exception.
  NotFoundException({
    required super.message,
    super.stackTrace,
    super.cause,
    super.request,
    super.response,
  });

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when there is a conflict with the current state.
///
/// This occurs when the API returns a 409 status code, such as when
/// trying to create a resource that already exists.
class ConflictException extends ApiException {
  /// Creates a conflict exception.
  ConflictException({
    required super.message,
    super.stackTrace,
    super.cause,
    super.request,
    super.response,
  });

  @override
  String toString() => 'ConflictException: $message';
}

/// Exception thrown when a request exceeds rate limits.
///
/// This occurs when the API returns a 429 status code.
class RateLimitException extends ApiException {
  /// The duration to wait before retrying, if provided by the server.
  final Duration? retryAfter;

  /// Creates a rate limit exception.
  RateLimitException({
    required super.message,
    super.stackTrace,
    super.cause,
    super.request,
    super.response,
    this.retryAfter,
  });

  @override
  String toString() {
    final buffer = StringBuffer('RateLimitException: $message');
    if (retryAfter != null) {
      buffer.write(' (retry after ${retryAfter!.inSeconds}s)');
    }
    return buffer.toString();
  }
}

/// Exception thrown when the server encounters an error.
///
/// This occurs when the API returns a 5xx status code.
class ServerException extends ApiException {
  /// Creates a server exception.
  ServerException({
    required super.message,
    super.stackTrace,
    super.cause,
    super.request,
    super.response,
  });

  @override
  String toString() => 'ServerException: $message';
}

/// Exception thrown when request validation fails.
///
/// This occurs when the client detects invalid input before sending
/// a request, or when the API returns a 400 or 422 status code.
class ValidationException extends ChromaException {
  @override
  final String message;

  @override
  final StackTrace? stackTrace;

  @override
  final Exception? cause;

  /// Metadata about the request that caused the error.
  final RequestMetadata? request;

  /// Metadata about the error response.
  final ResponseMetadata? response;

  /// Creates a validation exception.
  ValidationException({
    required this.message,
    this.stackTrace,
    this.cause,
    this.request,
    this.response,
  });

  @override
  String toString() => 'ValidationException: $message';
}

/// Exception thrown when a request times out.
///
/// This can occur due to network issues or server-side timeouts.
class TimeoutException extends ChromaException {
  @override
  final String message;

  @override
  final StackTrace? stackTrace;

  @override
  final Exception? cause;

  /// Creates a timeout exception.
  TimeoutException({required this.message, this.stackTrace, this.cause});

  @override
  String toString() => 'TimeoutException: $message';
}

/// Exception thrown when a request is aborted.
///
/// This occurs when the user cancels a request or the client is closed.
class AbortedException extends ChromaException {
  @override
  final String message;

  @override
  final StackTrace? stackTrace;

  @override
  final Exception? cause;

  /// Creates an aborted exception.
  AbortedException({required this.message, this.stackTrace, this.cause});

  @override
  String toString() => 'AbortedException: $message';
}

// ============================================================================
// Metadata Classes
// ============================================================================

/// Metadata about an HTTP request.
///
/// This is included in exceptions to help with debugging.
/// Sensitive headers are redacted before being included.
class RequestMetadata {
  /// The HTTP method used.
  final String method;

  /// The full URL that was requested.
  final Uri url;

  /// The headers that were sent (sensitive values redacted).
  final Map<String, String> headers;

  /// The correlation ID for request tracing.
  final String correlationId;

  /// The timestamp when the request was initiated.
  final DateTime timestamp;

  /// Creates request metadata.
  const RequestMetadata({
    required this.method,
    required this.url,
    required this.headers,
    required this.correlationId,
    required this.timestamp,
  });

  @override
  String toString() => 'RequestMetadata($method $url)';
}

/// Metadata about an HTTP response.
///
/// This is included in exceptions to help with debugging.
class ResponseMetadata {
  /// The HTTP status code.
  final int statusCode;

  /// The response headers.
  final Map<String, String> headers;

  /// An excerpt of the response body (first 200 chars).
  final String bodyExcerpt;

  /// The time taken to receive the response.
  final Duration latency;

  /// Creates response metadata.
  const ResponseMetadata({
    required this.statusCode,
    required this.headers,
    required this.bodyExcerpt,
    required this.latency,
  });

  @override
  String toString() =>
      'ResponseMetadata($statusCode, ${latency.inMilliseconds}ms)';
}
