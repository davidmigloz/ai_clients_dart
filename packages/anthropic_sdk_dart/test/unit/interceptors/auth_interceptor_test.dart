import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:anthropic_sdk_dart/src/interceptors/auth_interceptor.dart';
import 'package:anthropic_sdk_dart/src/interceptors/interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('AuthInterceptor', () {
    group('with ApiKeyProvider', () {
      test('adds x-api-key header to request', () async {
        const interceptor = AuthInterceptor(
          authProvider: ApiKeyProvider('test-key'),
        );

        final request = http.Request('POST', Uri.parse('https://api.test.com'));
        final context = RequestContext(request: request);

        http.BaseRequest? capturedRequest;
        Future<http.Response> next(RequestContext ctx) async {
          capturedRequest = ctx.request;
          return http.Response('{}', 200);
        }

        await interceptor.intercept(context, next);

        expect(capturedRequest!.headers['x-api-key'], 'test-key');
      });

      test('does not override existing x-api-key header', () async {
        const interceptor = AuthInterceptor(
          authProvider: ApiKeyProvider('new-key'),
        );

        final request = http.Request('POST', Uri.parse('https://api.test.com'))
          ..headers['x-api-key'] = 'existing-key';
        final context = RequestContext(request: request);

        http.BaseRequest? capturedRequest;
        Future<http.Response> next(RequestContext ctx) async {
          capturedRequest = ctx.request;
          return http.Response('{}', 200);
        }

        await interceptor.intercept(context, next);

        expect(capturedRequest!.headers['x-api-key'], 'existing-key');
      });

      test('preserves request body when adding header', () async {
        const interceptor = AuthInterceptor(
          authProvider: ApiKeyProvider('key'),
        );

        final request = http.Request('POST', Uri.parse('https://api.test.com'))
          ..body = '{"message": "hello"}';
        final context = RequestContext(request: request);

        http.BaseRequest? capturedRequest;
        Future<http.Response> next(RequestContext ctx) async {
          capturedRequest = ctx.request;
          return http.Response('{}', 200);
        }

        await interceptor.intercept(context, next);

        expect((capturedRequest! as http.Request).body, '{"message": "hello"}');
        expect(capturedRequest!.headers['x-api-key'], 'key');
      });

      test('preserves other headers when adding auth', () async {
        const interceptor = AuthInterceptor(
          authProvider: ApiKeyProvider('key'),
        );

        final request = http.Request('POST', Uri.parse('https://api.test.com'))
          ..headers['Content-Type'] = 'application/json'
          ..headers['X-Custom'] = 'value';
        final context = RequestContext(request: request);

        http.BaseRequest? capturedRequest;
        Future<http.Response> next(RequestContext ctx) async {
          capturedRequest = ctx.request;
          return http.Response('{}', 200);
        }

        await interceptor.intercept(context, next);

        expect(capturedRequest!.headers['Content-Type'], 'application/json');
        expect(capturedRequest!.headers['X-Custom'], 'value');
        expect(capturedRequest!.headers['x-api-key'], 'key');
      });
    });

    group('with NoAuthProvider', () {
      test('does not add auth header', () async {
        const interceptor = AuthInterceptor(authProvider: NoAuthProvider());

        final request = http.Request('POST', Uri.parse('https://api.test.com'));
        final context = RequestContext(request: request);

        http.BaseRequest? capturedRequest;
        Future<http.Response> next(RequestContext ctx) async {
          capturedRequest = ctx.request;
          return http.Response('{}', 200);
        }

        await interceptor.intercept(context, next);

        expect(capturedRequest!.headers.containsKey('x-api-key'), isFalse);
      });
    });

    test('calls next interceptor in chain', () async {
      const interceptor = AuthInterceptor(authProvider: ApiKeyProvider('key'));

      final request = http.Request('POST', Uri.parse('https://api.test.com'));
      final context = RequestContext(request: request);

      var nextCalled = false;
      Future<http.Response> next(RequestContext ctx) async {
        nextCalled = true;
        return http.Response('{"result": "ok"}', 200);
      }

      final response = await interceptor.intercept(context, next);

      expect(nextCalled, isTrue);
      expect(response.statusCode, 200);
      expect(response.body, '{"result": "ok"}');
    });
  });
}
