import 'dart:math';
import 'package:http/http.dart' as http;
import '../client/config.dart';
import '../errors/exceptions.dart';

/// Wraps HTTP transport execution with retry logic.
///
/// This implements exponential backoff with jitter for retrying failed requests.
/// Per spec, retry wraps the transport layer, not part of the interceptor chain.
class RetryWrapper {
  /// Configuration containing retry policy.
  final GoogleAIConfig config;

  /// Random number generator for jitter.
  final Random _random;

  /// Creates a [RetryWrapper].
  RetryWrapper({required this.config}) : _random = Random();

  /// Executes an HTTP request with retry logic.
  ///
  /// The [execute] function should perform the actual HTTP transport.
  /// The optional [abortTrigger] allows immediate abort during retry delays.
  /// The [correlationId] is used for request tracing and error reporting.
  /// Retries are attempted for rate limits, 5xx errors, and timeouts.
  /// Only idempotent HTTP methods are retried by default.
  Future<http.Response> executeWithRetry(
    http.BaseRequest request,
    Future<http.Response> Function() execute,
    Future<void>? abortTrigger,
    String correlationId,
  ) async {
    var attempt = 0;
    Duration delay = config.retryPolicy.initialDelay;

    while (attempt <= config.retryPolicy.maxRetries) {
      try {
        final response = await execute();

        // Check for retryable status codes (429, 5xx)
        if (_shouldRetry(response.statusCode, request.method, attempt)) {
          final retryAfter =
              _parseRetryAfter(response.headers['retry-after']);
          if (retryAfter != null) {
            // Clamp server-provided Retry-After to a reasonable maximum
            final maxServerDelay = config.retryPolicy.maxDelay * 2;
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
        if (!_isIdempotent(request.method) ||
            attempt >= config.retryPolicy.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      }
    }

    // Should never reach here; reaching this point indicates a logic error.
    throw StateError('Unreachable: executeWithRetry fell through retry loop');
  }

  /// Checks if an HTTP method is idempotent and safe to retry.
  ///
  /// Per spec: "Retry decisions should consider HTTP method idempotency"
  /// Safe methods: GET, HEAD, OPTIONS, PUT, DELETE
  /// Unsafe: POST, PATCH (may create duplicates)
  bool _isIdempotent(String method) {
    const idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};
    return idempotentMethods.contains(method.toUpperCase());
  }

  /// Determines if a response should be retried based on status code.
  bool _shouldRetry(int statusCode, String method, int attempt) {
    if (attempt >= config.retryPolicy.maxRetries) return false;

    // Retry rate limits (429)
    if (statusCode == 429) return true;

    // Retry 5xx server errors for idempotent methods only
    if (statusCode >= 500 && statusCode < 600) return _isIdempotent(method);

    return false;
  }

  /// Parses the Retry-After header value (supports delta-seconds format).
  Duration? _parseRetryAfter(String? value) {
    if (value == null) return null;
    final seconds = int.tryParse(value.trim());
    if (seconds != null) return Duration(seconds: max(0, seconds));
    return null;
  }

  /// Applies exponential backoff to the current delay.
  Duration _exponentialBackoff(Duration currentDelay) {
    final nextDelay = currentDelay * 2;
    return nextDelay > config.retryPolicy.maxDelay
        ? config.retryPolicy.maxDelay
        : nextDelay;
  }

  /// Delays with jitter to avoid thundering herd.
  Future<void> _delayWithJitter(Duration delay) async {
    final jitterMs =
        (_random.nextDouble() *
                config.retryPolicy.jitter *
                delay.inMilliseconds)
            .round();

    final finalDelay = delay + Duration(milliseconds: jitterMs);
    await Future<void>.delayed(finalDelay);
  }

  /// Delays with abort check - aborts immediately if trigger fires during delay.
  ///
  /// This allows immediate abort during retry delays instead of waiting
  /// for the full delay duration. If no abort trigger is provided,
  /// falls back to normal jittered delay.
  Future<void> _delayWithAbortCheck(
    Duration delay,
    Future<void>? abortTrigger,
    String correlationId,
  ) async {
    if (abortTrigger == null) {
      // No abort trigger, use normal delay
      await _delayWithJitter(delay);
    } else {
      // Race the delay with abort trigger
      final jitterMs =
          (_random.nextDouble() *
                  config.retryPolicy.jitter *
                  delay.inMilliseconds)
              .round();

      final finalDelay = delay + Duration(milliseconds: jitterMs);

      await Future.any([
        Future<void>.delayed(finalDelay),
        abortTrigger.then((_) {
          throw AbortedException(
            message: 'Request aborted during retry delay',
            correlationId: correlationId,
            timestamp: DateTime.now(),
            stage: AbortionStage.beforeRequest, // Before next retry attempt
          );
        }),
      ]);
    }
  }
}
