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
  });
}
