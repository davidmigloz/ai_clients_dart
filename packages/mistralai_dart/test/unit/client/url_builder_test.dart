import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:mistralai_dart/src/client/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('RequestBuilder.buildUrl', () {
    test('builds URL with the default base URL', () {
      const builder = RequestBuilder(config: MistralConfig());

      final url = builder.buildUrl('/v1/chat/completions');

      expect(url.scheme, equals('https'));
      expect(url.host, equals('api.mistral.ai'));
      expect(url.path, equals('/v1/chat/completions'));
      expect(url.query, isEmpty);
    });

    test('normalizes a trailing slash in the base URL (no double slash)', () {
      const builder = RequestBuilder(
        config: MistralConfig(baseUrl: 'https://api.mistral.ai/'),
      );

      final url = builder.buildUrl('/v1/chat/completions');

      // Should be /v1/chat/completions, not //v1/chat/completions.
      expect(url.path, equals('/v1/chat/completions'));
      expect(
        url.toString(),
        equals('https://api.mistral.ai/v1/chat/completions'),
      );
    });

    test('preserves a base URL sub-path with a trailing slash', () {
      const builder = RequestBuilder(
        config: MistralConfig(baseUrl: 'https://proxy.example.com/mistral/'),
      );

      final url = builder.buildUrl('/v1/chat/completions');

      expect(url.path, equals('/mistral/v1/chat/completions'));
    });

    test('handles an endpoint path without a leading slash', () {
      const builder = RequestBuilder(
        config: MistralConfig(baseUrl: 'https://api.mistral.ai/'),
      );

      final url = builder.buildUrl('v1/chat/completions');

      expect(url.path, equals('/v1/chat/completions'));
    });

    test('handles a base URL with no path', () {
      const builder = RequestBuilder(
        config: MistralConfig(baseUrl: 'https://api.example.com'),
      );

      final url = builder.buildUrl('/v1/chat/completions');

      expect(url.path, equals('/v1/chat/completions'));
    });

    test('handles a base URL with multiple path segments', () {
      const builder = RequestBuilder(
        config: MistralConfig(baseUrl: 'https://proxy.example.com/api/v1/x'),
      );

      final url = builder.buildUrl('/v1/chat/completions');

      expect(url.path, equals('/api/v1/x/v1/chat/completions'));
    });

    test('preserves query params carried by the base URL', () {
      const builder = RequestBuilder(
        config: MistralConfig(
          baseUrl: 'https://proxy.example.com/?api-version=2024',
        ),
      );

      final url = builder.buildUrl('/v1/chat/completions');

      expect(url.path, equals('/v1/chat/completions'));
      expect(url.queryParameters['api-version'], equals('2024'));
    });

    test('merges default and per-request query params', () {
      const builder = RequestBuilder(
        config: MistralConfig(
          baseUrl: 'https://api.mistral.ai/',
          defaultQueryParams: {'beta': 'true'},
        ),
      );

      final url = builder.buildUrl('/v1/models', queryParams: {'limit': '20'});

      expect(url.path, equals('/v1/models'));
      expect(url.queryParameters['beta'], equals('true'));
      expect(url.queryParameters['limit'], equals('20'));
    });

    test('per-request params override defaults on conflict', () {
      const builder = RequestBuilder(
        config: MistralConfig(defaultQueryParams: {'limit': '10'}),
      );

      final url = builder.buildUrl('/v1/models', queryParams: {'limit': '20'});

      expect(url.queryParameters['limit'], equals('20'));
    });

    test('per-request params override base-URL params on conflict', () {
      const builder = RequestBuilder(
        config: MistralConfig(
          baseUrl: 'https://proxy.example.com/?api-version=2024',
        ),
      );

      final url = builder.buildUrl(
        '/v1/models',
        queryParams: {'api-version': '2025'},
      );

      expect(url.queryParameters['api-version'], equals('2025'));
    });

    test('default params override base-URL params on conflict', () {
      const builder = RequestBuilder(
        config: MistralConfig(
          baseUrl: 'https://proxy.example.com/?api-version=2024',
          defaultQueryParams: {'api-version': '2025'},
        ),
      );

      final url = builder.buildUrl('/v1/models');

      expect(url.queryParameters['api-version'], equals('2025'));
    });

    test('preserves repeated query keys carried by the base URL', () {
      const builder = RequestBuilder(
        config: MistralConfig(baseUrl: 'https://proxy.example.com/?k=a&k=b'),
      );

      final url = builder.buildUrl('/v1/models');

      expect(url.queryParametersAll['k'], equals(['a', 'b']));
      expect(url.toString(), contains('k=a&k=b'));
    });

    test('per-request params replace the whole repeated-key list', () {
      const builder = RequestBuilder(
        config: MistralConfig(baseUrl: 'https://proxy.example.com/?k=a&k=b'),
      );

      final url = builder.buildUrl('/v1/models', queryParams: {'k': 'c'});

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('default params replace repeated base-URL keys', () {
      const builder = RequestBuilder(
        config: MistralConfig(
          baseUrl: 'https://proxy.example.com/?k=a&k=b',
          defaultQueryParams: {'k': 'c'},
        ),
      );

      final url = builder.buildUrl('/v1/models');

      expect(url.queryParametersAll['k'], equals(['c']));
    });

    test('renders Iterable query param values as repeated keys', () {
      // Mirrors WorkflowCoreResource.listWorkflows, which passes List<String>
      // values for form/explode array params (status=a&status=b).
      const builder = RequestBuilder(config: MistralConfig());

      final url = builder.buildUrl(
        '/v1/workflows',
        queryParams: {
          'status': ['queued', 'running'],
        },
      );

      expect(url.queryParametersAll['status'], equals(['queued', 'running']));
      expect(url.toString(), contains('status=queued&status=running'));
    });

    test('preserves a non-standard port in the base URL', () {
      const builder = RequestBuilder(
        config: MistralConfig(baseUrl: 'https://api.example.com:8443'),
      );

      final url = builder.buildUrl('/v1/models');

      expect(url.port, equals(8443));
      expect(url.path, equals('/v1/models'));
    });

    test('preserves userInfo and fragment from the base URL', () {
      const builder = RequestBuilder(
        config: MistralConfig(
          baseUrl: 'https://user:pass@api.example.com/base#frag',
        ),
      );

      final url = builder.buildUrl('/v1/models');

      expect(url.userInfo, equals('user:pass'));
      expect(url.path, equals('/base/v1/models'));
      expect(url.fragment, equals('frag'));
    });
  });
}
