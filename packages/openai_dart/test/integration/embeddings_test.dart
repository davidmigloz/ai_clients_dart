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

  group('Embeddings - Integration', () {
    test(
      'creates embedding for single text',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.embeddings.create(
          EmbeddingRequest(
            model: 'text-embedding-3-small',
            input: EmbeddingInput.text('Hello, world!'),
          ),
        );

        expect(response.object, 'list');
        expect(response.model, contains('text-embedding-3-small'));
        expect(response.data, hasLength(1));
        expect(response.data.first.index, 0);
        expect(response.data.first.embedding, isNotEmpty);
        // text-embedding-3-small has 1536 dimensions by default
        expect(response.data.first.embedding.length, 1536);
        expect(response.usage!.promptTokens, greaterThan(0));
        expect(response.usage!.totalTokens, greaterThan(0));
      },
    );

    test(
      'creates embeddings for multiple texts',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.embeddings.create(
          EmbeddingRequest(
            model: 'text-embedding-3-small',
            input: EmbeddingInput.textList([
              'First text',
              'Second text',
              'Third text',
            ]),
          ),
        );

        expect(response.data, hasLength(3));
        expect(response.data[0].index, 0);
        expect(response.data[1].index, 1);
        expect(response.data[2].index, 2);

        // Each embedding should have the same dimensions
        expect(
          response.data[0].embedding.length,
          response.data[1].embedding.length,
        );
        expect(
          response.data[1].embedding.length,
          response.data[2].embedding.length,
        );
      },
    );

    test(
      'respects dimensions parameter',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.embeddings.create(
          EmbeddingRequest(
            model: 'text-embedding-3-small',
            input: EmbeddingInput.text('Test text'),
            dimensions: 256,
          ),
        );

        expect(response.data.first.embedding.length, 256);
      },
    );

    test(
      'firstEmbedding getter returns first vector',
      timeout: const Timeout(Duration(minutes: 1)),
      () async {
        if (apiKey == null) {
          markTestSkipped('API key not available');
          return;
        }

        final response = await client!.embeddings.create(
          EmbeddingRequest(
            model: 'text-embedding-3-small',
            input: EmbeddingInput.text('Test'),
          ),
        );

        expect(response.firstEmbedding, equals(response.data.first.embedding));
      },
    );
  });
}
