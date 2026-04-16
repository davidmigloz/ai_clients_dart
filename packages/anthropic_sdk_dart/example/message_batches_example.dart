// ignore_for_file: avoid_print
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';

/// Message Batches API example.
///
/// This example demonstrates:
/// - Creating a batch of message requests
/// - Listing batches
/// - Retrieving batch status
/// - Getting batch results
/// - Canceling and deleting batches
///
/// Note: Batches can take minutes to hours to complete depending on load.
/// For a full example, see also batch_example.dart.
void main() async {
  final client = AnthropicClient(
    config: const AnthropicConfig(
      authProvider: ApiKeyProvider(String.fromEnvironment('ANTHROPIC_API_KEY')),
    ),
  );

  try {
    // Example 1: Create a message batch
    print('=== Create Message Batch ===');
    final batch = await client.messages.batches.create(
      MessageBatchCreateRequest(
        requests: [
          BatchRequestItem(
            customId: 'greeting-1',
            params: MessageCreateRequest(
              model: 'claude-sonnet-4-6',
              maxTokens: 50,
              messages: [InputMessage.user('Say hello!')],
            ),
          ),
          BatchRequestItem(
            customId: 'greeting-2',
            params: MessageCreateRequest(
              model: 'claude-sonnet-4-6',
              maxTokens: 50,
              messages: [InputMessage.user('Say goodbye!')],
            ),
          ),
        ],
      ),
    );

    print('Batch created:');
    print('  ID: ${batch.id}');
    print('  Status: ${batch.processingStatus}');
    print('  Total requests: ${batch.requestCounts.processing}');

    // Example 2: List all batches
    print('\n=== List Batches ===');
    final batchList = await client.messages.batches.list(limit: 5);

    print('Recent batches:');
    for (final b in batchList.data) {
      print('  - ${b.id}: ${b.processingStatus}');
    }

    // Example 3: Retrieve batch status
    print('\n=== Retrieve Batch Status ===');
    final status = await client.messages.batches.retrieve(batch.id);

    print('Batch status:');
    print('  Processing status: ${status.processingStatus}');
    print('  Request counts:');
    print('    - Processing: ${status.requestCounts.processing}');
    print('    - Succeeded: ${status.requestCounts.succeeded}');
    print('    - Errored: ${status.requestCounts.errored}');
    print('    - Canceled: ${status.requestCounts.canceled}');
    print('    - Expired: ${status.requestCounts.expired}');

    // Example 4: Stream batch results (when completed)
    if (status.processingStatus == ProcessingStatus.ended) {
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
      print('\nBatch is still processing...');
      print('Results will be available when processingStatus is "ended".');
    }

    // Example 5: Cancel a batch (demo)
    print('\n=== Cancel Batch (demo) ===');
    print('To cancel a running batch:');
    print('''
final canceledBatch = await client.messages.batches.cancel('${batch.id}');
print('Canceled: \${canceledBatch.processingStatus}');
''');

    // Example 6: Delete a batch (demo)
    print('\n=== Delete Batch (demo) ===');
    print('To delete a batch:');
    print('''
await client.messages.batches.deleteBatch('${batch.id}');
print('Batch deleted');
''');
  } finally {
    client.close();
  }
}
