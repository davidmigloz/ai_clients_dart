@TestOn('vm')
library;

import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

void main() {
  group('MistralConfig.fromEnvironment', () {
    test('throws StateError when MISTRAL_API_KEY is not set', () {
      if (Platform.environment['MISTRAL_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('MISTRAL_API_KEY is set');
        return;
      }
      expect(MistralConfig.fromEnvironment, throwsA(isA<StateError>()));
    });

    test('error message mentions MISTRAL_API_KEY', () {
      if (Platform.environment['MISTRAL_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('MISTRAL_API_KEY is set');
        return;
      }
      expect(
        MistralConfig.fromEnvironment,
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('MISTRAL_API_KEY'),
          ),
        ),
      );
    });

    test('creates config when MISTRAL_API_KEY is set', () {
      final apiKey = Platform.environment['MISTRAL_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('MISTRAL_API_KEY not set');
        return;
      }
      final config = MistralConfig.fromEnvironment();
      expect(config, isNotNull);
      expect(config.authProvider, isNotNull);
    });

    test('uses default base URL when MISTRAL_BASE_URL is not set', () {
      final apiKey = Platform.environment['MISTRAL_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('MISTRAL_API_KEY not set');
        return;
      }
      if (Platform.environment.containsKey('MISTRAL_BASE_URL')) {
        markTestSkipped('MISTRAL_BASE_URL is set');
        return;
      }
      final config = MistralConfig.fromEnvironment();
      expect(config.baseUrl, 'https://api.mistral.ai');
    });
  });

  group('MistralClient.fromEnvironment', () {
    test('throws StateError when MISTRAL_API_KEY is not set', () {
      if (Platform.environment['MISTRAL_API_KEY']?.isNotEmpty ?? false) {
        markTestSkipped('MISTRAL_API_KEY is set');
        return;
      }
      expect(MistralClient.fromEnvironment, throwsA(isA<StateError>()));
    });

    test('creates client when MISTRAL_API_KEY is set', () {
      final apiKey = Platform.environment['MISTRAL_API_KEY'];
      if (apiKey == null || apiKey.isEmpty) {
        markTestSkipped('MISTRAL_API_KEY not set');
        return;
      }
      final client = MistralClient.fromEnvironment();
      expect(client, isNotNull);
      client.close();
    });
  });
}
