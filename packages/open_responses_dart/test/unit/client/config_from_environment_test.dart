@TestOn('vm')
library;

import 'dart:io';

import 'package:open_responses_dart/open_responses_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OpenResponsesConfig.fromEnvironment', () {
    test('creates config without auth when OPENAI_API_KEY is not set', () {
      if (Platform.environment['OPENAI_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('OPENAI_API_KEY is set');
        return;
      }
      // Should NOT throw - API key is optional
      final config = OpenResponsesConfig.fromEnvironment();
      expect(config, isNotNull);
    });

    test(
      'creates config with BearerTokenProvider when OPENAI_API_KEY is set',
      () {
        final apiKey = Platform.environment['OPENAI_API_KEY'];
        if (apiKey == null || apiKey.isEmpty) {
          markTestSkipped('OPENAI_API_KEY not set');
          return;
        }
        final config = OpenResponsesConfig.fromEnvironment();
        expect(config.authProvider, isNotNull);
        expect(config.authProvider, isA<BearerTokenProvider>());
      },
    );

    test('uses default base URL when OPENAI_BASE_URL is not set', () {
      if (Platform.environment.containsKey('OPENAI_BASE_URL')) {
        markTestSkipped('OPENAI_BASE_URL is set');
        return;
      }
      final config = OpenResponsesConfig.fromEnvironment();
      expect(config.baseUrl, 'https://api.openai.com/v1');
    });

    test('authProvider is null when OPENAI_API_KEY is not set', () {
      if (Platform.environment['OPENAI_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('OPENAI_API_KEY is set');
        return;
      }
      final config = OpenResponsesConfig.fromEnvironment();
      expect(config.authProvider, isNull);
    });
  });

  group('OpenResponsesClient.fromEnvironment', () {
    test('creates client without auth when no env vars are set', () {
      if (Platform.environment['OPENAI_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('OPENAI_API_KEY is set');
        return;
      }
      // Should NOT throw
      final client = OpenResponsesClient.fromEnvironment();
      expect(client, isNotNull);
      client.close();
    });

    test('creates client when OPENAI_API_KEY is set', () {
      final apiKey = Platform.environment['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('OPENAI_API_KEY not set');
        return;
      }
      final client = OpenResponsesClient.fromEnvironment();
      expect(client, isNotNull);
      client.close();
    });
  });
}
