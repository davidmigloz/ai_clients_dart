import 'dart:async';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../errors/exceptions.dart';
import '../interceptors/interceptor.dart';
import 'interceptor_chain.dart';

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

  /// Multiplier for exponential backoff.
  final double backoffMultiplier;

  /// Maximum jitter to add to delays (0.0 to 1.0).
  final double jitterFactor;

  /// Creates a retry policy.
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.jitterFactor = 0.2,
  });

  /// A policy that disables retries.
  static const none = RetryPolicy(maxRetries: 0);
}

/// Wraps an interceptor chain with retry logic.
///
/// This wrapper implements exponential backoff with jitter for retrying
/// failed requests. It only retries idempotent requests and specific
/// error types.
///
/// Retryable conditions:
/// - HTTP 429 (Rate Limit)
/// - HTTP 5xx (Server Error)
/// - Network/connection errors
///
/// Non-retryable:
/// - HTTP 4xx (except 429)
/// - Non-idempotent requests (POST without explicit idempotency)
class RetryWrapper {
  final InterceptorChain _chain;
  final RetryPolicy _policy;
  final Random _random = Random();

  /// Creates a retry wrapper.
  RetryWrapper({
    required InterceptorChain chain,
    RetryPolicy policy = const RetryPolicy(),
  }) : _chain = chain,
       _policy = policy;

  /// Sends a request with retry logic.
  Future<http.Response> send(
    RequestContext context, {
    bool isIdempotent = true,
  }) async {
    var attempt = 0;
    Exception? lastException;

    while (attempt <= _policy.maxRetries) {
      // Create context with current attempt number (1-indexed)
      final attemptContext = RequestContext(
        method: context.method,
        path: context.path,
        queryParameters: context.queryParameters,
        headers: Map.of(context.headers),
        body: context.body,
        fullUrl: context.fullUrl,
        timestamp: context.timestamp,
        attemptNumber: attempt + 1,
      );

      try {
        return await _chain.send(attemptContext);
      } on RateLimitException catch (e) {
        lastException = e;
        if (!_shouldRetry(attempt, isIdempotent)) {
          rethrow;
        }
        final delay = e.retryAfter ?? _calculateDelay(attempt);
        await Future<void>.delayed(delay);
        attempt++;
      } on ServerException catch (e) {
        lastException = e;
        if (!_shouldRetry(attempt, isIdempotent)) {
          rethrow;
        }
        await Future<void>.delayed(_calculateDelay(attempt));
        attempt++;
      } on TimeoutException catch (e) {
        lastException = e;
        if (!_shouldRetry(attempt, isIdempotent)) {
          rethrow;
        }
        await Future<void>.delayed(_calculateDelay(attempt));
        attempt++;
      } on http.ClientException catch (e) {
        // Network errors
        lastException = Exception(e.message);
        if (!_shouldRetry(attempt, isIdempotent)) {
          throw TimeoutException(
            message: 'Network error: ${e.message}',
            cause: lastException,
          );
        }
        await Future<void>.delayed(_calculateDelay(attempt));
        attempt++;
      }
    }

    // Should not reach here, but just in case
    throw lastException ?? TimeoutException(message: 'Max retries exceeded');
  }

  bool _shouldRetry(int attempt, bool isIdempotent) {
    if (attempt >= _policy.maxRetries) return false;
    if (!isIdempotent) return false;
    return true;
  }

  Duration _calculateDelay(int attempt) {
    // Exponential backoff
    final exponentialDelay =
        _policy.initialDelay.inMilliseconds *
        pow(_policy.backoffMultiplier, attempt);

    // Cap at max delay
    final cappedDelay = min(
      exponentialDelay.toInt(),
      _policy.maxDelay.inMilliseconds,
    );

    // Add jitter
    final jitter = (_random.nextDouble() * 2 - 1) * _policy.jitterFactor;
    final finalDelay = (cappedDelay * (1 + jitter)).toInt();

    return Duration(milliseconds: max(finalDelay, 0));
  }
}
