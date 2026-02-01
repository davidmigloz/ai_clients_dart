// ignore_for_file: avoid_print, unused_local_variable
/// Example demonstrating batch operations with OpenAI.
///
/// The Batch API allows processing large numbers of requests asynchronously
/// at a 50% discount compared to synchronous API calls.
///
/// Run with: dart run example/batches_example.dart
library;

import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  String? batchId;
  String? inputFileId;

  try {
    // List existing batches
    print('=== List Existing Batches ===\n');

    final existingBatches = await client.batches.list(limit: 5);
    print('Found ${existingBatches.data.length} batch(es):');

    for (final batch in existingBatches.data) {
      print('  - ${batch.id}');
      print('    Status: ${batch.status}');
      print('    Endpoint: ${batch.endpoint}');
      if (batch.requestCounts != null) {
        print(
          '    Progress: ${batch.requestCounts!.completed}/'
          '${batch.requestCounts!.total} completed',
        );
      }
      print('');
    }

    // Prepare batch input file
    print('=== Prepare Batch Input ===\n');

    // Create batch requests in JSONL format
    // Each line is a separate request with a custom_id for tracking
    final batchRequests = [
      {
        'custom_id': 'request-1',
        'method': 'POST',
        'url': '/v1/chat/completions',
        'body': {
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': 'What is 2 + 2?'},
          ],
          'max_tokens': 50,
        },
      },
      {
        'custom_id': 'request-2',
        'method': 'POST',
        'url': '/v1/chat/completions',
        'body': {
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': 'What is the capital of France?'},
          ],
          'max_tokens': 50,
        },
      },
      {
        'custom_id': 'request-3',
        'method': 'POST',
        'url': '/v1/chat/completions',
        'body': {
          'model': 'gpt-4o-mini',
          'messages': [
            {'role': 'user', 'content': 'Name a primary color.'},
          ],
          'max_tokens': 50,
        },
      },
    ];

    // Convert to JSONL format
    final jsonlContent = batchRequests.map(jsonEncode).join('\n');
    final fileBytes = utf8.encode(jsonlContent);

    print('Batch contains ${batchRequests.length} requests');
    print('JSONL file size: ${fileBytes.length} bytes\n');

    // Upload the batch input file
    print('=== Upload Batch Input File ===\n');

    final uploaded = await client.files.upload(
      bytes: fileBytes,
      filename: 'batch_requests.jsonl',
      purpose: FilePurpose.batch,
    );

    inputFileId = uploaded.id;
    print('Uploaded file: ${uploaded.id}');
    print('  Filename: ${uploaded.filename}');
    print('  Purpose: ${uploaded.purpose}');
    print('  Status: ${uploaded.status}\n');

    // Create a batch
    print('=== Create Batch ===\n');

    final batch = await client.batches.create(
      CreateBatchRequest(
        inputFileId: inputFileId,
        endpoint: BatchEndpoint.chatCompletions,
        completionWindow: CompletionWindow.hours24,
        metadata: const {'project': 'example', 'type': 'demo'},
      ),
    );

    batchId = batch.id;
    print('Created batch: ${batch.id}');
    print('  Status: ${batch.status}');
    print('  Endpoint: ${batch.endpoint}');
    print('  Completion window: ${batch.completionWindow}');
    print('  Input file: ${batch.inputFileId}\n');

    // Check batch status
    print('=== Check Batch Status ===\n');

    final status = await client.batches.retrieve(batch.id);
    print('Batch ${status.id}:');
    print('  Status: ${status.status}');
    print('  Is processing: ${status.isProcessing}');
    print('  Is completed: ${status.isCompleted}');

    if (status.requestCounts != null) {
      print('  Total requests: ${status.requestCounts!.total}');
      print('  Completed: ${status.requestCounts!.completed}');
      print('  Failed: ${status.requestCounts!.failed}');
      print('  Pending: ${status.requestCounts!.pending}');
    }
    print('');

    // In production, you would poll until completion
    print('=== Polling Pattern (Example) ===\n');
    print(r'''
// Poll until batch completes
var currentBatch = batch;
while (currentBatch.isProcessing) {
  await Future.delayed(Duration(seconds: 30));
  currentBatch = await client.batches.retrieve(batch.id);
  print('Status: ${currentBatch.status}');
  if (currentBatch.requestCounts != null) {
    print('Progress: ${currentBatch.requestCounts!.completionPercentage}%');
  }
}

// Check results
if (currentBatch.isCompleted) {
  print('Output file: ${currentBatch.outputFileId}');
  // Download and process results...
} else if (currentBatch.isFailed) {
  print('Error file: ${currentBatch.errorFileId}');
  // Download and check errors...
}
''');

    // Batch status values explanation
    print('=== Batch Status Values ===\n');
    print('validating   - Input file being validated');
    print('in_progress  - Batch is processing');
    print('finalizing   - Results being prepared');
    print('completed    - Successfully completed');
    print('failed       - Validation or processing failed');
    print('expired      - Batch expired (24h window)');
    print('cancelling   - Cancellation in progress');
    print('cancelled    - Batch was cancelled\n');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    // Cleanup
    print('=== Cleanup ===\n');

    // Cancel the batch if still processing
    if (batchId != null) {
      try {
        final cancelled = await client.batches.cancel(batchId);
        print('Cancelled batch: ${cancelled.id}');
        print('  Status: ${cancelled.status}');
      } on ApiException catch (e) {
        // Batch may already be completed or cancelled
        print('Could not cancel batch: ${e.message}');
      }
    }

    // Delete the input file
    if (inputFileId != null) {
      try {
        final deleted = await client.files.delete(inputFileId);
        print('Deleted input file: ${deleted.id}');
      } on ApiException catch (e) {
        print('Could not delete file: ${e.message}');
      }
    }

    client.close();
    print('\nDone!');
  }
}
