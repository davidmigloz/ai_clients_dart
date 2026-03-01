import 'dart:async' show TimeoutException;
import 'dart:math';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../platform/http_utils.dart';
import 'config.dart';

/// Wraps HTTP transport execution with retry logic.
///
/// This implements exponential backoff with jitter for retrying failed requests.
/// In the OpenAI client integration, this wrapper is applied by the interceptor
/// chain only for regular `http.Request` instances. Multipart and streamed
/// requests are not retried to avoid issues with request body re-consumption.
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
///   () async {
///     final streamedResponse = await httpClient.send(request);
///     return http.Response.fromStream(streamedResponse);
///   },
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

  /// Multiplier for clamping server-provided Retry-After values.
  ///
  /// When a server returns a Retry-After header, we clamp it to
  /// `RetryPolicy.maxDelay * _serverRetryAfterMultiplier` to prevent excessively
  /// long delays while still respecting server guidance. The 2x multiplier
  /// balances server intent with configured client policy.
  static const _serverRetryAfterMultiplier = 2;

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
    var delay = config.retryPolicy.initialDelay;

    while (attempt <= config.retryPolicy.maxRetries) {
      try {
        final response = await execute();

        // Check for retryable status codes
        if (_shouldRetry(response.statusCode, request.method, attempt)) {
          final retryAfter = _parseRetryAfter(response.headers['retry-after']);
          if (retryAfter != null) {
            // Clamp server-provided Retry-After to a reasonable maximum to avoid
            // excessively long sleeps that bypass our configured retry policy.
            final maxServerDelay =
                config.retryPolicy.maxDelay * _serverRetryAfterMultiplier;
            delay = retryAfter <= maxServerDelay ? retryAfter : maxServerDelay;
          }

          // Enforce minimum delay to prevent tight retry loops (e.g., Retry-After: 0)
          final effectiveDelay = delay < config.retryPolicy.initialDelay
              ? config.retryPolicy.initialDelay
              : delay;
          await _delayWithAbortCheck(
            effectiveDelay,
            abortTrigger,
            correlationId,
          );
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
        if (!_isIdempotent(request.method) ||
            attempt >= config.retryPolicy.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } on RequestTimeoutException {
        // Retry on request timeout for idempotent methods only
        // (RequestTimeoutException is thrown by InterceptorChain.timeout)
        if (!_isIdempotent(request.method) ||
            attempt >= config.retryPolicy.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } on http.ClientException {
        // Retry on HTTP client errors for idempotent methods only.
        // This also handles SocketException on IO platforms (wrapped by http package)
        // and network errors on web platforms.
        if (!_isIdempotent(request.method) ||
            attempt >= config.retryPolicy.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } catch (e) {
        // Handle SocketException on IO platforms (when not wrapped by http package)
        if (isSocketException(e)) {
          if (!_isIdempotent(request.method) ||
              attempt >= config.retryPolicy.maxRetries) {
            rethrow;
          }

          await _delayWithAbortCheck(delay, abortTrigger, correlationId);
          attempt++;
          delay = _exponentialBackoff(delay);
        } else {
          rethrow;
        }
      }
    }

    // Should never reach here; reaching this point indicates a logic error.
    throw StateError('Unreachable: executeWithRetry fell through retry loop');
  }

  /// Determines if a response should be retried based on status code.
  bool _shouldRetry(int statusCode, String method, int attempt) {
    if (attempt >= config.retryPolicy.maxRetries) {
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
  /// Ensures:
  /// - Minimum delay of [RetryPolicy.initialDelay] to avoid tight retry loops
  ///   when Retry-After is 0 or resolves to a past/now HTTP-date
  /// - Monotonic backoff: once we reach or exceed [RetryPolicy.maxDelay], we
  ///   don't decrease the delay on subsequent attempts
  Duration _exponentialBackoff(Duration currentDelay) {
    // Enforce minimum delay to prevent tight retry loops
    if (currentDelay < config.retryPolicy.initialDelay) {
      return config.retryPolicy.initialDelay;
    }
    // If current delay already meets or exceeds max, keep it (monotonic)
    if (currentDelay >= config.retryPolicy.maxDelay) {
      return currentDelay;
    }
    final nextDelay = currentDelay * 2;
    return nextDelay > config.retryPolicy.maxDelay
        ? config.retryPolicy.maxDelay
        : nextDelay;
  }

  /// Parses the Retry-After header value.
  ///
  /// Supports both delta-seconds and HTTP-date formats.
  /// Handles leading/trailing whitespace in header values.
  Duration? _parseRetryAfter(String? value) {
    if (value == null) {
      return null;
    }

    // Trim whitespace - HTTP headers can contain leading/trailing spaces
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return null;
    }

    // Try parsing as seconds (clamp to >= 0 to avoid negative durations)
    final seconds = int.tryParse(trimmed);
    if (seconds != null) {
      return Duration(seconds: max(0, seconds));
    }

    // Try parsing as HTTP-date
    try {
      final date = _parseHttpDate(trimmed);
      final now = DateTime.now();
      if (date.isAfter(now)) {
        return date.difference(now);
      }
      // Date is now or in the past (clock skew, coarse timestamp) - retry immediately
      return Duration.zero;
    } catch (_) {
      // Ignore parse errors - fall through to return null
    }

    return null;
  }

  /// Parses an HTTP-date string.
  ///
  /// Supports RFC 7231 date formats. On IO platforms, all formats are supported:
  /// - RFC 1123 (preferred): "Wed, 21 Oct 2015 07:28:00 GMT"
  /// - RFC 850: "Wednesday, 21-Oct-15 07:28:00 GMT"
  /// - ANSI C asctime(): "Wed Oct 21 07:28:00 2015"
  ///
  /// On web platforms, only RFC 1123 format is supported.
  DateTime _parseHttpDate(String value) => parseHttpDate(value);

  /// Computes a delay with jitter to avoid thundering herd problem.
  ///
  /// Adds random jitter to the base delay based on the configured jitter
  /// factor (defaults to 10%). The jitter amount is bounded so that it never
  /// pushes the effective delay past the configured maximum retry delay. If
  /// the base delay already exceeds the maximum (e.g., from a server-provided
  /// Retry-After header), it is returned unchanged to preserve the server's
  /// requested delay.
  Duration _computeJitteredDelay(Duration delay) {
    final jitterFactor = config.retryPolicy.jitter;
    final baseMs = delay.inMilliseconds;
    final maxMs = config.retryPolicy.maxDelay.inMilliseconds;

    // If the base delay is already at or above the max, don't add jitter.
    // This preserves server-provided Retry-After values that may exceed
    // maxDelay (up to 2x maxDelay per upstream clamping).
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
      // Race the delay with abort trigger.
      // We use boolean futures instead of throwing in the future chain
      // to avoid unhandled async errors when the delay wins.
      final finalDelay = _computeJitteredDelay(delay);

      final delayFuture = Future<bool>.delayed(finalDelay, () => false);
      final abortFuture = abortTrigger.then(
        (_) => true,
        onError: (_) => true, // Also abort on error completion
      );

      final wasAborted = await Future.any([delayFuture, abortFuture]);

      if (wasAborted) {
        throw AbortedException(
          message: 'Request aborted during retry delay',
          correlationId: correlationId,
          stage: AbortionStage.beforeRequest,
          timestamp: DateTime.now(),
        );
      }
    }
  }
}
