// ignore_for_file: avoid_print, unused_local_variable
/// Custom embedding function example.
library;

import 'dart:math';

import 'package:chromadb/chromadb.dart';

/// A simple mock embedding function for demonstration.
///
/// In a real application, you would call an embedding API like:
/// - OpenAI text-embedding-3-small
/// - Cohere embed-v3
/// - Google textembedding-gecko
/// - A local model via Ollama
class MockEmbeddingFunction implements EmbeddingFunction {
  final int dimensions;

  MockEmbeddingFunction({this.dimensions = 384});

  @override
  Future<List<List<double>>> generate(List<Embeddable> inputs) async {
    // Simulate API latency
    await Future<void>.delayed(const Duration(milliseconds: 100));

    return inputs.map((input) {
      // Generate a deterministic embedding based on input hash
      final text = switch (input) {
        EmbeddableDocument(:final document) => document,
        EmbeddableImage(:final image) => image,
      };

      // Use hash to seed the random generator for reproducibility
      final seed = text.hashCode;
      final rng = Random(seed);

      // Generate embedding vector
      return List.generate(dimensions, (_) => rng.nextDouble() * 2 - 1);
    }).toList();
  }
}

/// Example of integrating with OpenAI (pseudo-code).
///
/// ```dart
/// class OpenAIEmbeddingFunction implements EmbeddingFunction {
///   final OpenAIClient client;
///   final String model;
///
///   OpenAIEmbeddingFunction(this.client, {this.model = 'text-embedding-3-small'});
///
///   @override
///   Future<List<List<double>>> generate(List<Embeddable> inputs) async {
///     final texts = inputs.map((e) => switch (e) {
///       EmbeddableDocument(:final document) => document,
///       EmbeddableImage(:final image) => image,
///     }).toList();
///
///     final response = await client.embeddings.create(
///       model: model,
///       input: texts,
///     );
///     return response.data.map((e) => e.embedding).toList();
///   }
/// }
/// ```

void main() async {
  final client = ChromaClient();

  try {
    // Create a collection with a custom embedding function
    final embeddingFunction = MockEmbeddingFunction(dimensions: 384);
    final collection = await client.getOrCreateCollection(
      name: 'auto-embed-example',
      embeddingFunction: embeddingFunction,
    );
    print('Created collection with embedding function');

    // Add documents - embeddings will be generated automatically!
    print('\nAdding documents (embeddings auto-generated)...');
    await collection.add(
      ids: ['doc1', 'doc2', 'doc3'],
      documents: [
        'Machine learning is a subset of artificial intelligence.',
        'Natural language processing enables computers to understand text.',
        'Computer vision allows machines to interpret visual data.',
      ],
      metadatas: [
        {'topic': 'ml'},
        {'topic': 'nlp'},
        {'topic': 'cv'},
      ],
    );
    print('Added 3 documents');

    // Query by text - embedding will be generated automatically!
    print('\nQuerying by text (embedding auto-generated)...');
    final results = await collection.query(
      queryTexts: ['What is machine learning?'],
      nResults: 2,
    );
    print('Query results:');
    for (var i = 0; i < results.ids.first.length; i++) {
      print('  - ${results.documents?.first[i]}');
    }

    // Multiple queries at once
    print('\nMultiple text queries...');
    final multiResults = await collection.query(
      queryTexts: ['artificial intelligence', 'image recognition'],
      nResults: 1,
    );
    for (var q = 0; q < multiResults.ids.length; q++) {
      print('Query ${q + 1}: ${multiResults.documents?[q].first}');
    }

    // You can still provide pre-computed embeddings if needed
    print('\nAdding with pre-computed embeddings...');
    await collection.add(
      ids: ['doc4'],
      embeddings: [List.generate(384, (i) => i / 384.0)],
      documents: ['Document with pre-computed embedding'],
    );
    print('Added document with custom embedding');

    // Update documents - new embeddings generated
    print('\nUpdating document (new embedding generated)...');
    await collection.update(
      ids: ['doc1'],
      documents: ['Deep learning is an advanced form of machine learning.'],
    );
    print('Document updated');

    // Upsert with auto-embedding
    print('\nUpserting documents...');
    await collection.upsert(
      ids: ['doc5', 'doc6'],
      documents: [
        'Reinforcement learning trains agents through rewards.',
        'Transformers revolutionized NLP with attention mechanisms.',
      ],
    );
    print('Upserted 2 documents');

    // Final count
    final count = await collection.count();
    print('\nTotal documents: $count');

    // Clean up
    await client.deleteCollection(name: 'auto-embed-example');
  } finally {
    client.close();
  }
}
