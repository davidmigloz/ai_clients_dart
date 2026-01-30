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
/// - Rate limit responses (HTTP 429)
/// - Server errors (HTTP 5xx)
/// - Timeout exceptions
/// - Connection errors
///
/// Retries are NOT attempted for:
/// - Client errors (HTTP 4xx except 429)
/// - Aborted requests
/// - Non-idempotent methods (POST, PATCH) by default
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
            delay = retryAfter;
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
      } on RateLimitException catch (e) {
        // Handle rate limiting
        if (attempt >= config.maxRetries) {
          rethrow;
        }

        // Honor retryAfter from exception if provided
        if (e.retryAfter != null) {
          final serverDelay = e.retryAfter!;
          // Use server's suggested delay if reasonable
          if (serverDelay <= config.maxRetryDelay * 2) {
            delay = serverDelay;
          }
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } on ApiException catch (e) {
        // Retry on 5xx server errors (transient failures)
        if (e.statusCode >= 500 && e.statusCode < 600) {
          if (!_isIdempotent(request.method)) {
            rethrow; // Don't retry non-idempotent operations
          }

          if (attempt >= config.maxRetries) {
            rethrow;
          }

          await _delayWithAbortCheck(delay, abortTrigger, correlationId);
          attempt++;
          delay = _exponentialBackoff(delay);
        } else {
          // 4xx errors are client errors, don't retry
          rethrow;
        }
      } on TimeoutException {
        // Retry on timeout for idempotent methods only
        if (!_isIdempotent(request.method)) {
          rethrow;
        }

        if (attempt >= config.maxRetries) {
          rethrow;
        }

        await _delayWithAbortCheck(delay, abortTrigger, correlationId);
        attempt++;
        delay = _exponentialBackoff(delay);
      } on ConnectionException {
        // Retry on connection errors for idempotent methods only
        if (!_isIdempotent(request.method)) {
          rethrow;
        }

        if (attempt >= config.maxRetries) {
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
  /// Safe methods: GET, HEAD, OPTIONS, PUT, DELETE
  /// Unsafe: POST, PATCH (may create duplicates)
  bool _isIdempotent(String method) {
    const idempotentMethods = {'GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'};
    return idempotentMethods.contains(method.toUpperCase());
  }

  /// Applies exponential backoff to the current delay.
  Duration _exponentialBackoff(Duration currentDelay) {
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

    // Try parsing as seconds
    final seconds = int.tryParse(value);
    if (seconds != null) {
      return Duration(seconds: seconds);
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
  DateTime _parseHttpDate(String value) {
    // RFC 7231 defines three formats, but DateTime.parse handles ISO 8601
    // For HTTP dates, we need custom parsing
    // Format: "Wed, 21 Oct 2015 07:28:00 GMT"
    final httpDateRegex = RegExp(
      r'^[A-Za-z]{3}, (\d{2}) ([A-Za-z]{3}) (\d{4}) (\d{2}):(\d{2}):(\d{2}) GMT$',
    );

    final match = httpDateRegex.firstMatch(value);
    if (match == null) {
      throw FormatException('Invalid HTTP date: $value');
    }

    const months = {
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'May': 5,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };

    final day = int.parse(match.group(1)!);
    final month = months[match.group(2)!]!;
    final year = int.parse(match.group(3)!);
    final hour = int.parse(match.group(4)!);
    final minute = int.parse(match.group(5)!);
    final second = int.parse(match.group(6)!);

    return DateTime.utc(year, month, day, hour, minute, second);
  }

  /// Delays with jitter to avoid thundering herd problem.
  Future<void> _delayWithJitter(Duration delay) async {
    // Add up to 25% jitter
    const jitterFactor = 0.25;
    final jitterMs =
        (_random.nextDouble() * jitterFactor * delay.inMilliseconds).round();
    final finalDelay = delay + Duration(milliseconds: jitterMs);
    await Future<void>.delayed(finalDelay);
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
      const jitterFactor = 0.25;
      final jitterMs =
          (_random.nextDouble() * jitterFactor * delay.inMilliseconds).round();
      final finalDelay = delay + Duration(milliseconds: jitterMs);

      await Future.any([
        Future<void>.delayed(finalDelay),
        abortTrigger.then((_) {
          throw const AbortedException(
            message: 'Request aborted during retry delay',
          );
        }),
      ]);
    }
  }
}
