import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:anthropic_sdk_dart/src/client/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('RequestBuilder.buildUrl', () {
    test('builds URL with the default base URL', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(authProvider: ApiKeyProvider('sk-test')),
      );

      final url = builder.buildUrl('/v1/messages');

      expect(url.scheme, equals('https'));
      expect(url.host, equals('api.anthropic.com'));
      expect(url.path, equals('/v1/messages'));
      expect(url.query, isEmpty);
    });

    test('normalizes a trailing slash in the base URL (no double slash)', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.anthropic.com/',
        ),
      );

      final url = builder.buildUrl('/v1/messages');

      // Should be /v1/messages, not //v1/messages.
      expect(url.path, equals('/v1/messages'));
      expect(url.toString(), equals('https://api.anthropic.com/v1/messages'));
    });

    test('preserves a base URL sub-path and avoids a double slash', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/anthropic/',
        ),
      );

      final url = builder.buildUrl('/v1/messages');

      expect(url.path, equals('/anthropic/v1/messages'));
    });

    test('handles an endpoint path without a leading slash', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.anthropic.com/',
        ),
      );

      final url = builder.buildUrl('v1/messages');

      expect(url.path, equals('/v1/messages'));
    });

    test('merges default and per-request query params', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.anthropic.com/',
          defaultQueryParams: {'beta': 'true'},
        ),
      );

      final url = builder.buildUrl(
        '/v1/messages/batches',
        queryParams: {'limit': '20'},
      );

      expect(url.path, equals('/v1/messages/batches'));
      expect(url.queryParameters['beta'], equals('true'));
      expect(url.queryParameters['limit'], equals('20'));
    });

    test('preserves query params carried by the base URL', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/?api-version=2024',
        ),
      );

      final url = builder.buildUrl(
        '/v1/messages',
        queryParams: {'beta': 'true'},
      );

      expect(url.path, equals('/v1/messages'));
      expect(url.queryParameters['api-version'], equals('2024'));
      expect(url.queryParameters['beta'], equals('true'));
    });

    test('per-request params override base-URL params on conflict', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/?api-version=2024',
        ),
      );

      final url = builder.buildUrl(
        '/v1/messages',
        queryParams: {'api-version': '2025'},
      );

      expect(url.queryParameters['api-version'], equals('2025'));
    });

    test('handles a base URL with multiple path segments', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/api/anthropic',
        ),
      );

      final url = builder.buildUrl('/v1/messages');

      expect(url.path, equals('/api/anthropic/v1/messages'));
    });

    test('default params override base-URL params on conflict', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/?api-version=2024',
          defaultQueryParams: {'api-version': '2025'},
        ),
      );

      final url = builder.buildUrl('/v1/messages');

      expect(url.queryParameters['api-version'], equals('2025'));
    });

    test('preserves repeated query keys carried by the base URL', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/?k=a&k=b',
        ),
      );

      final url = builder.buildUrl('/v1/messages');

      expect(url.queryParametersAll['k'], equals(['a', 'b']));
      expect(url.toString(), contains('k=a&k=b'));
    });

    test('per-request params replace the whole repeated-key list', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/?k=a&k=b',
        ),
      );

      final url = builder.buildUrl('/v1/messages', queryParams: {'k': 'c'});

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('default params replace repeated base-URL keys', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/?k=a&k=b',
          defaultQueryParams: {'k': 'c'},
        ),
      );

      final url = builder.buildUrl('/v1/messages');

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('renders Iterable query param values as repeated keys', () {
      // Mirrors SessionEventsResource, which passes List<String> values for
      // `types[]` / `event_deltas[]` array params.
      const builder = RequestBuilder(
        config: AnthropicConfig(authProvider: ApiKeyProvider('sk-test')),
      );

      final url = builder.buildUrl(
        '/v1/sessions/s_123/events',
        queryParams: {
          'types[]': ['message', 'tool_use'],
        },
      );

      expect(
        url.queryParametersAll['types[]'],
        equals(['message', 'tool_use']),
      );
    });

    test('preserves a non-standard port in the base URL', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com:8443',
        ),
      );

      final url = builder.buildUrl('/v1/messages');

      expect(url.port, equals(8443));
      expect(url.path, equals('/v1/messages'));
    });

    test('preserves userInfo and fragment from the base URL', () {
      const builder = RequestBuilder(
        config: AnthropicConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://user:pass@api.example.com/base#frag',
        ),
      );

      final url = builder.buildUrl('/v1/messages');

      expect(url.userInfo, equals('user:pass'));
      expect(url.path, equals('/base/v1/messages'));
      expect(url.fragment, equals('frag'));
    });
  });
}
