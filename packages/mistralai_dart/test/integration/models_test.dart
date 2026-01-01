// ignore_for_file: avoid_print

import 'dart:io';
import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

/// Integration tests for models API.
///
/// These tests require a real API key set in the MISTRAL_API_KEY
/// environment variable. If the key is not present, all tests are skipped.
void main() {
  String? apiKey;
  MistralClient? client;

  setUpAll(() {
    apiKey = Platform.environment[apiKeyEnvVar];
    if (apiKey == null || apiKey!.isEmpty) {
      print(
        '⚠️  $apiKeyEnvVar not set. Integration tests will be skipped.\n'
        '   To run these tests, export $apiKeyEnvVar=your_api_key',
      );
    } else {
      client = MistralClient.withApiKey(apiKey!);
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Models - Integration', () {
    test('lists available models', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final models = await client!.models.list();

      expect(models, isNotNull);
      expect(models.data, isNotEmpty);

      // Should include common models
      final modelIds = models.data.map((m) => m.id).toList();
      expect(
        modelIds.any((id) => id.contains('mistral')),
        isTrue,
        reason: 'Should include Mistral models',
      );
    });

    test('retrieves a specific model', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final model = await client!.models.get(defaultChatModel);

      expect(model, isNotNull);
      expect(model.id, contains('mistral'));
    });
  });
}
