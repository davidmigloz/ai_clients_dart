@Tags(['integration'])
library;

import 'dart:io';
import 'dart:math' as math;

import 'package:ollama_dart/ollama_dart.dart';
import 'package:test/test.dart';

/// Integration tests for the Embeddings API.
///
/// These tests require a running Ollama server with an embedding model.
/// Set OLLAMA_EMBED_MODEL environment variable to specify the model
/// (default: nomic-embed-text).
/// Run with: dart test --tags=integration
void main() {
  late OllamaClient client;
  late String embedModel;

  setUpAll(() {
    client = OllamaClient();
    embedModel =
        Platform.environment['OLLAMA_EMBED_MODEL'] ?? 'nomic-embed-text';
  });

  tearDownAll(() {
    client.close();
  });

  group('EmbeddingsResource', () {
    // Note: These tests require an embedding model to be available.
    // Common models: nomic-embed-text, mxbai-embed-large

    test('create generates embeddings for single text', () async {
      final response = await client.embeddings.create(
        request: EmbedRequest(model: embedModel, input: 'Hello, world!'),
      );

      expect(response.embeddings, isNotNull);
      expect(response.embeddings, isNotEmpty);
      expect(response.embeddings!.first, isNotEmpty);

      // Embedding vectors should be normalized (values between -1 and 1)
      for (final value in response.embeddings!.first) {
        expect(value, greaterThanOrEqualTo(-1.0));
        expect(value, lessThanOrEqualTo(1.0));
      }
    });

    test('create generates embeddings for multiple texts', () async {
      final response = await client.embeddings.create(
        request: EmbedRequest(
          model: embedModel,
          input: const ['Hello', 'World', 'Test'],
        ),
      );

      expect(response.embeddings, isNotNull);
      expect(response.embeddings!.length, 3);

      // All embeddings should have the same dimension
      final dimension = response.embeddings!.first.length;
      for (final embedding in response.embeddings!) {
        expect(embedding.length, dimension);
      }
    });

    test('similar texts have similar embeddings', () async {
      final response = await client.embeddings.create(
        request: EmbedRequest(
          model: embedModel,
          input: const [
            'The cat sat on the mat',
            'A cat is sitting on a mat',
            'Quantum physics is complex',
          ],
        ),
      );

      expect(response.embeddings!.length, 3);

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
        return dotProduct / math.sqrt(normA * normB);
      }

      final catSentence1 = response.embeddings![0];
      final catSentence2 = response.embeddings![1];
      final physicsSentence = response.embeddings![2];

      final similarityCats = cosineSimilarity(catSentence1, catSentence2);
      final similarityDifferent = cosineSimilarity(
        catSentence1,
        physicsSentence,
      );

      // Similar sentences should have higher similarity
      expect(similarityCats, greaterThan(similarityDifferent));
    });

    test('includes timing statistics', () async {
      final response = await client.embeddings.create(
        request: EmbedRequest(model: embedModel, input: 'Hello, world!'),
      );

      expect(response.totalDuration, isNotNull);
      expect(response.totalDuration, greaterThan(0));
    });
  });
}
