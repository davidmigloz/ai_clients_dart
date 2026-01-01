// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example of using the Mistral AI embeddings API.
void main() async {
  // Get API key from environment
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  // Create client
  final client = MistralClient.withApiKey(apiKey);

  try {
    // Generate embeddings for a single text
    print('=== Single Embedding ===');
    final singleResponse = await client.embeddings.create(
      request: EmbeddingRequest.single(
        model: 'mistral-embed',
        input: 'Hello, world!',
      ),
    );

    final embedding = singleResponse.data.first.embedding;
    print('Embedding dimension: ${embedding.length}');
    print('First 5 values: ${embedding.take(5).toList()}');
    print('Tokens used: ${singleResponse.usage?.totalTokens}');

    // Generate embeddings for multiple texts
    print('\n=== Batch Embeddings ===');
    final texts = [
      'The cat sat on the mat.',
      'The dog ran in the park.',
      'The bird flew in the sky.',
    ];

    final batchResponse = await client.embeddings.create(
      request: EmbeddingRequest.batch(model: 'mistral-embed', input: texts),
    );

    print('Generated ${batchResponse.data.length} embeddings');
    for (var i = 0; i < batchResponse.data.length; i++) {
      print('  Text ${i + 1}: ${texts[i]}');
      print('    -> Embedding dim: ${batchResponse.data[i].embedding.length}');
    }

    // Calculate similarity between embeddings
    print('\n=== Similarity Comparison ===');
    final emb1 = batchResponse.data[0].embedding;
    final emb2 = batchResponse.data[1].embedding;
    final emb3 = batchResponse.data[2].embedding;

    print(
      'Similarity between text 1 and 2: ${cosineSimilarity(emb1, emb2).toStringAsFixed(4)}',
    );
    print(
      'Similarity between text 1 and 3: ${cosineSimilarity(emb1, emb3).toStringAsFixed(4)}',
    );
    print(
      'Similarity between text 2 and 3: ${cosineSimilarity(emb2, emb3).toStringAsFixed(4)}',
    );
  } finally {
    client.close();
  }
}

/// Calculate cosine similarity between two vectors.
double cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length) {
    throw ArgumentError('Vectors must have the same length');
  }

  var dotProduct = 0.0;
  var normA = 0.0;
  var normB = 0.0;

  for (var i = 0; i < a.length; i++) {
    dotProduct += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }

  return dotProduct / (sqrt(normA) * sqrt(normB));
}
