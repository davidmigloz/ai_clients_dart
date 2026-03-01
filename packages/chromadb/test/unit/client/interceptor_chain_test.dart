import 'dart:async' show unawaited;

import 'package:chromadb/src/client/interceptor_chain.dart';
import 'package:chromadb/src/interceptors/interceptor.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('InterceptorChain', () {
    group('execute()', () {
      test('runs interceptors in order', () async {
        final callOrder = <String>[];

        final chain = InterceptorChain(
          interceptors: [
            _OrderTrackingInterceptor('first', callOrder),
            _OrderTrackingInterceptor('second', callOrder),
          ],
          httpClient: _FakeHttpClient(),
        );

        final request = http.Request(
          'GET',
          Uri.parse('https://example.com/test'),
        );

        await chain.execute(request);

        expect(callOrder, ['first', 'second']);
      });

      test('creates RequestContext internally', () async {
        RequestContext? capturedContext;

        final chain = InterceptorChain(
          interceptors: [
            _ContextCapturingInterceptor((ctx) => capturedContext = ctx),
          ],
          httpClient: _FakeHttpClient(),
        );

        final request = http.Request(
          'POST',
          Uri.parse('https://example.com/api'),
        );

        await chain.execute(request);

        expect(capturedContext, isNotNull);
        expect(capturedContext!.request.method, 'POST');
        expect(capturedContext!.request.url.path, '/api');
        expect(capturedContext!.metadata, containsPair('timestamp', isNotNull));
      });

      test('calls ensureNotClosed', () {
        var ensureNotClosedCalled = false;

        final chain = InterceptorChain(
          interceptors: [],
          httpClient: _FakeHttpClient(),
          ensureNotClosed: () => ensureNotClosedCalled = true,
        );

        final request = http.Request(
          'GET',
          Uri.parse('https://example.com/test'),
        );

        unawaited(chain.execute(request));

        expect(ensureNotClosedCalled, isTrue);
      });

      test('throws when ensureNotClosed throws', () {
        final chain = InterceptorChain(
          interceptors: [],
          httpClient: _FakeHttpClient(),
          ensureNotClosed: () => throw StateError('Client is closed'),
        );

        final request = http.Request(
          'GET',
          Uri.parse('https://example.com/test'),
        );

        expect(() => chain.execute(request), throwsA(isA<StateError>()));
      });

      test('passes abortTrigger to context', () async {
        RequestContext? capturedContext;
        final abortTrigger = Future<void>.value();

        final chain = InterceptorChain(
          interceptors: [
            _ContextCapturingInterceptor((ctx) => capturedContext = ctx),
          ],
          httpClient: _FakeHttpClient(),
        );

        final request = http.Request(
          'GET',
          Uri.parse('https://example.com/test'),
        );

        await chain.execute(request, abortTrigger: abortTrigger);

        expect(capturedContext, isNotNull);
        expect(capturedContext!.abortTrigger, isNotNull);
      });
    });
  });
}

/// Interceptor that tracks the order of execution.
class _OrderTrackingInterceptor implements Interceptor {
  final String name;
  final List<String> callOrder;

  _OrderTrackingInterceptor(this.name, this.callOrder);

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) {
    callOrder.add(name);
    return next(context);
  }
}

/// Interceptor that captures the context for inspection.
class _ContextCapturingInterceptor implements Interceptor {
  final void Function(RequestContext) onCapture;

  _ContextCapturingInterceptor(this.onCapture);

  @override
  Future<http.Response> intercept(
    RequestContext context,
    InterceptorNext next,
  ) {
    onCapture(context);
    return next(context);
  }
}

/// Fake HTTP client that returns a 200 response.
class _FakeHttpClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return http.StreamedResponse(Stream.value('{"ok": true}'.codeUnits), 200);
  }
}
