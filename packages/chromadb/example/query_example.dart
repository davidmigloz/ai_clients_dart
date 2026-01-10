// ignore_for_file: avoid_print, unused_local_variable
/// Similarity search (query) examples.
library;

import 'package:chromadb/chromadb.dart';

void main() async {
  final client = ChromaClient();

  try {
    // Create a collection with sample data
    final collection = await client.getOrCreateCollection(
      name: 'query-example',
    );

    // Add sample documents
    await collection.add(
      ids: ['doc1', 'doc2', 'doc3', 'doc4', 'doc5'],
      embeddings: [
        [1.0, 0.0, 0.0], // Category: tech
        [0.9, 0.1, 0.0], // Category: tech
        [0.0, 1.0, 0.0], // Category: science
        [0.1, 0.9, 0.0], // Category: science
        [0.0, 0.0, 1.0], // Category: arts
      ],
      documents: [
        'Introduction to machine learning',
        'Deep learning fundamentals',
        'Quantum physics explained',
        'The theory of relativity',
        'Modern art movements',
      ],
      metadatas: [
        {'category': 'tech', 'year': 2023},
        {'category': 'tech', 'year': 2024},
        {'category': 'science', 'year': 2022},
        {'category': 'science', 'year': 2021},
        {'category': 'arts', 'year': 2020},
      ],
    );
    print('Added 5 documents');

    // Basic similarity search
    print('\n--- Basic Query ---');
    final results = await collection.query(
      queryEmbeddings: [
        [1.0, 0.0, 0.0],
      ], // Query for tech content
      nResults: 3,
    );
    print('Top 3 results for tech query:');
    for (var i = 0; i < results.ids.first.length; i++) {
      final distance = results.distances?.first[i];
      print(
        '  ${results.ids.first[i]}: ${results.documents?.first[i]} '
        '(distance: ${distance?.toStringAsFixed(4)})',
      );
    }

    // Query multiple embeddings at once
    print('\n--- Multiple Queries ---');
    final multiResults = await collection.query(
      queryEmbeddings: [
        [1.0, 0.0, 0.0], // Tech
        [0.0, 1.0, 0.0], // Science
      ],
      nResults: 2,
    );
    for (var q = 0; q < multiResults.ids.length; q++) {
      print('Query ${q + 1} results:');
      for (var i = 0; i < multiResults.ids[q].length; i++) {
        print('  - ${multiResults.documents?[q][i]}');
      }
    }

    // Query with metadata filter
    print('\n--- Query with Metadata Filter ---');
    final filtered = await collection.query(
      queryEmbeddings: [
        [0.5, 0.5, 0.0],
      ],
      nResults: 5,
      where: {
        'year': {r'$gte': 2022},
      },
    );
    print('Results from 2022 or later:');
    for (var i = 0; i < filtered.ids.first.length; i++) {
      print('  - ${filtered.documents?.first[i]}');
    }

    // Query with document filter
    print('\n--- Query with Document Filter ---');
    final docFiltered = await collection.query(
      queryEmbeddings: [
        [0.5, 0.5, 0.0],
      ],
      nResults: 5,
      whereDocument: {r'$contains': 'learning'},
    );
    print('Results containing "learning":');
    for (var i = 0; i < docFiltered.ids.first.length; i++) {
      print('  - ${docFiltered.documents?.first[i]}');
    }

    // Query with specific includes
    print('\n--- Query with Embeddings ---');
    final withEmbeddings = await collection.query(
      queryEmbeddings: [
        [1.0, 0.0, 0.0],
      ],
      nResults: 2,
      include: [
        Include.documents,
        Include.metadatas,
        Include.embeddings,
        Include.distances,
      ],
    );
    print('Results with embeddings:');
    for (var i = 0; i < withEmbeddings.ids.first.length; i++) {
      print('  ID: ${withEmbeddings.ids.first[i]}');
      print('  Document: ${withEmbeddings.documents?.first[i]}');
      print('  Embedding: ${withEmbeddings.embeddings?.first[i]}');
      print('  Distance: ${withEmbeddings.distances?.first[i]}');
      print('');
    }

    // Clean up
    await client.deleteCollection(name: 'query-example');
  } finally {
    client.close();
  }
}
