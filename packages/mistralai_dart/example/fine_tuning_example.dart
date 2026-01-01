// ignore_for_file: avoid_print
import 'dart:io';

import 'package:mistralai_dart/mistralai_dart.dart';

/// Example demonstrating fine-tuning with the Mistral AI API.
///
/// This example shows how to:
/// - Create a fine-tuning job
/// - List fine-tuning jobs
/// - Retrieve job status
/// - Cancel a job
///
/// Note: Fine-tuning requires a valid training file to be uploaded first.
/// See the files_example.dart for how to upload files.
void main() async {
  final apiKey = Platform.environment['MISTRAL_API_KEY'];
  if (apiKey == null) {
    print('Please set MISTRAL_API_KEY environment variable');
    exit(1);
  }

  final client = MistralClient.withApiKey(apiKey);

  try {
    // --- Example 1: List existing fine-tuning jobs ---
    print('=== List Fine-tuning Jobs ===\n');

    final jobs = await client.fineTuning.jobs.list();
    print('Total jobs: ${jobs.data.length}');

    for (final job in jobs.data) {
      print('  - ${job.id}: ${job.model} (${job.status.value})');
      if (job.fineTunedModel != null) {
        print('    Fine-tuned model: ${job.fineTunedModel}');
      }
    }

    // --- Example 2: Create a fine-tuning job ---
    // Note: This requires a valid training file ID
    print('\n=== Create Fine-tuning Job (Example) ===\n');

    print('To create a fine-tuning job, you need:');
    print('1. Upload a JSONL training file using client.files.upload()');
    print('2. Create a job with the file ID');
    print(r'''
Example code:

final job = await client.fineTuning.jobs.create(
  request: CreateFineTuningJobRequest.single(
    model: 'mistral-small-latest',
    trainingFileId: 'your-training-file-id',
    suffix: 'my-custom-model',
    hyperparameters: Hyperparameters(
      trainingSteps: 100,
      learningRate: 0.0001,
    ),
  ),
);
print('Created job: ${job.id}');
''');

    // --- Example 3: Retrieve a specific job ---
    if (jobs.data.isNotEmpty) {
      print('\n=== Retrieve Job Details ===\n');

      final job = await client.fineTuning.jobs.retrieve(
        jobId: jobs.data.first.id,
      );

      print('Job ID: ${job.id}');
      print('Model: ${job.model}');
      print('Status: ${job.status.value}');
      print('Is Running: ${job.isRunning}');
      print('Is Complete: ${job.isComplete}');
      print('Is Success: ${job.isSuccess}');
      print('Fine-tuned Model: ${job.fineTunedModel ?? "N/A"}');

      if (job.hyperparameters != null) {
        print('Hyperparameters:');
        print('  Training Steps: ${job.hyperparameters!.trainingSteps}');
        print('  Learning Rate: ${job.hyperparameters!.learningRate}');
      }

      if (job.trainingFiles.isNotEmpty) {
        print('Training Files: ${job.trainingFiles.length}');
        for (final file in job.trainingFiles) {
          print('  - ${file.fileId}');
        }
      }

      if (job.trainedTokens != null) {
        print('Trained Tokens: ${job.trainedTokens}');
        print('Total Tokens: ${job.totalTokens}');
        if (job.totalTokens != null && job.totalTokens! > 0) {
          final progress = (job.trainedTokens! / job.totalTokens! * 100)
              .toStringAsFixed(1);
          print('Progress: $progress%');
        }
      }

      if (job.checkpoints.isNotEmpty) {
        print('Checkpoints: ${job.checkpoints.length}');
        for (final checkpoint in job.checkpoints) {
          print('  - Step ${checkpoint.stepNumber}: ${checkpoint.name}');
          if (checkpoint.trainingLoss != null) {
            print('    Training Loss: ${checkpoint.trainingLoss}');
          }
        }
      }
    }

    // --- Example 4: Poll for job completion ---
    print('\n=== Polling for Completion (Example) ===\n');

    print(r'''
To poll for job completion:

Future<FineTuningJob> waitForCompletion(
  MistralClient client,
  String jobId,
) async {
  while (true) {
    final job = await client.fineTuning.jobs.retrieve(jobId: jobId);

    if (job.isComplete) {
      if (job.isSuccess) {
        print('Job completed! Model: ${job.fineTunedModel}');
      } else {
        print('Job failed with status: ${job.status.value}');
      }
      return job;
    }

    print('Job status: ${job.status.value}');
    await Future.delayed(Duration(seconds: 30));
  }
}
''');

    // --- Example 5: Cancel a job ---
    print('=== Cancel a Job (Example) ===\n');

    print(r'''
To cancel a running job:

final cancelledJob = await client.fineTuning.jobs.cancel(
  jobId: 'your-job-id',
);
print('Job cancelled: ${cancelledJob.status.value}');
''');

    // --- Example 6: Using W&B Integration ---
    print('=== W&B Integration (Example) ===\n');

    print('''
To create a job with Weights & Biases integration:

final job = await client.fineTuning.jobs.create(
  request: CreateFineTuningJobRequest.single(
    model: 'mistral-small-latest',
    trainingFileId: 'your-file-id',
    suffix: 'my-model',
    integrations: [
      FineTuningIntegration.wandb(
        project: 'my-project',
        name: 'fine-tuning-run',
        apiKey: 'your-wandb-api-key',
      ),
    ],
  ),
);
''');
  } finally {
    client.close();
  }
}
