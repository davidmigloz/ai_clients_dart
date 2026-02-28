import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:openai_dart/src/client/config.dart';
import 'package:openai_dart/src/client/retry_wrapper.dart';
import 'package:openai_dart/src/errors/exceptions.dart';
import 'package:test/test.dart';

void main() {
  group('RetryWrapper', () {
    late RetryWrapper wrapper;

    setUp(() {
      wrapper = RetryWrapper(
        config: const OpenAIConfig(
          retryPolicy: RetryPolicy(
            maxRetries: 3,
            initialDelay: Duration(milliseconds: 10),
            maxDelay: Duration(milliseconds: 100),
          ),
        ),
      );
    });

    group('executeWithRetry', () {
      test('returns response on first successful call', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 200);
        expect(callCount, 1);
      });

      test('retries on 429 status code', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount < 3) {
              return http.Response('rate limited', 429);
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 200);
        expect(callCount, 3);
      });

      test('retries on 500 status code for GET', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount < 2) {
              return http.Response('server error', 500);
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 200);
        expect(callCount, 2);
      });

      test('does not retry 500 for POST', () async {
        var callCount = 0;
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            return http.Response('server error', 500);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 500);
        expect(callCount, 1);
      });

      test('does retry 429 for POST', () async {
        var callCount = 0;
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount < 2) {
              return http.Response('rate limited', 429);
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 200);
        expect(callCount, 2);
      });

      test('does not retry on 400 status code', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            return http.Response('bad request', 400);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 400);
        expect(callCount, 1);
      });

      test('honors Retry-After header with seconds', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );
        final stopwatch = Stopwatch()..start();

        await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount == 1) {
              return http.Response(
                'rate limited',
                429,
                headers: {'retry-after': '0'}, // 0 seconds
              );
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        stopwatch.stop();
        expect(callCount, 2);
      });

      test('respects maxRetries limit', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            return http.Response('rate limited', 429);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 429);
        expect(callCount, 4); // Initial + 3 retries
      });

      test('retries on TimeoutException for GET', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount < 2) {
              throw TimeoutException('Request timed out');
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 200);
        expect(callCount, 2);
      });

      test('does not retry TimeoutException for POST', () {
        var callCount = 0;
        final request = http.Request(
          'POST',
          Uri.parse('https://api.example.com'),
        );

        expect(
          wrapper.executeWithRetry(
            request,
            () {
              callCount++;
              throw TimeoutException('Request timed out');
            },
            null,
            'req_123',
          ),
          throwsA(isA<TimeoutException>()),
        );

        expect(callCount, 1);
      });

      test('retries on ClientException for GET', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        final response = await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount < 2) {
              throw http.ClientException('Connection failed');
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(response.statusCode, 200);
        expect(callCount, 2);
      });

      test('does not catch AbortedException', () {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        expect(
          wrapper.executeWithRetry(
            request,
            () {
              callCount++;
              throw const AbortedException(message: 'User cancelled');
            },
            null,
            'req_123',
          ),
          throwsA(isA<AbortedException>()),
        );

        expect(callCount, 1);
      });

      test('aborts during retry delay when trigger fires', () {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );
        final abortCompleter = Completer<void>();

        // Create a wrapper with longer delay to ensure abort fires during delay
        final slowWrapper = RetryWrapper(
          config: const OpenAIConfig(
            retryPolicy: RetryPolicy(
              maxRetries: 3,
              initialDelay: Duration(seconds: 10),
              maxDelay: Duration(seconds: 30),
            ),
          ),
        );

        final future = slowWrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount == 1) {
              // Schedule abort during retry delay
              Future.delayed(
                const Duration(milliseconds: 10),
                abortCompleter.complete,
              );
              return http.Response('rate limited', 429);
            }
            return http.Response('{"ok": true}', 200);
          },
          abortCompleter.future,
          'req_123',
        );

        expect(future, throwsA(isA<AbortedException>()));
        expect(callCount, 1);
      });
    });

    group('idempotent methods', () {
      final idempotentMethods = ['GET', 'HEAD', 'OPTIONS', 'PUT', 'DELETE'];
      final nonIdempotentMethods = ['POST', 'PATCH'];

      for (final method in idempotentMethods) {
        test('retries 500 for $method', () async {
          var callCount = 0;
          final request = http.Request(
            method,
            Uri.parse('https://api.example.com'),
          );

          final response = await wrapper.executeWithRetry(
            request,
            () async {
              callCount++;
              if (callCount < 2) {
                return http.Response('server error', 500);
              }
              return http.Response('{"ok": true}', 200);
            },
            null,
            'req_123',
          );

          expect(response.statusCode, 200);
          expect(callCount, 2, reason: '$method should be retried on 500');
        });
      }

      for (final method in nonIdempotentMethods) {
        test('does not retry 500 for $method', () async {
          var callCount = 0;
          final request = http.Request(
            method,
            Uri.parse('https://api.example.com'),
          );

          final response = await wrapper.executeWithRetry(
            request,
            () async {
              callCount++;
              return http.Response('server error', 500);
            },
            null,
            'req_123',
          );

          expect(response.statusCode, 500);
          expect(callCount, 1, reason: '$method should NOT be retried on 500');
        });
      }
    });

    group('Retry-After header parsing', () {
      test('parses integer seconds', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount == 1) {
              return http.Response(
                'rate limited',
                429,
                headers: {'retry-after': '1'},
              );
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(callCount, 2);
      });

      test('parses RFC 1123 date format', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        // Use a date in the past to ensure immediate retry
        const pastDate = 'Wed, 21 Oct 2015 07:28:00 GMT';

        await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount == 1) {
              return http.Response(
                'rate limited',
                429,
                headers: {'retry-after': pastDate},
              );
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(callCount, 2);
      });

      test('handles whitespace in Retry-After value', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount == 1) {
              return http.Response(
                'rate limited',
                429,
                headers: {'retry-after': '  0  '},
              );
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(callCount, 2);
      });

      test('ignores invalid Retry-After value', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );

        await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount == 1) {
              return http.Response(
                'rate limited',
                429,
                headers: {'retry-after': 'invalid'},
              );
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        expect(callCount, 2);
      });

      test('enforces minimum delay when Retry-After is 0', () async {
        var callCount = 0;
        final request = http.Request(
          'GET',
          Uri.parse('https://api.example.com'),
        );
        final stopwatch = Stopwatch()..start();

        await wrapper.executeWithRetry(
          request,
          () async {
            callCount++;
            if (callCount == 1) {
              // Retry-After: 0 should NOT cause a tight loop
              return http.Response(
                'rate limited',
                429,
                headers: {'retry-after': '0'},
              );
            }
            return http.Response('{"ok": true}', 200);
          },
          null,
          'req_123',
        );

        stopwatch.stop();
        expect(callCount, 2);
        // Should have waited at least config.retryDelay (10ms) despite Retry-After: 0
        expect(stopwatch.elapsedMilliseconds, greaterThanOrEqualTo(10));
      });
    });
  });
}
