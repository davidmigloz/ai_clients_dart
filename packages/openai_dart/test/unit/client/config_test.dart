import 'package:logging/logging.dart';
import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAIConfig', () {
    test('creates with default values', () {
      const config = OpenAIConfig();

      expect(config.baseUrl, 'https://api.openai.com/v1');
      expect(config.timeout, const Duration(minutes: 10));
      expect(config.connectTimeout, const Duration(seconds: 30));
      expect(config.maxRetries, 2);
      expect(config.retryDelay, const Duration(seconds: 1));
      expect(config.maxRetryDelay, const Duration(seconds: 30));
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
        maxRetries: 5,
        retryDelay: Duration(seconds: 2),
        maxRetryDelay: Duration(minutes: 1),
        logLevel: Level.INFO,
        defaultHeaders: {'X-Custom': 'header'},
        apiVersion: '2024-01-01',
        organization: 'org-123',
        project: 'proj-456',
      );

      expect(config.baseUrl, 'https://custom.api.com/v1');
      expect(config.timeout, const Duration(seconds: 60));
      expect(config.connectTimeout, const Duration(seconds: 10));
      expect(config.maxRetries, 5);
      expect(config.retryDelay, const Duration(seconds: 2));
      expect(config.maxRetryDelay, const Duration(minutes: 1));
      expect(config.logLevel, Level.INFO);
      expect(config.defaultHeaders, {'X-Custom': 'header'});
      expect(config.apiVersion, '2024-01-01');
      expect(config.organization, 'org-123');
      expect(config.project, 'proj-456');
    });

    test('copyWith replaces specified fields', () {
      const original = OpenAIConfig(
        baseUrl: 'https://original.api.com',
        maxRetries: 3,
      );

      final copy = original.copyWith(
        baseUrl: 'https://new.api.com',
        timeout: const Duration(seconds: 30),
      );

      expect(copy.baseUrl, 'https://new.api.com');
      expect(copy.timeout, const Duration(seconds: 30));
      expect(copy.maxRetries, 3); // Preserved from original
    });

    test('equality compares all fields', () {
      const config1 = OpenAIConfig(
        baseUrl: 'https://api.test.com',
        maxRetries: 3,
      );

      const config2 = OpenAIConfig(
        baseUrl: 'https://api.test.com',
        maxRetries: 3,
      );

      const config3 = OpenAIConfig(
        baseUrl: 'https://api.test.com',
        maxRetries: 5,
      );

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
    });
  });

  group('RetryPolicy', () {
    test('creates with default values', () {
      const policy = RetryPolicy();

      expect(policy.maxRetries, 2);
      expect(policy.initialDelay, const Duration(seconds: 1));
      expect(policy.maxDelay, const Duration(seconds: 30));
      expect(policy.backoffMultiplier, 2.0);
      expect(policy.retryOnTimeout, true);
      expect(policy.retryOnConnectionError, true);
      expect(policy.retryOn429, true);
      expect(policy.retryOn5xx, true);
    });

    test('getDelayForAttempt returns zero for attempt 0', () {
      const policy = RetryPolicy();
      expect(policy.getDelayForAttempt(0), Duration.zero);
    });

    test('getDelayForAttempt returns initial delay for first attempt', () {
      const policy = RetryPolicy(initialDelay: Duration(seconds: 2));
      expect(policy.getDelayForAttempt(1), const Duration(seconds: 2));
    });

    test('getDelayForAttempt applies exponential backoff', () {
      const policy = RetryPolicy(
        initialDelay: Duration(seconds: 1),
        backoffMultiplier: 2.0,
      );

      expect(policy.getDelayForAttempt(1), const Duration(seconds: 1));
      expect(policy.getDelayForAttempt(2), const Duration(seconds: 2));
      expect(policy.getDelayForAttempt(3), const Duration(seconds: 4));
    });

    test('getDelayForAttempt caps at maxDelay', () {
      const policy = RetryPolicy(
        initialDelay: Duration(seconds: 1),
        maxDelay: Duration(seconds: 5),
        backoffMultiplier: 10.0,
      );

      expect(policy.getDelayForAttempt(1), const Duration(seconds: 1));
      expect(policy.getDelayForAttempt(2), const Duration(seconds: 5));
      expect(policy.getDelayForAttempt(3), const Duration(seconds: 5));
    });
  });
}
