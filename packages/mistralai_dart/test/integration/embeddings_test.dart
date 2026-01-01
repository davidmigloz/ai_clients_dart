// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math' as math;

import 'package:mistralai_dart/mistralai_dart.dart';
import 'package:test/test.dart';

import 'test_config.dart';

/// Integration tests for embeddings.
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

  group('Embeddings - Integration', () {
    test('generates embedding for single text', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.embeddings.create(
        request: const EmbeddingRequest(
          model: defaultEmbeddingModel,
          input: 'Hello, world!',
        ),
      );

      expect(response, isNotNull);
      expect(response.data, isNotEmpty);
      expect(response.data.first.embedding, isNotEmpty);
      // Mistral embeddings are typically 1024 dimensions
      expect(response.data.first.embedding.length, greaterThan(100));
    });

    test('generates embeddings for multiple texts', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.embeddings.create(
        request: const EmbeddingRequest(
          model: defaultEmbeddingModel,
          input: [
            'The quick brown fox',
            'jumps over the lazy dog',
            'Machine learning is fascinating',
          ],
        ),
      );

      expect(response, isNotNull);
      expect(response.data, hasLength(3));

      for (final embedding in response.data) {
        expect(embedding.embedding, isNotEmpty);
      }
    });

    test('returns usage information', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.embeddings.create(
        request: const EmbeddingRequest(
          model: defaultEmbeddingModel,
          input: 'Test embedding',
        ),
      );

      expect(response, isNotNull);
      expect(response.usage, isNotNull);
      expect(response.usage!.promptTokens, greaterThan(0));
      expect(response.usage!.totalTokens, greaterThan(0));
    });

    test('similar texts have similar embeddings', () async {
      if (apiKey == null) {
        markTestSkipped('API key not available');
        return;
      }

      final response = await client!.embeddings.create(
        request: const EmbeddingRequest(
          model: defaultEmbeddingModel,
          input: [
            'I love programming in Dart',
            'Dart is my favorite programming language',
            'The weather is nice today',
          ],
        ),
      );

      expect(response, isNotNull);
      expect(response.data, hasLength(3));

      // Calculate cosine similarity
      double cosineSimilarity(List<double> a, List<double> b) {
        var dotProduct = 0.0;
        var normA = 0.0;
        var normB = 0.0;

        for (var i = 0; i < a.length; i++) {
          dotProduct += a[i] * b[i];
          normA += a[i] * a[i];
          normB += b[i] * b[i];
        }

        return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
      }

      final embedding1 = response.data[0].embedding;
      final embedding2 = response.data[1].embedding;
      final embedding3 = response.data[2].embedding;

      final similarityProgramming = cosineSimilarity(embedding1, embedding2);
      final similarityDifferent = cosineSimilarity(embedding1, embedding3);

      // Similar texts should have higher similarity
      expect(similarityProgramming, greaterThan(similarityDifferent));
    });
  });
}
