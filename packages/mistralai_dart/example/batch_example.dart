// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating batch processing with the Mistral AI API.
///
/// This example shows how to:
/// - Create a batch job
/// - List batch jobs
/// - Retrieve job status
/// - Cancel a job
/// - Poll for completion
///
/// Batch processing is ideal for:
/// - Processing large datasets asynchronously
/// - Running overnight jobs
/// - Cost optimization (batch requests may be discounted)
///
/// Note: Batch jobs require an input file in JSONL format to be uploaded first.
/// See the files_example.dart for how to upload files.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- Example 1: List existing batch jobs ---
    print('=== List Batch Jobs ===\n');

    final jobs = await client.batch.jobs.list();
    print('Total jobs: ${jobs.data.length}');

    for (final job in jobs.data) {
      print('  - ${job.id}: ${job.status.value}');
      print('    Model: ${job.model}');
      print('    Endpoint: ${job.endpoint}');
      print('    Progress: ${job.progress.toStringAsFixed(1)}%');
    }

    // --- Example 2: Create a batch job ---
    // Note: This requires a valid input file ID
    print('\n=== Create Batch Job (Example) ===\n');

    print('To create a batch job, you need:');
    print('1. Prepare a JSONL file with your requests');
    print('2. Upload it using client.files.upload(purpose: FilePurpose.batch)');
    print('3. Create a job with the file ID');
    print(r'''
Input file format (batch_requests.jsonl):
{"custom_id": "req-1", "body": {"model": "mistral-small-latest", "messages": [{"role": "user", "content": "Hello!"}]}}
{"custom_id": "req-2", "body": {"model": "mistral-small-latest", "messages": [{"role": "user", "content": "Hi there!"}]}}

Example code:

// Upload the input file
final inputFile = await client.files.upload(
  file: File('batch_requests.jsonl'),
  purpose: FilePurpose.batch,
);

// Create the batch job
final job = await client.batch.jobs.create(
  request: CreateBatchJobRequest(
    inputFileId: inputFile.id,
    endpoint: '/v1/chat/completions',
    model: 'mistral-small-latest',
    metadata: {'project': 'my-project'},
  ),
);
print('Created job: ${job.id}');
''');

    // --- Example 3: Retrieve a specific job ---
    if (jobs.data.isNotEmpty) {
      print('\n=== Retrieve Job Details ===\n');

      final job = await client.batch.jobs.retrieve(jobId: jobs.data.first.id);

      print('Job ID: ${job.id}');
      print('Model: ${job.model}');
      print('Endpoint: ${job.endpoint}');
      print('Status: ${job.status.value}');
      print('Input File: ${job.inputFileId}');
      print('Output File: ${job.outputFileId ?? "N/A"}');
      print('Error File: ${job.errorFileId ?? "N/A"}');

      print('\nProgress:');
      print('  Total Requests: ${job.totalRequests ?? "N/A"}');
      print('  Completed: ${job.completedRequests ?? 0}');
      print('  Succeeded: ${job.succeededRequests ?? 0}');
      print('  Failed: ${job.failedRequests ?? 0}');
      print('  Progress: ${job.progress.toStringAsFixed(1)}%');

      print('\nState:');
      print('  Is Running: ${job.isRunning}');
      print('  Is Complete: ${job.isComplete}');
      print('  Is Success: ${job.isSuccess}');
      print('  Is Failed: ${job.isFailed}');

      if (job.createdAt != null) {
        print('  Created: ${job.createdAt}');
      }
      if (job.startedAt != null) {
        print('  Started: ${job.startedAt}');
      }
      if (job.completedAt != null) {
        print('  Completed: ${job.completedAt}');
      }

      if (job.errors.isNotEmpty) {
        print('\nErrors:');
        for (final error in job.errors) {
          print('  - ${error.code}: ${error.message} (${error.count}x)');
        }
      }
    }

    // --- Example 4: Poll for job completion ---
    print('\n=== Polling for Completion (Example) ===\n');

    print(r'''
To poll for job completion:

Future<BatchJob> waitForCompletion(
  MistralClient client,
  String jobId,
) async {
  while (true) {
    final job = await client.batch.jobs.retrieve(jobId: jobId);

    print('Status: ${job.status.value}, Progress: ${job.progress.toStringAsFixed(1)}%');

    if (job.isComplete) {
      if (job.isSuccess) {
        print('Job completed successfully!');
        if (job.outputFileId != null) {
          print('Output file: ${job.outputFileId}');
          // Download results
          final results = await client.files.download(fileId: job.outputFileId!);
          // Process results...
        }
      } else {
        print('Job failed with status: ${job.status.value}');
        if (job.errorFileId != null) {
          // Download error details
          final errors = await client.files.download(fileId: job.errorFileId!);
          // Inspect errors...
        }
      }
      return job;
    }

    await Future.delayed(Duration(seconds: 30));
  }
}
''');

    // --- Example 5: Cancel a job ---
    print('=== Cancel a Job (Example) ===\n');

    print(r'''
To cancel a running batch job:

final cancelledJob = await client.batch.jobs.cancel(
  jobId: 'your-job-id',
);
print('Job cancelled: ${cancelledJob.status.value}');

Note: Cancellation may take some time. The status will first change to
CANCELLATION_REQUESTED, then to CANCELLED once fully stopped.
''');

    // --- Example 6: Filter jobs by status ---
    print('=== Filter Jobs (Example) ===\n');

    print(r'''
You can filter batch jobs by various criteria:

// Filter by status
final runningJobs = await client.batch.jobs.list(status: 'RUNNING');

// Filter by model
final embedJobs = await client.batch.jobs.list(model: 'mistral-embed');

// Paginate results
final page2 = await client.batch.jobs.list(page: 2, pageSize: 10);
''');

    // --- Example 7: Full workflow ---
    print('=== Full Workflow (Example) ===\n');

    print(r'''
Complete batch processing workflow:

// 1. Prepare input file
final inputData = [
  '{"custom_id": "1", "body": {"model": "mistral-small-latest", "messages": [{"role": "user", "content": "Summarize AI"}]}}',
  '{"custom_id": "2", "body": {"model": "mistral-small-latest", "messages": [{"role": "user", "content": "Explain ML"}]}}',
].join('\n');
File('input.jsonl').writeAsStringSync(inputData);

// 2. Upload file
final file = await client.files.upload(
  file: File('input.jsonl'),
  purpose: FilePurpose.batch,
);

// 3. Create batch job
final job = await client.batch.jobs.create(
  request: CreateBatchJobRequest(
    inputFileId: file.id,
    endpoint: '/v1/chat/completions',
    model: 'mistral-small-latest',
  ),
);

// 4. Wait for completion
var status = job;
while (!status.isComplete) {
  await Future.delayed(Duration(seconds: 30));
  status = await client.batch.jobs.retrieve(jobId: job.id);
  print('Progress: ${status.progress.toStringAsFixed(1)}%');
}

// 5. Process results
if (status.isSuccess && status.outputFileId != null) {
  final output = await client.files.download(fileId: status.outputFileId!);
  final results = String.fromCharCodes(output);
  print('Results:\n$results');
}

// 6. Cleanup
await client.files.delete(fileId: file.id);
if (status.outputFileId != null) {
  await client.files.delete(fileId: status.outputFileId!);
}
''');
  } finally {
    client.close();
  }
}
