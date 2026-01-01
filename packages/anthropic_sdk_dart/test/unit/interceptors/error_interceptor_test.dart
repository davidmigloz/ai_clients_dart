import 'dart:convert';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:anthropic_sdk_dart/src/interceptors/error_interceptor.dart';
import 'package:anthropic_sdk_dart/src/interceptors/interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('ErrorInterceptor', () {
    const interceptor = ErrorInterceptor();

    http.Request createRequest() => http.Request(
      'POST',
      Uri.parse('https://api.anthropic.com/v1/messages'),
    );

    test('passes through successful responses', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response('{"id": "msg_123"}', 200);
      }

      final response = await interceptor.intercept(context, next);

      expect(response.statusCode, 200);
      expect(response.body, '{"id": "msg_123"}');
    });

    test('throws AuthenticationException for 401', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response(
          jsonEncode({
            'type': 'error',
            'error': {
              'type': 'authentication_error',
              'message': 'Invalid API key',
            },
          }),
          401,
        );
      }

      await expectLater(
        interceptor.intercept(context, next),
        throwsA(
          isA<AuthenticationException>().having(
            (e) => e.message,
            'message',
            'Invalid API key',
          ),
        ),
      );
    });

    test('throws RateLimitException for 429', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response(
          jsonEncode({
            'type': 'error',
            'error': {
              'type': 'rate_limit_error',
              'message': 'Too many requests',
            },
          }),
          429,
          headers: {'retry-after': '60'},
        );
      }

      await expectLater(
        interceptor.intercept(context, next),
        throwsA(
          isA<RateLimitException>()
              .having((e) => e.message, 'message', 'Too many requests')
              .having((e) => e.code, 'code', 429)
              .having((e) => e.retryAfter, 'retryAfter', isNotNull),
        ),
      );
    });

    test('throws ApiException for other 4xx errors', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response(
          jsonEncode({
            'type': 'error',
            'error': {
              'type': 'invalid_request_error',
              'message': 'Invalid model specified',
            },
          }),
          400,
        );
      }

      await expectLater(
        interceptor.intercept(context, next),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Invalid model specified')
              .having((e) => e.code, 'code', 400),
        ),
      );
    });

    test('throws ApiException for 5xx errors', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response(
          jsonEncode({
            'type': 'error',
            'error': {'type': 'api_error', 'message': 'Internal server error'},
          }),
          500,
        );
      }

      await expectLater(
        interceptor.intercept(context, next),
        throwsA(
          isA<ApiException>()
              .having((e) => e.message, 'message', 'Internal server error')
              .having((e) => e.code, 'code', 500),
        ),
      );
    });

    test('handles empty error body', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response('', 500);
      }

      await expectLater(
        interceptor.intercept(context, next),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Unknown error',
          ),
        ),
      );
    });

    test('handles non-JSON error body', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response('Bad Gateway', 502);
      }

      await expectLater(
        interceptor.intercept(context, next),
        throwsA(
          isA<ApiException>().having(
            (e) => e.message,
            'message',
            'Bad Gateway',
          ),
        ),
      );
    });

    test('includes request metadata in exception', () async {
      final request = createRequest()..headers['X-Request-ID'] = 'req_123';
      final context = RequestContext(request: request);

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response('{"error": {"message": "error"}}', 400);
      }

      try {
        await interceptor.intercept(context, next);
        fail('Expected exception');
      } on ApiException catch (e) {
        expect(e.requestMetadata, isNotNull);
        expect(e.requestMetadata!.method, 'POST');
        expect(e.requestMetadata!.url.toString(), contains('anthropic.com'));
      }
    });

    test('includes response metadata in exception', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response(
          '{"error": {"message": "error"}}',
          400,
          headers: {'x-request-id': 'resp_123'},
        );
      }

      try {
        await interceptor.intercept(context, next);
        fail('Expected exception');
      } on ApiException catch (e) {
        expect(e.responseMetadata, isNotNull);
        expect(e.responseMetadata!.statusCode, 400);
        expect(e.responseMetadata!.latency, isNotNull);
      }
    });

    test('redacts sensitive headers in metadata', () async {
      final request = createRequest()..headers['x-api-key'] = 'secret-key';
      final context = RequestContext(request: request);

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response('{"error": {"message": "error"}}', 400);
      }

      try {
        await interceptor.intercept(context, next);
        fail('Expected exception');
      } on ApiException catch (e) {
        expect(e.requestMetadata!.headers['x-api-key'], '[REDACTED]');
      }
    });

    test('extracts error type as detail', () async {
      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response(
          jsonEncode({
            'type': 'error',
            'error': {
              'type': 'invalid_request_error',
              'message': 'Bad request',
            },
          }),
          400,
        );
      }

      try {
        await interceptor.intercept(context, next);
        fail('Expected exception');
      } on ApiException catch (e) {
        expect(e.details, contains('invalid_request_error'));
      }
    });
  });
}
