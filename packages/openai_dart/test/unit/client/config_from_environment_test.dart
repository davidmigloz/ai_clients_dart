@TestOn('vm')
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('OpenAIConfig.fromEnvironment', () {
    test('throws StateError when OPENAI_API_KEY is not set', () {
      // Use ApiKeyProvider.fromEnvironment with a fake var name
      // Config.fromEnvironment delegates to ApiKeyProvider.fromEnvironment
      expect(
        OpenAIConfig.fromEnvironment,
        // Only throws if OPENAI_API_KEY is not actually set
        Platform.environment['OPENAI_API_KEY']?.isNotEmpty ?? false
            ? returnsNormally
            : throwsA(isA<StateError>()),
      );
    });

    test('error message mentions OPENAI_API_KEY', () {
      if (Platform.environment['OPENAI_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('OPENAI_API_KEY is set');
        return;
      }
      expect(
        OpenAIConfig.fromEnvironment,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('OPENAI_API_KEY'),
          ),
        ),
      );
    });

    test('creates config when OPENAI_API_KEY is set', () {
      final apiKey = Platform.environment['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('OPENAI_API_KEY not set');
        return;
      }
      final config = OpenAIConfig.fromEnvironment();
      expect(config, isNotNull);
      expect(config.authProvider, isNotNull);
    });

    test('uses default base URL when OPENAI_BASE_URL is not set', () {
      final apiKey = Platform.environment['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('OPENAI_API_KEY not set');
        return;
      }
      if (Platform.environment.containsKey('OPENAI_BASE_URL')) {
        markTestSkipped('OPENAI_BASE_URL is set');
        return;
      }
      final config = OpenAIConfig.fromEnvironment();
      expect(config.baseUrl, 'https://api.openai.com/v1');
    });
  });

  group('OpenAIClient.fromEnvironment', () {
    test('throws StateError when OPENAI_API_KEY is not set', () {
      if (Platform.environment['OPENAI_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('OPENAI_API_KEY is set');
        return;
      }
      expect(OpenAIClient.fromEnvironment, throwsA(isA<StateError>()));
    });

    test('creates client when OPENAI_API_KEY is set', () {
      final apiKey = Platform.environment['OPENAI_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('OPENAI_API_KEY not set');
        return;
      }
      final client = OpenAIClient.fromEnvironment();
      expect(client, isNotNull);
      client.close();
    });
  });
}
