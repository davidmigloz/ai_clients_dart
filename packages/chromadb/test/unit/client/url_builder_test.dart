import 'package:chromadb/src/client/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('RequestBuilder.buildUrl', () {
    test('builds URL with a plain base URL', () {
      final builder = RequestBuilder(baseUrl: 'http://localhost:8000');

      final url = builder.buildUrl('/api/v2/healthcheck');

      expect(url.scheme, equals('http'));
      expect(url.host, equals('localhost'));
      expect(url.port, equals(8000));
      expect(url.path, equals('/api/v2/healthcheck'));
      expect(url.query, isEmpty);
    });

    test('normalizes a trailing slash in the base URL (no double slash)', () {
      final builder = RequestBuilder(baseUrl: 'http://localhost:8000/');

      final url = builder.buildUrl('/api/v2/healthcheck');

      expect(url.path, equals('/api/v2/healthcheck'));
      expect(
        url.toString(),
        equals('http://localhost:8000/api/v2/healthcheck'),
      );
    });

    test('preserves a base URL sub-path with a trailing slash', () {
      final builder = RequestBuilder(
        baseUrl: 'https://proxy.example.com/chroma/',
      );

      final url = builder.buildUrl('/api/v2/healthcheck');

      // Previously produced /chroma//api/v2/healthcheck.
      expect(url.path, equals('/chroma/api/v2/healthcheck'));
    });

    test('handles an endpoint path without a leading slash', () {
      final builder = RequestBuilder(baseUrl: 'http://localhost:8000/');

      final url = builder.buildUrl('api/v2/healthcheck');

      expect(url.path, equals('/api/v2/healthcheck'));
    });

    test('handles a base URL with multiple path segments', () {
      final builder = RequestBuilder(
        baseUrl: 'https://proxy.example.com/team/chroma',
      );

      final url = builder.buildUrl('/api/v2/healthcheck');

      expect(url.path, equals('/team/chroma/api/v2/healthcheck'));
    });

    test('preserves query params carried by the base URL', () {
      final builder = RequestBuilder(
        baseUrl: 'https://api.trychroma.com/?tenant=default',
      );

      final url = builder.buildUrl('/api/v2/healthcheck');

      expect(url.path, equals('/api/v2/healthcheck'));
      expect(url.queryParameters['tenant'], equals('default'));
    });

    test('preserves base-URL params when merging default params', () {
      // Regression: merging defaults/request params used to wipe the whole
      // base-URL query instead of merging into it.
      final builder = RequestBuilder(
        baseUrl: 'https://api.trychroma.com/?tenant=default',
        defaultQueryParameters: {'beta': 'true'},
      );

      final url = builder.buildUrl('/api/v2/healthcheck');

      expect(url.queryParameters['tenant'], equals('default'));
      expect(url.queryParameters['beta'], equals('true'));
    });

    test('preserves repeated base-URL keys when merging other params', () {
      final builder = RequestBuilder(
        baseUrl: 'https://proxy.example.com/?k=a&k=b',
        defaultQueryParameters: {'x': '1'},
      );

      final url = builder.buildUrl('/api/v2/collections');

      expect(url.queryParametersAll['k'], equals(['a', 'b']));
      expect(url.queryParameters['x'], equals('1'));
    });

    test('merges default and per-request query params', () {
      final builder = RequestBuilder(
        baseUrl: 'http://localhost:8000',
        defaultQueryParameters: {'beta': 'true'},
      );

      final url = builder.buildUrl(
        '/api/v2/collections',
        queryParameters: {'limit': '20'},
      );

      expect(url.queryParameters['beta'], equals('true'));
      expect(url.queryParameters['limit'], equals('20'));
    });

    test('per-request params override defaults on conflict', () {
      final builder = RequestBuilder(
        baseUrl: 'http://localhost:8000',
        defaultQueryParameters: {'limit': '10'},
      );

      final url = builder.buildUrl(
        '/api/v2/collections',
        queryParameters: {'limit': '20'},
      );

      expect(url.queryParameters['limit'], equals('20'));
    });

    test('per-request params override base-URL params on conflict', () {
      final builder = RequestBuilder(
        baseUrl: 'https://api.trychroma.com/?tenant=old',
      );

      final url = builder.buildUrl(
        '/api/v2/collections',
        queryParameters: {'tenant': 'new'},
      );

      expect(url.queryParameters['tenant'], equals('new'));
    });

    test('default params override base-URL params on conflict', () {
      final builder = RequestBuilder(
        baseUrl: 'https://api.trychroma.com/?tenant=old',
        defaultQueryParameters: {'tenant': 'new'},
      );

      final url = builder.buildUrl('/api/v2/collections');

      expect(url.queryParameters['tenant'], equals('new'));
    });

    test('preserves repeated query keys carried by the base URL', () {
      final builder = RequestBuilder(
        baseUrl: 'https://proxy.example.com/?k=a&k=b',
      );

      final url = builder.buildUrl('/api/v2/collections');

      expect(url.queryParametersAll['k'], equals(['a', 'b']));
      expect(url.toString(), contains('k=a&k=b'));
    });

    test('per-request params replace the whole repeated-key list', () {
      final builder = RequestBuilder(
        baseUrl: 'https://proxy.example.com/?k=a&k=b',
      );

      final url = builder.buildUrl(
        '/api/v2/collections',
        queryParameters: {'k': 'c'},
      );

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('default params replace repeated base-URL keys', () {
      final builder = RequestBuilder(
        baseUrl: 'https://proxy.example.com/?k=a&k=b',
        defaultQueryParameters: {'k': 'c'},
      );

      final url = builder.buildUrl('/api/v2/collections');

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('preserves a non-standard port in the base URL', () {
      final builder = RequestBuilder(
        baseUrl: 'https://chroma.example.com:8443',
      );

      final url = builder.buildUrl('/api/v2/collections');

      expect(url.port, equals(8443));
      expect(url.path, equals('/api/v2/collections'));
    });

    test('preserves userInfo and fragment from the base URL', () {
      final builder = RequestBuilder(
        baseUrl: 'https://user:pass@chroma.example.com/base#frag',
      );

      final url = builder.buildUrl('/api/v2/collections');

      expect(url.userInfo, equals('user:pass'));
      expect(url.path, equals('/base/api/v2/collections'));
      expect(url.fragment, equals('frag'));
    });
  });
}
