import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../platform/http_utils.dart';
import 'config.dart';
import 'retry_after.dart';

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
/// - Transient or unknown rate limit responses (HTTP 429), regardless of method
/// - Server errors (HTTP 5xx) - idempotent methods only
/// - Timeout exceptions - idempotent methods only
/// - Connection errors - idempotent methods only
///
/// Retries are NOT attempted for:
/// - Structured permanent quota or spend-limit errors (HTTP 429)
/// - Client errors (HTTP 4xx except 429)
/// - Aborted requests
/// - Non-idempotent methods (POST, PATCH) for 5xx, timeout, or connection errors
///
/// Server retry hints are minimum delays. Hints above twice the configured
/// maximum delay return the original response instead of being shortened.
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

  /// Multiplier for automatically waiting on a complete server retry hint.
  ///
  /// Hints above this eligibility bound are returned without waiting/replaying.
  /// Eligible hints are honored completely, including submillisecond precision.
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
        if (_shouldRetry(response, request.method, attempt)) {
          final retryAfter = parseRetryAfter(response.headers);
          if (retryAfter != null) {
            final maxServerDelay =
                config.retryPolicy.maxDelay * _serverRetryAfterMultiplier;
            if (retryAfter > maxServerDelay) return response;
            delay = retryAfter;
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
  bool _shouldRetry(http.Response response, String method, int attempt) {
    if (attempt >= config.retryPolicy.maxRetries) {
      return false;
    }

    // Retry rate limits
    if (response.statusCode == 429) {
      return !_hasPermanentQuotaError(response);
    }

    // Retry 5xx errors for idempotent methods
    if (response.statusCode >= 500 && response.statusCode < 600) {
      return _isIdempotent(method);
    }

    return false;
  }

  /// Recognizes only structured billing/quota fields, independent of message.
  bool _hasPermanentQuotaError(http.Response response) {
    const permanentCodes = {
      'credit_balance_exhausted',
      'organization_spend_limit_exceeded',
      'project_spend_limit_exceeded',
      'organization_usage_limit_exceeded',
      'insufficient_quota',
    };
    try {
      final json = jsonDecode(response.body);
      if (json is! Map || json['error'] is! Map) return false;
      final error = json['error'] as Map;
      return (error['code'] is String &&
              permanentCodes.contains(error['code'])) ||
          error['type'] == 'insufficient_quota';
    } on FormatException {
      return false;
    }
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

    // If the base delay is already at or above the max, don't add jitter.
    // This preserves server-provided Retry-After values that may exceed
    // maxDelay (up to the 2x automatic-wait eligibility bound).
    if (delay >= config.retryPolicy.maxDelay) {
      return delay;
    }

    // Compute jitter bounded by both the factor and available headroom
    final maxJitterFromFactor = (jitterFactor * baseMs).round();
    final headroom = (config.retryPolicy.maxDelay - delay).inMilliseconds;
    final allowedJitterMs = min(maxJitterFromFactor, headroom);
    final jitterMs = (_random.nextDouble() * allowedJitterMs).round();

    return delay + Duration(milliseconds: jitterMs);
  }

  /// Delays with jitter to avoid thundering herd problem.
  Future<void> _delayWithJitter(Duration delay) async {
    await Future<void>.delayed(_timerDelay(_computeJitteredDelay(delay)));
  }

  /// Dart timers use whole milliseconds; round upward to retain minimum waits.
  Duration _timerDelay(Duration delay) {
    if (delay <= Duration.zero) return Duration.zero;
    final milliseconds =
        delay.inMicroseconds ~/ Duration.microsecondsPerMillisecond;
    final remainder =
        delay.inMicroseconds % Duration.microsecondsPerMillisecond;
    return Duration(milliseconds: milliseconds + (remainder == 0 ? 0 : 1));
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
      final finalDelay = _timerDelay(_computeJitteredDelay(delay));

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
