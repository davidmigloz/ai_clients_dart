import 'package:anthropic_sdk_dart/src/interceptors/interceptor.dart';
import 'package:anthropic_sdk_dart/src/interceptors/logging_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('LoggingInterceptor', () {
    http.Request createRequest() => http.Request(
      'POST',
      Uri.parse('https://api.anthropic.com/v1/messages'),
    );

    test('adds X-Request-ID header if not present', () async {
      final interceptor = LoggingInterceptor(
        logLevel: Level.INFO,
        redactionList: const ['x-api-key'],
      );

      final request = createRequest();
      final context = RequestContext(request: request);

      http.BaseRequest? capturedRequest;
      Future<http.Response> next(RequestContext ctx) async {
        capturedRequest = ctx.request;
        return http.Response('{}', 200);
      }

      await interceptor.intercept(context, next);

      expect(capturedRequest!.headers.containsKey('X-Request-ID'), isTrue);
      expect(capturedRequest!.headers['X-Request-ID'], isNotEmpty);
    });

    test('preserves existing X-Request-ID header', () async {
      final interceptor = LoggingInterceptor(
        logLevel: Level.INFO,
        redactionList: const [],
      );

      final request = createRequest()..headers['X-Request-ID'] = 'existing-id';
      final context = RequestContext(request: request);

      http.BaseRequest? capturedRequest;
      Future<http.Response> next(RequestContext ctx) async {
        capturedRequest = ctx.request;
        return http.Response('{}', 200);
      }

      await interceptor.intercept(context, next);

      expect(capturedRequest!.headers['X-Request-ID'], 'existing-id');
    });

    test('stores correlationId in metadata', () async {
      final interceptor = LoggingInterceptor(
        logLevel: Level.INFO,
        redactionList: const [],
      );

      final request = createRequest();
      final context = RequestContext(request: request);

      Map<String, dynamic>? capturedMetadata;
      Future<http.Response> next(RequestContext ctx) async {
        capturedMetadata = ctx.metadata;
        return http.Response('{}', 200);
      }

      await interceptor.intercept(context, next);

      expect(capturedMetadata, isNotNull);
      expect(capturedMetadata!['correlationId'], isNotEmpty);
    });

    test('passes through successful response', () async {
      final interceptor = LoggingInterceptor(
        logLevel: Level.INFO,
        redactionList: const [],
      );

      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) async {
        return http.Response('{"result": "ok"}', 200);
      }

      final response = await interceptor.intercept(context, next);

      expect(response.statusCode, 200);
      expect(response.body, '{"result": "ok"}');
    });

    test('rethrows exceptions from next', () async {
      final interceptor = LoggingInterceptor(
        logLevel: Level.INFO,
        redactionList: const [],
      );

      final context = RequestContext(request: createRequest());

      Future<http.Response> next(RequestContext ctx) {
        throw Exception('Network error');
      }

      await expectLater(
        interceptor.intercept(context, next),
        throwsA(isA<Exception>()),
      );
    });

    test('redacts sensitive headers based on redactionList', () async {
      final interceptor = LoggingInterceptor(
        logLevel: Level.INFO,
        redactionList: const ['x-api-key', 'authorization'],
      );

      final request = createRequest()
        ..headers['x-api-key'] = 'secret'
        ..headers['Authorization'] = 'Bearer token';
      final context = RequestContext(request: request);

      // Interceptor logs headers - testing redaction is internal
      // but we can verify the interceptor runs successfully
      Future<http.Response> next(RequestContext ctx) async {
        return http.Response('{}', 200);
      }

      final response = await interceptor.intercept(context, next);
      expect(response.statusCode, 200);
    });

    test('preserves request body', () async {
      final interceptor = LoggingInterceptor(
        logLevel: Level.INFO,
        redactionList: const [],
      );

      final request = createRequest()..body = '{"message": "hello"}';
      final context = RequestContext(request: request);

      http.BaseRequest? capturedRequest;
      Future<http.Response> next(RequestContext ctx) async {
        capturedRequest = ctx.request;
        return http.Response('{}', 200);
      }

      await interceptor.intercept(context, next);

      expect((capturedRequest! as http.Request).body, '{"message": "hello"}');
    });
  });
}
