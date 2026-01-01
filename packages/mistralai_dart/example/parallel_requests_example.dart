// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating parallel and concurrent API requests.
///
/// Shows how to efficiently handle multiple requests simultaneously.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    return;
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // Example 1: Basic parallel requests
    await basicParallelRequests(client);

    // Example 2: Batch processing with concurrency limit
    await batchWithConcurrencyLimit(client);

    // Example 3: Multiple operations in parallel
    await multipleOperationsParallel(client);
  } finally {
    client.close();
  }
}

/// Basic parallel requests using Future.wait.
Future<void> basicParallelRequests(MistralClient client) async {
  print('=== Basic Parallel Requests ===\n');

  final questions = [
    'What is the capital of France?',
    'What is the capital of Germany?',
    'What is the capital of Italy?',
    'What is the capital of Spain?',
  ];

  print('Sending ${questions.length} requests in parallel...\n');

  final stopwatch = Stopwatch()..start();

  // Send all requests in parallel
  final futures = questions.map((question) async {
    final response = await client.chat.create(
      request: ChatCompletionRequest(
        model: 'mistral-small-latest',
        messages: [ChatMessage.user(question)],
        maxTokens: 50,
      ),
    );
    return MapEntry(question, response.text ?? '');
  });

  final results = await Future.wait(futures);

  stopwatch.stop();

  print('Results:');
  for (final result in results) {
    print('  Q: ${result.key}');
    print('  A: ${result.value}\n');
  }

  print('Total time: ${stopwatch.elapsedMilliseconds}ms');
  print(
    'Average time per request: ${stopwatch.elapsedMilliseconds ~/ questions.length}ms',
  );
  print('');
}

/// Batch processing with concurrency limit.
Future<void> batchWithConcurrencyLimit(MistralClient client) async {
  print('=== Batch Processing with Concurrency Limit ===\n');

  final items = List.generate(10, (i) => 'Item ${i + 1}: Generate a haiku');
  const maxConcurrent = 3;

  print('Processing ${items.length} items with max $maxConcurrent concurrent');
  print('');

  final stopwatch = Stopwatch()..start();

  // Process in batches
  final results = <String>[];

  for (var i = 0; i < items.length; i += maxConcurrent) {
    final batch = items.skip(i).take(maxConcurrent);
    final batchNum = (i ~/ maxConcurrent) + 1;

    print('Processing batch $batchNum...');

    final batchFutures = batch.map((item) async {
      final response = await client.chat.create(
        request: ChatCompletionRequest(
          model: 'mistral-small-latest',
          messages: [ChatMessage.user(item)],
          maxTokens: 50,
        ),
      );
      return response.text ?? '';
    });

    final batchResults = await Future.wait(batchFutures);
    results.addAll(batchResults);
  }

  stopwatch.stop();

  print('\nCompleted ${results.length} items');
  print('Total time: ${stopwatch.elapsedMilliseconds}ms');
  print('');
}

/// Multiple different operations in parallel.
Future<void> multipleOperationsParallel(MistralClient client) async {
  print('=== Multiple Operations in Parallel ===\n');

  final stopwatch = Stopwatch()..start();

  // Run different API calls in parallel
  final results = await Future.wait([
    // Chat completion
    client.chat
        .create(
          request: ChatCompletionRequest(
            model: 'mistral-small-latest',
            messages: [ChatMessage.user('Say hello in 3 languages')],
            maxTokens: 100,
          ),
        )
        .then((r) => 'Chat: ${r.text}'),

    // Embeddings
    client.embeddings
        .create(
          request: const EmbeddingRequest(
            model: 'mistral-embed',
            input: ['Hello, world!'],
          ),
        )
        .then((r) => 'Embedding: ${r.data.first.embedding.length} dimensions'),

    // Models list
    client.models.list().then((r) => 'Models: ${r.data.length} available'),
  ]);

  stopwatch.stop();

  print('Results:');
  for (final result in results) {
    print('  $result');
  }
  print('\nTotal time for all operations: ${stopwatch.elapsedMilliseconds}ms');
  print('(Much faster than sequential execution!)');
}
