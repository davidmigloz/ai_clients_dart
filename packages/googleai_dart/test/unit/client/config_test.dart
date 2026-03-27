import 'package:googleai_dart/googleai_dart.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('GoogleAIConfig', () {
    test('creates with defaults', () {
      const config = GoogleAIConfig();

      expect(config.baseUrl, 'https://generativelanguage.googleapis.com');
      expect(config.authProvider, isNull);
      expect(config.timeout, const Duration(minutes: 2));
      expect(config.logLevel, Level.INFO);
    });

    test('creates with custom values', () {
      const config = GoogleAIConfig(
        authProvider: ApiKeyProvider(
          'test-key',
          placement: AuthPlacement.header,
        ),
        timeout: Duration(seconds: 30),
      );

      expect(config.authProvider, isA<ApiKeyProvider>());
      expect(config.timeout, const Duration(seconds: 30));
    });

    test('copyWith overrides values', () {
      const original = GoogleAIConfig(authProvider: ApiKeyProvider('key1'));
      const updated = GoogleAIConfig(authProvider: ApiKeyProvider('key2'));

      expect(original.authProvider, isA<ApiKeyProvider>());
      expect(updated.authProvider, isA<ApiKeyProvider>());
      expect(updated.baseUrl, original.baseUrl);
    });

    test('copyWith preserves unmodified values', () {
      const original = GoogleAIConfig(
        authProvider: ApiKeyProvider('key1'),
        timeout: Duration(seconds: 45),
      );
      final updated = original.copyWith(
        authProvider: const ApiKeyProvider('key2'),
      );

      expect(updated.timeout, const Duration(seconds: 45));
    });

    test(
      'copyWith recalculates baseUrl when location changes on Vertex AI',
      () {
        final original = GoogleAIConfig.vertexAI(
          projectId: 'test-project',
          location: 'us-central1',
          authProvider: const ApiKeyProvider('test-key'),
        );
        expect(
          original.baseUrl,
          'https://us-central1-aiplatform.googleapis.com',
        );

        final updated = original.copyWith(location: 'global');
        expect(updated.baseUrl, 'https://aiplatform.googleapis.com');
        expect(updated.location, 'global');

        final regional = original.copyWith(location: 'europe-west1');
        expect(
          regional.baseUrl,
          'https://europe-west1-aiplatform.googleapis.com',
        );
      },
    );

    test('copyWith preserves explicit baseUrl even when location changes', () {
      final original = GoogleAIConfig.vertexAI(
        projectId: 'test-project',
        location: 'us-central1',
        authProvider: const ApiKeyProvider('test-key'),
      );

      final updated = original.copyWith(
        baseUrl: 'https://custom.endpoint.com',
        location: 'global',
      );
      expect(updated.baseUrl, 'https://custom.endpoint.com');
      expect(updated.location, 'global');
    });
  });

  group('GoogleAIConfig.vertexAI', () {
    test('global location uses aiplatform.googleapis.com', () {
      final config = GoogleAIConfig.vertexAI(
        projectId: 'test-project',
        location: 'global',
        authProvider: const ApiKeyProvider('test-key'),
      );
      expect(config.baseUrl, 'https://aiplatform.googleapis.com');
      expect(config.location, 'global');
    });

    test('default location is us-central1', () {
      final config = GoogleAIConfig.vertexAI(
        projectId: 'test-project',
        authProvider: const ApiKeyProvider('test-key'),
      );
      expect(config.baseUrl, 'https://us-central1-aiplatform.googleapis.com');
      expect(config.location, 'us-central1');
    });

    test('regional location uses location-prefixed host', () {
      final config = GoogleAIConfig.vertexAI(
        projectId: 'test-project',
        location: 'europe-west1',
        authProvider: const ApiKeyProvider('test-key'),
      );
      expect(config.baseUrl, 'https://europe-west1-aiplatform.googleapis.com');
    });
  });

  group('GoogleAIConfig.vertexAIHost', () {
    test('global returns bare host', () {
      expect(
        GoogleAIConfig.vertexAIHost('global'),
        'aiplatform.googleapis.com',
      );
    });

    test('regional location returns prefixed host', () {
      expect(
        GoogleAIConfig.vertexAIHost('us-central1'),
        'us-central1-aiplatform.googleapis.com',
      );
    });
  });

  group('GoogleAIConfig.vertexAIBaseUrl', () {
    test('global returns URL without location prefix', () {
      expect(
        GoogleAIConfig.vertexAIBaseUrl('global'),
        'https://aiplatform.googleapis.com',
      );
    });

    test('regional location returns URL with location prefix', () {
      expect(
        GoogleAIConfig.vertexAIBaseUrl('us-central1'),
        'https://us-central1-aiplatform.googleapis.com',
      );
    });
  });

  group('RetryPolicy', () {
    test('has sensible defaults', () {
      const policy = RetryPolicy.defaultPolicy;

      expect(policy.maxRetries, 3);
      expect(policy.initialDelay, const Duration(seconds: 1));
      expect(policy.maxDelay, const Duration(seconds: 60));
      expect(policy.jitter, 0.1);
    });
  });

  group('GoogleAIClient.withApiKey()', () {
    test('propagates baseUrl and defaultHeaders to config', () {
      final client = GoogleAIClient.withApiKey(
        'test-key',
        baseUrl: 'https://custom.api.com',
        defaultHeaders: {'X-Custom': 'value'},
      );
      addTearDown(client.close);

      expect(client.config.baseUrl, 'https://custom.api.com');
      expect(client.config.defaultHeaders, {'X-Custom': 'value'});
      expect(client.config.authProvider, isA<ApiKeyProvider>());
    });

    test('uses defaults when baseUrl and defaultHeaders are omitted', () {
      final client = GoogleAIClient.withApiKey('test-key');
      addTearDown(client.close);

      expect(
        client.config.baseUrl,
        'https://generativelanguage.googleapis.com',
      );
      expect(client.config.defaultHeaders, isEmpty);
    });
  });
}
