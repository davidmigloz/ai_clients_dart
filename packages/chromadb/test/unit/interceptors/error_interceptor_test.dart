import 'package:chromadb/src/errors/exceptions.dart';
import 'package:chromadb/src/interceptors/error_interceptor.dart';
import 'package:chromadb/src/interceptors/interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('ErrorInterceptor', () {
    const interceptor = ErrorInterceptor();

    InterceptorNext nextReturning(http.Response response) =>
        (_) => Future.value(response);

    test('builds RequestMetadata from context.request', () async {
      final request = http.Request(
        'POST',
        Uri.parse('https://example.com/api/v2/test'),
      )..headers['X-Request-ID'] = 'test-correlation-id';

      final now = DateTime.now();
      final context = RequestContext(
        request: request,
        metadata: {'timestamp': now},
      );

      try {
        await interceptor.intercept(
          context,
          nextReturning(http.Response('{"error": "not found"}', 404)),
        );
        fail('Should have thrown');
      } on NotFoundException catch (e) {
        expect(e.request, isNotNull);
        expect(e.request!.method, 'POST');
        expect(e.request!.url.path, '/api/v2/test');
        expect(e.request!.correlationId, 'test-correlation-id');
        expect(e.request!.timestamp, now);
      }
    });

    test('reads timestamp from context.metadata', () async {
      final timestamp = DateTime(2024, 1, 15, 10, 30, 0);
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(
        request: request,
        metadata: {'timestamp': timestamp},
      );

      try {
        await interceptor.intercept(
          context,
          nextReturning(http.Response('server error', 500)),
        );
        fail('Should have thrown');
      } on ServerException catch (e) {
        expect(e.request!.timestamp, timestamp);
      }
    });

    test('throws ValidationException for 400', () {
      final request = http.Request(
        'POST',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      expect(
        interceptor.intercept(
          context,
          nextReturning(http.Response('{"message": "invalid input"}', 400)),
        ),
        throwsA(isA<ValidationException>()),
      );
    });

    test('throws AuthenticationException for 401', () {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      expect(
        interceptor.intercept(
          context,
          nextReturning(http.Response('{"message": "unauthorized"}', 401)),
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('throws AuthenticationException for 403', () {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      expect(
        interceptor.intercept(
          context,
          nextReturning(http.Response('{"message": "forbidden"}', 403)),
        ),
        throwsA(isA<AuthenticationException>()),
      );
    });

    test('throws NotFoundException for 404', () {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      expect(
        interceptor.intercept(
          context,
          nextReturning(http.Response('{"message": "not found"}', 404)),
        ),
        throwsA(isA<NotFoundException>()),
      );
    });

    test('throws ConflictException for 409', () {
      final request = http.Request(
        'POST',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      expect(
        interceptor.intercept(
          context,
          nextReturning(http.Response('{"message": "already exists"}', 409)),
        ),
        throwsA(isA<ConflictException>()),
      );
    });

    test('throws RateLimitException for 429', () {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      expect(
        interceptor.intercept(
          context,
          nextReturning(http.Response('{"message": "too many requests"}', 429)),
        ),
        throwsA(isA<RateLimitException>()),
      );
    });

    test('throws ServerException for 500', () {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      expect(
        interceptor.intercept(
          context,
          nextReturning(http.Response('{"message": "internal error"}', 500)),
        ),
        throwsA(isA<ServerException>()),
      );
    });

    test('passes through 2xx responses', () async {
      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      final response = await interceptor.intercept(
        context,
        nextReturning(http.Response('{"ok": true}', 200)),
      );

      expect(response.statusCode, 200);
    });

    test('redacts sensitive headers in RequestMetadata', () async {
      final request = http.Request('GET', Uri.parse('https://example.com/test'))
        ..headers['Authorization'] = 'Bearer secret-token'
        ..headers['x-chroma-token'] = 'api-key-123'
        ..headers['X-Safe-Header'] = 'visible';

      final context = RequestContext(request: request);

      try {
        await interceptor.intercept(
          context,
          nextReturning(http.Response('error', 500)),
        );
        fail('Should have thrown');
      } on ServerException catch (e) {
        expect(e.request!.headers['Authorization'], '[REDACTED]');
        expect(e.request!.headers['x-chroma-token'], '[REDACTED]');
        expect(e.request!.headers['X-Safe-Header'], 'visible');
      }
    });
  });
}
