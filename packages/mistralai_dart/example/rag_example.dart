// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math' as math;

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating Retrieval Augmented Generation (RAG).
///
/// RAG combines retrieval of relevant documents with LLM generation
/// to produce grounded, accurate responses.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Basic RAG pipeline
    await basicRag(client);

    // Example 2: RAG with source attribution
    await ragWithSources(client);

    // Example 3: RAG with context window management
    await ragWithContextManagement(client);
  } finally {
    client.close();
  }
}

/// Simple in-memory vector store for demo.
class SimpleVectorStore {
  final List<String> _documents = [];
  final List<List<double>> _embeddings = [];

  void addDocuments(List<String> docs, List<List<double>> embeds) {
    _documents.addAll(docs);
    _embeddings.addAll(embeds);
  }

  List<String> search(List<double> queryEmbedding, {int topK = 3}) {
    final scores = <int, double>{};

    for (var i = 0; i < _embeddings.length; i++) {
      scores[i] = _cosineSimilarity(queryEmbedding, _embeddings[i]);
    }

    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sorted.take(topK).map((e) => _documents[e.key]).toList();
  }

  double _cosineSimilarity(List<double> a, List<double> b) {
    var dot = 0.0;
    var normA = 0.0;
    var normB = 0.0;
    for (var i = 0; i < a.length; i++) {
      dot += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }
    return dot / (math.sqrt(normA) * math.sqrt(normB));
  }
}

/// Basic RAG pipeline.
Future<void> basicRag(MistralClient client) async {
  print('=== Basic RAG Pipeline ===\n');

  // Step 1: Prepare knowledge base
  final documents = [
    'Mistral AI was founded in April 2023 by former DeepMind and Meta researchers.',
    'The company raised €105 million in its seed round, the largest in European history.',
    'Mistral-7B is the first open-source model, released in September 2023.',
    'Mixtral 8x7B uses a Mixture of Experts architecture with 8 experts.',
    'Mistral Large is the flagship commercial model with 32K context window.',
    'The company is headquartered in Paris, France.',
    'Mistral models support multiple languages including English and French.',
    'The API provides endpoints for chat, embeddings, and code generation.',
  ];

  print('Building knowledge base with ${documents.length} documents...\n');

  // Step 2: Create embeddings for documents
  final docResponse = await client.embeddings.create(
    request: EmbeddingRequest(model: 'mistral-embed', input: documents),
  );

  final store = SimpleVectorStore()
    ..addDocuments(
      documents,
      docResponse.data.map((e) => e.embedding).toList(),
    );

  // Step 3: Process user query
  const query = 'When was Mistral AI founded and what was their first model?';
  print('User query: "$query"\n');

  // Step 4: Retrieve relevant documents
  final queryResponse = await client.embeddings.create(
    request: const EmbeddingRequest(model: 'mistral-embed', input: [query]),
  );

  final relevantDocs = store.search(
    queryResponse.data.first.embedding,
    topK: 3,
  );

  print('Retrieved ${relevantDocs.length} relevant documents:');
  for (final doc in relevantDocs) {
    print('  - $doc');
  }
  print('');

  // Step 5: Generate response with context
  final context = relevantDocs.join('\n');

  final response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'You are a helpful assistant. Answer questions based only on the '
          'provided context. If the answer is not in the context, say so.',
        ),
        ChatMessage.user('Context:\n$context\n\nQuestion: $query'),
      ],
      maxTokens: 200,
    ),
  );

  print('Generated answer:');
  print(response.text);
  print('');
}

/// RAG with source attribution.
Future<void> ragWithSources(MistralClient client) async {
  print('=== RAG with Source Attribution ===\n');

  // Documents with IDs for attribution
  final sources = {
    'wiki-1': 'The Eiffel Tower is 330 meters tall and located in Paris.',
    'wiki-2': 'The tower was built for the 1889 World Fair.',
    'wiki-3': 'Gustave Eiffel designed the iconic iron lattice structure.',
    'wiki-4': 'Over 7 million people visit the Eiffel Tower each year.',
    'wiki-5': 'The tower has three accessible levels for visitors.',
  };

  // Create embeddings
  final response = await client.embeddings.create(
    request: EmbeddingRequest(
      model: 'mistral-embed',
      input: sources.values.toList(),
    ),
  );

  final store = SimpleVectorStore()
    ..addDocuments(
      sources.values.toList(),
      response.data.map((e) => e.embedding).toList(),
    );

  // Query with source tracking
  const query = 'How tall is the Eiffel Tower?';
  print('Query: "$query"\n');

  final queryEmbed = await client.embeddings.create(
    request: const EmbeddingRequest(model: 'mistral-embed', input: [query]),
  );

  final retrieved = store.search(queryEmbed.data.first.embedding, topK: 2);

  // Find source IDs
  final usedSources = <String>[];
  for (final doc in retrieved) {
    for (final entry in sources.entries) {
      if (entry.value == doc) {
        usedSources.add(entry.key);
      }
    }
  }

  // Generate with source context
  final contextWithSources = retrieved
      .asMap()
      .entries
      .map((e) {
        return '[${usedSources[e.key]}] ${e.value}';
      })
      .join('\n');

  final answer = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system(
          'Answer based on the sources. Cite sources using [source-id] format.',
        ),
        ChatMessage.user('Sources:\n$contextWithSources\n\nQuestion: $query'),
      ],
      maxTokens: 150,
    ),
  );

  print('Answer: ${answer.text}');
  print('\nSources used: ${usedSources.join(", ")}');
  print('');
}

/// RAG with context window management.
Future<void> ragWithContextManagement(MistralClient client) async {
  print('=== RAG with Context Management ===\n');

  // Simulate many documents
  final documents = List.generate(
    20,
    (i) =>
        'Document ${i + 1}: This is some information about topic $i. '
        'It contains details and facts that might be relevant.',
  );

  print('Knowledge base: ${documents.length} documents');

  // Create embeddings
  final docEmbeds = await client.embeddings.create(
    request: EmbeddingRequest(model: 'mistral-embed', input: documents),
  );

  final store = SimpleVectorStore()
    ..addDocuments(documents, docEmbeds.data.map((e) => e.embedding).toList());

  // Query
  const query = 'Tell me about topic 5';

  final queryEmbed = await client.embeddings.create(
    request: const EmbeddingRequest(model: 'mistral-embed', input: [query]),
  );

  // Retrieve with dynamic top-k based on context budget
  const maxContextTokens = 500; // Budget for context
  const avgTokensPerDoc = 30; // Estimate
  const topK = maxContextTokens ~/ avgTokensPerDoc;

  print('Context budget: $maxContextTokens tokens');
  print('Estimated tokens per doc: $avgTokensPerDoc');
  print('Dynamic top-k: $topK documents\n');

  final retrieved = store.search(queryEmbed.data.first.embedding, topK: topK);

  final context = retrieved.join('\n');

  final response = await client.chat.create(
    request: ChatCompletionRequest(
      model: 'mistral-small-latest',
      messages: [
        ChatMessage.system('Answer based on the provided context.'),
        ChatMessage.user('Context:\n$context\n\nQuestion: $query'),
      ],
      maxTokens: 100,
    ),
  );

  print('Query: "$query"');
  print('Answer: ${response.text}');
}
