import 'dart:async' show TimeoutException;
import 'dart:io' show HttpDate, SocketException;
import 'dart:math';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import 'config.dart';

/// Wraps HTTP transport execution with retry logic.
///
/// This implements exponential backoff with jitter for retrying failed requests.
/// The retry wrapper operates at the transport layer, separate from the
/// interceptor chain.
///
/// ## Retry Conditions
///
/// Retries are attempted for:
/// - Rate limit responses (HTTP 429) - always retried regardless of method
/// - Server errors (HTTP 5xx) - idempotent methods only
/// - Timeout exceptions - idempotent methods only
/// - Connection errors - idempotent methods only
///
/// Retries are NOT attempted for:
/// - Client errors (HTTP 4xx except 429)
/// - Aborted requests
/// - Non-idempotent methods (POST, PATCH) for 5xx, timeout, or connection errors
///
/// Note: HTTP 429 (rate limit) is always retried regardless of method,
/// as the request was not processed due to rate limiting.
///
/// ## Example
///
/// ```dart
/// final wrapper = RetryWrapper(config: config);
///
/// final response = await wrapper.executeWithRetry(
///   request,
///   () => httpClient.send(request),
///   null,
///   'req_123',
/// );
/// ```
class RetryWrapper {
  /// Creates a [RetryWrapper] with the given configuration.
  RetryWrapper({required this.config}) : _random = Random();

  /// The configuration containing retry policy settings.
  final OpenAIConfig config;

  /// Random number generator for jitter.
  final Random _random;

  /// Executes an HTTP request with retry logic.
  ///
  /// The [execute] function performs the actual HTTP transport.
  /// The optional [abortTrigger] allows immediate abort during retry delays.
  /// The [correlationId] is used for request tracing.
  ///
  /// Returns the HTTP response after successful execution.
  /// Throws the last exception if all retries are exhausted.
  Future<http.Response> executeWithRetry(
    http.BaseRequest request,
    Future<http.Response> Function() execute,
    Future<void>? abortTrigger,
    String correlationId,
  ) async {
    var attempt = 0;
    var delay = config.retryDelay;

    while (attempt <= config.maxRetries) {
      try {
        final response = await execute();

        // Check for retryable status codes
        if (_shouldRetry(response.statusCode, request.method, attempt)) {
          final retryAfter = _parseRetryAfter(response.headers['retry-after']);
          if (retryAfter != null) {
            // Clamp server-provided Retry-After to a reasonable maximum to avoid
            // excessively long sleeps that bypass our configured retry policy.
            final maxServerDelay = config.maxRetryDelay * 2;
            delay = retryAfter <= maxServerDelay ? retryAfter : maxServerDelay;
          }

          await _delayWithAbortCheck(delay, abortTrigger, correlationId);
          attempt++;
          delay = _exponentialBackoff(delay);
          continue;
        }

        return response;
      } on AbortedException {
        // Don't retry after abort - propagate immediately
        rethrow;
      } on TimeoutException {
        // Retry on timeout for idempotent methods only
        if (!_isIdempotent(request.method) || attempt >= config.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } on SocketException {
        // Retry on connection errors for idempotent methods only
        if (!_isIdempotent(request.method) || attempt >= config.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } on http.ClientException {
        // Retry on HTTP client errors for idempotent methods only
        if (!_isIdempotent(request.method) || attempt >= config.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      }
    }

    // Should never reach here, but throw if we somehow do
    throw ApiException(
      message: 'Max retries (${config.maxRetries}) exceeded',
      statusCode: 0,
    );
  }

  /// Determines if a response should be retried based on status code.
  bool _shouldRetry(int statusCode, String method, int attempt) {
    if (attempt >= config.maxRetries) {
      return false;
    }

    // Retry rate limits
    if (statusCode == 429) {
      return true;
    }

    // Retry 5xx errors for idempotent methods
    if (statusCode >= 500 && statusCode < 600) {
      return _isIdempotent(method);
    }

    return false;
  }

  /// Checks if an HTTP method is idempotent and safe to retry.
  ///
  /// Idempotent methods: GET, HEAD, OPTIONS, PUT, DELETE
  /// Non-idempotent: POST, PATCH (may create duplicates on retry)
  bool _isIdempotent(String method) {
    const idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};
    return idempotentMethods.contains(method.toUpperCase());
  }

  /// Applies exponential backoff to the current delay.
  ///
  /// Ensures monotonic backoff: once we reach or exceed maxRetryDelay, we
  /// don't decrease the delay on subsequent attempts. This handles the case
  /// where a server-provided Retry-After exceeded maxRetryDelay.
  Duration _exponentialBackoff(Duration currentDelay) {
    // If current delay already meets or exceeds max, keep it (monotonic)
    if (currentDelay >= config.maxRetryDelay) {
      return currentDelay;
    }
    final nextDelay = currentDelay * 2;
    return nextDelay > config.maxRetryDelay ? config.maxRetryDelay : nextDelay;
  }

  /// Parses the Retry-After header value.
  ///
  /// Supports both delta-seconds and HTTP-date formats.
  Duration? _parseRetryAfter(String? value) {
    if (value == null || value.isEmpty) {
      return null;
    }

    // Try parsing as seconds (clamp to >= 0 to avoid negative durations)
    final seconds = int.tryParse(value);
    if (seconds != null) {
      return Duration(seconds: max(0, seconds));
    }

    // Try parsing as HTTP-date
    try {
      final date = _parseHttpDate(value);
      final now = DateTime.now();
      if (date.isAfter(now)) {
        return date.difference(now);
      }
    } catch (_) {
      // Ignore parse errors
    }

    return null;
  }

  /// Parses an HTTP-date string.
  ///
  /// Uses [HttpDate.parse] which supports all RFC 7231 date formats:
  /// - RFC 1123 (preferred): "Wed, 21 Oct 2015 07:28:00 GMT"
  /// - RFC 850: "Wednesday, 21-Oct-15 07:28:00 GMT"
  /// - ANSI C asctime(): "Wed Oct 21 07:28:00 2015"
  DateTime _parseHttpDate(String value) => HttpDate.parse(value);

  /// Computes a delay with jitter to avoid thundering herd problem.
  ///
  /// Adds up to 25% random jitter to the base delay. The jitter amount is
  /// bounded so that it never pushes the effective delay past the configured
  /// maximum retry delay. If the base delay already exceeds the maximum
  /// (e.g., from a server-provided Retry-After header), it is returned
  /// unchanged to preserve the server's requested delay.
  Duration _computeJitteredDelay(Duration delay) {
    const jitterFactor = 0.25;
    final baseMs = delay.inMilliseconds;
    final maxMs = config.maxRetryDelay.inMilliseconds;

    // If the base delay is already at or above the max, don't add jitter.
    // This preserves server-provided Retry-After values that may exceed
    // maxRetryDelay (up to 2x maxRetryDelay per upstream clamping).
    if (baseMs >= maxMs) {
      return delay;
    }

    // Compute jitter bounded by both the factor and available headroom
    final maxJitterFromFactor = (jitterFactor * baseMs).round();
    final headroom = maxMs - baseMs;
    final allowedJitterMs = min(maxJitterFromFactor, headroom);
    final jitterMs = (_random.nextDouble() * allowedJitterMs).round();

    return delay + Duration(milliseconds: jitterMs);
  }

  /// Delays with jitter to avoid thundering herd problem.
  Future<void> _delayWithJitter(Duration delay) async {
    await Future<void>.delayed(_computeJitteredDelay(delay));
  }

  /// Delays with abort check.
  ///
  /// Aborts immediately if the trigger fires during the delay.
  Future<void> _delayWithAbortCheck(
    Duration delay,
    Future<void>? abortTrigger,
    String correlationId,
  ) async {
    if (abortTrigger == null) {
      await _delayWithJitter(delay);
    } else {
      // Race the delay with abort trigger
      final finalDelay = _computeJitteredDelay(delay);

      await Future.any([
        Future<void>.delayed(finalDelay),
        abortTrigger.then((_) {
          throw AbortedException(
            message: 'Request aborted during retry delay',
            correlationId: correlationId,
          );
        }),
      ]);
    }
  }
}
