// ignore_for_file: avoid_print, unused_local_variable
/// Example demonstrating fine-tuning operations with OpenAI.
///
/// Fine-tuning allows you to train custom models on your own data
/// for improved performance on specific tasks.
///
/// Run with: dart run example/fine_tuning_example.dart
library;

import 'dart:convert';

import 'package:openai_dart/openai_dart.dart';

Future<void> main() async {
  // Create client from environment variable
  final client = OpenAIClient.fromEnvironment();

  try {
    // List existing fine-tuning jobs
    print('=== List Fine-tuning Jobs ===\n');

    final jobs = await client.fineTuning.jobs.list(limit: 10);
    print('Found ${jobs.data.length} fine-tuning job(s):');

    for (final job in jobs.data) {
      print('  Job: ${job.id}');
      print('    Model: ${job.model}');
      print('    Status: ${job.status}');
      if (job.fineTunedModel != null) {
        print('    Fine-tuned model: ${job.fineTunedModel}');
      }
      print(
        '    Created: ${DateTime.fromMillisecondsSinceEpoch(job.createdAt * 1000)}',
      );
      print('');
    }

    // Explain training data format
    print('=== Training Data Format ===\n');
    print('Training data must be in JSONL format with conversations:');
    print('');

    final exampleData = [
      {
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful customer service assistant.',
          },
          {'role': 'user', 'content': 'How do I reset my password?'},
          {
            'role': 'assistant',
            'content':
                'To reset your password, go to Settings > Security > '
                'Reset Password. You will receive an email with instructions.',
          },
        ],
      },
      {
        'messages': [
          {
            'role': 'system',
            'content': 'You are a helpful customer service assistant.',
          },
          {'role': 'user', 'content': 'What are your business hours?'},
          {
            'role': 'assistant',
            'content':
                'Our business hours are Monday through Friday, '
                '9 AM to 5 PM EST. We are closed on weekends and holidays.',
          },
        ],
      },
    ];

    for (final example in exampleData) {
      print(jsonEncode(example));
    }
    print('');

    // Show how to upload training file
    print('=== Upload Training File ===\n');
    print(r'''
// Convert training data to JSONL
final jsonlContent = trainingData.map(jsonEncode).join('\n');
final fileBytes = utf8.encode(jsonlContent);

// Upload for fine-tuning
final file = await client.files.upload(
  bytes: fileBytes,
  filename: 'training_data.jsonl',
  purpose: FilePurpose.fineTune,
);

print('Uploaded file: ${file.id}');
''');

    // Show how to create a fine-tuning job
    print('=== Create Fine-tuning Job ===\n');
    print(r'''
// Create the fine-tuning job
final job = await client.fineTuning.jobs.create(
  CreateFineTuningJobRequest(
    model: 'gpt-4o-mini-2024-07-18', // Base model
    trainingFile: file.id,
    hyperparameters: HyperparametersRequest(
      nEpochs: 3, // Number of training epochs
    ),
    suffix: 'my-custom-model', // Optional: custom model name suffix
  ),
);

print('Created job: ${job.id}');
print('Status: ${job.status}');
''');

    // Show job monitoring pattern
    print('=== Monitor Job Progress ===\n');
    print(r'''
// Poll until job completes
var currentJob = job;
while (currentJob.isRunning) {
  await Future.delayed(Duration(seconds: 30));
  currentJob = await client.fineTuning.jobs.retrieve(job.id);

  print('Status: ${currentJob.status}');
  if (currentJob.trainedTokens != null) {
    print('Trained tokens: ${currentJob.trainedTokens}');
  }
}

// Check final status
if (currentJob.isSucceeded) {
  print('Fine-tuning succeeded!');
  print('Model: ${currentJob.fineTunedModel}');
} else if (currentJob.isFailed) {
  print('Fine-tuning failed: ${currentJob.error?.message}');
}
''');

    // If there are existing jobs, show events for the most recent one
    if (jobs.data.isNotEmpty) {
      final recentJob = jobs.data.first;

      print('=== Job Events (${recentJob.id}) ===\n');

      final events = await client.fineTuning.jobs.listEvents(
        recentJob.id,
        limit: 10,
      );

      if (events.data.isEmpty) {
        print('No events found for this job.\n');
      } else {
        for (final event in events.data) {
          print('  [${event.level}] ${event.message}');
          print(
            '    Created: ${DateTime.fromMillisecondsSinceEpoch(event.createdAt * 1000)}',
          );
          print('');
        }
      }

      // Show checkpoints if job succeeded
      if (recentJob.isSucceeded) {
        print('=== Job Checkpoints (${recentJob.id}) ===\n');

        final checkpoints = await client.fineTuning.jobs.listCheckpoints(
          recentJob.id,
          limit: 5,
        );

        if (checkpoints.data.isEmpty) {
          print('No checkpoints available.\n');
        } else {
          for (final checkpoint in checkpoints.data) {
            print('  Checkpoint: ${checkpoint.id}');
            print('    Step: ${checkpoint.stepNumber}');
            print('    Model: ${checkpoint.fineTunedModelCheckpoint}');
            if (checkpoint.metrics.trainLoss != null) {
              print('    Training loss: ${checkpoint.metrics.trainLoss}');
            }
            print('');
          }
        }
      }
    }

    // Job cancellation example
    print('=== Cancel Job (Example) ===\n');
    print(r'''
// Cancel a running job
final cancelled = await client.fineTuning.jobs.cancel(job.id);
print('Status: ${cancelled.status}'); // 'cancelled'
''');

    // Fine-tuning best practices
    print('=== Best Practices ===\n');
    print('1. Start with at least 50-100 high-quality examples');
    print('2. Use consistent formatting in training data');
    print('3. Include system messages for context');
    print('4. Balance examples across different scenarios');
    print('5. Start with fewer epochs (1-3) and increase if needed');
    print('6. Monitor training loss in checkpoints');
    print('7. Test thoroughly before production use');
    print('');

    // Available base models
    print('=== Available Base Models ===\n');
    print('gpt-4o-mini-2024-07-18 - Fast, cost-effective');
    print('gpt-4o-2024-08-06      - More capable, higher cost');
    print('gpt-3.5-turbo-0125     - Legacy, good for simple tasks');
    print('');

    // Using fine-tuned model
    print('=== Using Fine-tuned Model ===\n');
    print('''
// Use your fine-tuned model
final response = await client.chat.completions.create(
  ChatCompletionCreateRequest(
    model: 'ft:gpt-4o-mini-2024-07-18:org-id::model-id',
    messages: [
      ChatMessage.user('How do I reset my password?'),
    ],
  ),
);

print(response.text);
''');
  } on OpenAIException catch (e) {
    print('OpenAI error: ${e.message}');
    if (e is ApiException) {
      print('Status: ${e.statusCode}');
    }
  } finally {
    client.close();
    print('Done!');
  }
}
