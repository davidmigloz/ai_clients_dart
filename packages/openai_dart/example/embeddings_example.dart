// ignore_for_file: avoid_print
/// Example demonstrating text embeddings.
///
/// Run with: dart run example/embeddings_example.dart
library;

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  final client = OpenAIClient.fromEnvironment();

  try {
    // Single text embedding
    print('=== Single Text Embedding ===\n');

    final response = await client.embeddings.create(
      EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.text('Hello, world!'),
      ),
    );

    print('Model: ${response.model}');
    print('Dimensions: ${response.firstEmbedding.length}');
    print('First 5 values: ${response.firstEmbedding.take(5).toList()}');
    print('Usage: ${response.usage?.totalTokens ?? 'N/A'} tokens\n');

    // Multiple text embeddings
    print('=== Multiple Text Embeddings ===\n');

    final response2 = await client.embeddings.create(
      EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.textList([
          'The quick brown fox jumps over the lazy dog.',
          'A fast auburn fox leaps above a sleepy canine.',
          'Hello, how are you today?',
        ]),
      ),
    );

    print('Number of embeddings: ${response2.data.length}');
    for (final embedding in response2.data) {
      print('  Index ${embedding.index}: ${embedding.embedding.length} dims');
    }
    print('');

    // Reduced dimensions
    print('=== Reduced Dimensions ===\n');

    final response3 = await client.embeddings.create(
      EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.text('Dimensionality reduction example'),
        dimensions: 256,
      ),
    );

    print('Requested 256 dimensions');
    print('Actual dimensions: ${response3.firstEmbedding.length}\n');

    // Similarity calculation example
    print('=== Similarity Calculation ===\n');

    final texts = [
      'I love programming in Dart',
      'Dart is my favorite programming language',
      'The weather is nice today',
    ];

    final embeddings = await client.embeddings.create(
      EmbeddingRequest(
        model: 'text-embedding-3-small',
        input: EmbeddingInput.textList(texts),
      ),
    );

    // Simple square root using Newton's method
    double sqrtApprox(double x) {
      if (x <= 0) return 0;
      var guess = x / 2;
      for (var i = 0; i < 20; i++) {
        guess = (guess + x / guess) / 2;
      }
      return guess;
    }

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
      return dotProduct / (sqrtApprox(normA) * sqrtApprox(normB));
    }

    final vectors = embeddings.data.map((e) => e.embedding).toList();

    print('Text comparisons:');
    print('  "${texts[0]}" vs "${texts[1]}"');
    print(
      '  Similarity: ${cosineSimilarity(vectors[0], vectors[1]).toStringAsFixed(4)}',
    );
    print('');
    print('  "${texts[0]}" vs "${texts[2]}"');
    print(
      '  Similarity: ${cosineSimilarity(vectors[0], vectors[2]).toStringAsFixed(4)}',
    );
  } finally {
    client.close();
  }
}
