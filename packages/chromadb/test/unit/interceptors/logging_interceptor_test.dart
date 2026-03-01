import 'package:chromadb/src/interceptors/interceptor.dart';
import 'package:chromadb/src/interceptors/logging_interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('LoggingInterceptor', () {
    test('adds X-Request-ID via context.request.headers', () async {
      const interceptor = LoggingInterceptor();

      final request = http.Request(
        'GET',
        Uri.parse('https://example.com/test'),
      );
      final context = RequestContext(request: request);

      await interceptor.intercept(context, (ctx) async {
        expect(ctx.request.headers['X-Request-ID'], isNotNull);
        expect(ctx.request.headers['X-Request-ID'], startsWith('chroma-'));
        return http.Response('ok', 200);
      });
    });

    test('preserves existing X-Request-ID', () async {
      const interceptor = LoggingInterceptor();

      final request = http.Request('GET', Uri.parse('https://example.com/test'))
        ..headers['X-Request-ID'] = 'existing-id';
      final context = RequestContext(request: request);

      await interceptor.intercept(context, (ctx) async {
        expect(ctx.request.headers['X-Request-ID'], 'existing-id');
        return http.Response('ok', 200);
      });
    });

    test('reads method from context.request.method', () async {
      const interceptor = LoggingInterceptor();

      final request = http.Request(
        'POST',
        Uri.parse('https://example.com/api/v2/test'),
      );
      final context = RequestContext(request: request);

      // This test verifies that the interceptor reads from context.request
      // (i.e., no errors when accessing context.request.method)
      final response = await interceptor.intercept(context, (ctx) async {
        expect(ctx.request.method, 'POST');
        return http.Response('ok', 200);
      });

      expect(response.statusCode, 200);
    });
  });
}
