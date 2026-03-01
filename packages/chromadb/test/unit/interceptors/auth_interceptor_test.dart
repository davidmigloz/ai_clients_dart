import 'package:chromadb/src/auth/auth_provider.dart';
import 'package:chromadb/src/interceptors/auth_interceptor.dart';
import 'package:chromadb/src/interceptors/interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('AuthInterceptor', () {
    test('adds x-chroma-token via context.request.headers', () async {
      final interceptor = AuthInterceptor(
        authProvider: const ApiKeyProvider('test-key'),
      );

      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      await interceptor.intercept(context, (ctx) async {
        expect(ctx.request.headers['x-chroma-token'], 'test-key');
        return http.Response('ok', 200);
      });
    });

    test('adds Bearer token via context.request.headers', () async {
      final interceptor = AuthInterceptor(
        authProvider: const BearerTokenProvider('my-token'),
      );

      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      await interceptor.intercept(context, (ctx) async {
        expect(ctx.request.headers['Authorization'], 'Bearer my-token');
        return http.Response('ok', 200);
      });
    });

    test('does not add headers for NoAuthProvider', () async {
      final interceptor = AuthInterceptor(authProvider: const NoAuthProvider());

      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      await interceptor.intercept(context, (ctx) async {
        expect(ctx.request.headers.containsKey('x-chroma-token'), isFalse);
        expect(ctx.request.headers.containsKey('Authorization'), isFalse);
        return http.Response('ok', 200);
      });
    });
  });
}
