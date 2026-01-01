import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:http/http.dart' as http;
import 'package:test/test.dart';

void main() {
  group('AnthropicClient', () {
    test('can be created with default config', () {
      final client = AnthropicClient();

      expect(client.config, isNotNull);
      expect(client.config.baseUrl, 'https://api.anthropic.com');

      client.close();
    });

    test('can be created with custom config', () {
      final client = AnthropicClient(
        config: const AnthropicConfig(
          baseUrl: 'https://custom.anthropic.com',
          authProvider: ApiKeyProvider('test-key'),
        ),
      );

      expect(client.config.baseUrl, 'https://custom.anthropic.com');
      expect(client.config.authProvider, isA<ApiKeyProvider>());

      client.close();
    });

    test('can be created with custom HTTP client', () {
      final httpClient = http.Client();
      final client = AnthropicClient(httpClient: httpClient);

      expect(client, isNotNull);

      client.close();
      // httpClient is still usable because client didn't own it
    });

    test('exposes messages resource', () {
      final client = AnthropicClient();

      expect(client.messages, isNotNull);

      client.close();
    });

    test('exposes models resource', () {
      final client = AnthropicClient();

      expect(client.models, isNotNull);

      client.close();
    });

    test('exposes files resource', () {
      final client = AnthropicClient();

      expect(client.files, isNotNull);

      client.close();
    });

    test('exposes skills resource', () {
      final client = AnthropicClient();

      expect(client.skills, isNotNull);

      client.close();
    });

    test('exposes nested batches resource via messages', () {
      final client = AnthropicClient();

      expect(client.messages.batches, isNotNull);

      client.close();
    });

    test('exposes chain for advanced usage', () {
      final client = AnthropicClient();

      expect(client.chain, isNotNull);

      client.close();
    });

    test('exposes requestBuilder for advanced usage', () {
      final client = AnthropicClient();

      expect(client.requestBuilder, isNotNull);

      client.close();
    });

    test('exposes httpClient for streaming', () {
      final client = AnthropicClient();

      expect(client.httpClient, isNotNull);

      client.close();
    });

    test('close can be called multiple times safely', () {
      final client = AnthropicClient()..close();

      // Should not throw when called again
      expect(client.close, returnsNormally);
    });

    group('fromEnvironment', () {
      test('creates client from environment', () {
        // Note: This test relies on compile-time constants
        // In actual use, environment variables would be set
        final client = AnthropicClient.fromEnvironment();

        expect(client, isNotNull);
        expect(client.config, isNotNull);

        client.close();
      });
    });
  });
}
