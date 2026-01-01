// ignore_for_file: avoid_print
@Tags(['integration'])
library;

import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:test/test.dart';

void main() {
  String? apiKey;
  AnthropicClient? client;

  setUpAll(() {
    apiKey = Platform.environment['ANTHROPIC_API_KEY'];
    if (apiKey == null || apiKey!.isEmpty) {
      print('ANTHROPIC_API_KEY not set. Integration tests will be skipped.');
    } else {
      client = AnthropicClient(
        config: AnthropicConfig(authProvider: ApiKeyProvider(apiKey!)),
      );
    }
  });

  tearDownAll(() {
    client?.close();
  });

  group('Models API - Integration', () {
    test(
      'lists available models',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.models.list();

        expect(response.data, isNotEmpty);
        expect(response.hasMore, isA<bool>());

        // Verify each model has required fields
        for (final model in response.data) {
          expect(model.id, isNotEmpty);
          expect(model.displayName, isNotEmpty);
          expect(model.createdAt, isA<DateTime>());
        }

        // Should contain at least one Claude model
        final hasClaudeModel = response.data.any(
          (m) => m.id.contains('claude'),
        );
        expect(hasClaudeModel, isTrue);
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

        const modelId = 'claude-3-5-haiku-20241022';
        final response = await client!.models.retrieve(modelId);

        expect(response.id, modelId);
        expect(response.displayName, isNotEmpty);
        expect(response.createdAt, isA<DateTime>());
      },
    );

    test(
      'lists models with pagination',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        // Request a limited number of models
        final response = await client!.models.list(limit: 2);

        expect(response.data.length, lessThanOrEqualTo(2));
        expect(response.firstId, isNotNull);
        expect(response.lastId, isNotNull);

        // If there are more models, we can paginate
        if (response.hasMore) {
          final nextPage = await client!.models.list(
            limit: 2,
            afterId: response.lastId,
          );
          expect(nextPage.data, isNotEmpty);
        }
      },
    );
  });
}
