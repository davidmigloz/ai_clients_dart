import 'package:chromadb/chromadb.dart';
import 'package:test/test.dart';

void main() {
  group('ChromaConfig', () {
    test('creates config with default values', () {
      const config = ChromaConfig();

      expect(config.baseUrl, 'http://localhost:8000');
      expect(config.tenant, 'default_tenant');
      expect(config.database, 'default_database');
      expect(config.defaultHeaders, isEmpty);
    });

    test('creates config with custom headers', () {
      const config = ChromaConfig(defaultHeaders: {'X-Custom': 'value'});

      expect(config.defaultHeaders, {'X-Custom': 'value'});
    });

    test('creates config with multiple custom headers', () {
      const config = ChromaConfig(
        defaultHeaders: {
          'X-Custom-Header': 'value1',
          'X-Correlation-ID': 'request-123',
        },
      );

      expect(config.defaultHeaders, {
        'X-Custom-Header': 'value1',
        'X-Correlation-ID': 'request-123',
      });
    });

    test('copyWith preserves defaultHeaders when not specified', () {
      const original = ChromaConfig(defaultHeaders: {'X-Custom': 'value'});

      final copied = original.copyWith(baseUrl: 'http://other:8000');

      expect(copied.defaultHeaders, {'X-Custom': 'value'});
      expect(copied.baseUrl, 'http://other:8000');
    });

    test('copyWith updates defaultHeaders when specified', () {
      const original = ChromaConfig(defaultHeaders: {'X-Old': 'old'});

      final copied = original.copyWith(defaultHeaders: {'X-New': 'new'});

      expect(copied.defaultHeaders, {'X-New': 'new'});
    });

    test('copyWith can set defaultHeaders to empty map', () {
      const original = ChromaConfig(defaultHeaders: {'X-Custom': 'value'});

      final copied = original.copyWith(defaultHeaders: {});

      expect(copied.defaultHeaders, isEmpty);
    });

    test('copyWith preserves all other fields', () {
      const original = ChromaConfig(
        baseUrl: 'http://custom:9000',
        tenant: 'my-tenant',
        database: 'my-database',
        authProvider: NoAuthProvider(),
        timeout: Duration(minutes: 2),
        defaultHeaders: {'X-Custom': 'value'},
      );

      final copied = original.copyWith(defaultHeaders: {'X-New': 'new'});

      expect(copied.baseUrl, 'http://custom:9000');
      expect(copied.tenant, 'my-tenant');
      expect(copied.database, 'my-database');
      expect(copied.timeout, const Duration(minutes: 2));
      expect(copied.defaultHeaders, {'X-New': 'new'});
    });
  });

  group('ChromaClient.local()', () {
    test('accepts defaultHeaders parameter', () {
      final client = ChromaClient.local(defaultHeaders: {'X-Custom': 'value'});
      addTearDown(client.close);

      expect(client.config.defaultHeaders, {'X-Custom': 'value'});
    });

    test('uses empty headers by default', () {
      final client = ChromaClient.local();
      addTearDown(client.close);

      expect(client.config.defaultHeaders, isEmpty);
    });
  });

  group('ChromaClient.withApiKey()', () {
    test('accepts defaultHeaders parameter', () {
      final client = ChromaClient.withApiKey(
        'test-api-key',
        defaultHeaders: {'X-Custom': 'value'},
      );
      addTearDown(client.close);

      expect(client.config.defaultHeaders, {'X-Custom': 'value'});
      expect(client.config.authProvider, isA<ApiKeyProvider>());
    });

    test('uses empty headers by default', () {
      final client = ChromaClient.withApiKey('test-api-key');
      addTearDown(client.close);

      expect(client.config.defaultHeaders, isEmpty);
    });

    test('combines custom headers with api key authentication', () {
      final client = ChromaClient.withApiKey(
        'test-api-key',
        baseUrl: 'https://api.trychroma.com',
        tenant: 'my-tenant',
        database: 'my-database',
        defaultHeaders: {'X-Request-Source': 'my-app'},
      );
      addTearDown(client.close);

      expect(client.config.baseUrl, 'https://api.trychroma.com');
      expect(client.config.tenant, 'my-tenant');
      expect(client.config.database, 'my-database');
      expect(client.config.defaultHeaders, {'X-Request-Source': 'my-app'});
      expect(client.config.authProvider, isA<ApiKeyProvider>());
    });
  });
}
