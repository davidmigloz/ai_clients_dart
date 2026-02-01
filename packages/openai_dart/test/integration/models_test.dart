// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:openai_dart/openai_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  OpenAIClient? client;

  setUpAll(() {
    apiKey = Platform.environment['OPENAI_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('OPENAI_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = OpenAIClient(
        config: OpenAIConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Models - Integration', () {
    test(
      'lists available models',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.models.list();

        expect(response.object, 'list');
        expect(response.data, isNotEmpty);

        // Check that some well-known models are present
        final modelIds = response.data.map((m) => m.id).toList();
        expect(modelIds, anyElement(contains('gpt')));
      },
    );

    test(
      'retrieves a specific model',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final model = await client!.models.retrieve('gpt-4o-mini');

        expect(model.id, 'gpt-4o-mini');
        expect(model.object, 'model');
        expect(model.ownedBy, isNotEmpty);
        expect(model.created, greaterThan(0));
      },
    );

    test(
      'throws NotFoundException for non-existent model',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        await expectLater(
          () => client!.models.retrieve('non-existent-model-xyz'),
          throwsA(isA<NotFoundException>()),
        );
      },
    );
  });
}
