@TestOn('vm')
library;

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  group('AnthropicConfig.fromEnvironment', () {
    test('throws StateError when ANTHROPIC_API_KEY is not set', () {
      // We can't unset env vars, but we can verify the error path
      // by checking if it's set, and skip if so
      if (Platform.environment['ANTHROPIC_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('ANTHROPIC_API_KEY is set');
        return;
      }
      expect(AnthropicConfig.fromEnvironment, throwsA(isA<StateError>()));
    });

    test('error message mentions ANTHROPIC_API_KEY', () {
      if (Platform.environment['ANTHROPIC_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('ANTHROPIC_API_KEY is set');
        return;
      }
      expect(
        AnthropicConfig.fromEnvironment,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('ANTHROPIC_API_KEY'),
          ),
        ),
      );
    });

    test('creates config when ANTHROPIC_API_KEY is set', () {
      final apiKey = Platform.environment['ANTHROPIC_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('ANTHROPIC_API_KEY not set');
        return;
      }
      final config = AnthropicConfig.fromEnvironment();
      expect(config, isNotNull);
      expect(config.authProvider, isNotNull);
    });

    test('uses default base URL when ANTHROPIC_BASE_URL is not set', () {
      final apiKey = Platform.environment['ANTHROPIC_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('ANTHROPIC_API_KEY not set');
        return;
      }
      if (Platform.environment.containsKey('ANTHROPIC_BASE_URL')) {
        markTestSkipped('ANTHROPIC_BASE_URL is set');
        return;
      }
      final config = AnthropicConfig.fromEnvironment();
      expect(config.baseUrl, 'https://api.anthropic.com');
    });
  });

  group('AnthropicClient.fromEnvironment', () {
    test('throws StateError when ANTHROPIC_API_KEY is not set', () {
      if (Platform.environment['ANTHROPIC_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('ANTHROPIC_API_KEY is set');
        return;
      }
      expect(AnthropicClient.fromEnvironment, throwsA(isA<StateError>()));
    });

    test('creates client when ANTHROPIC_API_KEY is set', () {
      final apiKey = Platform.environment['ANTHROPIC_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('ANTHROPIC_API_KEY not set');
        return;
      }
      final client = AnthropicClient.fromEnvironment();
      expect(client, isNotNull);
      client.close();
    });
  });
}
