import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:logging/logging.dart';
import 'package:test/test.dart';

void main() {
  group('AnthropicConfig', () {
    test('has sensible defaults', () {
      const config = AnthropicConfig();

      expect(config.baseUrl, 'https://api.anthropic.com');
      expect(config.authProvider, isNull);
      expect(config.defaultHeaders, isEmpty);
      expect(config.defaultQueryParams, isEmpty);
      expect(config.timeout, const Duration(minutes: 10));
      expect(config.apiVersion, '2023-06-01');
      expect(config.logLevel, Level.INFO);
    });

    test('accepts custom values', () {
      const config = AnthropicConfig(
        baseUrl: 'https://custom.api.com',
        authProvider: ApiKeyProvider('key'),
        defaultHeaders: {'X-Custom': 'value'},
        defaultQueryParams: {'param': 'value'},
        timeout: Duration(seconds: 30),
        apiVersion: '2024-01-01',
        logLevel: Level.WARNING,
      );

      expect(config.baseUrl, 'https://custom.api.com');
      expect(config.authProvider, isA<ApiKeyProvider>());
      expect(config.defaultHeaders['X-Custom'], 'value');
      expect(config.defaultQueryParams['param'], 'value');
      expect(config.timeout, const Duration(seconds: 30));
      expect(config.apiVersion, '2024-01-01');
      expect(config.logLevel, Level.WARNING);
    });

    test('has default redaction list', () {
      const config = AnthropicConfig();

      expect(config.redactionList, contains('x-api-key'));
      expect(config.redactionList, contains('authorization'));
      expect(config.redactionList, contains('password'));
      expect(config.redactionList, contains('secret'));
    });

    test('copyWith creates modified copy', () {
      const original = AnthropicConfig(
        baseUrl: 'https://original.com',
        timeout: Duration(seconds: 10),
      );

      final modified = original.copyWith(baseUrl: 'https://modified.com');

      expect(modified.baseUrl, 'https://modified.com');
      expect(modified.timeout, const Duration(seconds: 10)); // Unchanged
    });

    test('copyWith preserves all unchanged fields', () {
      const original = AnthropicConfig(
        baseUrl: 'https://test.com',
        authProvider: ApiKeyProvider('key'),
        defaultHeaders: {'X-Test': 'value'},
        defaultQueryParams: {'q': 'v'},
        timeout: Duration(seconds: 5),
        apiVersion: '2024-01-01',
        logLevel: Level.FINE,
        redactionList: ['custom'],
      );

      final modified = original.copyWith(baseUrl: 'https://new.com');

      expect(modified.baseUrl, 'https://new.com');
      expect(modified.authProvider, original.authProvider);
      expect(modified.defaultHeaders, original.defaultHeaders);
      expect(modified.defaultQueryParams, original.defaultQueryParams);
      expect(modified.timeout, original.timeout);
      expect(modified.apiVersion, original.apiVersion);
      expect(modified.logLevel, original.logLevel);
      expect(modified.redactionList, original.redactionList);
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

    test('defaultPolicy has expected values', () {
      const policy = RetryPolicy.defaultPolicy;

      expect(policy.maxRetries, 3);
      expect(policy.initialDelay, const Duration(seconds: 1));
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

    test('can be used in AnthropicConfig', () {
      const customPolicy = RetryPolicy(maxRetries: 5);
      const config = AnthropicConfig(retryPolicy: customPolicy);

      expect(config.retryPolicy.maxRetries, 5);
    });
  });
}
