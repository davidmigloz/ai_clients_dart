import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('RetryPolicy', () {
    test('has sensible defaults', () {
      const policy = RetryPolicy.defaultPolicy;
      expect(policy.maxRetries, 3);
      expect(policy.initialDelay, const Duration(seconds: 1));
      expect(policy.maxDelay, const Duration(seconds: 60));
      expect(policy.jitter, 0.1);
    });

    test('defaultPolicy uses defaults', () {
      expect(RetryPolicy.defaultPolicy.maxRetries, 3);
    });

    test('accepts custom values', () {
      const policy = RetryPolicy(
        maxRetries: 5,
        initialDelay: Duration(milliseconds: 500),
        maxDelay: Duration(seconds: 30),
        jitter: 0.2,
      );
      expect(policy.maxRetries, 5);
      expect(policy.initialDelay, const Duration(milliseconds: 500));
      expect(policy.maxDelay, const Duration(seconds: 30));
      expect(policy.jitter, 0.2);
    });

    test('equality compares all fields', () {
      const policy1 = RetryPolicy.defaultPolicy;
      const policy2 = RetryPolicy.defaultPolicy;
      const policy3 = RetryPolicy(maxRetries: 5);
      expect(policy1, equals(policy2));
      expect(policy1, isNot(equals(policy3)));
    });
  });

  group('OpenAIConfig', () {
    test('creates with default values', () {
      const config = OpenAIConfig();

      expect(config.baseUrl, 'https://api.openai.com/v1');
      expect(config.timeout, const Duration(minutes: 10));
      expect(config.connectTimeout, const Duration(seconds: 30));
      expect(config.retryPolicy.maxRetries, 3);
      expect(config.retryPolicy.initialDelay, const Duration(seconds: 1));
      expect(config.retryPolicy.maxDelay, const Duration(seconds: 60));
      expect(config.retryPolicy.jitter, 0.1);
      expect(config.authProvider, isNull);
      expect(config.logLevel, isNull);
      expect(config.defaultHeaders, isEmpty);
    });

    test('creates with custom values', () {
      const config = OpenAIConfig(
        authProvider: ApiKeyProvider('sk-test'),
        baseUrl: 'https://custom.api.com/v1',
        timeout: Duration(seconds: 60),
        connectTimeout: Duration(seconds: 10),
        retryPolicy: RetryPolicy(
          maxRetries: 5,
          initialDelay: Duration(seconds: 2),
          maxDelay: Duration(minutes: 1),
        ),
        logLevel: Level.INFO,
        defaultHeaders: {'X-Custom': 'header'},
        apiVersion: '2024-01-01',
        organization: 'org-123',
        project: 'proj-456',
      );

      expect(config.baseUrl, 'https://custom.api.com/v1');
      expect(config.timeout, const Duration(seconds: 60));
      expect(config.connectTimeout, const Duration(seconds: 10));
      expect(config.retryPolicy.maxRetries, 5);
      expect(config.retryPolicy.initialDelay, const Duration(seconds: 2));
      expect(config.retryPolicy.maxDelay, const Duration(minutes: 1));
      expect(config.logLevel, Level.INFO);
      expect(config.defaultHeaders, {'X-Custom': 'header'});
      expect(config.apiVersion, '2024-01-01');
      expect(config.organization, 'org-123');
      expect(config.project, 'proj-456');
    });

    test('copyWith replaces specified fields', () {
      const original = OpenAIConfig(
        baseUrl: 'https://original.api.com',
        retryPolicy: RetryPolicy(maxRetries: 5),
      );

      final copy = original.copyWith(
        baseUrl: 'https://new.api.com',
        timeout: const Duration(seconds: 30),
      );

      expect(copy.baseUrl, 'https://new.api.com');
      expect(copy.timeout, const Duration(seconds: 30));
      expect(copy.retryPolicy.maxRetries, 5); // Preserved from original
    });

    test('copyWith replaces retryPolicy', () {
      const original = OpenAIConfig(retryPolicy: RetryPolicy.defaultPolicy);
      final copy = original.copyWith(
        retryPolicy: const RetryPolicy(maxRetries: 5),
      );
      expect(copy.retryPolicy.maxRetries, 5);
    });

    test('equality compares all fields', () {
      const config1 = OpenAIConfig(
        baseUrl: 'https://api.test.com',
        retryPolicy: RetryPolicy.defaultPolicy,
      );

      const config2 = OpenAIConfig(
        baseUrl: 'https://api.test.com',
        retryPolicy: RetryPolicy.defaultPolicy,
      );

      const config3 = OpenAIConfig(
        baseUrl: 'https://api.test.com',
        retryPolicy: RetryPolicy(maxRetries: 5),
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });

  group('OpenAIClient.withApiKey()', () {
    test('propagates baseUrl and defaultHeaders to config', () {
      final client = OpenAIClient.withApiKey(
        'sk-test',
        baseUrl: 'https://custom.api.com/v1',
        defaultHeaders: {'X-Custom': 'value'},
      );
      addTearDown(client.close);

      expect(client.config.baseUrl, 'https://custom.api.com/v1');
      expect(client.config.defaultHeaders, {'X-Custom': 'value'});
      expect(client.config.authProvider, isA<ApiKeyProvider>());
    });

    test('uses defaults when baseUrl and defaultHeaders are omitted', () {
      final client = OpenAIClient.withApiKey('sk-test');
      addTearDown(client.close);

      expect(client.config.baseUrl, 'https://api.openai.com/v1');
      expect(client.config.defaultHeaders, isEmpty);
    });
  });
}
