import 'package:open_responses/open_responses.dart';
import 'package:open_responses/src/client/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('RequestBuilder.buildUrl', () {
    test('builds URL with the default base URL (base path preserved)', () {
      const builder = RequestBuilder(config: OpenResponsesConfig());

      final url = builder.buildUrl('/responses');

      expect(url.scheme, equals('https'));
      expect(url.host, equals('api.openai.com'));
      expect(url.path, equals('/v1/responses'));
      expect(url.query, isEmpty);
    });

    test('normalizes a trailing slash in the base URL (no double slash)', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(baseUrl: 'https://api.openai.com/v1/'),
      );

      final url = builder.buildUrl('/responses');

      // Should be /v1/responses, not /v1//responses.
      expect(url.path, equals('/v1/responses'));
      expect(url.toString(), equals('https://api.openai.com/v1/responses'));
    });

    test('preserves an alternate local base URL with port', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(baseUrl: 'http://localhost:11434/v1'),
      );

      final url = builder.buildUrl('/responses');

      expect(url.scheme, equals('http'));
      expect(url.port, equals(11434));
      expect(url.path, equals('/v1/responses'));
    });

    test('handles an endpoint path without a leading slash', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(baseUrl: 'https://api.openai.com/v1/'),
      );

      final url = builder.buildUrl('responses');

      expect(url.path, equals('/v1/responses'));
    });

    test('handles a base URL with no path', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(baseUrl: 'https://api.example.com'),
      );

      final url = builder.buildUrl('/responses');

      expect(url.path, equals('/responses'));
    });

    test('handles a base URL with multiple path segments', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://proxy.example.com/openai/v1',
        ),
      );

      final url = builder.buildUrl('/responses');

      expect(url.path, equals('/openai/v1/responses'));
    });

    test('preserves query params carried by the base URL', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://proxy.example.com/v1?api-version=2024',
        ),
      );

      final url = builder.buildUrl('/responses');

      expect(url.path, equals('/v1/responses'));
      expect(url.queryParameters['api-version'], equals('2024'));
    });

    test('merges default and per-request query params', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://api.openai.com/v1/',
          defaultQueryParams: {'beta': 'true'},
        ),
      );

      final url = builder.buildUrl('/responses', queryParams: {'limit': '20'});

      expect(url.path, equals('/v1/responses'));
      expect(url.queryParameters['beta'], equals('true'));
      expect(url.queryParameters['limit'], equals('20'));
    });

    test('per-request params override defaults on conflict', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(defaultQueryParams: {'limit': '10'}),
      );

      final url = builder.buildUrl('/responses', queryParams: {'limit': '20'});

      expect(url.queryParameters['limit'], equals('20'));
    });

    test('per-request params override base-URL params on conflict', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://proxy.example.com/v1?api-version=2024',
        ),
      );

      final url = builder.buildUrl(
        '/responses',
        queryParams: {'api-version': '2025'},
      );

      expect(url.queryParameters['api-version'], equals('2025'));
    });

    test('default params override base-URL params on conflict', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://proxy.example.com/v1?api-version=2024',
          defaultQueryParams: {'api-version': '2025'},
        ),
      );

      final url = builder.buildUrl('/responses');

      expect(url.queryParameters['api-version'], equals('2025'));
    });

    test('preserves repeated query keys carried by the base URL', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://proxy.example.com/v1?k=a&k=b',
        ),
      );

      final url = builder.buildUrl('/responses');

      expect(url.queryParametersAll['k'], equals(['a', 'b']));
      expect(url.toString(), contains('k=a&k=b'));
    });

    test('per-request params replace the whole repeated-key list', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://proxy.example.com/v1?k=a&k=b',
        ),
      );

      final url = builder.buildUrl('/responses', queryParams: {'k': 'c'});

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('default params replace repeated base-URL keys', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://proxy.example.com/v1?k=a&k=b',
          defaultQueryParams: {'k': 'c'},
        ),
      );

      final url = builder.buildUrl('/responses');

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('renders Iterable query param values as repeated keys', () {
      const builder = RequestBuilder(config: OpenResponsesConfig());

      final url = builder.buildUrl(
        '/responses',
        queryParams: {
          'include': ['a', 'b'],
        },
      );

      expect(url.queryParametersAll['include'], equals(['a', 'b']));
      expect(url.toString(), contains('include=a&include=b'));
    });

    test('preserves a non-standard port in the base URL', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(baseUrl: 'https://api.example.com:8443/v1'),
      );

      final url = builder.buildUrl('/responses');

      expect(url.port, equals(8443));
      expect(url.path, equals('/v1/responses'));
    });

    test('preserves userInfo and fragment from the base URL', () {
      const builder = RequestBuilder(
        config: OpenResponsesConfig(
          baseUrl: 'https://user:pass@api.example.com/v1#frag',
        ),
      );

      final url = builder.buildUrl('/responses');

      expect(url.userInfo, equals('user:pass'));
      expect(url.path, equals('/v1/responses'));
      expect(url.fragment, equals('frag'));
    });
  });
}
