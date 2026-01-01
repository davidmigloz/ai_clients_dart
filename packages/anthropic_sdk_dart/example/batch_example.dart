// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Message Batches API example.
///
/// This example demonstrates:
/// - Creating batch requests
/// - Monitoring batch progress
/// - Retrieving batch results
/// - Cancelling batches
///
/// Note: Batches can take minutes to hours to complete depending on load.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Create a batch with multiple requests
    print('=== Create Batch ===');
    final batch = await client.messages.batches.create(
      MessageBatchCreateRequest(
        requests: [
          BatchRequestItem(
            customId: 'request-1',
            params: MessageCreateRequest(
              model: 'claude-sonnet-4-20250514',
              maxTokens: 100,
              messages: [InputMessage.user('What is 2 + 2?')],
            ),
          ),
          BatchRequestItem(
            customId: 'request-2',
            params: MessageCreateRequest(
              model: 'claude-sonnet-4-20250514',
              maxTokens: 100,
              messages: [InputMessage.user('What is the capital of France?')],
            ),
          ),
          BatchRequestItem(
            customId: 'request-3',
            params: MessageCreateRequest(
              model: 'claude-sonnet-4-20250514',
              maxTokens: 100,
              messages: [InputMessage.user('Write a haiku about coding.')],
            ),
          ),
        ],
      ),
    );

    print('Batch created:');
    print('  ID: ${batch.id}');
    print('  Status: ${batch.processingStatus}');
    print('  Created: ${batch.createdAt}');
    print('  Request counts: ${batch.requestCounts}');

    // Example 2: List batches
    print('\n=== List Batches ===');
    final batchList = await client.messages.batches.list(limit: 5);

    print('Recent batches:');
    for (final b in batchList.data) {
      print('  - ${b.id}: ${b.processingStatus}');
    }

    // Example 3: Monitor batch progress
    print('\n=== Monitor Batch ===');
    print('Checking batch status every 5 seconds...');
    print('(In production, you would poll less frequently)');

    var currentBatch = batch;
    var pollCount = 0;
    const maxPolls = 3; // Limit for demo purposes

    while (currentBatch.processingStatus == ProcessingStatus.inProgress &&
        pollCount < maxPolls) {
      await Future<void>.delayed(const Duration(seconds: 5));
      currentBatch = await client.messages.batches.retrieve(batch.id);
      pollCount++;

      print('  Status: ${currentBatch.processingStatus}');
      print('  Succeeded: ${currentBatch.requestCounts.succeeded}');
      print('  Errored: ${currentBatch.requestCounts.errored}');
      print('  Processing: ${currentBatch.requestCounts.processing}');
    }

    // Example 4: Retrieve results (if completed)
    if (currentBatch.processingStatus == ProcessingStatus.ended) {
      print('\n=== Batch Results ===');
      final results = client.messages.batches.results(batch.id);

      await for (final result in results) {
        print('Result for ${result.customId}:');
        switch (result.result) {
          case BatchResultSucceeded(:final message):
            print('  Success: ${message.text}');
          case BatchResultErrored(:final error):
            print('  Error: ${error.message}');
          case BatchResultCanceled():
            print('  Canceled');
          case BatchResultExpired():
            print('  Expired');
        }
      }
    } else {
      print('\nBatch still processing...');
      print('In production, you would continue polling or use webhooks.');
    }

    // Example 5: Cancel a batch (demo - commented to avoid canceling real batch)
    print('\n=== Cancel Batch (demo) ===');
    print('To cancel a batch:');
    print('''
final canceledBatch = await client.messages.batches.cancel('${batch.id}');
print('Batch canceled: \${canceledBatch.processingStatus}');
''');

    // Uncomment to actually cancel:
    // final canceledBatch = await client.messages.batches.cancel(batch.id);
    // print('Batch canceled: ${canceledBatch.processingStatus}');

    // Example 6: Delete a batch (demo)
    print('\n=== Delete Batch (demo) ===');
    print('To delete a batch after processing:');
    print('''
await client.messages.batches.deleteBatch('${batch.id}');
print('Batch deleted');
''');
  } finally {
    client.close();
  }
}
