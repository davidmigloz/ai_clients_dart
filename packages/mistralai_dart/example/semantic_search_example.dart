// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating semantic search using embeddings.
///
/// Shows how to use embeddings to find semantically similar content.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Basic semantic search
    await basicSemanticSearch(client);

    // Example 2: Document retrieval
    await documentRetrieval(client);

    // Example 3: Similarity threshold
    await similarityThreshold(client);
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

  return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
}

/// Basic semantic search example.
Future<void> basicSemanticSearch(MistralClient client) async {
  print('=== Basic Semantic Search ===\n');

  // Sample documents
  final documents = [
    'The cat sat on the mat.',
    'A dog played in the park.',
    'Python is a programming language.',
    'Machine learning is transforming industries.',
    'The weather is sunny today.',
    'Neural networks can recognize images.',
  ];

  // Query to search for
  const query = 'artificial intelligence and deep learning';

  print('Query: "$query"\n');
  print('Searching through ${documents.length} documents...\n');

  // Get embeddings for all documents and the query
  final allTexts = [...documents, query];

  final response = await client.embeddings.create(
    request: EmbeddingRequest(model: 'mistral-embed', input: allTexts),
  );

  // Extract embeddings
  final embeddings = response.data.map((e) => e.embedding).toList();
  final queryEmbedding = embeddings.last;
  final docEmbeddings = embeddings.sublist(0, documents.length);

  // Calculate similarities
  final similarities = <MapEntry<int, double>>[];
  for (var i = 0; i < documents.length; i++) {
    final similarity = cosineSimilarity(queryEmbedding, docEmbeddings[i]);
    similarities.add(MapEntry(i, similarity));
  }

  // Sort by similarity (descending)
  similarities.sort((a, b) => b.value.compareTo(a.value));

  // Print results
  print('Results (sorted by relevance):');
  for (final entry in similarities) {
    final doc = documents[entry.key];
    final score = entry.value.toStringAsFixed(4);
    print('  [$score] $doc');
  }

  print('');
}

/// Document retrieval for RAG.
Future<void> documentRetrieval(MistralClient client) async {
  print('=== Document Retrieval ===\n');

  // Knowledge base
  final knowledgeBase = {
    'doc1': 'Mistral AI is a French AI company founded in 2023.',
    'doc2': 'The Mistral-7B model has 7 billion parameters.',
    'doc3': 'Mixtral is a mixture of experts model.',
    'doc4': 'Mistral provides both open-source and commercial models.',
    'doc5': 'The API supports chat, embeddings, and code generation.',
  };

  const query = 'What models does Mistral offer?';
  const topK = 3;

  print('Query: "$query"');
  print('Retrieving top $topK relevant documents...\n');

  // Get embeddings
  final texts = [...knowledgeBase.values, query];

  final response = await client.embeddings.create(
    request: EmbeddingRequest(model: 'mistral-embed', input: texts.toList()),
  );

  final embeddings = response.data.map((e) => e.embedding).toList();
  final queryEmbed = embeddings.last;
  final docEmbeds = embeddings.sublist(0, knowledgeBase.length);

  // Find top K similar documents
  final docIds = knowledgeBase.keys.toList();
  final scored = <MapEntry<String, double>>[];

  for (var i = 0; i < docIds.length; i++) {
    final similarity = cosineSimilarity(queryEmbed, docEmbeds[i]);
    scored.add(MapEntry(docIds[i], similarity));
  }

  scored.sort((a, b) => b.value.compareTo(a.value));

  print('Retrieved documents:');
  for (final entry in scored.take(topK)) {
    final content = knowledgeBase[entry.key];
    print('  [${entry.key}] (${entry.value.toStringAsFixed(3)}) $content');
  }

  print('');
}

/// Using similarity threshold for filtering.
Future<void> similarityThreshold(MistralClient client) async {
  print('=== Similarity Threshold ===\n');

  final items = [
    'Apple iPhone 15 Pro Max',
    'Samsung Galaxy S24 Ultra',
    'Google Pixel 8 Pro',
    'MacBook Pro 16-inch',
    'iPad Air 5th generation',
    'Sony PlayStation 5',
    'Nintendo Switch OLED',
  ];

  const query = 'smartphone mobile phone';
  const threshold = 0.5;

  print('Query: "$query"');
  print('Threshold: $threshold\n');

  // Get embeddings
  final texts = [...items, query];

  final response = await client.embeddings.create(
    request: EmbeddingRequest(model: 'mistral-embed', input: texts),
  );

  final embeddings = response.data.map((e) => e.embedding).toList();
  final queryEmbed = embeddings.last;

  // Filter by threshold
  final matches = <MapEntry<String, double>>[];

  for (var i = 0; i < items.length; i++) {
    final similarity = cosineSimilarity(queryEmbed, embeddings[i]);
    if (similarity >= threshold) {
      matches.add(MapEntry(items[i], similarity));
    }
  }

  matches.sort((a, b) => b.value.compareTo(a.value));

  print('Items above threshold:');
  if (matches.isEmpty) {
    print('  No items matched the threshold');
  } else {
    for (final match in matches) {
      print('  [${match.value.toStringAsFixed(3)}] ${match.key}');
    }
  }

  print('\nItems below threshold:');
  for (var i = 0; i < items.length; i++) {
    final similarity = cosineSimilarity(queryEmbed, embeddings[i]);
    if (similarity < threshold) {
      print('  [${similarity.toStringAsFixed(3)}] ${items[i]}');
    }
  }
}
