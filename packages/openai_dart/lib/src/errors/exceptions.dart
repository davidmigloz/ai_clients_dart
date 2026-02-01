import 'package:meta/meta.dart';

/// Base exception class for all OpenAI client errors.
///
/// All exceptions thrown by the OpenAI client extend this class,
/// allowing for catch-all error handling when needed.
@immutable
sealed class OpenAIException implements Exception {
  /// Creates a new [OpenAIException] with the given message.
  const OpenAIException(this.message, {this.cause});

  /// A human-readable description of the error.
  final String message;

  /// The underlying cause of this exception, if any.
  final Object? cause;
}

/// Exception thrown when the API returns an error response.
///
/// This exception includes the HTTP status code, error type,
/// and any additional details provided by the API.
///
/// ## Example
///
/// ```dart
/// try {
///   await client.chat.completions.create(...);
/// } on ApiException catch (e) {
///   print('API error ${e.statusCode}: ${e.message}');
///   print('Error type: ${e.type}');
/// }
/// ```
@immutable
class ApiException extends OpenAIException {
  /// Creates a new [ApiException].
  const ApiException({
    required String message,
    required this.statusCode,
    this.type,
    this.param,
    this.code,
    this.requestId,
    this.body,
    Object? cause,
  }) : super(message, cause: cause);

  /// The HTTP status code returned by the API.
  final int statusCode;

  /// The error type returned by the API (e.g., 'invalid_request_error').
  final String? type;

  /// The parameter that caused the error, if applicable.
  final String? param;

  /// The error code returned by the API.
  final String? code;

  /// The request ID for debugging purposes.
  final String? requestId;

  /// The raw response body, if available.
  final Map<String, dynamic>? body;

  @override
  String toString() {
    final buffer = StringBuffer('ApiException: $message')
      ..write(' (status: $statusCode');
    if (type != null) buffer.write(', type: $type');
    if (code != null) buffer.write(', code: $code');
    if (param != null) buffer.write(', param: $param');
    if (requestId != null) buffer.write(', request_id: $requestId');
    buffer.write(')');
    return buffer.toString();
  }
}

/// Exception thrown when authentication fails (HTTP 401).
///
/// This typically indicates an invalid or expired API key.
///
/// ## Example
///
/// ```dart
/// try {
///   await client.chat.completions.create(...);
/// } on AuthenticationException catch (e) {
///   print('Invalid API key: ${e.message}');
/// }
/// ```
@immutable
class AuthenticationException extends ApiException {
  /// Creates a new [AuthenticationException].
  const AuthenticationException({
    required super.message,
    super.type,
    super.code,
    super.param,
    super.requestId,
    super.body,
    super.cause,
  }) : super(statusCode: 401);

  @override
  String toString() => 'AuthenticationException: $message';
}

/// Exception thrown when access is denied (HTTP 403).
///
/// This typically indicates the API key doesn't have permission
/// for the requested operation or resource.
@immutable
class PermissionDeniedException extends ApiException {
  /// Creates a new [PermissionDeniedException].
  const PermissionDeniedException({
    required super.message,
    super.type,
    super.code,
    super.param,
    super.requestId,
    super.body,
    super.cause,
  }) : super(statusCode: 403);

  @override
  String toString() => 'PermissionDeniedException: $message';
}

/// Exception thrown when a resource is not found (HTTP 404).
///
/// This typically indicates the requested model, file, or other
/// resource doesn't exist.
@immutable
class NotFoundException extends ApiException {
  /// Creates a new [NotFoundException].
  const NotFoundException({
    required super.message,
    super.type,
    super.code,
    super.param,
    super.requestId,
    super.body,
    super.cause,
  }) : super(statusCode: 404);

  @override
  String toString() => 'NotFoundException: $message';
}

/// Exception thrown when the request conflicts with current state (HTTP 409).
///
/// This might occur when trying to create a resource that already exists.
@immutable
class ConflictException extends ApiException {
  /// Creates a new [ConflictException].
  const ConflictException({
    required super.message,
    super.type,
    super.code,
    super.param,
    super.requestId,
    super.body,
    super.cause,
  }) : super(statusCode: 409);

  @override
  String toString() => 'ConflictException: $message';
}

/// Exception thrown when the request cannot be processed (HTTP 422).
///
/// This typically indicates the request was syntactically correct
/// but semantically invalid.
@immutable
class UnprocessableEntityException extends ApiException {
  /// Creates a new [UnprocessableEntityException].
  const UnprocessableEntityException({
    required super.message,
    super.type,
    super.code,
    super.param,
    super.requestId,
    super.body,
    super.cause,
  }) : super(statusCode: 422);

  @override
  String toString() => 'UnprocessableEntityException: $message';
}

/// Exception thrown when rate limited (HTTP 429).
///
/// This exception includes retry timing information when available.
///
/// ## Example
///
/// ```dart
/// try {
///   await client.chat.completions.create(...);
/// } on RateLimitException catch (e) {
///   print('Rate limited. Retry after: ${e.retryAfter}');
///   if (e.retryAfter != null) {
///     await Future.delayed(e.retryAfter!);
///     // Retry the request
///   }
/// }
/// ```
@immutable
class RateLimitException extends ApiException {
  /// Creates a new [RateLimitException].
  const RateLimitException({
    required super.message,
    super.type,
    super.code,
    super.param,
    super.requestId,
    super.body,
    this.retryAfter,
    super.cause,
  }) : super(statusCode: 429);

  /// The recommended duration to wait before retrying.
  ///
  /// Parsed from the `Retry-After` header if present.
  final Duration? retryAfter;

  @override
  String toString() {
    if (retryAfter case final duration?) {
      return 'RateLimitException: $message (retry after: ${duration.inSeconds}s)';
    }
    return 'RateLimitException: $message';
  }
}

/// Exception thrown when the request is invalid (HTTP 400).
///
/// This typically indicates malformed request parameters.
@immutable
class BadRequestException extends ApiException {
  /// Creates a new [BadRequestException].
  const BadRequestException({
    required super.message,
    super.type,
    super.code,
    super.param,
    super.requestId,
    super.body,
    super.cause,
  }) : super(statusCode: 400);

  @override
  String toString() => 'BadRequestException: $message';
}

/// Exception thrown when an internal server error occurs (HTTP 5xx).
///
/// These errors are typically transient and the request can be retried.
@immutable
class InternalServerException extends ApiException {
  /// Creates a new [InternalServerException].
  const InternalServerException({
    required super.message,
    required super.statusCode,
    super.type,
    super.code,
    super.param,
    super.requestId,
    super.body,
    super.cause,
  });

  @override
  String toString() =>
      'InternalServerException: $message (status: $statusCode)';
}

/// Exception thrown when a request times out.
///
/// This can occur due to network issues or the server taking too long
/// to respond.
///
/// Note: This is named `RequestTimeoutException` to avoid conflicts with
/// `dart:async`'s `TimeoutException`.
@immutable
class RequestTimeoutException extends OpenAIException {
  /// Creates a new [RequestTimeoutException].
  const RequestTimeoutException({
    required String message,
    this.timeout,
    Object? cause,
  }) : super(message, cause: cause);

  /// The timeout duration that was exceeded.
  final Duration? timeout;

  @override
  String toString() {
    if (timeout case final duration?) {
      return 'RequestTimeoutException: $message (after ${duration.inSeconds}s)';
    }
    return 'RequestTimeoutException: $message';
  }
}

/// The stage at which the request was aborted.
enum AbortionStage {
  /// Aborted before the request was sent.
  beforeRequest,

  /// Aborted while the request was being sent.
  duringRequest,

  /// Aborted while waiting for or receiving the response.
  duringResponse,

  /// Aborted while processing a streaming response.
  duringStream,
}

/// Exception thrown when a request is aborted.
///
/// This occurs when a request is explicitly cancelled, such as
/// when closing a stream or calling an abort method.
///
/// ## Example
///
/// ```dart
/// final abortController = Completer<void>();
///
/// // Start a request that can be cancelled
/// final future = client.chat.completions.create(
///   request,
///   abortTrigger: abortController.future,
/// );
///
/// // Cancel the request
/// abortController.complete();
///
/// try {
///   await future;
/// } on AbortedException catch (e) {
///   print('Request was aborted at stage: ${e.stage}');
/// }
/// ```
@immutable
class AbortedException extends OpenAIException {
  /// Creates a new [AbortedException].
  const AbortedException({
    String message = 'Request was aborted',
    this.stage,
    this.correlationId,
    this.timestamp,
    Object? cause,
  }) : super(message, cause: cause);

  /// Creates an [AbortedException] from an HTTP exception.
  factory AbortedException.fromHttpException(
    Object exception, {
    AbortionStage? stage,
    String? correlationId,
  }) {
    return AbortedException(
      message: 'Request aborted: $exception',
      stage: stage,
      correlationId: correlationId,
      timestamp: DateTime.now(),
      cause: exception,
    );
  }

  /// The stage at which the request was aborted.
  final AbortionStage? stage;

  /// The correlation ID for the aborted request.
  final String? correlationId;

  /// When the abort occurred.
  final DateTime? timestamp;

  @override
  String toString() {
    final buffer = StringBuffer('AbortedException: $message');
    final details = <String>[];
    if (stage != null) details.add('stage: ${stage!.name}');
    if (correlationId != null) details.add('correlationId: $correlationId');
    if (details.isNotEmpty) {
      buffer.write(' (${details.join(', ')})');
    }
    return buffer.toString();
  }
}

/// Exception thrown when a network connection cannot be established.
///
/// This indicates a network-level failure such as DNS resolution failure,
/// connection refused, or no network connectivity.
@immutable
class ConnectionException extends OpenAIException {
  /// Creates a new [ConnectionException].
  const ConnectionException({required String message, this.url, Object? cause})
    : super(message, cause: cause);

  /// The URL that failed to connect.
  final String? url;

  @override
  String toString() {
    if (url case final u?) {
      return 'ConnectionException: $message (url: $u)';
    }
    return 'ConnectionException: $message';
  }
}

/// Exception thrown when response parsing fails.
///
/// This indicates the API returned a response that couldn't be parsed
/// as expected. This might indicate an API change or bug.
@immutable
class ParseException extends OpenAIException {
  /// Creates a new [ParseException].
  const ParseException({
    required String message,
    this.responseBody,
    Object? cause,
  }) : super(message, cause: cause);

  /// The raw response body that failed to parse.
  final String? responseBody;

  @override
  String toString() => 'ParseException: $message';
}

/// Exception thrown when streaming fails.
///
/// This can occur due to connection issues during streaming,
/// malformed SSE data, or unexpected stream termination.
@immutable
class StreamException extends OpenAIException {
  /// Creates a new [StreamException].
  const StreamException({
    required String message,
    this.partialData,
    Object? cause,
  }) : super(message, cause: cause);

  /// Any partial data received before the error occurred.
  final String? partialData;

  @override
  String toString() => 'StreamException: $message';
}

/// Creates the appropriate exception based on HTTP status code.
///
/// This factory function examines the response and creates the most
/// specific exception type for the given error.
ApiException createApiException({
  required int statusCode,
  required String message,
  String? type,
  String? code,
  String? param,
  String? requestId,
  Map<String, dynamic>? body,
  Duration? retryAfter,
  Object? cause,
}) {
  return switch (statusCode) {
    400 => BadRequestException(
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      cause: cause,
    ),
    401 => AuthenticationException(
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      cause: cause,
    ),
    403 => PermissionDeniedException(
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      cause: cause,
    ),
    404 => NotFoundException(
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      cause: cause,
    ),
    409 => ConflictException(
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      cause: cause,
    ),
    422 => UnprocessableEntityException(
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      cause: cause,
    ),
    429 => RateLimitException(
      message: message,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      retryAfter: retryAfter,
      cause: cause,
    ),
    >= 500 && < 600 => InternalServerException(
      message: message,
      statusCode: statusCode,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      cause: cause,
    ),
    _ => ApiException(
      message: message,
      statusCode: statusCode,
      type: type,
      code: code,
      param: param,
      requestId: requestId,
      body: body,
      cause: cause,
    ),
  };
}
