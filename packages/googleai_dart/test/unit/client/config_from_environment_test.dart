@TestOn('vm')
library;

import 'dart:io';

import 'package:googleai_dart/googleai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('GoogleAIConfig.fromEnvironment', () {
    test('throws StateError when env var is not set', () {
      expect(
        () => GoogleAIConfig.fromEnvironment(
          envVarName: 'DEFINITELY_NOT_SET_12345',
        ),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('DEFINITELY_NOT_SET_12345 is not set'),
          ),
        ),
      );
    });

    test('error message mentions custom env var name', () {
      const customEnvVar = 'MY_CUSTOM_API_KEY_12345';
      expect(
        () => GoogleAIConfig.fromEnvironment(envVarName: customEnvVar),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            allOf(contains(customEnvVar), contains('not set')),
          ),
        ),
      );
    });

    test('creates config when env var is set', () {
      final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('GOOGLE_GENAI_API_KEY not set');
        return;
      }
      final config = GoogleAIConfig.fromEnvironment();
      expect(config, isNotNull);
      expect(config.authProvider, isNotNull);
    });

    test('passes through apiVersion parameter', () {
      final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('GOOGLE_GENAI_API_KEY not set');
        return;
      }
      final config = GoogleAIConfig.fromEnvironment(apiVersion: ApiVersion.v1);
      expect(config.apiVersion, ApiVersion.v1);
    });

    test('passes through timeout parameter', () {
      final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('GOOGLE_GENAI_API_KEY not set');
        return;
      }
      final config = GoogleAIConfig.fromEnvironment(
        timeout: const Duration(seconds: 30),
      );
      expect(config.timeout, const Duration(seconds: 30));
    });

    test('passes through retryPolicy parameter', () {
      final apiKey = Platform.environment['GOOGLE_GENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('GOOGLE_GENAI_API_KEY not set');
        return;
      }
      const customPolicy = RetryPolicy(maxRetries: 5);
      final config = GoogleAIConfig.fromEnvironment(retryPolicy: customPolicy);
      expect(config.retryPolicy.maxRetries, 5);
    });
  });
}
