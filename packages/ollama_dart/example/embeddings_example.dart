// ignore_for_file: avoid_print
import 'dart:math' as math;

import 'package:ollama_dart/ollama_dart.dart';

/// Example demonstrating embedding generation with the Ollama API.
void main() async {
  final client = OllamaClient();

  try {
    // Generate embeddings for a single text
    print('--- Single Embedding ---');
    final response = await client.embeddings.create(
      request: const EmbedRequest(
        model: 'nomic-embed-text',
        input: 'Hello, world!',
      ),
    );

    final embedding = response.embeddings?.first;
    if (embedding != null) {
      print('Embedding dimensions: ${embedding.length}');
      print('First 5 values: ${embedding.take(5).toList()}');
    }

    // Generate embeddings for multiple texts
    print('\n--- Batch Embeddings ---');
    final batchResponse = await client.embeddings.create(
      request: const EmbedRequest(
        model: 'nomic-embed-text',
        input: [
          'The cat sat on the mat',
          'A dog is playing in the park',
          'Machine learning is fascinating',
        ],
      ),
    );

    print('Generated ${batchResponse.embeddings?.length ?? 0} embeddings');

    // Calculate similarity between texts
    print('\n--- Similarity Calculation ---');
    if (batchResponse.embeddings != null &&
        batchResponse.embeddings!.length >= 3) {
      final catEmbedding = batchResponse.embeddings![0];
      final dogEmbedding = batchResponse.embeddings![1];
      final mlEmbedding = batchResponse.embeddings![2];

      final catDogSimilarity = cosineSimilarity(catEmbedding, dogEmbedding);
      final catMlSimilarity = cosineSimilarity(catEmbedding, mlEmbedding);

      print('Cat vs Dog similarity: ${catDogSimilarity.toStringAsFixed(4)}');
      print('Cat vs ML similarity: ${catMlSimilarity.toStringAsFixed(4)}');
      print(
        '\nNote: Higher values indicate more similar texts '
        '(animals vs ML topic)',
      );
    }

    // Timing information
    if (response.totalDuration != null) {
      final durationMs = response.totalDuration! ~/ 1000000;
      print('\nGeneration time: ${durationMs}ms');
    }
  } finally {
    client.close();
  }
}

/// Calculates cosine similarity between two vectors.
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
