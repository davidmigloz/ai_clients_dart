import 'dart:async' as dart_async;
import 'dart:math';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../platform/http_utils.dart';
import 'config.dart';

/// Configuration for retry behavior.
///
/// This class configures exponential backoff with jitter for retrying
/// failed requests.
class RetryPolicy {
  /// Maximum number of retry attempts.
  final int maxRetries;

  /// Initial delay before the first retry.
  final Duration initialDelay;

  /// Maximum delay between retries.
  final Duration maxDelay;

  /// Jitter factor (0.0 to 1.0) to add randomness to delays.
  final double jitter;

  /// Creates a retry policy.
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.jitter = 0.1,
  });

  /// A policy that disables retries.
  static const none = RetryPolicy(maxRetries: 0);
}

/// Wraps HTTP transport execution with retry logic.
///
/// This implements exponential backoff with jitter for retrying failed requests.
/// The wrapper is applied by the interceptor chain at the transport layer,
/// wrapping only the HTTP execution (not the entire interceptor chain).
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
/// The [isIdempotent] parameter on [executeWithRetry] allows callers to override
/// the HTTP method check for POST endpoints that are semantically idempotent
/// (e.g., ChromaDB's query/search/get endpoints).
class RetryWrapper {
  /// Creates a [RetryWrapper] with the given configuration.
  RetryWrapper({required this.config}) : _random = Random();

  /// The configuration containing retry policy settings.
  final ChromaConfig config;

  /// Random number generator for jitter.
  final Random _random;

  /// Multiplier for clamping server-provided Retry-After values.
  static const _serverRetryAfterMultiplier = 2;

  /// Executes an HTTP request with retry logic.
  ///
  /// The [execute] function performs the actual HTTP transport.
  /// The optional [abortTrigger] allows immediate abort during retry delays.
  /// The [correlationId] is used for request tracing.
  /// When [isIdempotent] is true, POST requests are treated as idempotent
  /// for retry purposes.
  Future<http.Response> executeWithRetry(
    http.BaseRequest request,
    Future<http.Response> Function() execute,
    Future<void>? abortTrigger,
    String correlationId, {
    bool isIdempotent = false,
  }) async {
    var attempt = 0;
    var delay = config.retryPolicy.initialDelay;

    while (attempt <= config.retryPolicy.maxRetries) {
      try {
        final response = await execute();

        // Check for retryable status codes
        if (_shouldRetry(
          response.statusCode,
          request.method,
          attempt,
          isIdempotent: isIdempotent,
        )) {
          final retryAfter = _parseRetryAfter(response.headers['retry-after']);
          if (retryAfter != null) {
            final maxServerDelay =
                config.retryPolicy.maxDelay * _serverRetryAfterMultiplier;
            delay = retryAfter <= maxServerDelay ? retryAfter : maxServerDelay;
          }

          // Enforce minimum delay to prevent tight retry loops
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
        rethrow;
      } on TimeoutException {
        if (!_isIdempotent(request.method, isIdempotent: isIdempotent) ||
            attempt >= config.retryPolicy.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } on dart_async.TimeoutException {
        if (!_isIdempotent(request.method, isIdempotent: isIdempotent) ||
            attempt >= config.retryPolicy.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } on http.ClientException {
        if (!_isIdempotent(request.method, isIdempotent: isIdempotent) ||
            attempt >= config.retryPolicy.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } catch (e) {
        // Handle SocketException on IO platforms (when not wrapped by http package)
        if (isSocketException(e)) {
          if (!_isIdempotent(request.method, isIdempotent: isIdempotent) ||
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
  bool _shouldRetry(
    int statusCode,
    String method,
    int attempt, {
    bool isIdempotent = false,
  }) {
    if (attempt >= config.retryPolicy.maxRetries) {
      return false;
    }

    // Retry rate limits
    if (statusCode == 429) {
      return true;
    }

    // Retry 5xx errors for idempotent methods
    if (statusCode >= 500 && statusCode < 600) {
      return _isIdempotent(method, isIdempotent: isIdempotent);
    }

    return false;
  }

  /// Checks if an HTTP method is idempotent and safe to retry.
  ///
  /// The [isIdempotent] parameter allows overriding for POST endpoints
  /// that are semantically idempotent (e.g., query, search, get).
  bool _isIdempotent(String method, {bool isIdempotent = false}) {
    if (isIdempotent) return true;
    const idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};
    return idempotentMethods.contains(method.toUpperCase());
  }

  /// Applies exponential backoff to the current delay.
  Duration _exponentialBackoff(Duration currentDelay) {
    if (currentDelay < config.retryPolicy.initialDelay) {
      return config.retryPolicy.initialDelay;
    }
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
  Duration? _parseRetryAfter(String? value) {
    if (value == null) return null;

    final trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    // Try parsing as seconds
    final seconds = int.tryParse(trimmed);
    if (seconds != null) {
      return Duration(seconds: max(0, seconds));
    }

    // Try parsing as HTTP-date
    try {
      final date = parseHttpDate(trimmed);
      final now = DateTime.now();
      if (date.isAfter(now)) {
        return date.difference(now);
      }
      return Duration.zero;
    } catch (_) {
      // Ignore parse errors
    }

    return null;
  }

  /// Computes a delay with jitter.
  Duration _computeJitteredDelay(Duration delay) {
    final jitterFactor = config.retryPolicy.jitter;
    final baseMs = delay.inMilliseconds;
    final maxMs = config.retryPolicy.maxDelay.inMilliseconds;

    if (baseMs >= maxMs) return delay;

    final maxJitterFromFactor = (jitterFactor * baseMs).round();
    final headroom = maxMs - baseMs;
    final allowedJitterMs = min(maxJitterFromFactor, headroom);
    final jitterMs = (_random.nextDouble() * allowedJitterMs).round();

    return delay + Duration(milliseconds: jitterMs);
  }

  /// Delays with jitter.
  Future<void> _delayWithJitter(Duration delay) async {
    await Future<void>.delayed(_computeJitteredDelay(delay));
  }

  /// Delays with abort check.
  Future<void> _delayWithAbortCheck(
    Duration delay,
    Future<void>? abortTrigger,
    String correlationId,
  ) async {
    if (abortTrigger == null) {
      await _delayWithJitter(delay);
    } else {
      final finalDelay = _computeJitteredDelay(delay);

      final delayFuture = Future<bool>.delayed(finalDelay, () => false);
      final abortFuture = abortTrigger.then((_) => true, onError: (_) => true);

      final wasAborted = await Future.any([delayFuture, abortFuture]);

      if (wasAborted) {
        throw AbortedException(message: 'Request aborted during retry delay');
      }
    }
  }
}
