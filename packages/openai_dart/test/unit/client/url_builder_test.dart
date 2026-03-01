import 'package:openai_dart/openai_dart.dart';
import 'package:openai_dart/src/client/request_builder.dart';
import 'package:test/test.dart';

void main() {
  group('URL Builder', () {
    test('builds URL with simple base URL', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1',
        ),
      );

      final url = builder.buildUrl('/chat/completions');

      expect(url.scheme, equals('https'));
      expect(url.host, equals('api.openai.com'));
      expect(url.path, equals('/v1/chat/completions'));
      expect(url.query, isEmpty);
    });

    test('normalizes double slashes', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1/',
        ),
      );

      final url = builder.buildUrl('/chat/completions');

      expect(url.path, equals('/v1/chat/completions'));
      // Should NOT be /v1//chat/completions
    });

    test('handles endpoint without leading slash', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1',
        ),
      );

      final url = builder.buildUrl('chat/completions');

      expect(url.path, equals('/v1/chat/completions'));
    });

    test('builds URL with Azure-style base URL including query params', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://example.openai.azure.com/openai/deployments/my-deploy?api-version=2024-10-01',
        ),
      );

      final url = builder.buildUrl('/chat/completions');

      expect(url.scheme, equals('https'));
      expect(url.host, equals('example.openai.azure.com'));
      expect(
        url.path,
        equals('/openai/deployments/my-deploy/chat/completions'),
      );
      expect(url.queryParameters['api-version'], equals('2024-10-01'));
    });

    test('merges request query params with base URL params', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://example.openai.azure.com/openai?api-version=2024-10-01',
        ),
      );

      final url = builder.buildUrl(
        '/files',
        queryParams: {'purpose': 'fine-tune'},
      );

      expect(url.queryParameters['api-version'], equals('2024-10-01'));
      expect(url.queryParameters['purpose'], equals('fine-tune'));
    });

    test('request query params override base URL params on conflict', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://example.openai.azure.com/openai?api-version=2024-10-01',
        ),
      );

      final url = builder.buildUrl(
        '/files',
        queryParams: {'api-version': '2025-01-01'},
      );

      expect(url.queryParameters['api-version'], equals('2025-01-01'));
    });

    test('handles base URL with multiple path segments', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/api/v1/openai',
        ),
      );

      final url = builder.buildUrl('/models');

      expect(url.path, equals('/api/v1/openai/models'));
    });

    test('handles localhost base URL', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'http://localhost:8080/v1',
        ),
      );

      final url = builder.buildUrl('/chat/completions');

      expect(url.scheme, equals('http'));
      expect(url.host, equals('localhost'));
      expect(url.port, equals(8080));
      expect(url.path, equals('/v1/chat/completions'));
    });

    test('handles base URL with no path', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com',
        ),
      );

      final url = builder.buildUrl('/v1/chat/completions');

      expect(url.path, equals('/v1/chat/completions'));
    });

    test('handles complex Azure URL with deployment and version', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://my-resource.openai.azure.com/openai/deployments/gpt-4o-mini?api-version=2024-08-01-preview',
        ),
      );

      final url = builder.buildUrl('/chat/completions');

      expect(url.host, equals('my-resource.openai.azure.com'));
      expect(
        url.path,
        equals('/openai/deployments/gpt-4o-mini/chat/completions'),
      );
      expect(url.queryParameters['api-version'], equals('2024-08-01-preview'));
    });
  });

  group('buildUrlWithQueryAll', () {
    test('preserves userInfo from base URL', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://user:pass@api.example.com/v1',
        ),
      );

      final url = builder.buildUrlWithQueryAll('/responses');

      expect(url.userInfo, equals('user:pass'));
      expect(url.host, equals('api.example.com'));
      expect(url.path, equals('/v1/responses'));
    });

    test('preserves fragment from base URL', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com/v1#section',
        ),
      );

      final url = builder.buildUrlWithQueryAll('/responses');

      expect(url.fragment, equals('section'));
      expect(url.path, equals('/v1/responses'));
    });

    test('preserves explicit port 443 when specified', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com:443/v1',
        ),
      );

      final url = builder.buildUrlWithQueryAll('/responses');

      expect(url.port, equals(443));
      expect(url.path, equals('/v1/responses'));
    });

    test('preserves explicit port 80 when specified', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'http://api.example.com:80/v1',
        ),
      );

      final url = builder.buildUrlWithQueryAll('/responses');

      expect(url.port, equals(80));
      expect(url.path, equals('/v1/responses'));
    });

    test('preserves non-standard port', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com:8443/v1',
        ),
      );

      final url = builder.buildUrlWithQueryAll('/responses');

      expect(url.port, equals(8443));
    });

    test('preserves all URI components together', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://user:pass@api.example.com:443/v1?api-version=1#frag',
        ),
      );

      final url = builder.buildUrlWithQueryAll(
        '/responses',
        queryParametersAll: {
          'include[]': ['step_details', 'file_search_results'],
        },
      );

      expect(url.scheme, equals('https'));
      expect(url.userInfo, equals('user:pass'));
      expect(url.host, equals('api.example.com'));
      expect(url.port, equals(443));
      expect(url.path, equals('/v1/responses'));
      expect(url.queryParametersAll['api-version'], equals(['1']));
      expect(
        url.queryParametersAll['include[]'],
        equals(['step_details', 'file_search_results']),
      );
      expect(url.fragment, equals('frag'));
    });

    test('handles repeated query parameters', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1',
        ),
      );

      final url = builder.buildUrlWithQueryAll(
        '/responses/resp_123',
        queryParametersAll: {
          'include[]': ['step_details', 'file_search_results'],
        },
      );

      expect(url.path, equals('/v1/responses/resp_123'));
      expect(
        url.queryParametersAll['include[]'],
        equals(['step_details', 'file_search_results']),
      );
    });

    test('merges single-value and repeated params with base URL params', () {
      const builder = RequestBuilder(
        config: OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com/v1?api-version=2024',
        ),
      );

      final url = builder.buildUrlWithQueryAll(
        '/responses',
        queryParameters: {'limit': '10'},
        queryParametersAll: {
          'include[]': ['step_details'],
        },
      );

      expect(url.queryParametersAll['api-version'], equals(['2024']));
      expect(url.queryParametersAll['limit'], equals(['10']));
      expect(url.queryParametersAll['include[]'], equals(['step_details']));
    });
  });
}
