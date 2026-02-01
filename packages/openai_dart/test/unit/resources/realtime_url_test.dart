import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('Realtime URL', () {
    test('buildUrl creates correct WebSocket URL from HTTPS base', () {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'https://api.openai.com/v1',
        ),
        httpClient: mockClient,
      );

      // Test that buildUrl works correctly for the realtime endpoint
      final httpUrl = client.buildUrl(
        '/realtime',
        queryParameters: {'model': 'gpt-4o-realtime-preview'},
      );

      expect(httpUrl.scheme, equals('https'));
      expect(httpUrl.host, equals('api.openai.com'));
      expect(httpUrl.path, equals('/v1/realtime'));
      expect(
        httpUrl.queryParameters['model'],
        equals('gpt-4o-realtime-preview'),
      );

      // Verify scheme conversion
      final wsUrl = httpUrl.replace(
        scheme: httpUrl.scheme == 'https' ? 'wss' : 'ws',
      );
      expect(wsUrl.scheme, equals('wss'));
      expect(wsUrl.host, equals('api.openai.com'));
      expect(wsUrl.path, equals('/v1/realtime'));
      expect(wsUrl.queryParameters['model'], equals('gpt-4o-realtime-preview'));

      client.close();
    });

    test('buildUrl handles HTTP base URL (converts to WS)', () {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl: 'http://localhost:8080/v1',
        ),
        httpClient: mockClient,
      );

      final httpUrl = client.buildUrl(
        '/realtime',
        queryParameters: {'model': 'gpt-4o-realtime-preview'},
      );

      // Verify scheme conversion for HTTP -> WS
      final wsUrl = httpUrl.replace(
        scheme: httpUrl.scheme == 'https' ? 'wss' : 'ws',
      );
      expect(wsUrl.scheme, equals('ws'));
      expect(wsUrl.host, equals('localhost'));
      expect(wsUrl.port, equals(8080));
      expect(wsUrl.path, equals('/v1/realtime'));

      client.close();
    });

    test('buildUrl handles Azure-style base URL for realtime', () {
      final mockClient = MockClient((request) async {
        return http.Response('{}', 200);
      });

      final client = OpenAIClient(
        config: const OpenAIConfig(
          authProvider: ApiKeyProvider('sk-test'),
          baseUrl:
              'https://example.openai.azure.com/openai/deployments/my-deploy?api-version=2024-10-01',
        ),
        httpClient: mockClient,
      );

      final httpUrl = client.buildUrl(
        '/realtime',
        queryParameters: {'model': 'gpt-4o-realtime-preview'},
      );

      expect(httpUrl.scheme, equals('https'));
      expect(httpUrl.host, equals('example.openai.azure.com'));
      expect(httpUrl.path, equals('/openai/deployments/my-deploy/realtime'));
      // Both base URL params and request params should be present
      expect(httpUrl.queryParameters['api-version'], equals('2024-10-01'));
      expect(
        httpUrl.queryParameters['model'],
        equals('gpt-4o-realtime-preview'),
      );

      // Verify scheme conversion
      final wsUrl = httpUrl.replace(
        scheme: httpUrl.scheme == 'https' ? 'wss' : 'ws',
      );
      expect(wsUrl.scheme, equals('wss'));

      client.close();
    });

    test('config contains all headers needed for realtime', () {
      const config = OpenAIConfig(
        authProvider: ApiKeyProvider('sk-test'),
        organization: 'test-org',
        project: 'test-project',
        apiVersion: '2024-01-01',
        defaultHeaders: {'X-Custom': 'value'},
      );

      // Verify all configuration is accessible
      expect(config.authProvider, isNotNull);
      expect(config.organization, equals('test-org'));
      expect(config.project, equals('test-project'));
      expect(config.apiVersion, equals('2024-01-01'));
      expect(config.defaultHeaders['X-Custom'], equals('value'));
    });
  });
}
