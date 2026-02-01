import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('URL Builder', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });
    });

    test('builds URL with simple base URL', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl('/chat/completions');

      expect(url.scheme, equals('https'));
      expect(url.host, equals('api.openai.com'));
      expect(url.path, equals('/v1/chat/completions'));
      expect(url.query, isEmpty);

      client.close();
    });

    test('normalizes double slashes', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1/',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl('/chat/completions');

      expect(url.path, equals('/v1/chat/completions'));
      // Should NOT be /v1//chat/completions

      client.close();
    });

    test('handles endpoint without leading slash', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl('chat/completions');

      expect(url.path, equals('/v1/chat/completions'));

      client.close();
    });

    test('builds URL with Azure-style base URL including query params', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://example.openai.azure.com/openai/deployments/my-deploy?api-version=2024-10-01',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl('/chat/completions');

      expect(url.scheme, equals('https'));
      expect(url.host, equals('example.openai.azure.com'));
      expect(
        url.path,
        equals('/openai/deployments/my-deploy/chat/completions'),
      );
      expect(url.queryParameters['api-version'], equals('2024-10-01'));

      client.close();
    });

    test('merges request query params with base URL params', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://example.openai.azure.com/openai?api-version=2024-10-01',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl(
        '/files',
        queryParameters: {'purpose': 'fine-tune'},
      );

      expect(url.queryParameters['api-version'], equals('2024-10-01'));
      expect(url.queryParameters['purpose'], equals('fine-tune'));

      client.close();
    });

    test('request query params override base URL params on conflict', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://example.openai.azure.com/openai?api-version=2024-10-01',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl(
        '/files',
        queryParameters: {'api-version': '2025-01-01'},
      );

      expect(url.queryParameters['api-version'], equals('2025-01-01'));

      client.close();
    });

    test('handles base URL with multiple path segments', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://proxy.example.com/api/v1/openai',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl('/models');

      expect(url.path, equals('/api/v1/openai/models'));

      client.close();
    });

    test('handles localhost base URL', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'http://localhost:8080/v1',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl('/chat/completions');

      expect(url.scheme, equals('http'));
      expect(url.host, equals('localhost'));
      expect(url.port, equals(8080));
      expect(url.path, equals('/v1/chat/completions'));

      client.close();
    });

    test('handles base URL with no path', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl('/v1/chat/completions');

      expect(url.path, equals('/v1/chat/completions'));

      client.close();
    });

    test('handles complex Azure URL with deployment and version', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://my-resource.openai.azure.com/openai/deployments/gpt-4o-mini?api-version=2024-08-01-preview',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrl('/chat/completions');

      expect(url.host, equals('my-resource.openai.azure.com'));
      expect(
        url.path,
        equals('/openai/deployments/gpt-4o-mini/chat/completions'),
      );
      expect(url.queryParameters['api-version'], equals('2024-08-01-preview'));

      client.close();
    });
  });

  group('buildUrlWithQueryAll', () {
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });
    });

    test('preserves userInfo from base URL', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://user:pass@api.example.com/v1',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrlWithQueryAll('/responses');

      expect(url.userInfo, equals('user:pass'));
      expect(url.host, equals('api.example.com'));
      expect(url.path, equals('/v1/responses'));

      client.close();
    });

    test('preserves fragment from base URL', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com/v1#section',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrlWithQueryAll('/responses');

      expect(url.fragment, equals('section'));
      expect(url.path, equals('/v1/responses'));

      client.close();
    });

    test('preserves explicit port 443 when specified', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com:443/v1',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrlWithQueryAll('/responses');

      expect(url.port, equals(443));
      expect(url.path, equals('/v1/responses'));

      client.close();
    });

    test('preserves explicit port 80 when specified', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'http://api.example.com:80/v1',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrlWithQueryAll('/responses');

      expect(url.port, equals(80));
      expect(url.path, equals('/v1/responses'));

      client.close();
    });

    test('preserves non-standard port', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com:8443/v1',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrlWithQueryAll('/responses');

      expect(url.port, equals(8443));

      client.close();
    });

    test('preserves all URI components together', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://user:pass@api.example.com:443/v1?api-version=1#frag',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrlWithQueryAll(
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

      client.close();
    });

    test('handles repeated query parameters', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrlWithQueryAll(
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

      client.close();
    });

    test('merges single-value and repeated params with base URL params', () {
      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.example.com/v1?api-version=2024',
        ),
        httpClient: mockClient,
      );

      final url = client.buildUrlWithQueryAll(
        '/responses',
        queryParameters: {'limit': '10'},
        queryParametersAll: {
          'include[]': ['step_details'],
        },
      );

      expect(url.queryParametersAll['api-version'], equals(['2024']));
      expect(url.queryParametersAll['limit'], equals(['10']));
      expect(url.queryParametersAll['include[]'], equals(['step_details']));

      client.close();
    });
  });
}
